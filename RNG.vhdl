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
--use work.PRNG_pkg.all;
use work.slowclk_pkg.all;
use work.sevenseg_pkg.all;

use work.uart_tx_pkg.all;
--use work.uart_rx_pkg.all;

use work.Dbncr_pkg.all;
--
-------------------------------------------------------------------------------
--
entity rng is

	-- 'LEN' is the generic value of the entity.
	-- 'R2', 'clk_fast', 'reset', 'mode' and 'start' are the inputs of rng entity.
	-- 'R1', 'X', 'segment7' and 'UART_TX' are the output of the entity.

	generic(
			LEN : integer := 32 -- Anzahl von Bits, DEFAULT = 128
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
--		output1 : out std_logic;
--		output2 : out std_logic;
--		output3 : out std_logic
	);

end rng;
--
-------------------------------------------------------------------------------
--
architecture beh of rng is

	constant CLK_FREQ    : integer := 100E6; -- UART parameter
	constant BAUDRATE    : integer := 4800; -- UART parameter
	constant TEST_RUNS   : integer := 10; --100000; -- Test Runs for NIST analyse tool
	constant NR_OF_CLKS  : integer := 1000; -- Number of System Clock periods while the incoming signal 
	
	signal RDY		 : std_logic := '1'; --UART parameter

	signal rnd_valid : std_logic := '0'; --Siganle for validaton of actual random number

	-- signal data_recv     : std_logic_vector(7 downto 0);
	-- signal data_recv_new : std_logic;

	-- UART Transmit Signals
	signal send_trans, send_trans_next  : std_logic;
	signal data_trans, data_trans_next  : std_logic_vector(7 downto 0);

	signal clk_slow: std_logic; -- Output of SlowClock module
	signal seed: std_logic_vector((LEN - 1) downto 0) := (others => '0'); -- Output TRNG module
	signal seed_en: std_logic := '0'; -- Output TRNG module
	signal rnd_en: std_logic := '0';
	signal rndnumb	: std_logic_vector((LEN - 1) downto 0) := (others => '0'); -- Output of PRNG module
	signal rnd_cpy : std_logic_vector((LEN - 1) downto 0) := (others => '0');
	signal rnd_done : std_logic := '0';
	
	signal run_sig : integer range 0 to TEST_RUNS := 0; -- Signal um die TestlÃ¤ufe mitzuzÃ¤hlen
	signal test_fin: std_logic := '0'; -- Flag for loop for NIST analyse
	signal en_7seg : std_logic := '0'; -- Enable flag for 7seg module used for valid random number
	
	signal bit_cnt, bit_cnt_next : integer range 0 to LEN := 0;
	
	signal start_en : std_logic := '0';

	-- States:
	type type_state is (
		STATE_IDLE,
		STATE_RUN,
		STATE_VALID,
		STATE_TEST,
		STATE_PROD,
		STATE_PROD_UART,
		STATE_PROD_UART_LF,
		STATE_PROD_UART_CR
	);

	signal state, state_next : type_state := STATE_IDLE;
	
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
			seed => rndnumb,
			seed_en => rnd_en
		);
		
