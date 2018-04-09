-------------------------------------------------------------------------------
--
-- PRNG
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--
-------------------------------------------------------------------------------
--
entity prng is

	-- 'LEN' is the generic value of the entity.
	-- 'seed' and 'Clk' are the input of prng entity.
	-- 'rndnumb' and 'rnd_en' are the output of the entity.
	
	generic(
		LEN: integer := 128 -- Anzahl von Bits, DEFAULT = 128
	);
	
	port (
		seed   : in std_logic_vector((LEN - 1) downto 0);
		Clk	   : in std_logic;
		seed_en: in std_logic;
		rndnumb: out std_logic_vector((LEN - 1) downto 0);
		rnd_en : out std_logic
	);

end prng;
--
-------------------------------------------------------------------------------
--
architecture beh of prng is
	constant M: integer := 77; -- M = p * q, p&q sind Primzahlen, p%4 = q%4 = 3, p = 7, q = 11
	
	signal seed_valid: integer := 0;

	signal mod_sig : integer range 0 to M := 0;
	signal seed_sig : integer := 0;

	signal seed_flag : std_logic := '0';

	signal bit_sig : integer range (LEN - 1) to 0 := 0;
	signal j_sig : integer range (LEN - 1) to 0 := 0;
	signal u_sig : integer range (LEN - 1) to 0 := 0;
	signal x_sig : integer range (LEN - 1) to 0 := 0;

	-- States:
	type type_state is (
		STATE_IDLE,
		STATE_INPUT,
		STATE_COMPARE
	);

	signal state, state_next : type_state := STATE_IDLE;

	-- States:
	type type_state_bbs is (
		STATE_IDLE,
		STATE_SEED,
		STATE_OUTPUT,
		STATE_BBS_S,
		STATE_MULT
	);

	signal state_bbs, state_bbs_next : type_state_bbs := STATE_IDLE;

begin
	
-------------------------------------------------------------------------------
--
-- Process state_proc: triggered by Clk and state
-- Evaluates if the transmitted seed is valid by a gcd algorithm implemented 
-- in a state maschine
--
	state_proc : process(Clk, state)
		variable modulus : integer range 0 to M := 0;
		variable seed_temp: integer := 0;
	begin
		modulus := mod_sig; -- Kopie erstellen
		seed_temp := seed_sig;
		state_next <= state;

		case state is
			
			when STATE_IDLE =>
				null;
			
			when STATE_INPUT =>
				seed_flag <= '0';
				if seed_en = '1' then
					mod_sig <= M; -- Kopie erstellen
					seed_sig <= to_integer(unsigned(seed));
					state_next <= STATE_COMPARE;
				end if;
					
			when STATE_COMPARE =>
				if modulus = seed_temp then
					seed_valid <= to_integer(unsigned(seed)); -- seed wird für weitere Berechnung weiter gereicht
					seed_flag <= '1';
					state_next <= STATE_INPUT;
				elsif modulus > seed_temp then
					modulus := modulus - seed_temp;
					mod_sig <= modulus;
					state_next <= STATE_COMPARE;
				else
					seed_temp := seed_temp - modulus;
					seed_sig <= seed_temp;
					state_next <= STATE_COMPARE;
				end if;
					
			when others => 
				null;
		end case;
	end process state_proc;

-------------------------------------------------------------------------------
--
-- Process sync_proc: triggered by Clk and seed_en
-- synchronization of state maschine
--
	sync_proc: process(Clk, seed_en)
	begin
		if seed_en = '1' then
			state <= STATE_INPUT;
		elsif rising_edge(Clk) then
			state <= state_next;
		end if;
	end process sync_proc;
		
	
-------------------------------------------------------------------------------
--
-- Process bbs_proc: triggered by seed_valid
-- algorithm to generate the pseudo random number based on the BBS algorithm
--
	bbs_proc : process(seed_valid, state_bbs)
