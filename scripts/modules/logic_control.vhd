library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
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
		current_bullet: in std_logic_vector(0 to 1);
		bullet_x, bullet_y: integer;
		buff: in buff_info;
		shadow_dir: in std_logic;
		
		next_grids_map: out std_logic_vector(0 to (GRIDS_BITS - 1));
		next_plate: out plate_info;
		next_velocity: out vector;
		next_ball: out ball_info;
		next_bullet: out std_logic_vector(0 to 1);
		fall_out: out std_logic
	);
end logic_control;

architecture bhv of logic_control is
	component collision_computation
		port(
			grids_map: in std_logic_vector(0 to (GRIDS_BITS - 1));
			ball: in ball_info;
			plate: in plate_info;
			plate_move: in integer;
			current_velocity: in vector;
			have_shadow: in std_logic;
			shadow_dir: in std_logic;
			bullet: in std_logic_vector(0 to 1);
			bullet_x, bullet_y: in integer;
			hit_map: out std_logic_vector(0 to (GRIDS_AMOUNT - 1));
			next_velocity: out vector;
			next_bullet: out std_logic_vector(0 to 1);
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
			bullet: in std_logic_vector(0 to 1);
			plate_move: in integer;
			grids_map: in std_logic_vector(0 to (GRIDS_BITS - 1));
			wiggle: in std_logic;
			ball_next: out ball_info;
			velocity_trans: out vector;
			plate_next: out plate_info;
			bullet_trans: out std_logic_vector(0 to 1);
			grids_map_trans: out std_logic_vector(0 to (GRIDS_BITS - 1));
			ball_moved: out std_logic
		);
	end component;
	
	signal zeros: std_logic_vector(0 to (GRIDS_AMOUNT - 1));
	signal ones: std_logic_vector(0 to (GRIDS_AMOUNT - 1));

	signal next_ball_t: ball_info;
	signal next_velocity_t: vector;
	signal next_plate_t: plate_info;
	signal next_ball_ub: ball_info;
	signal next_velocity_ub: vector;
	signal next_plate_ub: plate_info;
	signal fall_out_ub: std_logic;
	signal ball_moved: std_logic;
	signal hit_map: std_logic_vector(0 to (GRIDS_AMOUNT - 1));
	signal break_map: std_logic_vector(0 to (GRIDS_AMOUNT - 1));
	signal current_velocity_trans: vector;
	signal current_grids_map_trans: std_logic_vector(0 to (GRIDS_BITS - 1));
	signal bullet_trans: std_logic_vector(0 to 1);
	
	signal have_shadow: std_logic := '0';
	signal wiggling: std_logic := '0';
	signal trav: std_logic := '0';
begin
	zeros <= (others => '0');
	ones <= (others => '1');
	
	have_shadow <= '1' when buff = double else '0';
	u: collision_computation port map(current_grids_map_trans, next_ball_t, next_plate_t,
	                                  plate_move, current_velocity_trans, have_shadow, shadow_dir,
												 bullet_trans, bullet_x, bullet_y,
	                                  hit_map, next_velocity_t, next_bullet, fall_out_ub);
	gen_next_grids_map:
	for k in 0 to GRIDS_AMOUNT - 1 generate
		next_grids_map((k * GRID_BITS) to (k * GRID_BITS + GRID_BITS - 1)) <=
		current_grids_map_trans((k * GRID_BITS) to (k * GRID_BITS + GRID_BITS - 1)) - 1
		when hit_map(k) = '1' and current_grids_map_trans((k * GRID_BITS) to (k * GRID_BITS + GRID_BITS - 1)) /= ones
		else	current_grids_map_trans((k * GRID_BITS) to (k * GRID_BITS + GRID_BITS - 1));
		break_map(k) <= '1' when hit_map(k) = '1' and current_grids_map_trans((k * GRID_BITS) to (k * GRID_BITS + GRID_BITS - 1)) = 1 else '0';
	end generate gen_next_grids_map;
	
	u_trans: transfer port map(
		clk, ena, current_ball, current_velocity, current_plate, current_bullet, plate_move, current_grids_map, wiggling,
		next_ball_t, current_velocity_trans, next_plate_t, bullet_trans, current_grids_map_trans, ball_moved
	);
	next_velocity_ub <= next_velocity_t when ball_moved = '1' and (trav = '0' or break_map = zeros)
	                    else current_velocity_trans;
	next_ball_ub <= next_ball_t;
	next_plate_ub <= next_plate_t;
	
	
	---------------------  calc buff effects  ----------------------
	
	process(buff)
	begin
		next_ball.position <= next_ball_ub.position;
		next_ball.radius <= NORMAL_BALL_RADIUS;
		next_plate.l_position(1) <= next_plate_ub.l_position(1);
		if (next_plate_ub.l_position(0) < 0) then
			next_plate.l_position(0) <= 0;
		elsif (next_plate_ub.l_position(0) > SCREEN_WIDTH - NORMAL_PLATE_LEN) then
			next_plate.l_position(0) <= SCREEN_WIDTH - NORMAL_PLATE_LEN;
		else
			next_plate.l_position(0) <= next_plate_ub.l_position(0);
		end if;
		next_plate.len <= NORMAL_PLATE_LEN;
		next_velocity <= next_velocity_ub;
		fall_out <= fall_out_ub;
		wiggling <= '0';
		trav <= '0';
		case buff is
			when smaller =>
				next_ball.radius <= SMALL_BALL_RADIUS;
				
			when bigger =>
				next_ball.radius <= BIG_BALL_RADIUS;
				
			when shorter =>
				next_plate.len <= SHORT_PLATE_LEN;
				
			when longer =>
				if (next_plate_ub.l_position(0) > SCREEN_WIDTH - LONG_PLATE_LEN) then
					next_plate.l_position(0) <= SCREEN_WIDTH - LONG_PLATE_LEN;
				end if;
				next_plate.len <= LONG_PLATE_LEN;
				
			when death =>
				fall_out <= '1';
				
			when wiggle =>
				wiggling <= '1';
				
			when traversal =>
				trav <= '1';
				
			when double =>
				if (shadow_dir = '0' and next_plate_ub.l_position(0) < 200) then
					next_plate.l_position(0) <= 200;
				elsif (shadow_dir = '1' and next_plate_ub.l_position(0) > SCREEN_WIDTH - 300) then
					next_plate.l_position(0) <= SCREEN_WIDTH - 300;
				end if;
				
			when others =>
		end case;
	end process;
end bhv;