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
		r_out, g_out, b_out: out std_logic_vector(2 downto 0)
	);
end vga_control;

architecture bhv of vga_control is
	signal xt: std_logic_vector(9 downto 0);
	signal yt: std_logic_vector(8 downto 0);
	signal hst, vst: std_logic;
begin
	hs <= hst;
	vs <= vst;
	x <= xt;
	y <= yt;
	
	process(vga_clk, rst)
	begin
		if (rst = '0') then
			xt <= (others => '0');
			yt <= (others => '0');
		elsif (vga_clk'event and vga_clk = '1') then
			if (xt = 799) then
				xt <= (others => '0');
				if (yt = 524) then
					yt <= (others => '0');
				else
					yt <= yt + 1;
				end if;
			else
				xt <= xt + 1;
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