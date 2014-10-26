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
	
	signal p1_top_sig: unsigned (7 downto 0):="00110111";
	signal p2_top_sig: unsigned (7 downto 0):="00110111";
	signal p3_top_sig: unsigned (7 downto 0):="00110111";
	signal p4_top_sig: unsigned (7 downto 0):="00110111";
	
-----------------------------------------------------------------------------------------	
	signal puck_x: unsigned(7 downto 0) := "01010000";												--
	signal puck_y: unsigned(6 downto 0) := "0111100";												--
	signal puck_dir: std_logic_vector( 1 downto 0) := "10";										--	
-----------------------------------------------------------------------------------------
	
	signal slowclock: std_logic:='0';
BEGIN
	--green <= p1_top_sig;

	
		process( CLOCK )
			variable count: unsigned(21 downto 0) := "0000000000000000000000";
			variable loop_count: unsigned(10 downto 0) := "00000000000";
		begin	
		if( CLOCK = '1' ) then
			if( loop_count < "00011000000") then
				if( count = "1001100010010110100000" ) then
					slowclock <= not slowclock;
					count := "0000000000000000000000";
					loop_count := loop_count + 1;
				else
					count := count + 1;
				end if;
			elsif (loop_count < "11111111111") then
				if( count = "0011110100001001000000" ) then
					slowclock <= not slowclock;
					count := "0000000000000000000000";
					loop_count := loop_count + 1;
				else
					count := count + 1;
				end if;
			else
				if( count = "0001111010000100100000" ) then
					slowclock <= not slowclock;
					count := "0000000000000000000000";
				else
					count := count + 1;
				end if;
			end if;
		end if;
		end process;
	

	process(slowclock)
	begin
		if(rising_edge(slowclock) and draw2dp ='1')then
			if(reset2dp ='0')then
				if(p1_sw='1')then
					if(p1_top_sig > "00000000")then
						
						p1_top_sig <= p1_top_sig - "00000001";
					end if;
				elsif(p1_sw='0')then
					if(p1_top_sig < "01101101")then -- 160-10
						
						p1_top_sig <= p1_top_sig + "00000001";
					end if;
				end if;
			else
				p1_top_sig <= "00110111";
			end if;
		end if;
	end process;
	
	process(slowclock)
	begin
		if(rising_edge(slowclock)and draw2dp ='1')then
			if(reset2dp ='0')then
				if(p2_sw='1')then
					if(p2_top_sig > "00000000")then
						
						p2_top_sig <= p2_top_sig - "00000001";
					end if;
				elsif(p2_sw='0')then
					if(p2_top_sig < "01101101")then -- 160-10
						
						p2_top_sig <= p2_top_sig + "00000001";
					end if;
				end if;
			else
				p2_top_sig <= "00110111";
			end if;
		end if;
	end process;

	process(slowclock)
	begin
		
		if(rising_edge(slowclock)and draw2dp ='1')then
			if(reset2dp ='0')then
				if(p3_sw='1')then
					if(p3_top_sig > "00000000")then
						
						p3_top_sig <= p3_top_sig - "00000001";
					end if;
				elsif(p3_sw='0')then
					if(p3_top_sig < "01101101")then -- 160-10
						
						p3_top_sig <= p3_top_sig + "00000001";
					end if;
				end if;
			else
				p3_top_sig <= "00110111";
			end if;
		end if;
	end process;
	
	process(slowclock)
	begin		
		if(rising_edge(slowclock)and draw2dp ='1')then
			if(reset2dp ='0')then
				if(p4_sw='1')then
					if(p4_top_sig > "00000000")then
						
						p4_top_sig <= p4_top_sig - "00000001";
					end if;
				elsif(p4_sw='0')then
					if(p4_top_sig < "01101101")then -- 160-10
						
						p4_top_sig <= p4_top_sig + "00000001";
					end if;
				end if;
			else
				p4_top_sig <= "00110111";
			end if;
		end if;
	end process;
	
	
-----------------------------------------------------------------------------------------	
	process( slowclock )																						--
		variable puck_x_count: unsigned( 7 downto 0) := "01010000";
		variable puck_y_count: unsigned( 6 downto 0) := "0111100";
		begin
			if( draw2dp = '1' ) then
				if( reset2dp = '1') then
					puck_x_count := "01010000";
					puck_y_count := "0111100";
					puck_dir <= "10";
				else
					if( slowclock = '1' ) then
					
						if( puck_x_count = "00000010" ) then
							puck_dir(1) <= '1';
						elsif( puck_x_count = "10011101" ) then
							puck_dir(1) <= '0';
						end if;
						
						if( puck_dir(1) = '1') then
							puck_x_count := puck_x_count + "00000001";
						else
							puck_x_count := puck_x_count - "00000001";
						end if;
						
						if( puck_y_count = "0000010" ) then
							puck_dir(0) <= '1';
						elsif( puck_y_count = "1110101" ) then
							puck_dir(0) <= '0';
						end if;
						
						if( puck_dir(0) = '1') then
							puck_y_count := puck_y_count + "0000001";
						else
							puck_y_count := puck_y_count - "0000001";
						end if;
					
					end if;
				end if;
			end if;
			
			puck_x <= puck_x_count;
			puck_y <= puck_y_count;
				
	end process;																								--
