-----------------------------------------------------------------------------
--
-- 7-segment display
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
	-- 'reset', 'rndnumb', 'clk' and 'en_new_numb' are the inputs of sevenseg entity.
	-- 'segment7' and 'anode' are the output of the entity.

	generic(
			LEN : integer := 128 -- Anzahl von Bits, DEFAULT = 128
		);
		
	port (	
		reset 		: in std_logic;
		rndnumb		: in std_logic_vector((LEN - 1) downto 0);
		clk			: in std_logic;
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
	constant COUNT_MAX:integer := 6250; -- Zeitslot = 1/8 ms
	
	type array_t is array (0 to 7) of std_logic_vector(3 downto 0);
	signal array_seg : array_t := (others => (others => '0'));  -- Initialisierung
	signal digit_sig : integer range 0 to 7  := 0;

	signal clk_temp : std_logic := '0';
	signal clk_count : integer := 0;

-------------------------------------------------------------------------------
--
-- Function bcd_to_7seg: used to map the hexadezimal numbers of random number
-- to the defined mapping of the segment light display
-- Idee uebernommen von den Examples von LDIS lecture
--
	function bcd_to_7seg (bcd: std_logic_vector(3 downto 0)) return std_logic_vector is 
	begin
		case bcd is
			----------------------abcdefgp---------
			when "0000"=> return "00000011"; -- '0'
			when "0001"=> return "10011111"; -- '1'
			when "0010"=> return "00100101"; -- '2'
			when "0011"=> return "00001101"; -- '3'
			when "0100"=> return "10011001"; -- '4'
			when "0101"=> return "01001001"; -- '5'
			when "0110"=> return "01000001"; -- '6'
			when "0111"=> return "00011111"; -- '7'
			when "1000"=> return "00000001"; -- '8'
			when "1001"=> return "00001001"; -- '9'
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

-------------------------------------------------------------------------------
--
-- Process bcd_proc: triggered by en_new_numb and rndnumb
-- if en_new_numb = 1 then a new random number will be displayed
-- algorithm of the process is based on array that can be displayed with a fixed size
-- if random number is to short than leading zeros are implemented
-- if random number is to large then the MSBs are cut
--
	bcd_proc: process (en_new_numb, rndnumb)
		variable rndnumb_temp : std_logic_vector(32 downto 0) := (others => '0');
		variable length_min : integer range 0 to 33 := 0;
	begin
		if en_new_numb = '1' then -- Display new random number
			if LEN < rndnumb_temp'length then -- Laenge kuerzen
				length_min := LEN;
			else
				length_min := rndnumb_temp'length;
			end if;
			
			for k in 0 to 32 - 1 loop
				if k <= length_min - 1 then
					rndnumb_temp(k) := rndnumb(k); -- Temporaere Variable beschreiben
				else
					rndnumb_temp(k) := '0'; -- Restliche Werte mit 0 beschreiben um Latches zuvermeiden
				end if;
			end loop;
			
			for j in 0 to 7 loop -- Array mit Werten fuellen (bcd codiert)
				for i in 0 to 3 loop
					array_seg(j)(i) <= rndnumb_temp(i + 4 * j);
				end loop;
			end loop;
		else
			null;
		end if;		
	end process bcd_proc;

-------------------------------------------------------------------------------
--
-- Process clk_gen_proc: triggered by clk
-- Clockgenerator: Zeitslot = 1/8 ms
--
clk_gen_proc: process(clk)
		variable count : integer := 0;
	begin
		if rising_edge(clk) then
			count := clk_count;
			if count = COUNT_MAX then
				count := 0;
				clk_temp <= not clk_temp;
			else
				count := count + 1;
			end if;
			clk_count <= count;
		end if;
	end process clk_gen_proc;
			
-------------------------------------------------------------------------------
--
-- Process write_proc: triggered by reset and clk_temp
-- Wenn reset = 1 dann wird die 7-Segment Anzeige ausgeschaltet
-- Es werden alle digits kontinuierlich refreshed
-- Aenderung ist schnell genug, damit das menschliche Auge es nicht mitbekommt
--
	write_proc: process (reset, clk_temp)
		variable segment_temp : std_logic_vector(3 downto 0) := (others => '0');
		variable digit : integer range 0 to 7 := 0;
	begin
		if reset = '1' then	-- Schaltet die 7-Segment Anzeige aus
			anode <= "11111111";
			segment7 <= "11111111";
		elsif rising_edge(clk_temp) then
			digit := digit_sig;
			for i in segment_temp'range loop -- Laedt Ziffer, die angezeigt werden soll
				segment_temp(i) := array_seg(digit)(i);
			end loop;
			
			case digit is -- Schaltet richtiges digit aktiv und gibt die Ziffer aus
				when 0 => 
					anode <= "11111110";
					segment7 <= bcd_to_7seg(segment_temp);
				when 1 => 
					anode <= "11111101";
					segment7 <= bcd_to_7seg(segment_temp);
				when 2 => 
					anode <= "11111011";
					segment7 <= bcd_to_7seg(segment_temp);
				when 3 => 
					anode <= "11110111";
					segment7 <= bcd_to_7seg(segment_temp);
				when 4 => 
					anode <= "11101111";
					segment7 <= bcd_to_7seg(segment_temp);
				when 5 => 
					anode <= "11011111";
					segment7 <= bcd_to_7seg(segment_temp);
				when 6 => 
					anode <= "10111111";
					segment7 <= bcd_to_7seg(segment_temp);
				when 7 => 
					anode <= "01111111";
					segment7 <= bcd_to_7seg(segment_temp);
				when others =>
					anode <= "11111111";
					segment7 <= "11111111";
			end case;
			if digit < 7 then
				digit := digit + 1;
			else
				digit := 0;
			end if;
			digit_sig <= digit;
		end if;
	end process write_proc;
	
end behavioral;
--
-------------------------------------------------------------------------------