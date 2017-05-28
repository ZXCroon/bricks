library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.info.all;
use work.basic_settings.all;
use work.geometry.all;

entity buff_control is
	port(
		clk_100m: in std_logic;
		ena: in std_logic;
		rst: in std_logic;
		
		ball: in ball_info;
		plate: in plate_info;
		velocity: in vector;
		grids_map: in std_logic_vector(0 to (GRIDS_BITS - 1));
		
		ball_b: out ball_info;
		plate_b: out plate_info;
		velocity_b: out vector;
		grids_map_b: out std_logic_vector(0 to (GRIDS_BITS - 1));
		
		buff: out buff_info;
		time_left: out integer;
		
		ask_x: in std_logic_vector(9 downto 0);
		ask_y: in std_logic_vector(8 downto 0);
		answer_card: out card_info
	);
end buff_control;

architecture bhv of buff_control is
	component buff_time_control
		generic(duration: integer);    -- unit: ms
		port(
			clk_100m: in std_logic;
			ena: in std_logic;
			rst: in std_logic;
			buff_get: in buff_info;
			buff: out buff_info := none;
			time_left: out integer      -- unit: ms
		);
	end component;
	
	component card_generator
		generic(seed: integer);
		port(
			clk_100m: in std_logic;
			ena: in std_logic;
			rst: in std_logic;
			rst_s: in std_logic;
			random_factor: in integer;
			card: out card_info := construct_card_info(construct_point(0, 0), none)
		);
	end component;
	
	type cards_info is array(0 to (CARD_GENS - 1)) of card_info;
	signal rst_cg: std_logic;
	signal buff_get: buff_info;
	signal buff_t: buff_info;
	signal cards: cards_info;
	
	signal x_int, y_int: integer;
begin
	u_btc: buff_time_control generic map(60000) port map(clk_100m, ena, rst, buff_get, buff_t, time_left);
	buff <= buff_t;
	rst_cg <= '0' when buff_t /= none else '1';
	
	gen_card_gens:
	for k in 0 to CARD_GENS - 1 generate
		u_cg: card_generator generic map(k * 100 + 27)
		                     port map(clk_100m, ena, rst, rst_cg, plate.l_position(0) * 5, cards(k));
	end generate gen_card_gens;
	
	x_int <= conv_integer(ask_x);
	y_int <= conv_integer(ask_y);
	touch_detection:
	process(cards)
	begin
		for k in 0 to CARD_GENS - 1 loop
			if (cards(k).buff /= none) then
				if (cards(k).lt_position(0) <= plate.l_position(0) + plate.len and
				    cards(k).lt_position(0) + CARD_SIDE >= plate.l_position(0) and
					 cards(k).lt_position(1) >= plate.l_position(1)) then
					 buff_get <= cards(k).buff;
				end if;
				if (ask_x >= cards(k).lt_position(0) and ask_x <= cards(k).lt_position(0) + CARD_SIDE and
				    ask_y >= cards(k).lt_position(1) and ask_y <= cards(k).lt_position(1) + CARD_SIDE) then
					answer_card <= cards(k);
				end if;
			end if;
		end loop;
	end process touch_detection;
	
	process(buff_t)
	begin
		case buff_t is
			when smaller =>
				ball_b.position <= ball.position;
				ball_b.radius <= SMALL_BALL_RADIUS;
				velocity_b <= velocity;
				grids_map_b <= grids_map;
			when others =>
				ball_b <= ball;
				plate_b <= plate;
				velocity_b <= velocity;
				grids_map_b <= grids_map;
		end case;
	end process;
	
end bhv;