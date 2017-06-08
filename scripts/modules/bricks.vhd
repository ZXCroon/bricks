library IEEE;
use IEEE.std_logic_1164.all;
--use work.geometry.all;
use work.info.all;
use work.basic_settings.all;
use work.interface_coding.all;

entity bricks is
	port (
		clk_100m: in std_logic;
		ps2data, ps2clock: in std_logic;
		rst: in std_logic; -- reset when =0
		launch_sig: in std_logic;
--		load, run: in std_logic;
		interface: out interface_type;
		-- display
		hs, vs: out std_logic;
		r_out, g_out, b_out: out std_logic_vector(2 downto 0)
	);
end bricks;

architecture bhv of bricks is
	component keyboard_decoder
		port(
			-- datain: ps2data; clkin: ps2 clock; fclk: filter clock;
			datain,clkin,fclk,rst_in: in std_logic;
			board_speed: out integer;
			-- 游戏流程的确认，取消
			confirm, quit, upp, downp: out std_logic := '0'
		);
	end component; 

	component process_controller is
		port(
			clk, rst: in std_logic;
			confirm, quit, upp, downp: in std_logic;
			gameinfo: in std_logic;
			logic_run, logic_load: out std_logic := '0';
			interface_info: out interface_type
		);
	end component;

	component state_control
		port(
			clk_100m: in std_logic;
			load: in std_logic;
			run: in std_logic;
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
			bullet_x, bullet_y: out integer;
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
			shadow_dir: in std_logic;
			bullet_x, bullet_y: in integer;
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

	--clocks
	signal clk_50m, clk_25m, clk_10m: std_logic;

	-- keyboard output
	signal plate_speed: integer := 0;
	signal confirm, quit, upp, downp: std_logic := '0';

	-- process output
	signal logic_load, logic_run: std_logic := '0';
	signal interface_info: interface_type; -- gameflag

	-- display output
	signal ask_x: std_logic_vector(9 downto 0);
	signal ask_y: std_logic_vector(8 downto 0);

	-- state input
	signal grids_map_init: std_logic_vector(0 to (GRIDS_BITS - 1));
	-- load, run, plate_speed, askx, asky
	-- state output
	signal grids_map: std_logic_vector(0 to (GRIDS_BITS - 1));
	signal ball: ball_info;
	signal plate: plate_info;
	signal buff: buff_info;
	signal buff_time_left: integer;
	signal answer_card: card_info;
	signal finished, fall_out: std_logic;
	signal sig: std_logic;
	
	signal shadow_dir: std_logic;
	signal bullet_x, bullet_y: integer;
begin
	interface <= interface_info;
	u_keyboard: keyboard_decoder port map(
		datain=>ps2data, clkin=>ps2clock, fclk=>clk_10m, rst_in=>rst,
		board_speed=>plate_speed, confirm=>confirm, quit=>quit,
		upp=>upp, downp=>downp
	);
	u_process_control: process_controller port map(
		clk=>clk_10m, rst=>rst,
		confirm=>confirm, quit=>quit, upp=>upp, downp=>downp,
		gameinfo=>finished or fall_out,
		logic_run=>logic_run, logic_load=>logic_load,
		interface_info=>interface_info
	);
	--logic_load <= load;
	--logic_run <= run;
	u_display: display_control port map(
		clk_100m, rst, grids_map, plate, ball, answer_card, buff, shadow_dir, bullet_x, bullet_y, interface_info, 
		ask_x, ask_y, hs, vs, r_out, g_out, b_out
	);
	u_state: state_control port map(
		clk_100m, logic_load, logic_run, not launch_sig, plate_speed,
		grids_map_init, ask_x, ask_y,
		-- output
		grids_map, ball, plate, buff, shadow_dir, bullet_x, bullet_y, buff_time_left, answer_card,
		finished, fall_out, sig
	);

	grids_map_init <= (others => '1');


	-- convert clocks
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
	u_c: clock generic map(10) port map(clk_100m, clk_10m);
end bhv;