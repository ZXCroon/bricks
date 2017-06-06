library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

package img_coding2v is
	type img_info2v is (
		over,
		pause
	);
	type img_info2v2integer is array(img_info2v) of integer;
	constant offset_dic2v: img_info2v2integer := (
		over => 0,
		pause => 17400
	);
	constant width_dic2v: img_info2v2integer := (
		over => 200,
		pause => 200
	);
end img_coding2v;