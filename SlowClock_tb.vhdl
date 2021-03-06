-------------------------------------------------------------------------------
--
-- SlowClock Testbench
--
-------------------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.SlowClock_pkg.all;


--  A testbench has no ports.
entity slowclk_tb is
end slowclk_tb;
--
-------------------------------------------------------------------------------
--
architecture beh of slowclk_tb is

	--  Specifies which entity is bound with the component.
	for slowclk_0: slowclk use entity work.slowclk;	

	constant LEN : integer := 10; -- Anzahl von Bits
	constant clk_slow_Period : time := 19.5 ns; --50kHz
	constant clk_fast_Period : time := 1 ns;  --1MHz
	
	signal clk_slow: std_logic;	
	signal clk_fast: std_logic;
	signal seed: std_logic_vector((LEN - 1) downto 0);
	
begin

	--  Component instantiation.
	slowclk_0: slowclk
		generic map(
			LEN => LEN
		)
			
		port map (
			clk_slow => clk_slow,
			clk_fast => clk_fast,
			seed => seed
		);

	clk_slow_gen : process
	
	begin
	
		clk_slow <= '0';
		wait for clk_slow_Period/2;
		clk_slow <= '1';
		wait for clk_fast_Period/2;
		
	end process clk_slow_gen;

	clk_fast_gen : process
	
	begin
	
		clk_fast <= '0';
		wait for clk_fast_Period/2;
		clk_fast <= '1';
		wait for clk_fast_Period/2;
		
	end process clk_fast_gen;

	--  This process does the real job.
	stimuli : process

	begin

		wait for 100 ns;

		assert false report "end of test" severity note;

		--  Wait forever; this will finish the simulation.
		wait;

	end process stimuli;

end beh;
--
-------------------------------------------------------------------------------
