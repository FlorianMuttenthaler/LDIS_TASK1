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
	
	component IBUF -- Input Buffer
	port (
		I: in  STD_LOGIC; 
		O: out STD_LOGIC
	);
	end component;
		
	component OBUF -- Output Buffer
	port(
		I: in  STD_LOGIC; 
		O: out STD_LOGIC
	);
	end component;
	
	signal R2O_sig : std_logic := '0';
	signal R1I_sig : std_logic := '0';
	signal XI_sig  : std_logic := '0';
begin
	
	U1: IBUF port map (I => R2, O => R2O_sig);
	U2: OBUF port map (I => R1I_sig, O => R1);
	U3: OBUF port map (I => XI_sig, O => X);
	
	R1I_sig <= not R2O_sig; -- Inverter
	XI_sig <= R2O_sig;
	clk_slow <= R2O_sig;
	
end beh;
--
-------------------------------------------------------------------------------
