library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.geometry.all;
use work.info.all;
use work.basic_settings.all;

entity display_control is
	port(
		clk: in std_logic;
		rst: in std_logic;
		
		grids_map: in std_logic_vector(0 to (GRIDS_BITS - 1));
		plate: in plate_info;
		ball: in ball_info;
		card_xy: in card_info;
		game_flag: in integer;
		
		x: out std_logic_vector(9 downto 0);
		y: out std_logic_vector(8 downto 0);
		hs, vs: out std_logic;
		r_out, g_out, b_out: out std_logic_vector(2 downto 0)
	);
end display_control;

architecture bhv of display_control is
	component vga_control
		port(
			vga_clk: in std_logic;
			rst: in std_logic;
			
			r_in, g_in, b_in: in std_logic_vector(2 downto 0);
			
			hs, vs: out std_logic;
			x: out std_logic_vector(9 downto 0);
			y: out std_logic_vector(8 downto 0);
			r_out, g_out, b_out: out std_logic_vector(2 downto 0)
		);
	end component;
	
	component draw_bricks
		port(
			x: in std_logic_vector(9 downto 0);
			y: in std_logic_vector(8 downto 0);
			grids_map: in std_logic_vector(0 to (GRIDS_BITS - 1));
			
			inside: out boolean;
			r_out, b_out, g_out: out std_logic_vector(2 downto 0)
		);
	end component;
	
	signal now_x: std_logic_vector(9 downto 0);
	signal now_y: std_logic_vector(8 downto 0);
	signal now_r, now_g, now_b: std_logic_vector(2 downto 0);
	signal now_r_bt, now_g_bt, now_b_bt: std_logic_vector(2 downto 0);
	signal inside_bricks: boolean;
begin
	u0: vga_control port map(clk, rst, now_r, now_g, now_b, hs, vs, now_x, now_y, r_out, g_out, b_out);
	u1: draw_bricks port map(now_x, now_y, grids_map, inside_bricks, now_r_bt, now_g_bt, now_b_bt);
	
	x <= now_x;
	y <= now_y;
	
	process(now_x, now_y)
	begin
		-- background --
		now_r <= "001";
		now_g <= "001";
		now_b <= "001";
		
		-- bricks --
		if (inside_bricks) then
			now_r <= now_r_bt;
			now_g <= now_g_bt;
			now_b <= now_b_bt;
		end if;
		
		-- ball --
		if (distance2(construct_point(conv_integer(now_x), conv_integer(now_y)), ball.position) <=
		    ball.radius * ball.radius) then
			now_r <= "111";
			now_g <= "111";
			now_b <= "111";
		end if;
		
		-- plate --
		if (now_x >= conv_std_logic_vector(plate.l_position(0), 10) and
	       now_x <= conv_std_logic_vector(plate.l_position(0) + plate.len, 10) and
		    now_y >= conv_std_logic_vector(plate.l_position(1), 9) and
			 now_y <= conv_std_logic_vector(plate.l_position(1) + 5, 9)) then
			now_r <= "010";
			now_g <= "101";
			now_b <= "100";
		end if;
		
		-- card --
		if (card_xy.buff /= none) then
			now_r <= "100";
			now_g <= "001";
			now_b <= "001";
		end if;
		
		-- popup --
		
	end process;
end bhv;