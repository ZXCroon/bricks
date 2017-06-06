library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.interface_coding.all;

entity process_controller is
	port(
		clk, rst: in std_logic;
		confirm, quit, upp, downp: in std_logic;
		gameinfo: in std_logic;
		logic_run, logic_load: out std_logic := '0';
		interface_info: out interface_type
	);
end process_controller;

architecture bhv of process_controller is
	type state_type is (menu, loading, gaming, pause, gameover);
	signal curstate: state_type := menu;
	-- 表示z,x键被按下
	signal zp, xp: std_logic;
	
	component convert_risingedge is
		port(
			-- fclk: filter clock, clkin: 想检测上升沿的时钟
			fclk, clkin: in std_logic;
			clk: out std_logic
		);
	end component;
begin
	cvtz: convert_risingedge port map(clk, confirm, zp);
	cvtx: convert_risingedge port map(clk, quit, xp);

	state_trans: process(clk, rst, curstate) is
		constant loadtime: integer := 1023;
		variable cnt: integer range 0 to loadtime := 0;
	begin
		if(rst='0') then
			curstate <= menu;
		elsif(rising_edge(clk)) then
			logic_load <= '0';
			case curstate is
				when menu =>
					if(zp='1') then
						curstate <= loading;
					end if;
				when loading =>
					-- wait for logic module loading
					logic_load <= '1';
					cnt := cnt + 1;
					if(cnt=loadtime) then
						cnt := 0;
						curstate <= gaming;
					end if;
				when gaming =>
					if(xp='1') then
						curstate <= pause;
					elsif(gameinfo='1') then
						curstate <= gameover;
					end if;
				when pause =>
					if(zp='1') then
						curstate <= gaming;
					elsif(xp='1') then
						curstate <= menu;
					end if;
				when gameover =>
					if((zp or xp) = '1') then
						curstate <= menu;
					end if;
			end case;
		end if;
	end process;
	
	logic_run <= '1' when curstate=gaming else '0';
	
	-- output interface info
	with curstate select
		interface_info <= 
			ui_menu when menu,
			ui_menu when loading,
			ui_gaming when gaming,
			ui_pause when pause,
			ui_gameover when gameover;
end bhv;
