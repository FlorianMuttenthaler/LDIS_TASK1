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
	-- 'rndnumb' is the output of the entity.
	
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

	signal rnd_valid : std_logic := '0';

	-- States:
	type type_state is (
		STATE_IDLE,
		STATE_INPUT,
		STATE_COMPARE
	);

	signal state, state_next : type_state := STATE_IDLE;

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
				if seed_en = '1' then
					mod_sig <= M; -- Kopie erstellen
					seed_sig <= to_integer(unsigned(seed));
					state_next <= STATE_COMPARE;
				end if;
					
			when STATE_COMPARE =>
				if modulus = seed_temp then
					seed_valid <= to_integer(unsigned(seed)); -- seed wird für weitere Berechnung weiter gereicht
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
	bbs_proc : process(seed_valid)
--		variable i: integer := 0; -- Laufindex für while
		variable x: integer := 0;
		variable temp: integer := 0;
		variable temp_vec: std_logic_vector((LEN - 1) downto 0) := (others => '0');
		variable bit_i: std_logic := '0';
		variable parity_v: std_logic := '0';
		variable rndnumb_temp: std_logic_vector((LEN - 1) downto 0) := (others => '0');
		
	begin
	
		x := seed_valid; -- Startwert initialisieren
		for i in 0 to (LEN - 1) loop
			temp := (x * x) mod M; --BBS Algorithmus
			
			temp_vec := std_logic_vector(to_unsigned(temp, temp_vec'length));
			
			for j in temp_vec'range loop -- Paritätsbit berechnen	
				parity_v := parity_v xor temp_vec(j);
			end loop;
			bit_i := parity_v; 		
			
			rndnumb_temp(i) := bit_i; -- i.tes Bit schreiben
			
			x := temp; -- nächsten Iterationswert übergeben
		end loop;
	
		rndnumb <= rndnumb_temp; -- Zufallszahl ausgeben
		rnd_valid <= '1';
	end process bbs_proc;
														 
-------------------------------------------------------------------------------
--
-- Process sync_proc: triggered by Clk and seed_en
-- synchronization of state maschine
--
	en_proc: process(Clk, rnd_valid)
	begin
		if rising_edge(Clk) then
			if rnd_valid = '1' then
				rnd_en <= '1';
				rnd_valid <= '0';
			else
				rnd_en <= '0';
			end if;
		end if;
	end process en_proc;
													 
end beh;
--
-------------------------------------------------------------------------------
