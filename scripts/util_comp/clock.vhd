library ieee;
use ieee.std_logic_1164.all;

entity clock is
	generic(n: integer);
	port(
		clk_in: in std_logic;
		clk_out: out std_logic
	);
end clock;

architecture bhv of clock is
	signal clk_out_t: std_logic;
begin
	clk_out <= clk_out_t;
	process(clk_in)
		variable cnt: integer := 0;
	begin
		if (clk_in'event and clk_in = '1') then
			cnt := cnt + 1;
			if (cnt = n) then
				cnt := 0;
				clk_out_t <= not clk_out_t;
			end if;
		end if;
	end process;
end bhv;