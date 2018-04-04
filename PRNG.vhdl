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
		rndnumb: out std_logic_vector((LEN - 1) downto 0)
	);

end prng;
--
-------------------------------------------------------------------------------
--
architecture beh of prng is
	constant M: integer := 77; -- M = p * q, p&q sind Primzahlen, p%4 = q%4 = 3, p = 7, q = 11
	
	signal seed_valid: integer := 0;

	signal mod_sig : integer := 0;
	signal seed_sig : integer := 0;
	signal start : std_logic := '0';

	-- States:
	type type_state is (
		STATE_INPUT,
		STATE_COMPARE
	);

	signal state, state_next : type_state;

--	function gcd_sub (modulus, seed_temp : integer) return integer is
--		variable swap:integer := 0;
--		variable modu:integer := 0;
--		variable temp:integer := 0;
--	begin
--		temp := seed_temp;
--		modu := modulus;
--		temp := temp - modu;
--		if temp = 1 then
--			return 1;
--		end if;
--		if temp = 0 then
--			return 0;
--		end if;
--		if temp < 0 then
--			temp := temp + modu;
--		end if;
--			swap := temp;
--			temp := modu;
--			modu := swap;
--			return gcd_sub(modu, temp);
--	end gcd_sub;
begin
	
	start_proc : process(seed)
	begin
		start <= '1';
	end process start_proc;
	
	state_proc : process(state)
		variable modulus : integer := 0;
		variable seed_temp: integer := 0;
	begin
		modulus := mod_sig; -- Kopie erstellen
		seed_temp := seed_sig;
		state_next <= state;

		case state is
			
			when STATE_INPUT =>
				if start = '1' then
					mod_sig <= M; -- Kopie erstellen
					seed_sig <= to_integer(unsigned(seed));
					state_next <= STATE_COMPARE;
					start <= '0';
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

	sync_proc: process(Clk)
	begin
		if rising_edge(Clk) then
			if start = '1' then
				state <= STATE_INPUT;
			else
				state <= state_next;
			end if;
		end if;
	end process sync_proc;
		
--	seed_valid_proc : process(seed)
--		variable modulus: integer := 0;
--		variable seed_temp: integer := 0;

--	begin
--		modulus := M; -- Kopie erstellen
--		seed_temp := to_integer(unsigned(seed));

--		if seed_temp /= 0 then -- Falls seed = 0 Algorithmus überspringen
--			while seed_temp /= modulus loop -- Algorithmus Grösster gemeinsamer Teiler
--				if seed_temp > modulus then
--					seed_temp := seed_temp - modulus;
--				else
--					modulus := modulus - seed_temp;
--				end if;
--			end loop;
--			if gcd_sub(modulus, seed_temp) = 1 then
--				seed_valid <= to_integer(unsigned(seed)); -- seed wird für weitere Berechnung weiter gereicht
--			end if;
--		end if;

--		if seed_temp = 1 then -- Grösster gemeinsamer Teiler ist 1 = teilerfremd
--			seed_valid <= to_integer(unsigned(seed)); -- seed wird für weitere Berechnung weiter gereicht
--		end if;
-------------------------------------------------------------------------------
--
-- Process bbs_proc: triggered by seed_valid
-- 
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
		
--		-- weitere Möglichkeit um mit einer Iteration gleich zwei Bits zu generieren
--		while i <= (LEN / 2) loop
--			temp := (x * x) mod M; --BBS Algorithmus
--			
--			temp_vec := std_logic_vector(to_unsigned(temp, temp_vec'length));
--
--			for j in temp_vec'range loop -- Paritätsbit berechnen	
--				parity_v := parity_v xor temp_vec(j);
--			end loop;
--			bit_i := parity_v;	
--			
--			rndnumb_temp(i) := bit_i; -- i.tes Bit schreiben
--			
--			bit_i := temp_vec(0); -- Least significant bit berechnen
--			
--			rndnumb_temp(i + 1) := bit_i; -- (i + 1).tes Bit schreiben
--			
--			x := temp; -- nächsten Iterationswert übergeben
--			i := i + 2;
--		end loop;
--		
--		i := 0; -- Reset Laufindex
--		
--		if (LEN mod 2) = 1 then
--			rndnumb_temp(LEN - 1) := '0'; -- Letzten Wert setzen, da LEN ungerade
--		end if;
	
		rndnumb <= rndnumb_temp; -- Zufallszahl ausgeben	
	end process bbs_proc;
	
end beh;
--
-------------------------------------------------------------------------------
