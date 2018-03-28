-------------------------------------------------------------------------------
--
-- 7-segment display Testbench
--
-------------------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sevenseg_pkg.all;


--  A testbench has no ports.
entity sevenseg_tb is
end sevenseg_tb;
--
-------------------------------------------------------------------------------
--
architecture beh of sevenseg_tb is

	--  Specifies which entity is bound with the component.
	for sevenseg_0: sevenseg use entity work.sevenseg;	

	constant LEN : integer := 40; -- Anzahl von Bits
	constant clk_period : time := 1 ns;
	
	signal clk : std_logic := '0';
	signal en_new_numb : std_logic := '0'; 	
	signal rndnumb: std_logic_vector((LEN - 1) downto 0);
	signal segment7: std_logic_vector(7 downto 0);  
	signal anode: std_logic_vector(7 downto 0);

begin

	--  Component instantiation.
	sevenseg_0: sevenseg
		generic map(
			LEN => LEN
		)
			
		port map (
			rndnumb => rndnumb,
			clk => clk,
			en_new_numb => en_new_numb,
			segment7 => segment7,
			anode => anode
		);

	clk_process : process
	
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;

	end process clk_process;	

	--  This process does the real job.
	stimuli : process

	begin

		wait for 20 ns;
		
		rndnumb <= "1000111010100011101010001110101000111010";
		wait for 2 ns;
		en_new_numb <= '1';
		wait for 2 ns;
		en_new_numb <= '0';

		wait for 20 ns;
		
		rndnumb <= "0000111010000011101000001110100000111010";
		wait for 2 ns;
		en_new_numb <= '1';
		wait for 2 ns;
		en_new_numb <= '0';


		wait for 20 ns;
		
		rndnumb <= "0011111010000011101000001110100000111010";
		wait for 2 ns;
		en_new_numb <= '1';
		wait for 2 ns;
		en_new_numb <= '0';


		assert false report "end of test" severity failure;

		--  Wait forever; this will finish the simulation.
		wait;

	end process stimuli;

end beh;
--
-------------------------------------------------------------------------------
