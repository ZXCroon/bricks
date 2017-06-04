library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

package img_coding is
	type img_info is (
		ball_big,
		ball_normal,
		ball_small,
		ball_traversal,
		bg_texture,
		brick1,
		brick2,
		brick3,
		brick4,
		card_bigger,
		card_death,
		card_longer,
		card_shorter,
		card_smaller,
		card_traversal,
		card_wiggle,
		plate_long,
		plate_normal,
		plate_short,
		start
	);
	type img_info2integer is array(img_info) of integer;
	constant offset_dic: img_info2integer := (
		ball_big => 0,
		ball_normal => 576,
		ball_small => 832,
		ball_traversal => 896,
		bg_texture => 1152,
		brick1 => 1552,
		brick2 => 2152,
		brick3 => 2752,
		brick4 => 3352,
		card_bigger => 3952,
		card_death => 4352,
		card_longer => 4752,
		card_shorter => 5152,
		card_smaller => 5552,
		card_traversal => 5952,
		card_wiggle => 6352,
		plate_long => 6752,
		plate_normal => 7402,
		plate_short => 7902,
		start => 8252
	);
	constant width_dic: img_info2integer := (
		ball_big => 24,
		ball_normal => 16,
		ball_small => 8,
		ball_traversal => 16,
		bg_texture => 20,
		brick1 => 40,
		brick2 => 40,
		brick3 => 40,
		brick4 => 40,
		card_bigger => 20,
		card_death => 20,
		card_longer => 20,
		card_shorter => 20,
		card_smaller => 20,
		card_traversal => 20,
		card_wiggle => 20,
		plate_long => 130,
		plate_normal => 100,
		plate_short => 70,
		start => 300
	);
end img_coding;