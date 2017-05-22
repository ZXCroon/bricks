library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

-- 在rising_edge中再度使用rising_edge的解决方法
entity convert_risingedge is
	port(
		-- fclk: filter clock, clkin: 想检测上升沿的时钟
		fclk, clkin: in std_logic;
		clk: out std_logic
	);
end convert_risingedge;

architecture rising of convert_risingedge is
	signal clk1, clk2: std_logic;
begin
	--滤波并且让clkin高电平变窄，宽度只有fclk的一个周期
	clk1 <= clkin when rising_edge(fclk) ;
	clk2 <= clk1 when rising_edge(fclk) ;
	clk <= clk1 and (not clk2) ;
end;