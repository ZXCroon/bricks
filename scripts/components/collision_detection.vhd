library ieee;
use ieee.std_logic_1164.all;
use work.geometry.all;
use work.basic_settings.all;
use work.info.all;

entity collision_detection is
	port(
		brick: in brick_info;
		ball: in ball_info;
		collision: out collision_info
	);
end collision_detection;

architecture bhv of collision_detection is
	signal left_side, right_side, top_side, bottom_side, inside_x_range, inside_y_range: boolean := false;
	signal or_sum: std_logic_vector(0 to (GRID_BITS - 1));
begin
	left_side <= (brick.lt_position(0) - ball.position(0) <= ball.radius);
	right_side <= (ball.position(0) - (brick.lt_position(0) + BRICK_WIDTH) <= ball.radius);
	top_side <= (brick.lt_position(1) - ball.position(1) <= ball.radius);
	bottom_side <= (ball.position(1) - (brick.lt_position(1) + BRICK_HEIGHT) <= ball.radius);
	inside_x_range <= (ball.position(0) >= brick.lt_position(0) and
	                   ball.position(0) <= brick.lt_position(0) + BRICK_WIDTH);
	inside_y_range <= (ball.position(1) >= brick.lt_position(1) and
	                   ball.position(1) <= brick.lt_position(1) + BRICK_HEIGHT);
	
	or_sum(0) <= brick.class(0);
	gen_or_sum: for k in 1 to GRID_BITS - 1 generate
		or_sum(k) <= or_sum(k - 1) and brick.class(k);
	end generate gen_or_sum;
	
	collision <= none when (or_sum(GRID_BITS - 1) = '0') else
	             horizontal when ((left_side or right_side) and inside_y_range) else
	             vertical when ((top_side or bottom_side) and inside_x_range) else none;
	-- corner-collision --
	
end bhv;