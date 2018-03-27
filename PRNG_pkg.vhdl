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
		-- 'seed' is the input of prng entity.
		-- 'rndnumb' is the output of the entity.
		
		generic(
			LEN : integer := 128 -- Anzahl von Bits, DEFAULT = 128
		);
		
		port (
			seed: in std_logic_vector((LEN - 1) downto 0);
			rndnumb: out std_logic_vector((LEN - 1) downto 0)
		);
	
	end component prng;
	
end prng_pkg;

