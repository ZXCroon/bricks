library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity rand_generator is
	generic(
		lowerbound: integer := 700;
		upperbound: integer := 7000;
		seed, a, b: integer := 812734
	);
	port(
		clk_100m: in std_logic;
		capture_sig: in std_logic;
		time_varying_factor: in integer;
		output: out integer
	);
end rand_generator;

architecture bhv of rand_generator is
	function gen_next(x, random_factor: integer) return integer is
	begin
		return (x + a + random_factor) * b rem (upperbound - lowerbound + 1) + lowerbound;
	end gen_next;
	
	signal init_sig: std_logic := '1';
	signal init_val: integer := (seed + a) * b rem (upperbound - lowerbound + 1) + lowerbound;
	signal now_val: integer := -1;
begin
	process(clk_100m)
		variable cnt: integer := 0;
	begin
		if (clk_100m'event and clk_100m = '1') then
			if (cnt < 20) then
				cnt := cnt + 1;
				init_val <= gen_next(init_val, 0);
			else
				init_sig <= '0';
			end if;
		end if;
	end process;
	
	process(capture_sig)
	begin
		if (capture_sig'event and capture_sig = '1') then
			if (init_sig = '1') then
				now_val <= init_val;
			else
				now_val <= gen_next(now_val, time_varying_factor);
			end if;
		end if;
	end process;
	
	output <= now_val when now_val /= -1 else init_val;
end bhv;