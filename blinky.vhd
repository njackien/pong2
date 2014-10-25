library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blinky is
	port(
		CLOCK_50: in std_logic;
		LEDG: out std_logic_vector(7 downto 0));
end blinky;

architecture Structural of blinky is
	signal lights: std_logic_vector( 7 downto 0) := "11111111";
	begin
	
		LEDG <= lights;
	
		process( CLOCK_50 )
			variable count: unsigned(27 downto 0) := "0000000000000000000000000000";
			variable loop_count: unsigned(5 downto 0);
		begin	
		if( CLOCK_50 = '1' ) then
			if( loop_count < "01010") then
				if( count = "0011111110101111000010000000" ) then
					lights <= not lights;
					count := "0000000000000000000000000000";
					loop_count := loop_count + 1;
				else
					count := count + 1;
				end if;
			elsif (loop_count < "10100") then
				if( count = "0010011000100101100111111111" ) then
					lights <= not lights;
					count := "0000000000000000000000000000";
					loop_count := loop_count + 1;
				else
					count := count + 1;
				end if;
			else
				if( count = "0001110010011100001101111111" ) then
					lights <= not lights;
					count := "0000000000000000000000000000";
					--loop_count := loop_count + 1;
				else
					count := count + 1;
				end if;
			end if;
		end if;
		end process;
	
						
end structural;
