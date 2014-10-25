library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

ENTITY datapath IS
	PORT(
		clock 				: in std_logic;	
		
		reset2dp				: in std_logic;
		reset2fsm			: out std_logic;
		
		P1_sw				: in std_logic; -- signals from sw to control paddles
		P2_sw				: in std_logic;
		P3_sw				: in std_logic;
		P4_sw				: in std_logic;
		
		player_win 		:out std_logic;
		draw2dp				: in std_logic; --tells dp to calc and draw
		draw2fsm				: out std_logic;	--tells fsm to go from draw idle to draw state
		
		green					: out unsigned(7 downto 0);
		colour				: out std_logic_vector(2 downto 0);
		x						: out std_logic_vector(7 downto 0);
		y 						: out std_logic_vector(6 downto 0);
		plot					: out std_logic
	);
END;
	
Architecture Behavioural of datapath  is
	signal x_state : unsigned( 7 downto 0 ) := "00000000";
	signal y_state : unsigned( 6 downto 0 ) := "0000000";
	
	signal p1_top_sig: unsigned (7 downto 0):="00010000";
	signal p2_top_sig: unsigned (7 downto 0):="00000000";
	signal p3_top_sig: unsigned (7 downto 0):="00000000";
	signal p4_top_sig: unsigned (7 downto 0):="00000000";
	
	signal slowclock: std_logic:='0';
BEGIN
	green <= p1_top_sig;
	
	process(clock)
		variable count : unsigned (14 downto 0) := "000000000000000";
	begin
		
		if (count = "111111111111110")then
			slowclock <= '1';
			count := "000000000000000";
		else
			count := count + "000000000000001";
			slowclock <= '0';
		end if;
	end process;
	
