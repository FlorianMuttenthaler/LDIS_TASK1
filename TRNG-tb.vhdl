-------------------------------------------------------------------------------
--
-- TRNG Testbench
--
-------------------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


--  A testbench has no ports.
entity trng_tb is
end trng_tb;
--
-------------------------------------------------------------------------------
--
architecture beh of trng_tb is

	--  Declaration of the component that will be instantiated.
	component trng

  		port (
			length: in integer;
			clk_slow: in std_logic;	
			clk_fast: in std_logic;
			seed: out std_logic_vector(1023 downto 0)
		);

	end component;

	--  Specifies which entity is bound with the component.
	for trng_0: trng use entity work.trng;								
	constant clk_slow_Period : time := 20 ns; --50kHz
	constant clk_fast_Period : time := 1 ns;  --1MHz
	
	signal length:integer;
	signal clk_slow: std_logic;	
	signal clk_fast: std_logic;
	signal seed: std_logic_vector(1023 downto 0);
begin

	--  Component instantiation.
	trng_0: trng port map (
		length => length,
	 	clk_slow => clk_slow,
		clk_fast => clk_fast,
		seed => seed
	);

	clk_slow_gen: process
	begin
		clk_slow <= '0';
		wait for clk_slow_Period/2;
		clk_slow <= '1';
		wait for clk_slow_Period/2;
	end process;

	clk_fast_gen: process
	begin
		clk_fast <= '0';
		wait for clk_fast_Period/2;
		clk_fast <= '1';
		wait for clk_fast_Period/2;
	end process;

	--  This process does the real job.
	stimuli: process

	begin

		wait for 100 ns;

		length <= 20;

		assert false report "end of test" severity note;

		--  Wait forever; this will finish the simulation.
		wait;

	end process;

end beh;
--
-------------------------------------------------------------------------------