--	prng: entity work.prng
--		generic map(
--			LEN => LEN
--		)
--			
--		port map (
--			seed => seed,
--			Clk => clk_fast,
--			seed_en => seed_en,
--			rndnumb => rndnumb,
--			rnd_en => rnd_en
--		);
		
	sevenseg: entity work.sevenseg
		generic map(
				LEN => LEN 
		)
			
		port map(
			reset => reset,
			rndnumb	=> rnd_cpy,
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
		
	Dbncr : entity work.Dbncr
		generic map(
			NR_OF_CLKS => NR_OF_CLKS
		)

		port map(
			clk_i   => clk_fast,
			sig_i   => start,
			pls_o   => start_en
		);
		
-----------------------------------------------------------------------------
--
-- Process rnd_valid_proc: triggered by clk_fast and rnd_en
-- if new rndnumb is generated, validation flag is set

	rnd_valid_proc: process(clk_fast, rnd_en)
	begin
		if rnd_en = '1' then
			rnd_valid <= '1';
			if rnd_done = '1' then
				rnd_cpy <= rndnumb;	
			end if;
		else
			rnd_valid <= '0';
		end if;
	end process rnd_valid_proc;		

-------------------------------------------------------------------------------
--
-- Process rnd_valid_proc: triggered by clk_fast and reset
-- if reset the reset state maschine, flags and UART communinicatin
-- each clk pereiod basic state and uart synchronization
--
	sync_proc: process (clk_fast, reset)
	begin

		if(reset = '1') then		
			send_trans <= '0';
			data_trans <= (others => '0');
			state      <= STATE_IDLE;
		
		elsif(rising_edge(clk_fast)) then		
			send_trans <= send_trans_next;
			data_trans <= data_trans_next;		
			state      <= state_next;
			bit_cnt    <= bit_cnt_next;

		end if;

	end process sync_proc;

-------------------------------------------------------------------------------
--
-- Process state_out_proc: triggered by state and mode
-- basic state maschine with IDLE state, state for NIST analyse and state for segment display
--
	state_out_proc: process (state, mode, start_en)
		variable run : integer range 0 to TEST_RUNS := 0;
		variable len_var : integer range 0 to LEN := 0;
		variable rest : integer range 0 to LEN := 0;
	begin

		-- prevent latches
		send_trans_next <= send_trans;
		data_trans_next <= data_trans;
		state_next      <= state;
		bit_cnt_next    <= bit_cnt;
		
		case state is

				when STATE_IDLE =>
					en_7seg 			<= '0';
					test_fin 		<= '0';
					bit_cnt_next  	<= 0;
					rnd_done 		<= '1';
					send_trans_next <= '0';
					
--					output2 <= '0';
--					output3 <= '0';
					
					if mode = '1' then
						state_next <= STATE_RUN;
					else
						state_next <= STATE_PROD;
					end if;
						
				when STATE_RUN =>	
					
					if test_fin = '1' then
						null;
					else
						run := run_sig;
						
						if run = (TEST_RUNS - 1) then
							test_fin <= '1';
						else
							state_next <= STATE_VALID;
							run := run + 1;
							run_sig <= run;
						end if;
					end if;
					
				when STATE_VALID =>
					if rnd_valid = '1' then	-- Abfrage ob neue rndnumb vorhanden
						state_next <= STATE_TEST;
						--rnd_valid <= '0';
					end if;	
				
				when STATE_TEST =>
				
					-- UART rndnumb senden
--					for j in 0 to (LEN - 1) loop
--						if rndnumb(j) = '1' then
--							data_trans_next <= "00110001"; -- ASCII-Code: 1
--							send_trans_next <= '1';
--						else
--							data_trans_next <= "00110000"; -- ASCII-Code: 0
--							send_trans_next <= '1';
--						end if;

--					end loop;
					
					data_trans_next <= "00001010"; -- ASCII-Code: 10: Line Feed
					send_trans_next <= '1';
					
					state_next <= STATE_RUN;
					
				when STATE_PROD =>
					if start_en = '1' then
						en_7seg <= '1';
						rnd_done <= '0';
						state_next <= STATE_PROD_UART;
					else
--						output3 <= '1';
						en_7seg <= '0';
						rnd_done <= '1';
						send_trans_next <= '0';
						state_next <= STATE_PROD;
					end if;
						
				when STATE_PROD_UART => -- Idee von Constantin Schieber übernommen
					-- UART rndnumb senden
					send_trans_next <= '0';
					
					if RDY = '1' then
					
--						data_trans_next 	<= rnd_cpy((len_var + 7) downto ((len_var)));
--						send_trans_next		<= '1';
						
						if rnd_cpy(bit_cnt) = '1' then
							data_trans_next <= "00110001"; -- ASCII-Code: 1
						else
							data_trans_next <= "00110000"; -- ASCII-Code: 0
						end if;
						
						send_trans_next <= '1';

						if bit_cnt = (LEN - 1) then
							bit_cnt_next <= 0;
							state_next <= STATE_PROD_UART_LF;
						else
							bit_cnt_next <= bit_cnt + 1;
							state_next <= STATE_PROD_UART;
						end if;
					end if;
				
				when STATE_PROD_UART_LF => -- Idee von Constantin Schieber uebernommen
					
					send_trans_next <= '0';
					
					if RDY = '1' then
					
						data_trans_next <= "00001010"; -- ASCII-Code: 10: Line Feed
						send_trans_next <= '1';
						
						state_next <= STATE_PROD_UART_CR;
					end if;

				when STATE_PROD_UART_CR => -- Idee von Constantin Schieber uebernommen
					
					send_trans_next <= '0';
					
					if RDY = '1' then
						
						data_trans_next <= "00001101"; -- ASCII-Code: 13: Carriage Return
						send_trans_next <= '1';
						
						state_next <= STATE_IDLE;
						
					end if;					
					
				when others =>
					null;

			end case;

	end process state_out_proc;
	
end beh;
--
-------------------------------------------------------------------------------