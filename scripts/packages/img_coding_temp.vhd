library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

package img_coding is
	type img_info is (
{img_info}
	);
	type img_info2integer is array(img_info) of integer;
	constant offset_dic: img_info2integer := (
{dic}
	);
end img_coding;