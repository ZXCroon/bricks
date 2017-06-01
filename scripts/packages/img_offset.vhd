library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

package img_offset is
	constant ball_big_start: integer := 0;
	constant ball_normal_start: integer := 576;
	constant ball_small_start: integer := 832;
	constant ball_traversal_start: integer := 896;
	constant bg_texture_start: integer := 1152;
	constant brick1_start: integer := 1552;
	constant brick2_start: integer := 2152;
	constant brick3_start: integer := 2752;
	constant brick4_start: integer := 3352;
	constant card_bigger_start: integer := 3952;
	constant card_death_start: integer := 4352;
	constant card_longer_start: integer := 4752;
	constant card_shorter_start: integer := 5152;
	constant card_smaller_start: integer := 5552;
	constant card_traversal_start: integer := 5952;
	constant plate_long_start: integer := 6352;
	constant plate_normal_start: integer := 7002;
	constant plate_short_start: integer := 7502;
end img_offset;