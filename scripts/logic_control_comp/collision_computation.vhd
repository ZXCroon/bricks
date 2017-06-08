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
		plate_move: in integer;
		current_velocity: in vector;
		have_shadow: in std_logic;
		shadow_dir: in std_logic;
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
		variable now_collision: collision_info;
	begin
		now_collision := none;
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
		
	function velocity_change(velocity: vector; force: integer) return vector is
		variable v_x, v_x_1: integer;
	begin
		if (force = 0) then
			return velocity;
		end if;
		v_x := velocity(0);
		if (v_x = 0) then
			v_x_1 := force * 3;
		elsif (v_x > 0) then
			if (force > 0) then
				-- TODO: change according to force --
				v_x_1 := v_x * 7 / 8;
			else
				v_x_1 := v_x + (250 + force) / 2;
			end if;
		else
			if (force < 0) then
				v_x_1 := v_x * 3 / 4;
			else
				v_x_1 := v_x - (150 - force) / 2;
			end if;
		end if;
		if (v_x_1 >= 0 and v_x_1 < MIN_VELOCITY_VALUE_X) then
			v_x_1 := MIN_VELOCITY_VALUE_X;
		elsif (v_x_1 <= 0 and v_x_1 > -MIN_VELOCITY_VALUE_X) then
			v_x_1 := -MIN_VELOCITY_VALUE_X;
		end if;
		
		return construct_vector(v_x_1, velocity(1));
	end velocity_change;
	
	signal plate_shadow: plate_info;
	signal shadow_x: integer;
	signal bricks: bricks_info;
	signal collisions: collisions_info;
	signal plate_collision, plate_collision_1, plate_collision_2, plate_shadow_collision, wall_collision: collision_info;
	signal summarized_collision: collision_info;
	signal next_velocity_t: vector;
	signal fall_out_bool, fall_out_bool_1, fall_out_bool_2: boolean;
	
begin
	summarized_collision <= summarize_collisions(collisions, plate_collision, wall_collision);
	u0: reflection_computation port map(current_velocity, summarized_collision, next_velocity_t);
	
	next_velocity <= next_velocity_t when (plate_collision /= horizontal or wall_collision /= none) else
	                 velocity_change(next_velocity_t, plate_move);
	
	gen_computing_blocks: for k in 0 to GRIDS_AMOUNT - 1 generate
		bricks(k) <= construct_brick_info(construct_point(GRIDS_LT_X + k rem GRIDS_COLUMNS * BRICK_WIDTH,
		                                                  GRIDS_LT_Y + k / GRIDS_COLUMNS * BRICK_HEIGHT),
													 grids_map((k * GRID_BITS) to (k * GRID_BITS + GRID_BITS - 1)));
		u1: collision_detection port map(bricks(k), ball, collisions(k));
		hit_map(k) <= '0' when collisions(k) = none else '1';
	end generate gen_computing_blocks;
	
	shadow_x <= plate.l_position(0) + 200 when shadow_dir = '1' else plate.l_position(0) - 200;
	plate_shadow <= construct_plate_info(construct_point(shadow_x, plate.l_position(1)), plate.len, plate.class);
	
	u1_1: plate_collision_detection port map(plate, ball, plate_collision_1, fall_out_bool_1);
	u1_1_s: plate_collision_detection port map(plate_shadow, ball, plate_collision_2, fall_out_bool_2);
	u1_2: wall_collision_detection port map(ball, wall_collision);
	
	plate_collision <= plate_collision_1 when plate_collision_1 /= none else
	                   plate_collision_2 when plate_collision_2 /= none and have_shadow = '1' else
							 none;
	
	fall_out_bool <= fall_out_bool_1 and (have_shadow = '0' or fall_out_bool_2);
	fall_out <= '1' when fall_out_bool else '0';
end bhv;