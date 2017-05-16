library ieee;
use ieee.std_logic_1164.all;
use work.geometry.all;
use work.basic_settings.all;

package info is
	type ball_info is record
		radius: integer;
		position: point;
	end record;
	
	type brick_info is record
		lt_position: point;
		class: std_logic_vector((GRID_BITS - 1) downto 0);
	end record;
	
	type plate_info is record
		l_position: point;
		len: integer;
		class: integer;
	end record;
	
	type collision_info is (none, vertical, horizontal, corner);
	
	function construct_brick_info(lt_position_0: point; class_0: std_logic_vector) return brick_info;
end info;

package body info is


function construct_brick_info(lt_position_0: point; class_0: std_logic_vector) return brick_info is
	variable brick_info_0: brick_info;
begin
	brick_info_0.lt_position := lt_position_0;
	brick_info_0.class := class_0;
	return brick_info_0;
end construct_brick_info;


end info;