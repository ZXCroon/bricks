library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

package interface_coding is
	subtype interface_type is integer range 0 to 3;
	constant ui_menu:     interface_type := 0;
	constant ui_gaming:   interface_type := 1;
	constant ui_pause:    interface_type := 2;
	constant ui_gameover: interface_type := 3;

end interface_coding;