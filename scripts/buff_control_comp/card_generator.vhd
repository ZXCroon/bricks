library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
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
		card: out card_info := construct_card_info(construct_point(0, 0), none)
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
	
	function gen_next(x, random_factor: integer) return integer is
	begin
		return (x + random_factor) * 32768 rem 7000 + 3000;
	end gen_next;
	
	type state is (st0, st1);
	signal clk_1k: std_logic;
	signal calc_sig: std_logic := '0';
	signal interval: integer := seed rem 7000 + 7000;
begin
	u_c: clock generic map(100000) port map(clk_100m, clk_1k);
	
	process(clk_1k, rst)
		variable cnt: integer := 0;
		variable current_state: state := st0;
		variable now_x, now_y: integer;
	begin
		if (rst = '0') then
			card <= construct_card_info(construct_point(0, 0), none);
			cnt := 0;
			current_state := st0;
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
					when st0 =>
						cnt := cnt + 1;
						if (cnt >= interval) then
							cnt := 0;
							calc_sig <= '1';
							current_state := st1;
							-- TODO: finish card generator --
							card.lt_position <= construct_point(300, -CARD_SIDE);
							now_x := 300;
							now_y := -CARD_SIDE;
							card.buff <= smaller;
						else
							calc_sig <= '0';
						end if;
						
					when st1 =>
						calc_sig <= '0';
						cnt := cnt + 1;
						if (cnt = 10) then
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
			end if;
		end if;
	end process;
	
	process(calc_sig)
		variable interval_v: integer;
	begin
		if (calc_sig'event and calc_sig = '1') then
			interval_v := interval;
			interval <= gen_next(interval_v, random_factor);
		end if;
	end process;
end bhv;