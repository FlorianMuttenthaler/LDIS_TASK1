-------------------------------------------------------------------------------
--
-- SlowClock package
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--
-------------------------------------------------------------------------------
--
package slowclk_pkg is

	component slowclk is

		-- 'R2' is the input for the external component.
		-- 'R1' and 'X' are the outputs for the external components.
		-- 'clk_slow' is the output of the entity.

		port (
			R2 		 : in  std_logic;
			R1 		 : out std_logic;
			X  		 : out std_logic;
			clk_slow : out std_logic
		);
	
	end component slowclk;
	
end slowclk_pkg;

