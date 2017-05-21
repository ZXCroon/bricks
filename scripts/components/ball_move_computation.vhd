library ieee;
use ieee.std_logic_1164.all;
use work.geometry.all;
use work.info.all;

entity ball_move_computation is
	port(
		clk: in std_logic;
		ena: in std_logic;
		ball: in ball_info;
		velocity: in vector;
		set: out std_logic;
		ball_next: out ball_info
	);
end ball_move_computation;

architecture bhv of ball_move_computation is
	signal velocity_abs: vector;
	signal delta_x, delta_y: vector;
	signal set_t: std_logic := '0';
begin
	set <= set_t;
	
	velocity_abs(0) <= velocity(0) when velocity(0) >= 0 else -velocity(0);
	velocity_abs(1) <= velocity(1) when velocity(1) >= 0 else -velocity(1);
	delta_x <= construct_vector(1, 0) when velocity(0) >= 0 else construct_vector(-1, 0);
	delta_y <= construct_vector(0, 1) when velocity(0) >= 0 else construct_vector(0, -1);
	
	process(clk)
		variable x_cnt, y_cnt: integer := 0;
	begin
		if (clk'event and clk = '1') then
			if (ena = '0') then
				ball_next <= ball;
			else
				if (x_cnt >= velocity_abs(0) - 1 and y_cnt >= velocity_abs(1) - 1) then
					x_cnt := 0;
					y_cnt := 0;
					ball_next <= construct_ball_info(ball.radius, ball.position + delta_x + delta_y);
				else
					if (x_cnt >= velocity_abs(0) - 1) then
						x_cnt := 0;
						ball_next <= construct_ball_info(ball.radius, ball.position + delta_x);
					else
						x_cnt := x_cnt + 1;
						ball_next <= ball;
					end if;
					
					if (y_cnt >= velocity_abs(1) - 1) then 
						y_cnt := 0;
						ball_next <= construct_ball_info(ball.radius, ball.position + delta_y);
					else
						y_cnt := y_cnt + 1;
						ball_next <= ball;
					end if;
				end if;
				set_t <= '1';
			end if;
		end if;
	end process;
end bhv;