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
architecture beh of slowclk is
--	signal temp: std_logic := '0'; 
	
	component IBUF
	port (I: in STD_LOGIC; O: out STD_LOGIC);
	end component;
		
	component OBUF
	port(I: in STD_LOGIC; O: out STD_LOGIC);
	end component;
		

	
	signal R2O_sig:std_logic := '0';
	signal R1I_sig:std_logic := '0';
	signal XI_sig:std_logic := '0';
begin
	
	U1: IBUF port map (I => R2, O => R2O_sig);
	U2: OBUF port map (I => R1I_sig, O => R1);
	U3: OBUF port map (I => XI_sig, O => X);
	
	R1I_sig <= not R2O_sig;
	XI_sig <= R2O_sig;
--	temp <= R2;
	clk_slow <= R2O_sig;
	
--	Inverter_proc : process(temp)
				
--	begin
		
--		R1 <= not temp;
	
--	end process Inverter_proc;

--	Buf_X_proc : process(temp) -- Buffer
				
--	begin
		
--		X <= temp;
	
--	end process Buf_X_proc;
	
--	Buf_R2_proc : process(R2) -- Buffer
				
--	begin
		
--		temp <= R2;
--		clk_slow <= R2;
	
--	end process Buf_R2_proc;
	
end beh;
--
-------------------------------------------------------------------------------
