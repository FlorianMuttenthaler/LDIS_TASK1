-------------------------------------------------------------------------------
--
-- RNG package
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--
-------------------------------------------------------------------------------
--
package rng_pkg is

	component rng is

		-- 'LEN' is the generic value of the entity.
		-- 'R2', 'clk_fast', 'reset', 'mode' and 'start' are the inputs of rng entity.
		-- 'R1', 'X', 'segment7' and 'UART_TX' are the output of the entity.
		
		generic(
			LEN : integer := 128 -- Anzahl von Bits, DEFAULT = 128
		);
		
		port (
			rndnumb  : in std_logic_vector((LEN - 1) downto 0);
			R2		: in std_logic;
			clk_fast: in std_logic;
			reset	: in std_logic;
			mode	: in std_logic;
			start	: in std_logic;
			R1		: out std_logic;
			X		: out std_logic;
			segment7: out std_logic_vector(7 downto 0);
			anode 	: out std_logic_vector(7 downto 0);
			--UART_RX : in std_logic;
			UART_TX : out std_logic
		);
	
	end component rng;
	
end rng_pkg;

