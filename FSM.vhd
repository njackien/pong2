library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FSM is
  port(CLOCK            : in  std_logic;
       resetn				: in 	std_logic;
		 Draw_now 			: in	std_logic; -- key 0
		
		 reset2dp			: out std_logic; -- to dp telling to reset
		 reset2fsm			: in std_logic; -- from dp saying finish reset
		 
		 draw2dp				: out std_logic; -- tell dp to draw
		 draw2fsm			: in std_logic; -- tell fsm to move from draw idle to draw state		
		 
		 player_win 		:in std_logic --someone wins
		);
end FSM;

architecture behavourial of FSM is
	signal slowclock: std_logic := '0';
begin




process(clock, resetn)
	type state_type is (Idle_State, Draw_State, Draw_idle_state, End_State);	
	variable PRESENT_STATE : state_type := IDLE_State;
	variable NEXT_STATE : state_type;
	 
	begin
		if(resetn = '0') then
			reset2dp <= '1';
			NexT_STATE := idle_State;
		elsif(rising_edge(clock)) then --change state
			case PRESENT_STATE is
			
				when idle_State =>
					if(Draw_now='0')then 
						NexT_STATE:=draw_State; 
					end if; 
					
				when draw_State => 
						NEXT_STATE := draw_State;--draw_idle_state;
				when draw_idle_state =>
					if(draw2fsm ='1')then
						Next_state := draw_State;
					elsif(player_win='1')then 
						Next_state := end_State;
					else
						NEXT_STATE := draw_idle_State;
					end if;
					
				when end_State => if(draw_now = '0')then
											NexT_STATE := Draw_State;
										end if;
					
				when others => NEXT_STATE := idle_State;
			end case;
			
			PRESENT_STATE := NEXT_STATE;
			
			case NEXT_STATE is --outputs for each state
				when idle_State => 
					reset2dp <= '0';
					draw2dp <= '0';
				when draw_State =>
					reset2dp <= '0';
					draw2dp <= '1';
				when draw_idle_state =>	
					reset2dp <= '0';
					draw2dp <= '0';
				when end_State => 
					reset2dp <= '0'; 
					draw2dp <= '0';
					
			end case;
		end if;
end process;


end behavourial;



