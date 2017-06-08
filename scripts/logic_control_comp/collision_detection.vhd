library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.geometry.all;
use work.basic_settings.all;
use work.info.all;

entity collision_detection is
	port(
		brick: in brick_info;
		ball: in ball_info;
		bullet: in std_logic_vector(0 to 1);
		bullet_x, bullet_y: in integer;
		bullet_hit: out std_logic_vector(0 to 1);
		collision: out collision_info
	);
end collision_detection;

architecture bhv of collision_detection is
	signal left_side, right_side, top_side, bottom_side, inside_x_range, inside_y_range: boolean := false;
	signal lt_corner, rt_corner, lb_corner, rb_corner: boolean := false;
	signal zeros: std_logic_vector(0 to (GRID_BITS - 1));
	signal radius2: integer;
begin
	left_side <= (brick.lt_position(0) - ball.position(0) = ball.radius);
	right_side <= (ball.position(0) - (brick.lt_position(0) + BRICK_WIDTH) = ball.radius);
	top_side <= (brick.lt_position(1) - ball.position(1) = ball.radius);
	bottom_side <= (ball.position(1) - (brick.lt_position(1) + BRICK_HEIGHT) = ball.radius);
	inside_x_range <= (ball.position(0) >= brick.lt_position(0) and
	                   ball.position(0) <= brick.lt_position(0) + BRICK_WIDTH);
	inside_y_range <= (ball.position(1) >= brick.lt_position(1) and
	                   ball.position(1) <= brick.lt_position(1) + BRICK_HEIGHT);
	radius2 <= ball.radius * ball.radius;
	lt_corner <= distance2(brick.lt_position, ball.position) <= radius2;
	rt_corner <= distance2(brick.lt_position + construct_vector(BRICK_WIDTH, 0), ball.position) <= radius2;
	lb_corner <= distance2(brick.lt_position + construct_vector(0, BRICK_HEIGHT), ball.position) <= radius2;
	rb_corner <= distance2(brick.lt_position + construct_vector(BRICK_WIDTH, BRICK_HEIGHT), ball.position) <= radius2;
	
	zeros <= (others => '0');
	collision <= none when (brick.class = zeros) else
	             vertical when ((left_side or right_side) and inside_y_range) else
	             horizontal when ((top_side or bottom_side) and inside_x_range) else
					 corner when (lt_corner or rt_corner or lb_corner or rb_corner) else none;
	
	bullet_hit(0) <= '1' when
	(bullet(0) = '1' and bullet_x >= brick.lt_position(0) and bullet_x <= brick.lt_position(0) + BRICK_WIDTH and
	 bullet_y >= brick.lt_position(1) and bullet_y <= brick.lt_position(1) + BRICK_HEIGHT and brick.class /= zeros)
	else '0';
	bullet_hit(1) <= '1' when
	(bullet(1) = '1' and bullet_x + NORMAL_PLATE_LEN >= brick.lt_position(0) and bullet_x + NORMAL_PLATE_LEN <= brick.lt_position(0) + BRICK_WIDTH and
	 bullet_y >= brick.lt_position(1) and bullet_y <= brick.lt_position(1) + BRICK_HEIGHT and brick.class /= zeros)
	else '0';

--	bullet_hit <= "00" when bullet_x > -1 and bullet_y < 800 else "11";
end bhv;