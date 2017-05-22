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
	signal lastconfirm, lastquit, zp, xp: std_logic;
begin
	state_trans: process(clk, rst, curstate) is
		-- zp: confirm pressed, xp: quit pressed
		variable lastconfirm, lastquit, zp, xp: std_logic;
	begin
		if(rst='1') then
			curstate <= menu;
			logic_ena <= '0';
			maploader_ena <= '0';
		elsif(rising_edge(clk)) then
			lastconfirm := confirm;
			lastquit := quit;
			-- 表示z,x键被按下了
			zp := confirm and (not lastconfirm);
			xp := quit and (not lastquit);
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
	
	-- output interface info
	with curstate select
		interface_info <= "00" when menu,
		                  "01" when gaming,
						  "10" when pause,
						  "11" when gameover;
end bhv;
