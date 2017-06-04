library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.img_coding.all;

entity img_test is
	port(
		clk_100m: in std_logic;
		hs, vs: out std_logic;
		r_out, g_out, b_out: out std_logic_vector(2 downto 0)
	);
end img_test;

architecture bhv of img_test is
	component img_reader
		port (
			x: in std_logic_vector(9 downto 0);
			y: in std_logic_vector(8 downto 0);
			img: in img_info;
--			-- outclk frequnceny = inclk freq * 2
			inclk: in std_logic;
			clken: in std_logic;
			r, g, b: out std_logic_vector(2 downto 0);
			dataok: out std_logic := '0'
		);
	end component;

	signal vga_clk: std_logic;
	signal rst: std_logic := '1';
	signal xt: std_logic_vector(9 downto 0);
	signal yt: std_logic_vector(8 downto 0);
	signal next_x: std_logic_vector(9 downto 0);
	signal next_y: std_logic_vector(8 downto 0);
	signal hst, vst: std_logic;
	signal ask_x: std_logic_vector(9 downto 0);
	signal ask_y: std_logic_vector(8 downto 0);
begin
	u: img_reader port map(ask_x, ask_y, bg_texture, clk_100m, '1', r_out, g_out, b_out, vga_clk);
	hs <= hst;
	vs <= vst;
	
	ask_x <= conv_std_logic_vector(conv_integer(next_x) rem 20, 10);
	ask_y <= conv_std_logic_vector(conv_integer(next_y) rem 20, 9);
	
	process(vga_clk, rst)
		variable xt_v: std_logic_vector(9 downto 0);
		variable yt_v: std_logic_vector(8 downto 0);
	begin
		if (rst = '0') then
			xt <= (others => '0');
			yt <= (others => '0');
			next_x <= (others => '0');
			next_x(0) <= '1';
			next_y <= (others => '0');
		elsif (vga_clk'event and vga_clk = '1') then
			xt_v := next_x;
			yt_v := next_y;
			xt <= xt_v;
			yt <= yt_v;
			
			if (xt_v = 799) then
				next_x <= (others => '0');
				if (yt_v = 524) then
					next_y <= (others => '0');
				else
					next_y <= yt_v + 1;
				end if;
			else
				next_x <= xt_v + 1;
			end if;
		end if;
	end process;
	
	process(vga_clk, rst)
	begin
		if (rst = '0') then
			hst <= '1';
			vst <= '1';
		elsif (vga_clk'event and vga_clk = '1') then
			if (xt >= 656 and xt < 752) then
				hst <= '0';
			else
				hst <= '1';
			end if;
			
			if (yt >= 490 and yt < 492) then
				vst <= '0';
			else
				vst <= '1';
			end if;
		end if;
	end process;
	
--	process(vga_clk, rst, xt, yt)
--	begin
--		if (rst = '0') then
--			r_out <= (others => '0');
--			g_out <= (others => '0');
--			b_out <= (others => '0');
--		elsif (vga_clk'event and vga_clk = '1') then
--			if (xt >= 640 or yt >= 480) then
--				r_out <= (others => '0');
--				g_out <= (others => '0');
--				b_out <= (others => '0');
--			else
--				r_out <= (others => '1');
--				g_out <= (others => '0');
--				b_out <= (others => '0');
--			end if;
--		end if;
--	end process;
end bhv;