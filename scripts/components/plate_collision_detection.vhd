library ieee;
use ieee.std_logic_1164.all;
use work.geometry.all;
use work.basic_settings.all;
use work.info.all;

entity plate_collision_detection is
	port(
		plate: in plate_info;
		ball: in ball_info;
		collision: out collision_info;
		fall_out: out boolean
	);
end plate_collision_detection;

architecture bhv of plate_collision_detection is
	signal top_side, inside_x_range: boolean;
	signal l_corner, r_corner: boolean;
	signal radius2: integer;
begin
	top_side <= ((plate.l_position(1) - ball.position(1)) <= ball.radius);
	inside_x_range <= (ball.position(0) >= plate.l_position(0) and
	                   ball.position(0) <= plate.l_position(0) + plate.len);
	
	radius2 <= ball.radius * ball.radius;
	l_corner <= distance2(plate.l_position, ball.position) <= radius2;
	r_corner <= distance2(plate.l_position + construct_vector(plate.len, 0), ball.position) <= radius2;
	collision <= corner when (l_corner or r_corner) else
	             horizontal when (top_side and inside_x_range) else none;
	fall_out <= (ball.position(1) > plate.l_position(1));
end bhv;