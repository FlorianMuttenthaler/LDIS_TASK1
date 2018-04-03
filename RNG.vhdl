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
use work.slowclk_pkg.all;
use work.sevenseg_pkg.all;

use work.uart_tx_pkg.all;
--use work.uart_rx_pkg.all;
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
		R2		: in std_logic;
		clk_fast: in std_logic;
		reset	: in std_logic;
		mode	: in std_logic;
		start	: in std_logic;
		R1		: out std_logic;
		X		: out std_logic;
		segment7: out std_logic_vector(7 downto 0);
		anode 	: out std_logic_vector(7 downto 0);
		--UART_RX : in std_logic;
		UART_TX : out std_logic
	);

end rng;
--
-------------------------------------------------------------------------------
--
architecture beh of rng is

	constant CLK_FREQ    : integer := 100E6;
	constant BAUDRATE    : integer := 9600;
	constant TEST_RUNS	 : integer := 100000;
	
	signal RDY		 : std_logic := '1';

	signal rnd_valid : std_logic := '0';

	-- signal data_recv     : std_logic_vector(7 downto 0);
	-- signal data_recv_new : std_logic;

	signal send_trans, send_trans_next  : std_logic;
	signal data_trans, data_trans_next  : std_logic_vector(7 downto 0);

	signal clk_slow: std_logic;
	signal seed: std_logic_vector((LEN - 1) downto 0) := (others => '0');

	signal rndnumb	: std_logic_vector((LEN - 1) downto 0) := (others => '0');
	
	signal test_fin: std_logic := '0';

	signal en_7seg : std_logic := '0';

	type type_state is (
		STATE_IDLE,
		STATE_TEST,
		STATE_PROD
	);

	signal state, state_next : type_state;
	
begin

	slowclk: entity work.slowclk
		port map (
			R2 => R2,
			R1 => R1,
			X => X,			
			clk_slow => clk_slow
		);

	trng: entity work.trng
		generic map(
			LEN => LEN
		)
			
		port map (
			clk_slow => clk_slow,
			clk_fast => clk_fast,
			seed => seed
		);
		
	prng: entity work.prng
		generic map(
			LEN => LEN
		)
			
		port map (
			seed => seed,
			rndnumb => rndnumb
		);
		
	sevenseg: entity work.sevenseg
		generic map(
				LEN => LEN 
		)
			
		port map(
			rndnumb	=> rndnumb,
			clk	=> clk_fast,
			en_new_numb	=> en_7seg,
			segment7 => segment7,
			anode => anode
		);
		
	-- uart_recv : entity work.uart_rx
		-- generic map(
			-- CLK_FREQ => CLK_FREQ,
			-- BAUDRATE => BAUDRATE
		-- )

		-- port map(
			-- clk      => clk_fast,
			-- rst      => reset,
			-- rx       => UART_RX,
			-- data     => data_recv,
			-- data_new => data_recv_new
		-- );
		
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
			rdy   => RDY,
			tx    => UART_TX
		);

	rnd_valid_proc: process(rndnumb)
	begin
		rnd_valid <= '1';
	end process rnd_valid_proc;		
	
	sync_proc: process (clk_fast, reset)
	begin

		if(reset = '1') then		
			send_trans <= '0';
			data_trans <= (others => '0');
			test_fin   <= '0';
			en_7seg    <= '0';
			state      <= STATE_IDLE;

		elsif(rising_edge(clk_fast)) then		
			send_trans <= send_trans_next;
			data_trans <= data_trans_next;		
			state      <= state_next;

		end if;

	end process sync_proc;
	
	state_out_proc: process (state, mode)
	begin

		-- prevent latches
		send_trans_next <= send_trans;
		data_trans_next <= data_trans;
		state_next      <= state;

		case state is

				when STATE_IDLE =>
					en_7seg <= '0';
					test_fin <= '0';
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
						
							-- Abfrage ob neue rndnumb vorhanden
							while rnd_valid = '0' loop
								null;
							end loop;
							
							-- UART rndnumb senden
							for j in 0 to (LEN - 1) loop
								if rndnumb(j) = '1' then
									data_trans_next <= "00110001"; -- ASCII-Code: 1
									send_trans_next <= '1';
								else
									data_trans_next <= "00110000"; -- ASCII-Code: 0
									send_trans_next <= '1';
								end if;
								-- Leerzeichen nach jedem Bit eingefügt
								data_trans_next <= "00100000"; -- ASCII-Code: Leerzeichen
								send_trans_next <= '1';
							end loop;
							data_trans_next <= "00001010"; -- ASCII-Code: 10: Line Feed
							send_trans_next <= '1';
							rnd_valid <= '0';
						end loop;
						
						test_fin <= '1';
						
					end if;					
					
				when STATE_PROD =>
					
					if start = '1' then
						en_7seg <= '1';
						-- UART rndnumb senden
						for j in 0 to (LEN - 1) loop
							if rndnumb(j) = '1' then
								data_trans_next <= "00110001"; -- ASCII-Code: 1
								send_trans_next <= '1';
							else
								data_trans_next <= "00110000"; -- ASCII-Code: 0
								send_trans_next <= '1';
							end if;
							-- Leerzeichen nach jedem Bit eingefügt
							data_trans_next <= "00100000"; -- ASCII-Code: Leerzeichen
							send_trans_next <= '1';
						end loop;
						data_trans_next <= "00001010"; -- ASCII-Code: 10: Line Feed
						send_trans_next <= '1';
					end if;
					
				when others =>
					null;

			end case;

	end process state_out_proc;
	
end beh;
--
-------------------------------------------------------------------------------