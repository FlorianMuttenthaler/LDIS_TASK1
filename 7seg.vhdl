-----------------------------------------------------------------------------
--
-- 7-segment display
-- Source: http://vhdlguru.blogspot.co.at/2010/03/vhdl-code-for-bcd-to-7-segment-display.html
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--
-------------------------------------------------------------------------------
--
entity sevenseg is

	-- 'LEN' is the generic value of the entity.
	-- 'rndnumb' and 'clk' are the inputs of sevenseg entity.
	-- 'segment7' and 'anode' are the output of the entity.

	generic(
			LEN : integer := 128 -- Anzahl von Bits, DEFAULT = 128
		);
		
	port (
		rndnumb		: in std_logic_vector((LEN - 1) downto 0);
		clk		: in std_logic;
		en_new_numb	: in std_logic;	-- New rndnumb to display			
		segment7	: out std_logic_vector(7 downto 0);  -- 8 bit decoded output.
		anode		: out std_logic_vector(7 downto 0)  -- 8 bit output for anodes.
	);

end sevenseg;
--
-------------------------------------------------------------------------------
--
-- NOTE: 'a' corresponds to MSB of segment7 and 'g' corresponds to LSB of
--	segment7:
--
architecture behavioral of sevenseg is
	
	type array_t is array (0 to 7) of std_logic_vector(3 downto 0);
	
	signal array_seg: array_t := (others => (others => '0'));  -- Initialisierung
	signal digit:integer  := 0;

	function bcd_to_7seg (bcd: std_logic_vector(3 downto 0)) return std_logic_vector is 
		
	begin
	
		case bcd is
			--------------------------abcdefg----------
			when "0000"=> return "00000011";  -- '0'
			when "0001"=> return "10011111";  -- '1'
			when "0010"=> return "00100101";  -- '2'
			when "0011"=> return "00001101";  -- '3'
			when "0100"=> return "10011001";  -- '4'
			when "0101"=> return "01001001";  -- '5'
			when "0110"=> return "01000001";  -- '6'
			when "0111"=> return "00011111";  -- '7'
			when "1000"=> return "00000001";  -- '8'
			when "1001"=> return "00001001";  -- '9'
			when "1010"=> return "00010000"; -- 'A'
			when "1011"=> return "00000000"; -- 'B'
			when "1100"=> return "01100010"; -- 'C'
			when "1101"=> return "00000010"; -- 'D'
			when "1110"=> return "01100000"; -- 'E'
			when "1111"=> return "01110000"; -- 'F'
			
			--nothing is displayed when a number more than F is given as input.
			when others=> return "11111111";

		end case;
		
	end bcd_to_7seg;


begin

	bcd_proc: process (en_new_numb)
		
	begin
		if en_new_numb = '1' then 
			for j in anode'range loop
				for i in 0 to 3 loop
					array_seg(j)(i) <= rndnumb(i + 4 * j);
				end loop;
			end loop;
		end if;		

	end process bcd_proc;
	
	write_proc: process (clk)
		variable segment_temp:std_logic_vector(3 downto 0) := (others => '0');
	begin
		if rising_edge(clk) then
			
			for i in segment_temp'range loop
				segment_temp(i) := array_seg(digit)(i);
			end loop;
			
			case digit is
				when 0 => 
					anode <= "00000001";
					segment7 <= bcd_to_7seg(segment_temp);
				when 1 => 
					anode <= "00000010";
					segment7 <= bcd_to_7seg(segment_temp);
				when 2 => 
					anode <= "00000100";
					segment7 <= bcd_to_7seg(segment_temp);
				when 3 => 
					anode <= "00001000";
					segment7 <= bcd_to_7seg(segment_temp);
				when 4 => 
					anode <= "00010000";
					segment7 <= bcd_to_7seg(segment_temp);
				when 5 => 
					anode <= "00100000";
					segment7 <= bcd_to_7seg(segment_temp);
				when 6 => 
					anode <= "01000000";
					segment7 <= bcd_to_7seg(segment_temp);
				when 7 => 
					anode <= "10000000";
					segment7 <= bcd_to_7seg(segment_temp);
				when others =>
					anode <= "00000000";
					segment7 <= "11111111";
			end case;
			if digit < 8 then
				digit <= digit + 1;
			else
				digit <= 0;
			end if;
		end if;
	end process write_proc;
	
	
end behavioral;
--
-------------------------------------------------------------------------------