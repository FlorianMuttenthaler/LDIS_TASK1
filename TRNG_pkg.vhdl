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
		-- 'clk_slow', 'clk_fast' are the inputs of trng entity.
		-- 'seed' is the output of the entity.

		generic(
			LEN : integer -- Anzahl von Bits
		);
		
		port (
			clk_slow: in std_logic;
			clk_fast: in std_logic;
				--Length of vector is 1024
			seed: out std_logic_vector((LEN - 1) downto 0) 
		);
	
	end component trng;
	
end trng_pkg;

