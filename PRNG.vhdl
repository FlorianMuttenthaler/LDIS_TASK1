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

	-- `seed`, 'length'  are the inputs of trng entity.
	-- `rndnumb' is the output of the entitiy.

	port (
		length: in integer;
		-- length of the vectors 1024
		seed: in std_logic_vector(1023 downto 0);
		rndnumb: out std_logic_vector(1023 downto 0);
	);

end prng;
--
-------------------------------------------------------------------------------
--
architecture beh of prng is
	constant M: integer := 4;
begin


end beh;
--
-------------------------------------------------------------------------------
