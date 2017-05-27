library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.key_coding.all;

entity test_kb is
	port(
		datain, clkin, fclk, rst_in: in std_logic;
		showspeed: out std_logic_vector(1 downto 0);
		showz, showx, showup, showdown: out std_logic
	);
end test_kb;

architecture bhv of test_kb is
	component keyboard_decoder is
	port(
		-- datain: ps2data; clkin: ps2 clock; fclk: filter clock;
		datain, clkin, fclk, rst_in: in std_logic;
		board_speed: out integer;
		-- 游戏流程的确认，取消
		confirm, quit, upp, downp: out std_logic
	);
	end component;
	
	constant lowspeed: integer := 1;
	constant highspeed: integer := 2;
	signal board_speed: integer := 0;
	
--	function abs(n: integer) return integer is
--		variable ret: integer;
--	begin
--		if(n>=0) then
--			ret := n;
--		else
--			ret := -n;
--		end if;
--		return ret;
--	end function;
begin
	kbd: keyboard_decoder port map(datain, clkin, fclk, rst_in, board_speed, showz, showx, showup, showdown);
		
	with abs(board_speed) select
		showspeed <= "00" when 0,
		             "01" when highspeed,
					 "10" when lowspeed,
					 "11" when others;
end;

