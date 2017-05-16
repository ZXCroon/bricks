library ieee;
use ieee.std_logic_1164.all;
use work.geometry.all;
use work.basic_settings.all;
use work.info.all;

entity wall_collision_detection is
	port(
		ball: in ball_info;
		collision: out collision_info
	);
end wall_collision_detection;

architecture bhv of wall_collision_detection is
	signal left_side, right_side, ceiling: boolean := false;
begin
	left_side <= (ball.position(0) <= ball.radius);
	right_side <= (SCREEN_WIDTH - ball.position(0) <= ball.radius);
	ceiling <= (ball.position(1) <= ball.radius);
	collision <= corner when (ceiling and (left_side or right_side)) else
	             horizontal when ceiling else
					 vertical when (left_side or right_side) else
					 none;
end bhv;