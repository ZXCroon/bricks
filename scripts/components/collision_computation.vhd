library ieee;
use ieee.std_logic_1164.all;
use work.geometry.all;
use work.basic_settings.all;
use work.info.all;

entity collision_computation is
	port(
		grids_map: in std_logic_vector(0 to (GRIDS_BITS - 1));
		ball: in ball_info;
		plate: in plate_info;
		current_velocity: in vector;
		hit_map: out std_logic_vector(0 to (GRIDS_AMOUNT - 1));
		next_velocity: out vector;
		fall_out: out std_logic
	);
end collision_computation;

architecture bhv of collision_computation is
	component collision_detection
		port(
			brick: in brick_info;
			ball: in ball_info;
			collision: out collision_info
		);
	end component;
	
	component plate_collision_detection
		port(
			plate: in plate_info;
			ball: in ball_info;
			collision: out collision_info;
			fall_out: out boolean
		);
	end component;
	
	component wall_collision_detection
		port(
			ball: in ball_info;
			collision: out collision_info
		);
	end component;
	
	component reflection_computation
		port(
			current_velocity: in vector;
			collision: in collision_info;
			next_velocity: out vector
		);
	end component;
	
	type bricks_info is array(0 to (GRIDS_AMOUNT - 1)) of brick_info;
	type collisions_info is array(0 to (GRIDS_AMOUNT - 1)) of collision_info;
	
	function summarize_collisions(collisions: collisions_info;
	                              plate_collision, wall_collision: collision_info) return collision_info is
		variable now_collision: collision_info := none;
	begin
		if (plate_collision /= none) then
			return plate_collision;
		elsif (wall_collision /= none) then
			return wall_collision;
		else
			for k in 0 to collisions'length - 1 loop
				-- hit two corners --
				if (collisions(k) = corner) then
					return corner;
				elsif (collisions(k) = vertical or collisions(k) = horizontal) then
					if (now_collision = none) then
						now_collision := collisions(k);
					else
						return corner;
					end if;
				end if;
			end loop;
			return now_collision;
		end if;
	end summarize_collisions;
	
	signal bricks: bricks_info;
	signal collisions: collisions_info;
	signal plate_collision, wall_collision: collision_info;
	signal summarized_collision: collision_info;
	signal fall_out_bool: boolean;
	
begin
	summarized_collision <= summarize_collisions(collisions, plate_collision, wall_collision);
	u0: reflection_computation port map(current_velocity, summarized_collision, next_velocity);
	
	gen_computing_blocks: for k in 0 to GRIDS_AMOUNT - 1 generate
		bricks(k) <= construct_brick_info(construct_point(GRIDS_LT_X + k rem GRIDS_COLUMNS * BRICK_WIDTH,
		                                                  GRIDS_LT_Y + k / GRIDS_COLUMNS * BRICK_HEIGHT),
													 grids_map((k * 2) to (k * 2 + 1)));
		u1: collision_detection port map(bricks(k), ball, collisions(k));
		hit_map(k) <= '0' when collisions(k) = none else '1';
	end generate gen_computing_blocks;
	
	u1_1: plate_collision_detection port map(plate, ball, plate_collision, fall_out_bool);
	u1_2: wall_collision_detection port map(ball, wall_collision);
	
	fall_out <= '1' when fall_out_bool else '0';
end bhv;