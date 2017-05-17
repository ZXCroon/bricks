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
	
	function construct_ball_info(radius_0: integer; position_0: point) return ball_info;
	function construct_brick_info(lt_position_0: point; class_0: std_logic_vector) return brick_info;
	function construct_plate_info(l_position_0: point; len_0, class_0: integer) return plate_info;
end info;

package body info is


function construct_ball_info(radius_0: integer; position_0: point) return ball_info is
	variable ball_info_0: ball_info;
begin
	ball_info_0.radius := radius_0;
	ball_info_0.position := position_0;
	return ball_info_0;
end construct_ball_info;

function construct_brick_info(lt_position_0: point; class_0: std_logic_vector) return brick_info is
	variable brick_info_0: brick_info;
begin
	brick_info_0.lt_position := lt_position_0;
	brick_info_0.class := class_0;
	return brick_info_0;
end construct_brick_info;

function construct_plate_info(l_position_0: point; len_0, class_0: integer) return plate_info is
	variable plate_info_0: plate_info;
begin
	plate_info_0.l_position := l_position_0;
	plate_info_0.len := len_0;
	plate_info_0.class := class_0;
	return plate_info_0;
end construct_plate_info;


end info;