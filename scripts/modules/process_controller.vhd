library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity process_controller is
	port(
		clk, rst: in std_logic;
		confirm, quit, upp, downp: in std_logic;
		gameinfo: in std_logic;
		logic_ena, maploader_ena: out std_logic := '0';
		interface_info: out std_logic_vector(1 downto 0)
	);
end process_controller;

architecture bhv of process_controller is
	type state_type is (menu, gaming, pause, gameover);
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
	begin
		if(rst='0') then
			curstate <= menu;
		elsif(rising_edge(clk)) then
			case curstate is
				when menu =>
					if(zp='1') then
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
	
	logic_ena <= '1' when curstate=gaming else '0';
	
	-- output interface info
	with curstate select
		interface_info <= "00" when menu,
		                  "01" when gaming,
						  "10" when pause,
						  "11" when gameover;
end bhv;
