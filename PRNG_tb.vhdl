-------------------------------------------------------------------------------
--
-- PRNG Testbench
--
-------------------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.PRNG_pkg.all;


--  A testbench has no ports.
entity prng_tb is
end prng_tb;
--
-------------------------------------------------------------------------------
--
architecture beh of prng_tb is

	--  Specifies which entity is bound with the component.
	for prng_0: prng use entity work.prng;	

	constant LEN : integer := 10; -- Anzahl von Bits
	constant clk_period : time := 1 ns;
	
	signal Clk : std_logic := '0';
	signal seed: std_logic_vector((LEN - 1) downto 0) := (others => '0');
	signal rndnumb: std_logic_vector((LEN - 1) downto 0);
	signal seed_en: std_logic := '0';
	signal rnd_en: std_logic := '0';
begin

	--  Component instantiation.
	prng_0: prng
		generic map(
			LEN => LEN
		)
			
		port map (
			seed => seed,
			Clk => Clk,
			seed_en => seed_en,
			rndnumb => rndnumb,
			rnd_en => rnd_en
		);
		
	Clk_process : process
	
	begin
		Clk <= '0';
		wait for clk_period/2;
		Clk <= '1';
		wait for clk_period/2;

	end process clk_process;	

	--  This process does the real job.
	stimuli : process

	begin
		wait for 100 ns;

		seed <= "0001000011"; -- 67
		
		wait for 1 ns;
		
		seed_en <= '1';
		
		wait for 1.5 ns;
			
		seed_en <= '0';
		
		wait for 100 ns;

		assert rndnumb = "1010101010" report "correct calculation" severity note; --682

		seed <= "0010011010"; --154

		wait for 1 ns;
		
		seed_en <= '1';
		
		wait for 1.5 ns;
			
		seed_en <= '0';

		wait for 100 ns;

		assert rndnumb = "1010101010" report "rndnumb not changed because of invalid seed" severity note;

		assert false report "end of test" severity note;

		--  Wait forever; this will finish the simulation.
		wait;

	end process stimuli;

end beh;
--
-------------------------------------------------------------------------------
