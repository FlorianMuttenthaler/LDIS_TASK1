-------------------------------------------------------------------------------
--
-- TRNG
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--
-------------------------------------------------------------------------------
--
entity trng is

	-- `length`, 'clk_slow', 'clk_fast' are the inputs of trng entity.
	-- `seed' is the output of the entitiy.

	port (
		length: in integer;
		clk_slow: in std_logic;
		clk_fast: in std_logic;
	        --Length of vector is 1024
		seed: out std_logic_vector(1023 downto 0) 
	);

end trng;
--
-------------------------------------------------------------------------------
--
architecture beh of trng is
	signal i: integer := 0;
	signal seed_array:std_logic_vector(1023 downto 0) := (others => '0');
begin
	sample_proc:process(clk_slow)
		
	begin
		if rising_edge(clk_slow) then
			seed_array(i) <= clk_fast;
			i <= i + 1;
		end if;
	end process;

	push_proc:process(i)

	begin
		if i = (length -1) then
			i <= 0;
			seed <= seed_array;
		end if;
	end process;


end beh;
--
-------------------------------------------------------------------------------
