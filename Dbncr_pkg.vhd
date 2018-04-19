-------------------------------------------------------------------------------
--
-- Dbncr package
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--
-------------------------------------------------------------------------------
--
package Dbncr_pkg is

	component Dbncr is

		-- 'NR_OF_CLKS' is the generic value of the entity.
		-- 'clk_i' and 'sig_i' are the inputs of sevenseg entity.
		-- 'pls_o' is the output of the entity.

		generic(
      NR_OF_CLKS : integer := 1000 -- Number of System Clock periods while the incoming signal 
		);                              -- has to be stable until a one-shot output signal is generated
		port(
			clk_i : in std_logic;
			sig_i : in std_logic;
			pls_o : out std_logic
		);
	
	end component Dbncr;
	
end Dbncr_pkg;

