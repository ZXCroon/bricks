library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity KeyboardReader is
port (
	datain, clkin : in std_logic ; -- PS2 clk and data
	fclk, rst : in std_logic ;  -- filter clock
	dataok : buffer std_logic ;  -- data output enable signal
	scancode : out std_logic_vector(7 downto 0) -- scan code signal output
	) ;
end KeyboardReader ;

architecture rtl of KeyboardReader is
	type state_type is (delay, start, d0, d1, d2, d3, d4, d5, d6, d7, parity, stop, finish) ;
	signal data, clk, clk1, clk2, odd: std_logic ; -- 毛刺处理内部信号, odd为奇偶校验
	signal code : std_logic_vector(7 downto 0) ; 
	signal state : state_type ;
begin
	--滤波并且让clkin高电平变窄，宽度只有fclk的一个周期
	clk1 <= clkin when rising_edge(fclk) ;
	clk2 <= clk1 when rising_edge(fclk) ;
	clk <= (not clk1) and clk2 ;
	
	data <= datain when rising_edge(fclk) ;
	
	odd <= code(0) xor code(1) xor code(2) xor code(3) 
		xor code(4) xor code(5) xor code(6) xor code(7) ;
	
--	scancode <= code when dataok = '1' ;
	
	process(rst, fclk)
	begin
		if rst = '1' then
			state <= delay ;
			code <= (others => '0') ;
			dataok <= '0' ;
		elsif rising_edge(fclk) then
			dataok <= '0' ;
			case state is 
				when delay =>
					state <= start ;
				when start =>
					if clk = '1' then
						-- 初始‘0’
						if data = '0' then
							state <= d0 ;
						else
							state <= delay ;
						end if ;
					end if ;
				when d0 =>
					if clk = '1' then
						code(0) <= data ;
						state <= d1 ;
					end if ;
				when d1 =>
					if clk = '1' then
						code(1) <= data ;
						state <= d2 ;
					end if ;
				when d2 =>
					if clk = '1' then
						code(2) <= data ;
						state <= d3 ;
					end if ;
				when d3 =>
					if clk = '1' then
						code(3) <= data ;
						state <= d4 ;
					end if ;
				when d4 =>
					if clk = '1' then
						code(4) <= data ;
						state <= d5 ;
					end if ;
				when d5 =>
					if clk = '1' then
						code(5) <= data ;
						state <= d6 ;
					end if ;
				when d6 =>
					if clk = '1' then
						code(6) <= data ;
						state <= d7 ;
					end if ;
				when d7 =>
					if clk = '1' then
						code(7) <= data ;
						state <= parity ;
					end if ;
				WHEN parity =>
					-- 奇偶校验
					IF clk = '1' then
						if (data xor odd) = '1' then
							state <= stop ;
						else
							state <= delay ;
						end if;
					END IF;

				WHEN stop =>
					IF clk = '1' then
						-- 末尾‘1’
						if data = '1' then
							state <= finish;
							scancode <= code;
						else
							state <= delay;
						end if;
					END IF;

				WHEN finish =>
					state <= delay ;
					--scancode <= code;
					dataok <= '1' ;
				when others =>
					state <= delay ;
			end case ; 
		end if ;
	end process ;
end rtl ;
			
						
