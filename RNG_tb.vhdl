-------------------------------------------------------------------------------
--
-- RNG Testbench
--
-------------------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.RNG_pkg.all;


--  A testbench has no ports.
entity rng_tb is
end rng_tb;
--
-------------------------------------------------------------------------------
--
architecture beh of rng_tb is

	--  Specifies which entity is bound with the component.
	for rng_0: rng use entity work.rng;	

	constant LEN : integer := 32; -- Anzahl von Bits
	constant clk_period : time := 1 ns;
	
	signal R2       :	std_logic;
	signal clk_fast : std_logic;
	signal reset	 : std_logic;
	signal mode		 :	std_logic;
	signal start	 :	std_logic;
	signal R1		 : std_logic;
	signal X			 : std_logic;
	signal segment7 : std_logic_vector(7 downto 0);
	signal anode 	 : std_logic_vector(7 downto 0);
	signal UART_TX  : std_logic;
	signal rndnumb  : std_logic_vector((LEN - 1) downto 0);
	
begin

	--  Component instantiation.
	rng_0: rng
		generic map(
			LEN => LEN
		)
			
		port map (
			rndnumb => rndnumb,
			R2	=> R2,
			clk_fast => clk_fast,
			reset => reset,
			mode => mode,
			start => start,
			R1 => R1,
			X => X,
			segment7 => segment7,
			anode => anode,
			UART_TX => UART_TX
		);
		
	Clk_process : process
	
	begin
		clk_fast <= '0';
		wait for clk_period/2;
		clk_fast <= '1';
		wait for clk_period/2;

	end process clk_process;	

	--  This process does the real job.
	stimuli : process

	begin
		wait for 100 ns;

		mode <= '0';
		
		wait for 1 ns;
		
		start <= '1';
		rndnumb <= "01101010110101001111101110010101";
		
		wait for 1.5 ns;
			
		start <= '0';
		
		wait for 100 ns;

		assert false report "end of test" severity failure;

		--  Wait forever; this will finish the simulation.
		wait;

	end process stimuli;

end beh;
--
-------------------------------------------------------------------------------
