library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

package img_coding2v is
	type img_info2v is (
		{img_info2v}
	);
	type img_info2v2integer is array(img_info2v) of integer;
	constant offset_dic2v: img_info2v2integer := (
		{offset}
	);
	constant width_dic2v: img_info2v2integer := (
		{width}
	);
end img_coding2v;