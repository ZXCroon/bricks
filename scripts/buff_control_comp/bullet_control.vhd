library ieee;
use ieee.std_logic_1164.all;
use work.geometry.all;
use work.info.all;

entity bullet_control is
	port(
		clk_100m: in std_logic;
		ena: in std_logic;
		rst: in std_logic;
		shoot_sig: in std_logic;
		l_position: in point;
		lt_x, lt_y: out integer
	);
end bullet_control;

architecture bhv of bullet_control is
	component clock
		generic(n: integer);
		port(
			clk_in: in std_logic;
			clk_out: out std_logic
		);
	end component;
	
	signal clk_1k: std_logic;
	type state is (ready, flying);
begin
	u_c: clock generic map(100000) port map(clk_100m, clk_1k);
	
	process(clk_1k, ena, rst)
		variable cnt: integer := 0;
		variable current_state: state := ready;
		variable x, y: integer;
	begin
		if (rst = '0') then
			cnt := 0;
			x := 0;
			y := -400;
			current_state := ready;
			lt_x <= x;
			lt_y <= y;
		elsif (clk_1k'event and clk_1k = '1') then
			if (ena = '1') then
				case current_state is
					when ready =>
						if (shoot_sig = '1') then
							current_state := flying;
							cnt := 0;
							x := l_position(0);
							y := l_position(1);
						end if;
					when flying =>
						cnt := cnt + 1;
						if (cnt = 3) then
							cnt := 0;
							y := y - 1;
							if (y = -400) then
								current_state := ready;
								x := 0;
							end if;
						end if;
					when others =>
						current_state := ready;
						cnt := 0;
						x := 0;
						y := -400;
				end case;
				lt_x <= x;
				lt_y <= y;
			end if;
		end if;
	end process;
end bhv;