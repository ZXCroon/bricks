library ieee;
use ieee.std_logic_1164.all;
use work.geometry.all;
use work.info.all;
use work.basic_settings.all;

entity transfer is
	port(
		clk: in std_logic;
		ena: in std_logic;
		ball: in ball_info;
		velocity: in vector;
		plate: in plate_info;
		plate_move: in integer;
		grids_map: in std_logic_vector(0 to (GRIDS_BITS - 1));
		ball_next: out ball_info;
		velocity_trans: out vector;
		plate_next: out plate_info;
		grids_map_trans: out std_logic_vector(0 to (GRIDS_BITS - 1));
		ball_moved: out std_logic
	);
end transfer;

architecture bhv of transfer is
	signal velocity_abs: vector;
	signal delta_x, delta_y: vector;
	signal plate_move_abs: integer;
	signal delta: vector;
begin	
	velocity_abs(0) <= velocity(0) when velocity(0) >= 0 else -velocity(0);
	velocity_abs(1) <= velocity(1) when velocity(1) >= 0 else -velocity(1);
	delta_x <= construct_vector(1, 0) when velocity(0) > 0 else
	           construct_vector(-1, 0) when velocity(0) < 0 else
				  construct_vector(0, 0);
	delta_y <= construct_vector(0, 1) when velocity(1) > 0 else
	           construct_vector(0, -1) when velocity(1) < 0 else
				  construct_vector(0, 0);
	
	plate_move_abs <= plate_move when plate_move >= 0 else -plate_move;
	delta <= (1, 0) when plate_move > 0 else (-1, 0) when plate_move < 0 else (0, 0);

	process(clk)
		variable x_cnt, y_cnt, p_cnt: integer := 0;
	begin
		if (clk'event and clk = '1') then
			velocity_trans <= velocity;
			grids_map_trans <= grids_map;
			
			if (ena = '0') then
				ball_next <= ball;
				plate_next <= plate;
				ball_moved <= '0';
			else
				if (x_cnt >= velocity_abs(0) - 1 and y_cnt >= velocity_abs(1) - 1) then
					x_cnt := 0;
					y_cnt := 0;
					ball_next <= construct_ball_info(ball.radius, ball.position + delta_x + delta_y);
					ball_moved <= '1';
				else
					if (x_cnt >= velocity_abs(0) - 1) then
						x_cnt := 0;
						ball_next <= construct_ball_info(ball.radius, ball.position + delta_x);
						ball_moved <= '1';
					else
						x_cnt := x_cnt + 1;
						ball_next <= ball;
						ball_moved <= '0';
					end if;
					
					if (y_cnt >= velocity_abs(1) - 1) then 
						y_cnt := 0;
						ball_next <= construct_ball_info(ball.radius, ball.position + delta_y);
						ball_moved <= '1';
					else
						y_cnt := y_cnt + 1;
						ball_next <= ball;
						ball_moved <= '0';
					end if;
				end if;
				
				if (p_cnt >= plate_move_abs - 1) then
					p_cnt := 0;
					if ((plate.l_position(0) > 0 or plate_move > 0) and
					    (plate.l_position(0) + plate.len < SCREEN_WIDTH or plate_move < 0)) then
						plate_next <= construct_plate_info(plate.l_position + delta, plate.len, plate.class);
					else
						plate_next <= plate;
					end if;
				else
					p_cnt := p_cnt + 1;
					plate_next <= plate;
				end if;
			end if;
		end if;
	end process;
end bhv;