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
		card_double,
		card_invisible,
		card_longer,
		card_shoot,
		card_shorter,
		card_smaller,
		card_traversal,
		card_wiggle,
		img_menu,
		plate_long,
		plate_normal,
		plate_shoot,
		plate_short,
		start
	);
	type img_info2integer is array(img_info) of integer;
	constant offset_dic: img_info2integer := (
		ball_big => 0,
		ball_normal => 576,
		ball_small => 832,
		ball_traversal => 976,
		bg_texture => 1232,
		brick1 => 1632,
		brick2 => 2232,
		brick3 => 2832,
		brick4 => 3432,
		card_bigger => 4032,
		card_death => 4432,
		card_double => 4832,
		card_invisible => 5232,
		card_longer => 5632,
		card_shoot => 6032,
		card_shorter => 6432,
		card_smaller => 6832,
		card_traversal => 7232,
		card_wiggle => 7632,
		img_menu => 8032,
		plate_long => 51232,
		plate_normal => 51882,
		plate_shoot => 52382,
		plate_short => 52882,
		start => 53232
	);
	constant width_dic: img_info2integer := (
		ball_big => 24,
		ball_normal => 16,
		ball_small => 12,
		ball_traversal => 16,
		bg_texture => 20,
		brick1 => 40,
		brick2 => 40,
		brick3 => 40,
		brick4 => 40,
		card_bigger => 20,
		card_death => 20,
		card_double => 20,
		card_invisible => 20,
		card_longer => 20,
		card_shoot => 20,
		card_shorter => 20,
		card_smaller => 20,
		card_traversal => 20,
		card_wiggle => 20,
		img_menu => 300,
		plate_long => 130,
		plate_normal => 100,
		plate_shoot => 100,
		plate_short => 70,
		start => 300
	);
end img_coding;