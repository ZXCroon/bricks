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
		bullet: in std_logic_vector(0 to 1);
		score: in integer;
		plate_move: in integer;
		grids_map: in std_logic_vector(0 to (GRIDS_BITS - 1));
		wiggle: in std_logic;
		ball_next: out ball_info;
		velocity_trans: out vector;
		plate_next: out plate_info;
		bullet_trans: out std_logic_vector(0 to 1);
		score_trans: out integer;
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
		variable last_velocity: vector;
		variable wiggle_d: integer := -30;
		variable dir: std_logic := '0';
	begin
		if (clk'event and clk = '1') then
			velocity_trans <= velocity;
			grids_map_trans <= grids_map;
			bullet_trans <= bullet;
			score_trans <= score;
			
			if (ena = '0') then
				ball_next <= ball;
				plate_next <= plate;
				ball_moved <= '0';
			else
				if (last_velocity /= velocity) then
					x_cnt := 0;
					y_cnt := 0;
				end if;
				last_velocity := velocity;
				if (x_cnt = 0 and y_cnt = 0) then
					ball_next <= construct_ball_info(ball.radius, ball.position + delta_x + delta_y);
					ball_moved <= '1';
					
					if (dir = '0') then
						wiggle_d := wiggle_d + 1;
						if (wiggle_d = 30) then
							dir := '1';
						end if;
					else
						wiggle_d := wiggle_d - 1;
						if (wiggle_d = -30) then
							dir := '0';
						end if;
					end if;
				else
					if (x_cnt = 0) then
						ball_next <= construct_ball_info(ball.radius, ball.position + delta_x);
						ball_moved <= '1';
						
						if (dir = '0') then
							wiggle_d := wiggle_d + 1;
							if (wiggle_d = 30) then
								dir := '1';
							end if;
						else
							wiggle_d := wiggle_d - 1;
							if (wiggle_d = -30) then
								dir := '0';
							end if;
						end if;
					elsif (y_cnt = 0) then
						ball_next <= construct_ball_info(ball.radius, ball.position + delta_y);
						ball_moved <= '1';
					else
						ball_next <= ball;
						ball_moved <= '0';
					end if;
				end if;
				x_cnt := x_cnt + 1;
				y_cnt := y_cnt + 1;
				if ((wiggle = '0' and x_cnt >= velocity_abs(0)) or (wiggle = '1' and x_cnt >= velocity_abs(0) + wiggle_d)) then
					x_cnt := 0;
				end if;
				if (y_cnt >= velocity_abs(1)) then
					y_cnt := 0;
				end if;
				
				if (p_cnt = 0) then
					if ((plate.l_position(0) > 0 or plate_move > 0) and
					    (plate.l_position(0) + plate.len < SCREEN_WIDTH or plate_move < 0)) then
						plate_next <= construct_plate_info(plate.l_position + delta, plate.len, plate.class);
					end if;
				else
					plate_next <= plate;
				end if;
				p_cnt := p_cnt + 1;
				if (p_cnt >= plate_move_abs) then
					p_cnt := 0;
				end if;
			end if;
		end if;
	end process;
end bhv;