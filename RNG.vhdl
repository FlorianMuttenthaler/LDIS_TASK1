-------------------------------------------------------------------------------
--
-- RNG
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slowclk_pkg.all;
use work.TRNG_pkg.all;
--use work.PRNG_pkg.all; -- not used
use work.sevenseg_pkg.all;

use work.uart_tx_pkg.all;
--use work.uart_rx_pkg.all; -- not yet used

use work.Dbncr_pkg.all;
--
-------------------------------------------------------------------------------
--
entity rng is

	-- 'LEN' is the generic value of the entity.
	-- 'R2', 'clk_fast', 'reset', 'mode' and 'start' are the inputs of rng entity.
	-- 'R1', 'X', 'segment7', 'anode' and 'UART_TX' are the outputs of the entity.

	generic(
			LEN : integer := 256			-- Anzahl von Bits, DEFAULT = 128
		);
		
	port (
		R2				 : in std_logic;
		clk_fast 	 : in std_logic;
		reset			 : in std_logic;
		mode			 : in std_logic;
		start			 : in std_logic;
		R1				 : out std_logic;
		X				 : out std_logic;
		segment7		 : out std_logic_vector(7 downto 0);
		anode 		 : out std_logic_vector(7 downto 0);
		UART_TX 		 : out std_logic;
--		UART_RX  	 : in std_logic;
		LED_TEST_FIN : out std_logic
	);

end rng;
--
-------------------------------------------------------------------------------
--
architecture beh of rng is

	constant CLK_FREQ    : integer := 100E6; -- UART parameter
	constant BAUDRATE    : integer := 9600;  -- UART parameter
	constant TEST_RUNS   : integer := 10; --100000; -- Test Runs for NIST analyse tool
	constant NR_OF_CLKS  : integer := 1000; -- Number of System Clock periods while the incoming signal, for Debouncer
	constant TEST_MODE 	: std_logic := '1';
	
	-- UART Transmit Signals
	signal rdy_trans : std_logic := '1'; 
	signal send_trans, send_trans_next  : std_logic;
	signal data_trans, data_trans_next  : std_logic_vector(7 downto 0);

	-- Output of SlowClock module
	signal clk_slow: std_logic; 
	
	-- Output TRNG module
	signal rndnumb	: std_logic_vector((LEN - 1) downto 0) := (others => '0');
	signal rnd_en: std_logic := '0';
	
	-- Input Dbncr module
	signal start_en : std_logic := '0';
	
	-- Random number
	signal rnd_valid : std_logic := '0'; -- Signal for validation of actual random number
	signal rnd_done : std_logic := '0'; -- Signal for used random number 
	signal rnd_cpy : std_logic_vector((LEN - 1) downto 0) := (others => '0'); -- Signal for copy of actual random number
	
	-- Test mode
	signal run_cnt, run_cnt_next : integer range 0 to TEST_RUNS := 0; -- Counter for test runs
	signal test_fin: std_logic := '0'; -- Flag for test finish, NIST analyse
	
	-- Prod mode
	signal en_7seg : std_logic := '0'; -- Enable flag for 7seg module used for valid random number
	signal bit_cnt, bit_cnt_next : integer range 0 to LEN := 0; -- Bit counter for UART communication
	
	-- States:
	type type_state is (
		STATE_IDLE,
		
		STATE_TEST,
		STATE_TEST_VALID,
		STATE_TEST_UART,
		STATE_TEST_UART_LF,
		STATE_TEST_UART_CR,
		
		STATE_PROD,
		STATE_PROD_UART,
		STATE_PROD_UART_LF,
		STATE_PROD_UART_CR
	);

	signal state, state_next : type_state := STATE_IDLE;
	
