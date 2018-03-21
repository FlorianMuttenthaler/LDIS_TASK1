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

	-- `length`, 'x', 'y', 'clk_fast',  'reset', 'mode', 'start' are the inputs of trng entity.
	-- `rndnumb' is the output of the entitiy.

	port (
		length: in integer;
		x: in integer;
		y: in integer;
		clk_fast: in std_logic;
		reset: in std_logic;
		mode: in std_logic;
		start: in std_logic;
		-- Maximum length of the rndnumber is 1024
		rndnumber: out std_logic_vector(1023 downto 0);
		segment7: out std_logic_vector(7 downto 0)
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
