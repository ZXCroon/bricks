library ieee;
use ieee.std_logic_1164.all;
use work.info.all;

entity buff_test is
	port(
		clk_100m: in std_logic;
		b: in std_logic;
		buff: out std_logic
	);
end buff_test;

architecture bhv of buff_test is
	component buff_control
		generic(duration: integer);    -- unit: ms
		port(
			clk_100m: in std_logic;
			buff_get: in buff_info;
			buff: out buff_info := none
		);
	end component;
	signal buff_get: buff_info;
	signal buff0: buff_info;
begin
	buff_get <= smaller when b = '0' else none;
	u: buff_control generic map(60000) port map(clk_100m, buff_get, buff0);
	buff <= '1' when buff0 /= none else '0';
end bhv;