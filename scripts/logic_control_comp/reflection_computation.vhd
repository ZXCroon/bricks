library ieee;
use ieee.std_logic_1164.all;
use work.geometry.all;
use work.info.all;

entity reflection_computation is
	port(
		current_velocity: in vector;
		collision: in collision_info;
		next_velocity: out vector
	);
end reflection_computation;

architecture bhv of reflection_computation is
begin
--	with collision select
--		next_velocity <= construct_vector(-current_velocity(0), current_velocity(1)) when vertical,
--		                 construct_vector(current_velocity(0), -current_velocity(1)) when horizontal,
--		                 -current_velocity when corner,
--							  current_velocity when none,
--		                 current_velocity when others;
	
	process(collision)
	begin
		case collision is
			when vertical => next_velocity <= construct_vector(-current_velocity(0), current_velocity(1));
			when horizontal => next_velocity <= construct_vector(current_velocity(0), -current_velocity(1));
			when corner => next_velocity <= -current_velocity;
			when others => next_velocity <= current_velocity;
		end case;
	end process;
end bhv;