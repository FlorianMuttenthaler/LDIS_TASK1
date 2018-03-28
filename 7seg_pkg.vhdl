-------------------------------------------------------------------------------
--
-- 7-segment display package
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--
-------------------------------------------------------------------------------
--
package sevenseg_pkg is

	component sevenseg is

		-- 'LEN' is the generic value of the entity.
		-- 'rndnumb' and 'clk' are the inputs of sevenseg entity.
		-- 'segment7' and 'anode' are the output of the entity.

		generic(
				LEN : integer := 128 -- Anzahl von Bits, DEFAULT = 128
			);
			
		port (
			rndnumb		: in std_logic_vector((LEN - 1) downto 0);
			clk		: in std_logic;
			en_new_numb	: in std_logic; -- New rndnumb to display
			segment7	: out std_logic_vector(7 downto 0);  -- 8 bit decoded output.
			anode		: out std_logic_vector(7 downto 0)  -- 8 bit output for anodes.
		);
	
	end component sevenseg;
	
end sevenseg_pkg;

