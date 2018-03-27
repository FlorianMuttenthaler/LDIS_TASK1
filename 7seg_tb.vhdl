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

	constant LEN : integer := 10; -- Anzahl von Bits
	
	signal rndnumb: std_logic_vector((LEN - 1) downto 0);
	signal segment7: std_logic_vector(6 downto 0);  
	signal anode: std_logic_vector(7 downto 0);

begin

	--  Component instantiation.
	sevenseg_0: sevenseg
		generic map(
			LEN => LEN
		)
			
		port map (
			rndnumb => rndnumb,
			segment7 => segment7,
			anode => anode
		);

	--  This process does the real job.
	stimuli : process

	begin

		wait for 100 ns;
		
		rndnumb <= "1000111010";
		
		wait for 100 ns;
		
		rndnumb <= "0000111010";
		
		wait for 100 ns;
		
		rndnumb <= "0011111010";
		
		assert false report "end of test" severity note;

		--  Wait forever; this will finish the simulation.
		wait;

	end process stimuli;

end beh;
--
-------------------------------------------------------------------------------
