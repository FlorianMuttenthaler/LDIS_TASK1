-------------------------------------------------------------------------------
--
-- RNG
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.TRNG_pkg.all;
use work.PRNG_pkg.all;
use work.SlowClock_pkg.all;

use work.uart_tx_pkg.all;
use work.uart_rx_pkg.all;
--
-------------------------------------------------------------------------------
--
entity rng is

	-- 'LEN' is the generic value of the entity.
	-- 'R2', 'clk_fast', 'reset', 'mode' and 'start' are the inputs of rng entity.
	-- 'R1', 'X', 'rndnumb' and 'segment7' are the output of the entity.

	generic(
			LEN : integer := 128 -- Anzahl von Bits, DEFAULT = 128
		);
		
	port (
		R2: in std_logic;
		clk_fast: in std_logic;
		reset: in std_logic;
		mode: in std_logic;
		start: in std_logic;
		R1: out std_logic;
		X: out std_logic;
		rndnumb: out std_logic_vector((LEN - 1) downto 0);
		segment7: out std_logic_vector(7 downto 0)
		UART_RX : in std_logic;
		UART_TX : out std_logic;
		LED     : out std_logic_vector(7 downto 0)
	);

end rng;
--
-------------------------------------------------------------------------------
--
architecture behavioral of rng is

	constant CLK_FREQ    : integer := 100E6;
	constant BAUDRATE    : integer := 9600;
	constant TEST_RUNS	 : integer := 100000;

	signal data_recv     : std_logic_vector(7 downto 0);
	signal data_recv_new : std_logic;
	signal rdy_trans     : std_logic;

	signal send_trans, send_trans_next  : std_logic;
	signal data_trans, data_trans_next  : std_logic_vector(7 downto 0);
	signal led_int, led_int_next        : std_logic_vector(7 downto 0);

	signal clk_slow: std_logic;
	signal seed: std_logic_vector((LEN - 1) downto 0);
	
	signal test_fin: std_logic := 0;

	type type_state is (
		STATE_IDLE,
		STATE_TEST,
		STATE_PROD
	);

	signal state, state_next : type_state;
	
begin

	slowclk: slowclk
		port map (
			R2 => R2,
			R1 => R1,
			X => X,			
			clk_slow => clk_slow
		);

	trng: trng
		generic map(
			LEN => LEN
		)
			
		port map (
			clk_slow => clk_slow,
			clk_fast => clk_fast,
			seed => seed
		);
		
	prng: prng
		generic map(
			LEN => LEN
		)
			
		port map (
			seed => seed,
			rndnumb => rndnumb
		);
		
	uart_recv : entity work.uart_rx
		generic map(
			CLK_FREQ => CLK_FREQ,
			BAUDRATE => BAUDRATE
		)

		port map(
			clk      => clk_fast,
			rst      => reset,
			rx       => UART_RX,
			data     => data_recv,
			data_new => data_recv_new
		);
		
	uart_trans : entity work.uart_tx
		generic map(
			CLK_FREQ => CLK_FREQ,
			BAUDRATE => BAUDRATE
		)

		port map(
			clk   => clk_fast,
			rst   => reset,
			send  => send_trans,
			data  => data_trans,
			rdy   => rdy_trans,
			tx    => UART_TX
		);
		
	LED <= led_int;

	sync: process (clk_fast, reset)
	begin

		if(reset = '1') then		
			send_trans <= '0';
			data_trans <= (others => '0');
			led_int    <= (others => '0');	
			test_fin   := 0;			
			state      <= STATE_IDLE;

		elsif(rising_edge(clk_fast)) then		
			send_trans <= send_trans_next;
			data_trans <= data_trans_next;
			led_int    <= led_int_next;			
			state      <= state_next;

		end if;

	end process sync;
	
	state_out: process (state, mode)
	begin

		-- prevent latches
		send_trans_next <= send_trans;
		data_trans_next <= data_trans;
		led_int_next    <= led_int;
		state_next      <= state;

		case state is

				when STATE_IDLE =>

					if mode = '1' then
						state_next   <= STATE_TEST;
					else
						state_next   <= STATE_PROD;
					end if;

				when STATE_TEST =>

					if test_fin = '1' then
						null;
					else
						for i in 0 to (TEST_RUNS - 1) loop
						-- UART rndnumb senden
						-- if(rdy_trans = '1') then
							-- data_trans_next <= data_recv;
							-- send_trans_next <= '1';
							-- state_next      <= STATE_READY_RECV;
						-- end if;
						end loop;
						
						test_fin := '1';
						
					end if;					
					
				when STATE_PROD =>
					
					if start = '1' then
					
						-- if(rdy_trans = '1') then
							-- data_trans_next <= data_recv;
							-- send_trans_next <= '1';
							-- state_next      <= STATE_READY_RECV;
						-- end if;
					end if;
					
				when others =>
					null;

			end case;

	end process state_out;
	
	
	
end rng;
--
-------------------------------------------------------------------------------
