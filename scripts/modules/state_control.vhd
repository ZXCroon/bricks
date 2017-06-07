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
		plate_move: in integer;
		grids_map_load: in std_logic_vector(0 to (GRIDS_BITS - 1));
		ask_x: in std_logic_vector(9 downto 0);
		ask_y: in std_logic_vector(8 downto 0);
		
		grids_map: out std_logic_vector(0 to (GRIDS_BITS - 1));
		ball: out ball_info;
		plate: out plate_info;
		buff: out buff_info;
		buff_time_left: out integer;
		answer_card: out card_info;
		
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
			buff: in buff_info;
			
			next_grids_map: out std_logic_vector(0 to (GRIDS_BITS - 1));
			next_plate: out plate_info;
			next_velocity: out vector;
			next_ball: out ball_info;
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
			time_left: out integer;
			
			ask_x: in std_logic_vector(9 downto 0);
			ask_y: in std_logic_vector(8 downto 0);
			answer_card: out card_info;
			
			sig: out std_logic
		);
	end component;
	
	signal clk_trans, clk_load, clk_start: std_logic;
	signal buff_t: buff_info;
	
	signal current_grids_map: std_logic_vector(0 to (GRIDS_BITS - 1));
	signal current_ball: ball_info;
	signal current_plate: plate_info;
	signal current_velocity: vector;
	
	signal next_grids_map: std_logic_vector(0 to (GRIDS_BITS - 1));
	signal next_ball: ball_info;
	signal next_plate: plate_info;
	signal next_velocity: vector;
	
	signal zeros: std_logic_vector(0 to (GRIDS_BITS - 1));
begin
	u_c: clock generic map(1000) port map(clk_100m, clk_trans);
	
	u_trans: logic_control port map(clk_trans, run, plate_move,
	                                current_grids_map, current_plate, current_velocity, current_ball, buff_t,
	                                next_grids_map, next_plate, next_velocity, next_ball, fall_out);
	u_buff: buff_control port map(clk_100m, run, not load, next_plate, buff_t, buff_time_left, ask_x, ask_y, answer_card, sig);
	buff <= buff_t;
									  
	current_grids_map <= next_grids_map when load = '0' else grids_map_load;
	current_plate <= next_plate when load = '0' else
	                 construct_plate_info(construct_point((SCREEN_WIDTH - NORMAL_PLATE_LEN) / 2, 450), NORMAL_PLATE_LEN, 0);
	current_velocity <= next_velocity when load = '0' else construct_vector(100, -100);
	current_ball <= next_ball when load = '0' else construct_ball_info(NORMAL_BALL_RADIUS, construct_point(320, 442));
	
	grids_map <= current_grids_map;
	ball <= current_ball;
	plate <= current_plate;
	
	zeros <= (others => '0');
	finished <= '1' when current_grids_map = zeros else '0';
end bhv;