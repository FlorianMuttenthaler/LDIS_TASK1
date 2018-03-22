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
		LEN : integer -- Anzahl von Bits
	);
	
	port (
		seed: in std_logic_vector((LEN - 1) downto 0);
		rndnumb: out std_logic_vector((LEN - 1) downto 0);
	);

end prng;
--
-------------------------------------------------------------------------------
--
architecture beh of prng is
	constant M: integer := 77; -- M = p * q, p&q sind Primzahlen, p%4 = q%4 = 3, p = 7, q = 11
	
	signal seed_val: std_logic := 0;
begin

	seed_val_proc:process(seed)
		variable modulus: integer;
		variable seed_temp: integer := 0;
		variable swap: integer := 0;
	begin
		modulus := M;
		seed_temp := to_integer(unsigned(seed));
		
		seed_temp := seed_temp - modulus;
		
		if seed_temp = 1 then 
			seed_val <= '1';
		elsif seed_temp = 0 then
			--seed_temp := to_integer(unsigned(seed));
		elsif seed_temp < 0 then
			seed_temp := seed_temp + modulus;	
			swap := seed_temp;
			seed_temp := modulus;
			modulus := swap;
		end if;
			
			
	
	end process seed_val_proc;

end beh;
--
-------------------------------------------------------------------------------
