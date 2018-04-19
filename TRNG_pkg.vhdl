-------------------------------------------------------------------------------
--
-- TRNG package
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--
-------------------------------------------------------------------------------
--
package trng_pkg is

	component trng is

		-- 'LEN' is the generic value of the entity.
		-- 'clk_slow' and 'clk_fast' are the inputs of trng entity.
		-- 'seed' and 'seed_en' are the output of the entity.

		generic(
			LEN : integer := 128 -- Anzahl von Bits, DEFAULT = 128
		);
		
		port (
			clk_slow	: in  std_logic;
			clk_fast	: in  std_logic;
			seed		: out std_logic_vector((LEN - 1) downto 0); 
			seed_en		: out std_logic
		);
	
	end component trng;
	
end trng_pkg;

