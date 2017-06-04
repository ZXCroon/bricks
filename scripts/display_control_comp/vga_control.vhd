library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.geometry.all;
use work.info.all;
use work.basic_settings.all;

entity vga_control is
	port(
		vga_clk: in std_logic;
		rst: in std_logic;
		
		r_in, g_in, b_in: in std_logic_vector(2 downto 0);
		
		hs, vs: out std_logic;
		x: out std_logic_vector(9 downto 0);
		y: out std_logic_vector(8 downto 0);
		next_x: out std_logic_vector(9 downto 0);
		next_y: out std_logic_vector(8 downto 0);
		r_out, g_out, b_out: out std_logic_vector(2 downto 0)
	);
end vga_control;

architecture bhv of vga_control is
	signal xt: std_logic_vector(9 downto 0);
	signal yt: std_logic_vector(8 downto 0);
	signal next_xt: std_logic_vector(9 downto 0);
	signal next_yt: std_logic_vector(8 downto 0);
	signal hst, vst: std_logic;
begin
	hs <= hst;
	vs <= vst;
	x <= xt;
	y <= yt;
	next_x <= next_xt;
	next_y <= next_yt;
	
	process(vga_clk, rst)
		variable x_v: std_logic_vector(9 downto 0);
		variable y_v: std_logic_vector(8 downto 0);
	begin
		if (rst = '0') then
			xt <= (others => '0');
			yt <= (others => '0');
			next_xt <= (others => '0');
			next_xt(0) <= '1';
			next_yt <= (others => '0');
		elsif (vga_clk'event and vga_clk = '1') then
			x_v := next_xt;
			y_v := next_yt;
			xt <= x_v;
			yt <= y_v;
			
			if (x_v = 799) then
				next_xt <= (others => '0');
				if (y_v = 524) then
					next_yt <= (others => '0');
				else
					next_yt <= y_v + 1;
				end if;
			else
				next_xt <= x_v + 1;
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
	
	process(vga_clk, rst, xt, yt)
	begin
		if (rst = '0') then
			r_out <= (others => '0');
			g_out <= (others => '0');
			b_out <= (others => '0');
		elsif (vga_clk'event and vga_clk = '1') then
			if (xt >= 640 or yt >= 480) then
				r_out <= (others => '0');
				g_out <= (others => '0');
				b_out <= (others => '0');
			else
				r_out <= r_in;
				g_out <= g_in;
				b_out <= b_in;
			end if;
		end if;
	end process;
end bhv;