begin
	
	slowclk: entity work.slowclk
		port map(
			R2 => R2,
			R1 => R1,
			X => X,			
			clk_slow => clk_slow
		);

	trng: entity work.trng
		generic map(
			LEN => LEN
		)
			
		port map(
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
--		port map(
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
			rdy   => rdy_trans,
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
		
	LED_TEST_FIN <= test_fin;
		
-----------------------------------------------------------------------------
--
-- Process rnd_valid_proc: triggered by clk_fast, rnd_en, rnd_done and rndnumb
-- if new rndnumb is generated, validation flag is set
-- Copy actual random number for later use
--
	rnd_valid_proc: process(clk_fast, rnd_en, rnd_done, rndnumb)
	begin
		if rising_edge(clk_fast) then
			if rnd_en = '1' then
				rnd_valid <= '1';
				if rnd_done = '1' then
					rnd_cpy <= rndnumb;	
				end if;
			else
				rnd_valid <= '0';
			end if;
		end if;
	end process rnd_valid_proc;		

-------------------------------------------------------------------------------
--
-- Process sync_proc: triggered by clk_fast and reset
-- if reset active, resets state maschine, flags and UART communication
-- each clk period states and flags are updated
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
			run_cnt	  <= run_cnt_next;

		end if;

	end process sync_proc;

-------------------------------------------------------------------------------
--
-- Process state_out_proc: triggered by state, mode, start_en, send_trans, data_trans, bit_cnt, 
--	run_cnt, test_fin, rnd_valid, rdy_trans and rnd_cpy
-- basic state maschine with IDLE state, state for NIST analyse and state for segment display
--
	state_out_proc: process (state, mode, start_en, send_trans, data_trans, bit_cnt, 
									 run_cnt, test_fin, rnd_valid, rdy_trans, rnd_cpy)
	begin

		-- prevent latches
		send_trans_next <= send_trans;
		data_trans_next <= data_trans;
		state_next      <= state;
		bit_cnt_next    <= bit_cnt;
		run_cnt_next	 <= run_cnt;
		
		case state is

			when STATE_IDLE =>
				-- Reset flags
				en_7seg <= '0';
				test_fin <= '0';
				bit_cnt_next <= 0;
				run_cnt_next <= 0;
				rnd_done <= '1';
				send_trans_next <= '0';
									
				if mode = TEST_MODE then
					state_next <= STATE_TEST;
				else -- PROD_MODE
					state_next <= STATE_PROD;
				end if;
					
			when STATE_TEST =>
				send_trans_next <= '0';
				if test_fin = '1' then
					null;
				else
					if run_cnt = TEST_RUNS then
						test_fin <= '1'; -- Test finished
					else
						rnd_done <= '1'; -- get new random number (used)
						run_cnt_next <= run_cnt + 1; -- Increment counter
						state_next <= STATE_TEST_VALID;
					end if;
				end if;
				
			when STATE_TEST_VALID =>
				if rnd_valid = '1' then	-- Abfrage ob neue rndnumb vorhanden
					rnd_done <= '0'; -- random number in use
					state_next <= STATE_TEST_UART;
				end if;	
			
			when STATE_TEST_UART => -- Idee von Constantin Schieber uebernommen
				send_trans_next <= '0';
				
				if rdy_trans = '1' then -- UART is ready for next transmission?
					
					if bit_cnt = LEN then -- all bits sended?
						bit_cnt_next <= 0; -- reset bit counter
						state_next <= STATE_TEST_UART_LF;
					else
						data_trans_next <= rndnumb((bit_cnt + 7) downto ((bit_cnt))); -- send 8 bit of random number
						send_trans_next <= '1';
						bit_cnt_next <= bit_cnt + 8; -- increment bit counter
						state_next <= STATE_TEST_UART;
					end if;
					
--						if rnd_cpy(bit_cnt) = '1' then
--							data_trans_next <= "00110001"; -- ASCII-Code: 1
--						else
--							data_trans_next <= "00110000"; -- ASCII-Code: 0
--						end if;
--						
--						send_trans_next <= '1';
--
--						if bit_cnt = (LEN - 1) then
--							bit_cnt_next <= 0;
--							state_next <= STATE_PROD_UART_LF;
--						else
--							bit_cnt_next <= bit_cnt + 1;
--							state_next <= STATE_PROD_UART;
--						end if;
				end if;
				
			when STATE_TEST_UART_LF => -- Idee von Constantin Schieber uebernommen
				send_trans_next <= '0';
				
				if rdy_trans = '1' then -- UART is ready for next transmission?
				
					data_trans_next <= "00001010"; -- ASCII-Code: 10: Line Feed
					send_trans_next <= '1';
					
					state_next <= STATE_TEST_UART_CR;
				end if;

			when STATE_TEST_UART_CR => -- Idee von Constantin Schieber uebernommen
				send_trans_next <= '0';
				
				if rdy_trans = '1' then -- UART is ready for next transmission?
					
					data_trans_next <= "00001101"; -- ASCII-Code: 13: Carriage Return
					send_trans_next <= '1';
					
					state_next <= STATE_TEST; -- next Turn
				end if;			
									
			when STATE_PROD =>
				if start_en = '1' then
					en_7seg <= '1'; -- activate 7-Segment display
					rnd_done <= '0'; -- random number in use
					state_next <= STATE_PROD_UART;
				else
					en_7seg <= '0'; -- deactivate 7-Segment display
					rnd_done <= '1'; -- random number used
					send_trans_next <= '0';
					state_next <= STATE_PROD;
				end if;
					
			when STATE_PROD_UART => -- Idee von Constantin Schieber uebernommen
				send_trans_next <= '0';
				
				if rdy_trans = '1' then -- UART is ready for next transmission?
					
					if (bit_cnt * 8) = LEN then -- all bits sended?
						bit_cnt_next <= 0; -- reset bit counter
						state_next <= STATE_PROD_UART_LF;
					else
						data_trans_next <= rnd_cpy((bit_cnt + 7) downto ((bit_cnt))); -- send 8 bit of random number
						send_trans_next <= '1';
						bit_cnt_next <= bit_cnt + 8; -- increment bit counter
						state_next <= STATE_PROD_UART;
					end if;
					
--						if rnd_cpy(bit_cnt) = '1' then
--							data_trans_next <= "00110001"; -- ASCII-Code: 1
--						else
--							data_trans_next <= "00110000"; -- ASCII-Code: 0
--						end if;
--						
--						send_trans_next <= '1';
--
--						if bit_cnt = (LEN - 1) then
--							bit_cnt_next <= 0;
--							state_next <= STATE_PROD_UART_LF;
--						else
--							bit_cnt_next <= bit_cnt + 1;
--							state_next <= STATE_PROD_UART;
--						end if;
				end if;
			
			when STATE_PROD_UART_LF => -- Idee von Constantin Schieber uebernommen
				send_trans_next <= '0';
				
				if rdy_trans = '1' then -- UART is ready for next transmission?
				
					data_trans_next <= "00001010"; -- ASCII-Code: 10: Line Feed
					send_trans_next <= '1';
					
					state_next <= STATE_PROD_UART_CR;
				end if;

			when STATE_PROD_UART_CR => -- Idee von Constantin Schieber uebernommen
				send_trans_next <= '0';
				
				if rdy_trans = '1' then -- UART is ready for next transmission?
					
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