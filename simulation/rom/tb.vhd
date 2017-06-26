library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.math_real.all;
use work.img_coding.all;

entity tb is

end tb;

architecture bhv of tb is
	component img_reader is
		port (
			x: in std_logic_vector(9 downto 0);
			y: in std_logic_vector(8 downto 0);
			img: in img_info;
			-- outclk frequnceny = inclk freq * 2
			inclk: in std_logic;
			clken: in std_logic;
			r, g, b: out std_logic_vector(2 downto 0);
			dataok: out std_logic := '0'
		);
	end component;

	signal x: std_logic_vector(9 downto 0) := (others=>'0');
	signal y: std_logic_vector(8 downto 0) := (others=>'0');
	signal img: img_info := img_info'left;
	signal inclk, dataok: std_logic := '0';
	signal r, g, b: std_logic_vector(2 downto 0);
	signal q: std_logic_vector(8 downto 0);
	signal clken: std_logic := '1';

	signal qqq: std_logic;

	constant Pinclk: time := 5ns;
	constant Poutclk: time := Pinclk/2;

	function randint(l, r: integer) return integer is
		variable s1, s2: positive := 123;
		variable ran: real;
		variable ret: integer;
	begin
		uniform(s1, s2, ran);
		ret := integer(trunc(ran*real(r-l))) + l;
		return ret;
	end function;
begin
	tentity: img_reader port map(x, y, img, inclk, clken, r, g, b, dataok);
	inclk <= not inclk after Pinclk/2;
	--outclk <= not outclk after Poutclk/2;
	q <= r&g&b;

	process(dataok)
		variable count: integer range 0 to 2 := 0;
	begin
		if(rising_edge(dataok)) then
			if(q="111111111") then
				qqq <= '1';
			else
				qqq <= '0';
			end if;
			img <= img_info'rightof(img);
			x <= conv_std_logic_vector(randint(0, width_dic(img)-2), x'length);
			y <= conv_std_logic_vector(randint(0, 5), y'length);
		end if;
	end process;
end bhv;