-------------------------------------------------------------------------------
--
-- TRNG
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--
-------------------------------------------------------------------------------
--
entity trng is

	-- 'LEN' is the generic value of the entity.
	-- 'clk_slow', 'clk_fast' are the inputs of trng entity.
	-- 'seed' and 'seed_en' are the output of the entity.

	generic(
		LEN : integer := 128 -- Anzahl von Bits, DEFAULT = 128
	);
	
	port (
		clk_slow: in std_logic;
		clk_fast: in std_logic;
		seed: out std_logic_vector((LEN - 1) downto 0); 
		seed_en: out std_logic
	);

end trng;
--
-------------------------------------------------------------------------------
--
architecture beh of trng is
	signal i_sig: integer range 0 to LEN := 0;
	signal seed_array:std_logic_vector((LEN - 1) downto 0) := (others => '0');
	
begin

-------------------------------------------------------------------------------
--
-- Process state_out_proc: triggered by clk_slow
-- fulfills a seed array with values of clk_fast sampled by clk_slow
--
	trng_proc : process(clk_slow)
		variable i : integer range 0 to LEN := 0;
	begin
	
		if rising_edge(clk_slow) then
			i := i_sig;
			
			seed_array(i) <= clk_fast;
			if i = (LEN - 1) then
				i := 0;
				seed <= seed_array;
				seed_en <= '1';
			else
				i := i + 1;
				seed_en <= '0';
			end if;
			i_sig <= i;
		end if;
		
	end process trng_proc;


end beh;
--
-------------------------------------------------------------------------------
