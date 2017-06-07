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
	
	type buff_info is (none, smaller, bigger, shorter, longer, death, wiggle, traversal);
	constant BUFF_NUM: integer := 8;
	type card_info is record
		lt_position: point;
		buff: buff_info;
	end record;
	
	function construct_ball_info(radius_0: integer; position_0: point) return ball_info;
	function construct_brick_info(lt_position_0: point; class_0: std_logic_vector) return brick_info;
	function construct_plate_info(l_position_0: point; len_0, class_0: integer) return plate_info;
	function construct_card_info(lt_position_0: point; buff_0: buff_info) return card_info;
	function get_buff(num: integer) return buff_info;
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

function construct_card_info(lt_position_0: point; buff_0: buff_info) return card_info is
	variable card_info_0: card_info;
begin
	card_info_0.lt_position := lt_position_0;
	card_info_0.buff := buff_0;
	return card_info_0;
end construct_card_info;

function get_buff(num: integer) return buff_info is
begin
	case num is
		when 0 => return none;
		when 1 => return smaller;
		when 2 => return bigger;
		when 3 => return shorter;
		when 4 => return longer;
		when 5 => return death;
		when 6 => return wiggle;
		when 7 => return traversal;
		when others => return none;
	end case;
end get_buff;


end info;