-------------------------------------------------------------------------------
--
-- SlowClock
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--
-------------------------------------------------------------------------------
--
entity slowclk is

	-- 'x', 'y' are the inputs of trng entity.
	-- `clk_slow' is the output of the entitiy.

	port (
		x: in unsigned integer;
		y: in unsigned integer;
		clk_slow: out std_logic
	);

end slowclk;
--
-------------------------------------------------------------------------------
--
architecture behavioral of slowclk is


begin
	

end slowclk;
--
-------------------------------------------------------------------------------