--	process(clock)
--		variable count : unsigned (27 downto 0) := "0000000000000000000000000000";
--	begin
--				if( count = "0000000000000001111111111110" ) then
--					slowclock <= '1';
--					count := "0000000000000000000000000000";
--				else
--					count := count + "0000000000000000000000000001";
--					slowclock <= '0';
--				end if;
--	end process;
	
	
--	process(clock)
--		variable count : unsigned (27 downto 0) := "0000000000000000000000000000";
--	begin
--				if( count = "0011111110101111000010000000" ) then
--					slowclock <= '1';
--					count := "0000000000000000000000000000";
--				else
--					count := count + 1;
--					slowclock <= '0';
--				end if;
--	end process;
	
	
	process(slowclock)
	begin
		if(rising_edge(slowclock))then
			if(p1_sw='1')then
				if(p1_top_sig > "00000010")then
					
					p1_top_sig <= p1_top_sig - "00000001";
				end if;
			elsif(p1_sw='0')then
				if(p1_top_sig < "10010101")then -- 160-10
					
					p1_top_sig <= p1_top_sig + "00000001";
				end if;
			end if;
		end if;
	end process;
	
	process(p2_sw, clock)
	begin
		if(p2_sw='1')then
			if(p2_top_sig > "00000010")then
				p2_top_sig <= p2_top_sig - "00000001";
			else
				p2_top_sig <= p2_top_sig;
			end if;
		else
			if(p2_top_sig < "10010101")then -- 160-10-1
				p2_top_sig <= p2_top_sig + "00000001";
			else
				p2_top_sig <= p2_top_sig;
			end if;
		end if;
	end process;
	
	process(p3_sw, clock)
	begin
		if(p3_sw='1')then
			if(p3_top_sig > 0)then
				p3_top_sig <= p3_top_sig + "00000001";
			else
				p3_top_sig <= p3_top_sig;
			end if;
		else
			if(p3_top_sig < 150)then -- 160-10
				p3_top_sig <= p3_top_sig - "00000001";
			else
				p3_top_sig <= p3_top_sig;
			end if;
		end if;
	end process;
	
	process(p4_sw, clock)
	begin
		if(p4_sw='1')then
			if(p4_top_sig > 0)then
				p4_top_sig <= p4_top_sig + "00000001";
			else
				p4_top_sig <= p4_top_sig;
			end if;
		else
			if(p4_top_sig < 150)then -- 160-10
				p4_top_sig <= p4_top_sig - "00000001";
			else
				p4_top_sig <= p4_top_sig;
			end if;
		end if;
	end process;
	
	
	
	process(reset2dp, draw2dp, clock)
		variable in_loop: std_logic := '0';
		variable in_loop2: std_logic := '1';
		variable dx : signed (8 downto 0);
		variable dy : signed (7 downto 0);
		variable X0 : signed (8 downto 0):="001010000";--80
		variable Y0 : signed (7 downto 0):="00111100";--60
		variable X1 : signed (8 downto 0);
		variable Y1 : signed (7 downto 0);
		variable err: signed (8 downto 0);
		variable e2: signed (17 downto 0);
		variable sx: signed (1 downto 0);
		variable sy: signed (1 downto 0);
		
		variable p1_top: unsigned (7 downto 0):="00111111";
		variable p2_top: unsigned (7 downto 0):="00110111";
		variable p3_top: unsigned (7 downto 0):="00110111";
		variable p4_top: unsigned (7 downto 0):="00110111";
	begin
		if(reset2dp = '1' and rising_edge(clock))then	--clear screen and set walls
			plot <= '1';
			--colour <= "000";
					if(y_state = "0000000" or y_state = "1110111")then --make the top an bottom line white 
						colour <= "111";
					end if;	
					
					if (x_state = "00000000" ) then
						--if(y_state = "0000000" or y_state = "1110111")then --make the top an bottom line white 
							--colour <="111";
						--end if;
						x <= std_logic_vector(x_state);
						x_state <= x_state+ "00000001";
					elsif (x_state = "10011111") then
							colour <="000";
						x <= std_logic_vector(x_state);
						x_state <= "00000000";
						y_state <= y_state + "0000001";
						if(y_state = "1111001") then
							reset2fsm <= '1';
							y_state <= "0000000";
						else
							reset2fsm <= '0';
						end if;	
					else
					
						if(x_state = "00000101")then -- 5 use a diff color
							if((y_state > p1_top) and (y_state <(p1_top+10)))then
								colour <= "001";
							end if;
						elsif(x_State = "00101101")then--70
							if(y_state > p2_top and y_state <(p2_top+10))then
								colour <= "001";
							end if;
						elsif(x_State = "01101001")then--105
							if(y_state > p3_top and y_state <(p3_top+10))then
								colour <= "011";
							end if;
						elsif(x_state = "10011010")then--154
							if(y_state > p4_top and y_state <(p4_top+10))then
								colour <= "011";
							end if;						
						else
							colour <= "000";
						end if;
						
						x <= std_logic_vector( x_state);
						x_state <= x_state + "00000001";
					end if;
					
					if(y_state = "0000000" or y_state = "1110111")then --make the top an bottom line white 
						colour <= "111";
					end if;
					
					y<=std_logic_vector( y_state);
					x0:= "001010000";
					y0:= "00111100";
					
		elsif(draw2dp = '1' and rising_edge(clock))then	
			plot <= '0';
			x_state <= "00000001";
			y_state <= "0000000";
					if (x_state = "00000000") then
						if(y_state = "0000000" or y_state = "1110111")then --make the top an bottom line white 
							colour <="111";
						else
							colour <="000";
						end if;
						x <= std_logic_vector(x_state);
						
					--choose colour
						if(x_state = "00000101")then -- 5 use a diff color
							if(y_state > p1_top and y_state <(p1_top+10))then
								colour <= "001";
							end if;
						elsif(x_State = "00101101")then--70
							if(y_state > p2_top and y_state <(p2_top+10))then
								colour <= "001";
							end if;
						elsif(x_State = "01101001")then--105
							if(y_state > p3_top and y_state <(p3_top+10))then
								colour <= "011";
							end if;
						elsif(x_state = "10011010")then--154
							if(y_state > p4_top and y_state <(p4_top+10))then
								colour <= "011";
							end if;						
						else
							colour <= "000";
						end if;
						
						x_state <= x_state+ "00000001";
					elsif (x_state = "10011111") then
						x <= std_logic_vector(x_state);
						x_state <= "00000000";
						y_state <= y_state + "0000001";
						if(y_state = "1111001") then
							draw2fsm <= '1';
						else
							draw2fsm <= '0';
						end if;	
					else
						x <= std_logic_vector( x_state);
						x_state <= x_state + "00000001";
					end if;
					y<=std_logic_vector( y_state);
					
		end if;
	end process;
END Behavioural;
