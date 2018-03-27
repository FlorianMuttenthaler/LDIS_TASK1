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

	-- 'R2' is the input of slowclk entity.
	-- 'R1' and 'X' are the outputs for the external components.
	-- 'clk_slow' is the output of the entity.

	port (
		R2: in std_logic;
		R1: out std_logic;
		X: out std_logic;
		clk_slow: out std_logic
	);

end slowclk;
--
-------------------------------------------------------------------------------
--
architecture behavioral of slowclk is
	signal temp: std_logic := 0; 

begin
	
	Inverter_proc : process(temp)
				
	begin
		
		R1 <= not temp;
	
	end process Inverter_proc;

	Buf_X_proc : process(temp) -- Buffer
				
	begin
		
		X <= temp;
	
	end process Buf_X_proc;
	
	Buf_R2_proc : process(R2) -- Buffer
				
	begin
		
		temp <= R2;
		clk_slow <= R2;
	
	end process Buf_R2_proc;
	
end slowclk;
--
-------------------------------------------------------------------------------
