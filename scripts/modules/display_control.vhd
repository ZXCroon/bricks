library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.geometry.all;
use work.info.all;
use work.img_coding.all;
use work.basic_settings.all;
use work.interface_coding.all;

entity display_control is
	port(
		clk_100m: in std_logic;
		rst: in std_logic;
		
		grids_map: in std_logic_vector(0 to (GRIDS_BITS - 1));
		plate: in plate_info;
		ball: in ball_info;
		card_xy: in card_info;
		buff: in buff_info;
		game_flag: in interface_type;
		
		ask_x: out std_logic_vector(9 downto 0);
		ask_y: out std_logic_vector(8 downto 0);
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
			next_x: out std_logic_vector(9 downto 0);
			next_y: out std_logic_vector(8 downto 0);
			r_out, g_out, b_out: out std_logic_vector(2 downto 0)
		);
	end component;
	
	component img_reader 
		port (
			x: in std_logic_vector(9 downto 0);
			y: in std_logic_vector(8 downto 0);
			img: in img_info;
			inclk: in std_logic;
			clken: in std_logic;
			r, g, b: out std_logic_vector(2 downto 0);
			dataok: out std_logic := '0'
		);
	end component;
	
	component draw_bricks
		port(
			x: in std_logic_vector(9 downto 0);
			y: in std_logic_vector(8 downto 0);
			grids_map: in std_logic_vector(0 to (GRIDS_BITS - 1));
			
			inside_which: out std_logic_vector(0 to (GRID_BITS - 1));
			x_r: out std_logic_vector(9 downto 0);
			y_r: out std_logic_vector(8 downto 0)
		);
	end component;
	
	signal clk_25m: std_logic;
	
	signal now_x: std_logic_vector(9 downto 0);
	signal now_y: std_logic_vector(8 downto 0);
	signal next_x: std_logic_vector(9 downto 0);
	signal next_y: std_logic_vector(8 downto 0);
	signal next_x_r: std_logic_vector(9 downto 0);
	signal next_y_r: std_logic_vector(8 downto 0);
	signal next_x_r_b: std_logic_vector(9 downto 0);
	signal next_y_r_b: std_logic_vector(8 downto 0);
	signal now_r, now_g, now_b: std_logic_vector(2 downto 0);
	signal next_r, next_g, next_b: std_logic_vector(2 downto 0);
	signal inside_which: std_logic_vector(0 to (GRID_BITS - 1));
	signal zeros: std_logic_vector(0 to (GRID_BITS - 1));
	signal img: img_info;

begin
	u0: vga_control port map(clk_25m, rst, now_r, now_g, now_b, hs, vs, now_x, now_y, next_x, next_y, r_out, g_out, b_out);
	u1: draw_bricks port map(next_x, next_y, grids_map, inside_which, next_x_r_b, next_y_r_b);
	u2: img_reader port map(next_x_r, next_y_r, img, clk_100m, '1', now_r, now_g, now_b, clk_25m);
	
	ask_x <= next_x;
	ask_y <= next_y;
	zeros <= (others => '0');

	process(next_x, next_y)
	begin
		img <= bg_texture;
		next_x_r <= conv_std_logic_vector(conv_integer(next_x) rem 20, 10);
		next_y_r <= conv_std_logic_vector(conv_integer(next_y) rem 20, 9);
		
		-- ball --
		if (distance2(construct_point(conv_integer(next_x), conv_integer(next_y)), ball.position) * 4 <=
		    ball.radius * ball.radius * 4 + 26) then
			next_x_r <= next_x - (ball.position(0) - ball.radius);
			next_y_r <= next_y - (ball.position(1) - ball.radius);
			case buff is
				when smaller => img <= ball_small;
				when bigger  => img <= ball_big;
				when others  => img <= ball_normal;
			end case;
		end if;
		
		-- bricks --
		if (inside_which /= zeros) then
			img <= brick1;
			next_x_r <= next_x_r_b;
			next_y_r <= next_y_r_b;
		end if;
		
		-- plate --
		if (next_x >= conv_std_logic_vector(plate.l_position(0), 10) and
	       next_x <= conv_std_logic_vector(plate.l_position(0) + plate.len, 10) and
		    next_y >= conv_std_logic_vector(plate.l_position(1), 9) and
			 next_y <= conv_std_logic_vector(plate.l_position(1) + PLATE_WIDTH, 9)) then
--			 case buff is
			img <= plate_normal;
			next_x_r <= next_x - plate.l_position(0);
			next_y_r <= next_y - plate.l_position(1);
		end if;
		
		-- card --
		if (card_xy.buff /= none) then
			case card_xy.buff is
				when smaller => img <= card_smaller;
				when bigger => img <= card_bigger;
				when others => img <= card_smaller;
			end case;
			next_x_r <= next_x - card_xy.lt_position(0);
			next_y_r <= next_y - card_xy.lt_position(1);
		end if;
		
		-- ball --
		if (distance2(construct_point(conv_integer(next_x), conv_integer(next_y)), ball.position) <=
		    ball.radius * ball.radius) then
			next_x_r <= next_x - (ball.position(0) - ball.radius);
			next_y_r <= next_y - (ball.position(1) - ball.radius);
			case buff is
				when smaller => img <= ball_small;
				when bigger  => img <= ball_big;
				when others  => img <= ball_normal;
			end case;
		end if;

		-- menu --
		case game_flag is
			when ui_menu=>
				if(next_x>=170 and next_x<170+300
				and next_y>=168 and next_y<168+144) then
					img <= img_menu;
					next_x_r <= next_x-170;
					next_y_r <= next_y-168;
				else
					img <= bg_texture;
					next_x_r <= (others=>'0');
					next_y_r <= (others=>'0');
				end if;
			when ui_pause =>
				if (next_x >= 220 and next_x < 420 and next_y >= 180 and next_y < 267) then
					img <= img_pause;
					next_x_r <= next_x - 220;
					next_y_r <= next_y - 180;
				end if;
			when ui_gameover =>
				if (next_x >= 220 and next_x < 420 and next_y >= 180 and next_y < 267) then
					img <= img_over;
					next_x_r <= next_x - 220;
					next_y_r <= next_y - 180;
				end if;
			when others => null;
		end case;
	end process;
	
end bhv;