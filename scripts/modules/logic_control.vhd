library ieee;
use ieee.std_logic_1164.all;
use work.geometry.all;
use work.info.all;
use work.basic_settings.all;

entity logic_control is
	port(
		clk: in std_logic;
		ena: in std_logic;
		plate_move: in integer;
		current_grids_map: in std_logic_vector(0 to (GRIDS_BITS - 1));
		current_plate: in plate_info;
		current_velocity: in vector;
		current_ball: in ball_info;
		
		next_grids_map: out std_logic_vector(0 to (GRIDS_BITS - 1));
		next_plate: out plate_info;
		next_velocity: out vector;
		next_ball: out ball_info;
		fall_out: out std_logic
	);
end logic_control;

architecture bhv of logic_control is
	component collision_computation
		port(
			grids_map: in std_logic_vector(0 to (GRIDS_BITS - 1));
			ball: in ball_info;
			plate: in plate_info;
			current_velocity: in vector;
			hit_map: out std_logic_vector(0 to (GRIDS_AMOUNT - 1));
			next_velocity: out vector;
			fall_out: out std_logic
		);
	end component;
	
	component transfer
		port(
			clk: in std_logic;
			ena: in std_logic;
			ball: in ball_info;
			velocity: in vector;
			plate: in plate_info;
			plate_move: in integer;
			grids_map: in std_logic_vector(0 to (GRIDS_BITS - 1));
			ball_next: out ball_info;
			velocity_trans: out vector;
			plate_next: out plate_info;
			grids_map_trans: out std_logic_vector(0 to (GRIDS_BITS - 1));
			ball_moved: out std_logic
		);
	end component;
	
	signal next_ball_t: ball_info;
	signal next_velocity_t: vector;
	signal next_plate_t: plate_info;
	signal ball_moved: std_logic;
	signal hit_map: std_logic_vector(0 to (GRIDS_AMOUNT - 1));
	signal current_velocity_trans: vector;
	signal current_grids_map_trans: std_logic_vector(0 to (GRIDS_BITS - 1));
begin
	u: collision_computation port map(current_grids_map_trans, next_ball_t, next_plate_t, current_velocity_trans,
	                                  hit_map, next_velocity_t, fall_out);
	gen_next_grids_map:
	for k in 0 to GRIDS_AMOUNT - 1 generate
		next_grids_map((k * GRID_BITS) to (k * GRID_BITS + GRID_BITS - 1)) <= (others => '0') when hit_map(k) = '1' else
				current_grids_map_trans((k * GRID_BITS) to (k * GRID_BITS + GRID_BITS - 1));
	end generate gen_next_grids_map;
	
	u_trans: transfer port map(
		clk, ena, current_ball, current_velocity, current_plate, plate_move, current_grids_map,
		next_ball_t, current_velocity_trans, next_plate_t, current_grids_map_trans, ball_moved
	);
	next_velocity <= next_velocity_t when ball_moved = '1' else current_velocity_trans;
	next_ball <= next_ball_t;
	next_plate <= next_plate_t;
end bhv;