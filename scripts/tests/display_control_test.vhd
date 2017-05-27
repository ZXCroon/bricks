library ieee;
use ieee.std_logic_1164.all;
use work.geometry.all;
use work.info.all;
use work.basic_settings.all;

entity display_control_test is
	port(
		clk_100m: in std_logic;
		ena: in std_logic;
		hs, vs: out std_logic;
		r_out, g_out, b_out: out std_logic_vector(2 downto 0)
	);
end display_control_test;

architecture bhv of display_control_test is
	component display_control
		port(
			clk: in std_logic;
			rst: in std_logic;
			
			grids_map: in std_logic_vector(0 to (GRIDS_BITS - 1));
			plate: in plate_info;
			ball: in ball_info;		
			game_flag: in integer;
			
			hs, vs: out std_logic;
			r_out, g_out, b_out: out std_logic_vector(2 downto 0)
		);
	end component;
	
	component ball_move_computation
		port(
			clk: in std_logic;
			ena: in std_logic;
			ball: in ball_info;
			velocity: in vector;
			set: out std_logic;
			ball_next: out ball_info
		);
	end component;
	
	signal clk_50m, clk_25m: std_logic;
	signal rst: std_logic;
	signal grids_map: std_logic_vector(0 to (GRIDS_BITS - 1));
	signal plate: plate_info;
	signal ball, ball_next: ball_info;
	signal ball_init: ball_info := construct_ball_info(8, construct_point(340, 400));
	signal velocity: vector := construct_vector(-600000, -1200000);
	signal game_flag: integer;
	
	signal set: std_logic;
	
	--shared variable cnt: integer := 0;
begin
	rst <= '1';
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
	
	plate <= construct_plate_info(construct_point(300, 450), 80, 0);
	
	gen_bricks:
	for k in 0 to (GRIDS_AMOUNT - 1) generate
		grids_map((k * GRID_BITS) to (k * GRID_BITS + GRID_BITS - 2)) <= (others => '0');
		gen_brick_0:
		if (k rem 2 = 1) generate
			grids_map(k * GRID_BITS + GRID_BITS - 1) <= '0';
		end generate gen_brick_0;
		gen_brick_1:
		if (k rem 2 = 0) generate
			grids_map(k * GRID_BITS + GRID_BITS - 1) <= '1';
		end generate gen_brick_1;
	end generate gen_bricks;

--	process(clk_25m)
--		variable cnt: integer := 0;
--	begin
--		if (clk_25m'event and clk_25m = '1') then
--			if (cnt = 999999) then
--				ball_next <= construct_ball_info(ball_next.radius, ball_next.position + construct_vector(1, 0));
--				cnt := 0;
--			else
--				cnt := cnt + 1;
--			end if;
--		end if;
--	end process;
	u_b: ball_move_computation port map(clk_25m, ena, ball, velocity, set, ball_next);
	ball <= ball_next when set = '1' else ball_init;
	
	u: display_control port map(clk_25m, rst, grids_map, plate, ball, game_flag, hs, vs, r_out, g_out, b_out);
end bhv;