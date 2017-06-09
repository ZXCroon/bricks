library ieee;
use ieee.std_logic_1164.all;
use work.geometry.all;
use work.info.all;
use work.basic_settings.all;

entity state_control is
	port(
		clk_100m: in std_logic;
		load: in std_logic; -- =1 load initial map, =0 continue game
		run: in std_logic; -- =0 pause game, =1 game running
		launch_sig: in std_logic;
		plate_move: in integer;
		grids_map_load: in std_logic_vector(0 to (GRIDS_BITS - 1));
		ask_x: in std_logic_vector(9 downto 0);
		ask_y: in std_logic_vector(8 downto 0);
		
		grids_map: out std_logic_vector(0 to (GRIDS_BITS - 1));
		ball: out ball_info;
		plate: out plate_info;
		buff: out buff_info;
		shadow_dir: out std_logic;
		bullet: out std_logic_vector(0 to 1);
		bullet_x, bullet_y: out integer;
		buff_time_left: out integer;
		answer_card: out card_info;
		score: out integer;
		
		finished: out std_logic;
		fall_out: out std_logic;
		
		sig: out std_logic
	);
end state_control;

architecture bhv of state_control is
--	component serial_to_parallel
--		port(
--			clk: in std_logic;
--			ena: in std_logic;
--			input: in std_logic;
--			valid: out std_logic;
--			output: out std_logic_vector(0 to GRIDS_BITS - 1)
--		);
--	end component;
	
	component clock
		generic(n: integer);
		port(
			clk_in: in std_logic;
			clk_out: out std_logic
		);
	end component;
	
	component logic_control
		port(
			clk: in std_logic;
			ena: in std_logic;
			plate_move: in integer;
			current_grids_map: in std_logic_vector(0 to (GRIDS_BITS - 1));
			current_plate: in plate_info;
			current_velocity: in vector;
			current_ball: in ball_info;
			current_score: in integer;
			buff: in buff_info;
			shadow_dir: in std_logic;
			current_bullet: in std_logic_vector(0 to 1);
			bullet_x, bullet_y: integer;
			
			next_grids_map: out std_logic_vector(0 to (GRIDS_BITS - 1));
			next_plate: out plate_info;
			next_velocity: out vector;
			next_bullet: out std_logic_vector(0 to 1);
			next_ball: out ball_info;
			next_score: out integer;
			fall_out: out std_logic
		);
	end component;
	
	component buff_control
		port(
			clk_100m: in std_logic;
			ena: in std_logic;
			rst: in std_logic;
			
			plate: in plate_info;
			
			buff: out buff_info;
			shadow_dir: out std_logic;
			time_left: out integer;
			
			ask_x: in std_logic_vector(9 downto 0);
			ask_y: in std_logic_vector(8 downto 0);
			answer_card: out card_info;
			
			sig: out std_logic
		);
	end component;
	
	component bullet_control
		port(
			clk_100m: in std_logic;
			ena: in std_logic;
			rst: in std_logic;
			can_shoot: in std_logic;
			shoot_sig: in std_logic;
			l_position: in point;
			lt_x, lt_y: out integer
		);
	end component;
	
	signal clk_trans, clk_load, clk_start: std_logic;
	signal buff_t: buff_info;
	
	signal current_grids_map: std_logic_vector(0 to (GRIDS_BITS - 1));
	signal current_ball: ball_info;
	signal current_plate: plate_info;
	signal current_velocity: vector;
	signal current_bullet: std_logic_vector(0 to 1);
	signal current_score: integer;
	
	signal next_grids_map: std_logic_vector(0 to (GRIDS_BITS - 1));
	signal next_ball: ball_info;
	signal next_plate: plate_info;
	signal next_velocity: vector;
	signal next_bullet: std_logic_vector(0 to 1);
	signal next_score: integer;
	signal bullet_x_t, bullet_y_t: integer;
	signal can_shoot: std_logic;
	
	
	signal zeros: std_logic_vector(0 to (GRIDS_BITS - 1));
	
	type state is (stick, fly);
	signal current_state: state := stick;
	
	signal shadow_dir_t: std_logic;
begin
	u_c: clock generic map(1000) port map(clk_100m, clk_trans);
	
	u_trans: logic_control port map(clk_trans, run, plate_move,
	                                current_grids_map, current_plate, current_velocity, current_ball, current_score,
											  buff_t, shadow_dir_t,
											  current_bullet, bullet_x_t, bullet_y_t,
	                                next_grids_map, next_plate, next_velocity, next_bullet, next_ball, next_score, fall_out);
	u_buff: buff_control port map(clk_100m, run, not load, next_plate, buff_t, shadow_dir_t, buff_time_left,
	                              ask_x, ask_y, answer_card, sig);
	u_bullet: bullet_control port map(clk_100m, run, not load, can_shoot, launch_sig, next_plate.l_position, bullet_x_t, bullet_y_t);
	bullet_x <= bullet_x_t;
	bullet_y <= bullet_y_t;
	
	buff <= buff_t;
	shadow_dir <= shadow_dir_t;
	can_shoot <= '1' when buff_t = shoot else '0';
									  
	current_grids_map <= next_grids_map when load = '0' else grids_map_load;
	current_plate <= next_plate when load = '0' else
	                 construct_plate_info(construct_point((SCREEN_WIDTH - NORMAL_PLATE_LEN) / 2, 450), NORMAL_PLATE_LEN, 0);
	current_velocity <= next_velocity when load = '0' else construct_vector(160, -160);
	current_ball <= construct_ball_info(NORMAL_BALL_RADIUS, construct_point(320, 442)) when load = '1' else
						construct_ball_info(NORMAL_BALL_RADIUS, current_plate.l_position + construct_vector(NORMAL_PLATE_LEN / 2, -NORMAL_BALL_RADIUS)) when current_state = stick else
						next_ball;
	current_bullet <= "11" when launch_sig = '1' else next_bullet;
	current_score <= next_score when load = '0' else 0;
	
	grids_map <= current_grids_map;
	ball <= current_ball;
	plate <= current_plate;
	bullet <= current_bullet;
	score <= current_score;
	
	zeros <= (others => '0');
	finished <= '1' when current_grids_map = zeros else '0';
	
	process(load, launch_sig)
	begin
		if (load = '1') then
			current_state <= stick;
		elsif (launch_sig'event and launch_sig = '1') then
			if (current_state = stick) then
				current_state <= fly;
			end if;
		end if;
	end process;
end bhv;