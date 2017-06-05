library ieee;
use ieee.std_logic_1164.all;
use work.geometry.all;
use work.info.all;
use work.basic_settings.all;
use work.interface_coding.all;

entity logic_control_test is
	port(
		clk_100m: in std_logic;
		Ld: in std_logic;
		run: in std_logic;
		ps2data, ps2clock: in std_logic;
		hs, vs: out std_logic;
		r_out, g_out, b_out: out std_logic_vector(2 downto 0);
		finished: out std_logic;
		fall_out: out std_logic;
		
		sig: out std_logic
	);
end logic_control_test;

architecture bhv of logic_control_test is
	component keyboard_decoder
	port(
		-- datain: ps2data; clkin: ps2 clock; fclk: filter clock;
		datain,clkin,fclk,rst_in: in std_logic;
		board_speed: out integer
	);
	end component;
	
	component state_control
		port(
			clk_100m: in std_logic;
			load: in std_logic;
			run: in std_logic;
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
	end component;
	
	component display_control
		port(
			clk_100m: in std_logic;
			rst: in std_logic;
			
			grids_map: in std_logic_vector(0 to (GRIDS_BITS - 1));
			plate: in plate_info;
			ball: in ball_info;
			card_xy: in card_info;
			buff: in buff_info;
			game_flag: in interface_type;
			
			ask_x: out std_logic_vector(9 downto 0);
			ask_y: out std_logic_vector(8 downto 0);
			hs, vs: out std_logic;
			r_out, g_out, b_out: out std_logic_vector(2 downto 0)
		);
	end component;
	
	component clock
		generic(n: integer);
		port(
			clk_in: in std_logic;
			clk_out: out std_logic
		);
	end component;

	component convert_risingedge is
		port(
			-- fclk: filter clock, clkin: 想检测上升沿的时钟
			fclk, clkin: in std_logic;
			clk: out std_logic
		);
	end component;
	
	signal rst: std_logic := '1';
	signal plate_move: integer := 0;
	
	signal grids_map: std_logic_vector(0 to (GRIDS_BITS - 1));
	signal grids_map_init: std_logic_vector(0 to (GRIDS_BITS - 1));
	signal plate: plate_info;
	signal ball: ball_info;
	signal game_flag: interface_type;
	
	signal clk_50m: std_logic;
	signal clk_25m: std_logic;
	signal clk_1m: std_logic;
	signal clk_10m: std_logic;
	
	signal keyboard_rst: std_logic := '1';
	signal plate_move_t: integer;
	
	signal ask_x: std_logic_vector(9 downto 0);
	signal ask_y: std_logic_vector(8 downto 0);
	signal buff: buff_info;
	signal buff_time_left: integer;
	signal answer_card: card_info;

	signal load, LD_cvt: std_logic := '1';
begin
	-- TODO: clk_25m和clk_100m上升沿可能不同步
	process(clk_100m)
	begin
		if (clk_100m'event and clk_100m = '1') then
			clk_50m <= not clk_50m;
		end if;
	end process;
	process(clk_50m)
	begin
		if (clk_50m'event and clk_50m = '1') then
			clk_25m <= not clk_25m;
		end if;
	end process;
	
	narrow_Ld: convert_risingedge port map(clk_10m, Ld, LD_cvt);
	process(load, LD_cvt)
	begin
		if(rising_edge(clk_10m) and LD_cvt='1') then
			load <= not load;
		end if;
--		if(falling_edge(Ld)) then
--			load <= not load;
--		end if;
	end process;
	
	u_c: clock generic map(10) port map(clk_100m, clk_10m);
	
	u_k: keyboard_decoder port map(ps2data, ps2clock, clk_10m, keyboard_rst, plate_move_t);
	plate_move <= plate_move_t;
	
	u_d: display_control port map(clk_100m, rst, grids_map, plate, ball, answer_card, buff, game_flag, 
	                              ask_x, ask_y, hs, vs, r_out, g_out, b_out);
	u_s: state_control port map(clk_100m, Ld, run, plate_move, grids_map_init, ask_x, ask_y,
	                            grids_map, ball, plate, buff, buff_time_left, answer_card, finished, fall_out, sig);
	
	grids_map_init <= (others => '1');
	
end bhv;