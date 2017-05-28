library ieee;
use ieee.std_logic_1164.all;
use work.geometry.all;
use work.info.all;

entity buff_test is
	port(
		clk_100m: in std_logic;
		c: out std_logic
	);
end buff_test;

architecture bhv of buff_test is
	component buff_time_control
		generic(duration: integer);    -- unit: ms
		port(
			clk_100m: in std_logic;
			ena: in std_logic;
			rst: in std_logic;
			buff_get: in buff_info;
			buff: out buff_info := none
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
	signal buff_get: buff_info;
	signal buff0: buff_info;
	signal random_factor: integer := 0;
	
	signal card: card_info;
begin
--	buff_get <= smaller when b = '0' else none;
--	u: buff_time_control generic map(60000) port map(clk_100m, '1', '1', buff_get, buff0);
--	buff <= '1' when buff0 /= none else '0';
	
	u_cg: card_generator generic map(32) port map(clk_100m, '1', '1', '1', random_factor, card);
	c <= '1' when card.buff /= none else '0';
end bhv;