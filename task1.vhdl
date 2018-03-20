-------------------------------------------------------------------------------
--
-- Full adder
--
-- Source: https://en.wikibooks.org/wiki/VHDL_for_FPGA_Design/4-Bit_Adder
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--
-------------------------------------------------------------------------------
--
entity adder is

	-- `i0`, `i1` and the carry-in `ci` are inputs of the adder.
	-- `s` is the sum output, `co` is the carry-out.

	port (
		i0, i1 : in unsigned(3 downto 0);
	   	s : out unsigned(3 downto 0);
	   	co : out std_logic
	);

end adder;
--
-------------------------------------------------------------------------------
--
architecture behavioral of adder is

	signal tmp: unsigned (4 downto 0);

begin

   --  This full-adder architecture contains three concurrent assignments
   --  Compute the sum.
   tmp <= ("0" & i0) + ("0" & i1);

   --  Assign output signals
   s  <= tmp(3 downto 0);
   co <= tmp(4);

end behavioral;
--
-------------------------------------------------------------------------------
