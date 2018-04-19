-------------------------------------------------------------------------------
--
-- PRNG package
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--
-------------------------------------------------------------------------------
--
package prng_pkg is

	component prng is

		-- 'LEN' is the generic value of the entity.
		-- 'seed', 'Clk' and 'seed_en' are the inputs of prng entity.
		-- 'rndnumb' and 'rnd_en' are the outputs of the entity.
		
		generic(
			LEN: integer := 128 -- Anzahl von Bits, DEFAULT = 128
		);
		
		port (
			seed	: in std_logic_vector((LEN - 1) downto 0);
			Clk	   	: in std_logic;
			seed_en	: in std_logic;
			rndnumb	: out std_logic_vector((LEN - 1) downto 0);
			rnd_en 	: out std_logic
		);
	
	end component prng;
	
end prng_pkg;