-----------------------------------------------------------------------------------------	
	
	process(reset2dp, draw2dp, clock)
	
		variable p1_top: unsigned (7 downto 0):="00110111";
		variable p2_top: unsigned (7 downto 0):="00110111";
		variable p3_top: unsigned (7 downto 0):="00110111";
		variable p4_top: unsigned (7 downto 0):="00110111";
		variable puck_x_var: unsigned( 7 downto 0) := "01010000";
		variable puck_y_var: unsigned( 6 downto 0) := "0111100";
	begin
		if(reset2dp = '1' and rising_edge(clock))then	--clear screen and set walls
			plot <= '1';
			
--					if(y_state = "0000000" or y_state = "1110111")then --make the top an bottom line white 
--						colour <= "111";
--					end if;	
					
					if (x_state = "00000000" ) then
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
							x_state <= "00000000"; 
						else
							reset2fsm <= '0';
						end if;	
					else
					
						if(x_state = "00000101")then -- 5 use a diff color
							if((y_state > p1_top) and (y_state <(p1_top+10)))then
								colour <= "100";
							end if;
						elsif(x_State = "00101101")then--70
							if(y_state > p2_top and y_state <(p2_top+10))then
								colour <= "100";
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
						
--------------------------------------------------------------------------------------		
						if(x_state = puck_x ) then --puck_x position								--
							if( y_state = puck_y ) then --puck_y position
								colour <="111";
							end if;
						end if;																				--
--------------------------------------------------------------------------------------		
					
						
						x <= std_logic_vector( x_state);
						x_state <= x_state + "00000001";
					end if;
					
					if(y_state = "0000000" or y_state = "1110111")then --make the top an bottom line white 
						colour <= "111";
					end if;
					
					y<=std_logic_vector( y_state);

					
		elsif(draw2dp = '1' and rising_edge(clock))then	
			p1_top:=p1_top_sig;
			p2_top:=p2_top_sig;
			p3_top:=p3_top_sig;
			p4_top:=p4_top_sig;
			puck_x_var:=puck_x;
			puck_y_var:=puck_y;
			plot <= '1';
			--colour <= "000";
--					if(y_state = "0000000" or y_state = "1110111")then --make the top an bottom line white 
--						colour <= "111";
--					end if;	
					
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
							x_state <= "00000000"; 
						else
							reset2fsm <= '0';
						end if;	
					else
					
						if(x_state = "00000101")then -- 5 use a diff color
							if((y_state > p1_top) and (y_state <(p1_top+10)))then
								colour <= "100";
							elsif(x_state = puck_x_var and y_state = puck_y_var) then --puck_x position								--
								colour <="111";
							else
								colour <= "000";
							end if;
						elsif(x_State = "00101101")then--70
							if(y_state > p2_top and y_state <(p2_top+10))then
								colour <= "100";
							elsif(x_state = puck_x_var and y_state = puck_y_var) then --puck_x position								--
								colour <="111";
							else
								colour <= "000";
							end if;
						elsif(x_State = "01101001")then--105
							if(y_state > p3_top and y_state <(p3_top+10))then
								colour <= "011";
							elsif(x_state = puck_x_var and y_state = puck_y_var) then --puck_x position								--
								colour <="111";
							else
								colour <= "000";
							end if;
						elsif(x_state = "10011010")then--154	
							if(y_state > p4_top and y_state <(p4_top+10))then
								colour <= "011";
							elsif(x_state = puck_x_var and y_state = puck_y_var) then --puck_x position								--
								colour <="111";
							else
								colour <= "000";
							end if;	
						else
							if(x_state = puck_x_var and y_state = puck_y_var) then --puck_x position								--
								colour <="111";	
							elsif(x_state = puck_x_var and y_state = puck_y_var) then --puck_x position								--
								colour <="111";	
							else
								colour <= "000";
							end if;		
							
						end if;
						
						x <= std_logic_vector( x_state);
						x_state <= x_state + "00000001";
					end if;
					
					if(y_state = "0000000" or y_state = "1110111")then --make the top an bottom line white 
						colour <= "111";
					end if;
					
					y<=std_logic_vector( y_state);

						
		end if;
	end process;
END Behavioural;
