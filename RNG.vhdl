-------------------------------------------------------------------------------
--
-- RNG
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--
-------------------------------------------------------------------------------
--
entity rng is

	-- `length`, 'clk_slow', 'clock_fast',  'reset', 'mode', 'start' are the inputs of trng entity.
	-- `rndnumb' is the output of the entitiy.

	port (
		length: in unsigned integer;
		clk_slow: in std_logic;
		cl_fast: in std_logic;
		reset: in std_logic;
		mode: in std_logic;
		start: in std_logic;
		rndnumber: out unsigned integer
	);

end rng;
--
-------------------------------------------------------------------------------
--
architecture behavioral of rng is

begin


end rng;
--
-------------------------------------------------------------------------------