--		variable i: integer := 0; -- Laufindex für while
		variable x: integer := 0;
		--variable temp: integer := 0;
		variable temp_vec: std_logic_vector((LEN - 1) downto 0) := (others => '0');
		variable bit_i: std_logic := '0';
		variable parity_v: std_logic := '0';
		variable rndnumb_temp: std_logic_vector((LEN - 1) downto 0) := (others => '0');

		variable bit: integer := 0;
		variable u:integer := 0;
		variable j:integer := 0;
		variable xi:std_logic_vector((LEN - 1) downto 0) := (others => '0');
		
		
	begin
	
		state_bbs_next <= state_bbs;
		bit := bit_sig;
		j := j_sig;
		u := u_sig;
		x := x_sig;

		case state_bbs is
			
			when STATE_IDLE =>
				rnd_en <= '0';
				state_bbs_next <= STATE_OUTPUT;
		
			when STATE_SEED =>
				if seed_flag = '1' then
					x := seed_valid; -- Startwert initialisieren
					x_sig <= x;

					if x > M then
						state_bbs_next <= STATE_IDLE;
					else
						state_bbs_next <= STATE_OUTPUT;
					end if;
				else
					state_bbs_next <= STATE_IDLE;
				end if;
			
			when STATE_OUTPUT =>
				
				if bit = (LEN - 1) then
					rndnumb <= rndnumb_temp; -- Zufallszahl ausgeben
					rnd_en <= '1';
					state_bbs_next <= STATE_IDLE;
				else
					bit := bit + 1;
					bit_sig <= bit;
					
					if bit = 0 then
						null;
					else
						temp_vec := std_logic_vector(to_unsigned(u, temp_vec'length));

						for t in temp_vec'range loop -- Paritätsbit berechnen	
							parity_v := parity_v xor temp_vec(t);
						end loop;
						bit_i := parity_v; 		

						rndnumb_temp(bit) := bit_i; -- i.tes Bit schreiben

						x := u; -- nächsten Iterationswert übergeben
					end if;								 
					state_bbs_next <= STATE_BBS_S;
				end if;
					
			when STATE_BBS_S =>
				u := 0;
				j := LEN - 1;
				
				if j = 0 then
					state_bbs_next <= STATE_OUTPUT;
				else
					state_bbs_next <= STATE_MULT;
				end if;
		
			when STATE_MULT =>
				u := 2 * u;
				xi := std_logic_vector(to_unsigned(x, LEN -1));

				if xi(j) = '1' then
					u := u + x;
				end if;
				
				if u >= M then
					u := u -M;
				end if;
					
				if u >= M then
					u := u -M;
				end if;
				j := j - 1;
				j_sig <= j;
			
				state_bbs_next <= STATE_BBS_S;
				
				




--					for i in 0 to (LEN - 1) loop
--						-- BBS Algorithm : y = x*x % M
--						
--						temp := (x * x) mod M; --BBS Algorithmus
--
--						temp_vec := std_logic_vector(to_unsigned(temp, temp_vec'length));
--
--						for j in temp_vec'range loop -- Paritätsbit berechnen	
--							parity_v := parity_v xor temp_vec(j);
--						end loop;
--						bit_i := parity_v; 		
--
--						rndnumb_temp(i) := bit_i; -- i.tes Bit schreiben
--
--						x := temp; -- nächsten Iterationswert übergeben
--					end loop;
--
--					rndnumb <= rndnumb_temp; -- Zufallszahl ausgeben
--					rnd_en <= '1';
			
																 
		 	when others =>
				null;
															 
			end case;
	end process bbs_proc;
														 
-------------------------------------------------------------------------------
--
-- Process sync_proc: triggered by Clk and seed_en
-- synchronization of state maschine
--
	en_proc: process(Clk)
	begin
		if rising_edge(Clk) then
			state_bbs <= state_bbs_next;
		end if;
	end process en_proc;
													 
end beh;
--
-------------------------------------------------------------------------------
