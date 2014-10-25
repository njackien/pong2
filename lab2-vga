library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab2vga is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
		 LEDG						: out  std_logic_vector(7 downto 0);
       VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);  -- The outs go to VGA controller
       VGA_HS              : out std_logic;
       VGA_VS              : out std_logic;
       VGA_BLANK           : out std_logic;
       VGA_SYNC            : out std_logic;
       VGA_CLK             : out std_logic);
end lab2vga;




architecture rtl of lab2vga is

 --Component from the Verilog file: vga_adapter.v

  component vga_adapter
    generic(RESOLUTION : string);
    port (resetn                                       : in  std_logic;
          clock                                        : in  std_logic;
          colour                                       : in  std_logic_vector(2 downto 0);
          x                                            : in  std_logic_vector(7 downto 0);
          y                                            : in  std_logic_vector(6 downto 0);
          plot                                         : in  std_logic;
          VGA_R, VGA_G, VGA_B                          : out std_logic_vector(9 downto 0);
          VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK : out std_logic);
  end component;

  component FSM
    port (CLOCK            : in  std_logic;
			resetn				: in 	std_logic;
			Draw_now 			: in	std_logic;
			reset2dp			: out std_logic;
			reset2fsm			: in std_logic; -- from dp saying finish reset
			draw2dp			: out std_logic;
			draw2fsm			: in std_logic;
			player_win 		:in std_logic );--someone wins
	end component;
  
component Datapath
    port (
		clock 				: in std_logic;
		reset2dp				: in std_logic;	
		reset2fsm			: out std_logic;		
		draw2dp				: in std_logic;
		draw2fsm			: out std_logic;
		P1_sw				: in std_logic; -- signals from sw to control paddles
		P2_sw				: in std_logic;
		P3_sw				: in std_logic;
		P4_sw				: in std_logic;
		player_win 		: out std_logic;
		green					: out std_logic_vector(7 downto 0);
		colour				: out std_logic_vector(2 downto 0);
		x						: out std_logic_vector(7 downto 0);
		y 						: out std_logic_vector(6 downto 0);
		plot					: out std_logic);
end component;

  signal x      : std_logic_vector(7 downto 0);
  signal y      : std_logic_vector(6 downto 0);
  signal colour : std_logic_vector(2 downto 0);
  signal plot   : std_logic;
	signal sw_int : std_logic_vector(17 downto 0);
	signal y_int : std_logic_vector(6 downto 0);
	signal x_int : std_logic_vector(7 downto 0);

	signal reset_int			:  std_logic;
	signal reset2fsm_sig		:  std_logic;
	signal draw2dp_int		:  std_logic;
	signal draw2fsm_int	:  std_logic;
	signal player_win_sig	:std_logic;
	

begin
  -- includes the vga adapter, which should be in your project 

  vga_u0 : vga_adapter
    generic map(RESOLUTION => "160x120") 
    port map(resetn    => KEY(3),
             clock     => CLOCK_50,
             colour    => colour,
             x         => x,
             y         => y,
             plot      => plot,
             VGA_R     => VGA_R,
             VGA_G     => VGA_G,
             VGA_B     => VGA_B,
             VGA_HS    => VGA_HS,
             VGA_VS    => VGA_VS,
             VGA_BLANK => VGA_BLANK,
             VGA_SYNC  => VGA_SYNC,
             VGA_CLK   => VGA_CLK);

	FSM_U1 : FSM
		port map(
				CLOCK          => CLOCK_50,
				resetn			=> KEY(3),
				Draw_now 		=> KEY(0),
				reset2dp			=> reset_int,
				reset2fsm 		=> reset2fsm_sig,
				draw2dp			=> draw2dp_int,
				draw2fsm			=> draw2fsm_int,
				player_win 		=> player_win_sig);
				
	Datapath_U2 : Datapath
		port map(
				clock					=>cloCK_50,
				reset2dp				=>reset_int,
				reset2fsm 		=> reset2fsm_sig,
				draw2dp				=>draw2dp_int,
				draw2fsm			=>draw2fsm_int,
				P1_sw				=> sw(0),
				P2_sw				=> sw(1),
				P3_sw				=> sw(16),
				P4_sw				=> sw(17),
				player_win		=> player_win_sig,
				colour				=> colour,
				green					=>LEDG,
				x						=>x,
				y 						=>y,
				plot					=>plot);
  -- rest of your code goes here, as well as possibly additional files


end RTL;


