library ieee;
use ieee.std_logic_1164.all;
use work.geometry.all;
use work.info.all;
use work.basic_settings.all;

entity buff_time_control is
	generic(duration: integer);    -- unit: ms
	port(
		clk_100m: in std_logic;
		ena: in std_logic;
		rst: in std_logic;
		buff_get: in buff_info;
		buff: out buff_info := none;
		time_left: out integer      -- unit: ms
	);
end buff_time_control;

architecture bhv of buff_time_control is
	component clock
		generic(n: integer);
		port(
			clk_in: in std_logic;
			clk_out: out std_logic
		);
	end component;
	
	type state is (st0, st1, st2);
	signal clk_10m: std_logic;
begin
	u_c: clock generic map(10) port map(clk_100m, clk_10m);
	
	process(clk_10m)
		variable current_state: state := st0;
		variable cnt: integer := 0;
		variable time_left_v: integer := 0;
	begin
		if (rst = '0') then
			buff <= none;
			time_left <= 0;
			current_state := st0;
			cnt := 0;
			time_left_v := 0;
		elsif (clk_10m'event and clk_10m = '1') then
			if (ena = '1') then
				case current_state is
					when st0 =>
						if (buff_get /= none) then
							current_state := st1;
							buff <= buff_get;
						end if;
					when st1 =>
						if (buff_get = none) then
							current_state := st2;
							cnt := 0;
							time_left_v := duration;
						end if;
					when st2 =>
						cnt := cnt + 1;
						if (cnt = 1000) then
							cnt := 0;
							time_left_v := time_left_v - 1;
							if (time_left_v = 0) then
								current_state := st0;
								buff <= none;
							end if;
						end if;
					when others =>
						current_state := st0;
						cnt := 0;
						time_left_v := 0;
						buff <= none;
				end case;
				time_left <= time_left_v;
			end if;
		end if;
	end process;
end bhv;