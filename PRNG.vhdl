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
	-- 'seed' is the input of prng entity.
	-- 'rndnumb' is the output of the entity.
	
	generic(
		LEN : integer := 5 -- Anzahl von Bits, DEFAULT = 5
	);
	
	port (
		seed: in std_logic_vector((LEN - 1) downto 0);
		rndnumb: out std_logic_vector((LEN - 1) downto 0)
	);

end prng;
--
-------------------------------------------------------------------------------
--
architecture beh of prng is
	constant M: integer := 77; -- M = p * q, p&q sind Primzahlen, p%4 = q%4 = 3, p = 7, q = 11
	
	signal seed_valid: integer := 0;
	
begin

	seed_valid_proc : process(seed)
		variable modulus: integer := 0;
		variable seed_temp: integer := 0;
		variable swap: integer := 0;
		
	begin
	
		modulus := M;
		seed_temp := to_integer(unsigned(seed));

		while seed_temp /= modulus loop
			if seed_temp > modulus then
				seed_temp := seed_temp - modulus;
			else
				modulus := modulus - seed_temp;
			end if;
		end loop;

		if seed_temp = 1 then
			seed_valid <= to_integer(unsigned(seed));
		end if;
	
	end process seed_valid_proc;

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
