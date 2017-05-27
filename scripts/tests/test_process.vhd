library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity test_process is
	port (
		fclk, rst: in std_logic;
		kbclk, kbdata: in std_logic;
		gameinfo_switch: in std_logic;
		logic_ena, maploader_ena: out std_logic;
		confirm, quit, upp, downp: buffer std_logic;
		interface_info: out std_logic_vector(1 downto 0)
	);
end test_process;

architecture bhv of test_process is
	component process_controller is
		port(
			clk, rst: in std_logic;
			confirm, quit, upp, downp: in std_logic;
			gameinfo: in std_logic;
			logic_ena, maploader_ena: out std_logic := '0';
			interface_info: out std_logic_vector(1 downto 0)
		);
	end component;

	component keyboard_decoder is
		port(
			-- datain: ps2data; clkin: ps2 clock; fclk: filter clock;
			datain,clkin,fclk,rst_in: in std_logic;
			board_speed: out integer;
			-- 游戏流程的确认，取消
			confirm, quit, upp, downp: out std_logic
		);
	end component;

	signal board_speed: integer;
begin
	kb_decoder: keyboard_decoder port map(kbdata, kbclk, fclk, rst, board_speed, confirm, quit, upp, downp);
	pro_con: process_controller port map(fclk, rst, confirm, quit, upp, downp, not gameinfo_switch, logic_ena, maploader_ena, interface_info);
end bhv;