library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.info.all;
use work.geometry.all;
use work.basic_settings.all;

entity card_generator is
	generic(seed: integer);
	port(
		clk_100m: in std_logic;
		ena: in std_logic;
		rst: in std_logic;
		rst_s: in std_logic;
		random_factor: in integer;
		card: out card_info := construct_card_info(construct_point(0, 0), none);
		sig: out std_logic_vector(1 downto 0)
	);
end card_generator;

architecture bhv of card_generator is
	component clock
		generic(n: integer);
		port(
			clk_in: in std_logic;
			clk_out: out std_logic
		);
	end component;
	
	component rand_generator
		generic(
			lowerbound, upperbound: integer;
			seed, a, b: integer
		);
		port(
			clk_100m: in std_logic;
			capture_sig: in std_logic;
			time_varying_factor: in integer;
			output: out integer
		);
	end component;
	
	type state is (st_init, st0, st1);
	signal clk_1k: std_logic;
	signal calc_sig: std_logic := '0';
	signal interval, buff_code, fallx, fall_period: integer;
begin
	u_c: clock generic map(100000) port map(clk_100m, clk_1k);
	u_r_interval: rand_generator generic map(1000, 12000, seed, seed + 32457, 79)
	                             port map(clk_100m, calc_sig, random_factor, interval);
	u_r_buff: rand_generator generic map(0, BUFF_NUM - 1, seed, 377, 787)
	                         port map(clk_100m, calc_sig, random_factor / 2, buff_code);
	u_r_fallx: rand_generator generic map(0, SCREEN_WIDTH - CARD_SIDE, seed, seed / 2, seed)
	                          port map(clk_100m, calc_sig, random_factor * 2, fallx);
	u_r_fallperiod: rand_generator generic map(4, 15, seed, 8, 3)
	                              port map(clk_100m, calc_sig, random_factor / 2, fall_period);
	process(clk_1k, rst)
		variable cnt: integer := 0;
		variable current_state: state := st_init;
		variable now_x, now_y: integer;
		variable interval_v: integer;
		variable fall_period_v: integer;
	begin
		if (rst = '0') then
			card <= construct_card_info(construct_point(0, 0), none);
			cnt := 0;
			current_state := st_init;
			now_x := 0;
			now_y := 0;
		elsif (clk_1k'event and clk_1k = '1') then
			if (rst_s = '0') then
				card <= construct_card_info(construct_point(0, 0), none);
				cnt := 0;
				current_state := st0;
				now_x := 0;
				now_y := 0;
			elsif (ena = '1') then
				case current_state is
					when st_init =>
						cnt := cnt + 1;
						if (cnt >= 1000) then
							cnt := 0;
							current_state := st0;
							interval_v := interval;
							calc_sig <= '1';
						end if;
					when st0 =>
						cnt := cnt + 1;
						if (cnt >= interval_v) then
							cnt := 0;
							interval_v := interval;
							calc_sig <= '1';
							current_state := st1;
							card.lt_position <= construct_point(fallx, -CARD_SIDE);
							now_x := fallx;
							now_y := -CARD_SIDE;
							card.buff <= get_buff(buff_code);
							fall_period_v := fall_period;
						else
							calc_sig <= '0';
						end if;
						
					when st1 =>
						calc_sig <= '0';
						cnt := cnt + 1;
						if (cnt = fall_period_v) then
							cnt := 0;
							now_y := now_y + 1;
							card.lt_position(1) <= now_y;
							if (now_y >= SCREEN_HEIGHT) then
								current_state := st0;
								card.lt_position <= construct_point(0, 0);
								card.buff <= none;
							end if;
						end if;
						
					when others =>
						card <= construct_card_info(construct_point(0, 0), none);
						cnt := 0;
						current_state := st0;
						now_x := 0;
						now_y := 0;
				end case;
			else
				sig <= "11";
			end if;
		end if;
	end process;
end bhv;