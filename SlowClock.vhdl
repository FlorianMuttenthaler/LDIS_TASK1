-------------------------------------------------------------------------------
--
-- SlowClock
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Library for buffer
library UNISIM;
use UNISIM.vcomponents.all;

--
-------------------------------------------------------------------------------
--
entity slowclk is

	-- 'R2' is the input for the external component.
	-- 'R1' and 'X' are the outputs for the external components.
	-- 'clk_slow' is the output of the entity.

	port (
		R2 		 : in  std_logic;
		R1 		 : out std_logic;
		X  		 : out std_logic;
		clk_slow : out std_logic
	);

end slowclk;
--
-------------------------------------------------------------------------------
--
architecture beh of slowclk is
	
	signal R2O_sig : std_logic := '0';
	signal R1I_sig : std_logic := '0';
	signal XI_sig  : std_logic := '0';
	
begin

	-- IBUF: Single-ended Input Buffer
	-- 7 Series
	-- Xilinx HDL Libraries Guide, version 2012.2
	IBUF_R2 : IBUF
		port map(
			O => R2O_sig, -- Buffer output
			I => R2 -- Buffer input (connect directly to top-level port)
		);
	-- End of IBUF instantiation
	
	-- OBUF: Single-ended Output Buffer
	-- 7 Series
	-- Xilinx HDL Libraries Guide, version 2012.2
	OBUF_R1 : OBUF
	port map(
			O => R1, -- Buffer output (connect directly to top-level port)
			I => R1I_sig -- Buffer input
		);
	
	OBUF_X : OBUF
		port map(
			O => X, -- Buffer output (connect directly to top-level port)
			I => XI_sig -- Buffer input
		);
	-- End of OBUF instantiation
	
	R1I_sig <= not R2O_sig; -- Inverter
	XI_sig <= R2O_sig;
	clk_slow <= R2O_sig;
	
end beh;
--
-------------------------------------------------------------------------------
