library IEEE;
use IEEE.std_logic_1164.all;

package key_coding is
	subtype KeyVector is std_logic_vector(7 downto 0);
	-- with E0 prefix
	constant key_up: keyVector := x"75";
	constant key_down: keyVector := x"72";
	constant key_left: keyVector := x"6b";
	constant key_right: keyVector := x"74";
	-- without
	constant key_lshift: KeyVector := x"12";
	constant key_z: KeyVector := x"1a";
	constant key_x: KeyVector := x"22";
	constant key_esc: KeyVector := x"76";
	constant key_break: KeyVector := x"f0";
	constant key_e0: KeyVector := x"e0";
end key_coding;