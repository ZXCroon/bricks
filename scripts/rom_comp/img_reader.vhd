library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.img_coding.all;
use work.img_coding2v.all;

-- 使用方式
-- 在rising_edge(dataok)时, 读取romdata, 并且准备好下一个请求的address
-- 之后在间隔一个clk跳变之后即可读取到新的data

entity img_reader is
	port (
		x: in std_logic_vector(9 downto 0);
		y: in std_logic_vector(8 downto 0);
		img: in img_info;
		img2v: in img_info2v;
		img_flag: in std_logic;
		-- outclk frequnceny = inclk freq * 2
		inclk: in std_logic;
		clken: in std_logic;
		r, g, b: out std_logic_vector(2 downto 0);
		dataok: out std_logic := '0'
	);
end img_reader;

architecture bhv of img_reader is
	component rom_reader
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (16 DOWNTO 0);
			clken		: IN STD_LOGIC  := '1';
			clock		: IN STD_LOGIC  := '1';
			q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
		);
	end component;
	
	component rom_reader_1
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			clock		: IN STD_LOGIC  := '1';
			q		: OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
		);
	end component;

	type statetype is (read_add, waiting1, waiting2, output);
	signal state: statetype := read_add;

	signal address: std_logic_vector(16 downto 0) := (others => '0');
	signal address2v: std_logic_vector(15 downto 0) := (others => '0');
	signal romdata: std_logic_vector(8 downto 0);
	signal romdata2v: std_logic_vector(0 downto 0);
	
	signal rt, gt, bt: std_logic_vector(2 downto 0);
	signal filled: std_logic;

	signal addint: integer range 0 to 2**address'length-1 := 0;
	signal addint2v: integer range 0 to 2**address2v'length-1 := 0;
begin
	romreader: rom_reader port map(address, clken, inclk, romdata);
	romreader2v: rom_reader_1 port map(address2v, inclk, romdata2v);
	address <= conv_std_logic_vector(addint, address'length);
	address2v <= conv_std_logic_vector(addint2v, address2v'length);
	rt <= romdata(8 downto 6);
	gt <= romdata(5 downto 3);
	bt <= romdata(2 downto 0);
	filled <= romdata2v(0);
	
	r <= rt when img_flag = '0' else "111" when filled = '1' else "000";
	g <= gt when img_flag = '0' else "111" when filled = '1' else "000";
	b <= bt when img_flag = '0' else "111" when filled = '1' else "000";

	state_machine: process(state, inclk)
	begin
		if(rising_edge(inclk)) then
			dataok <= '0';
			case state is
				--when ready =>
				--	addint <= addtmp;
				--	state <= read_add;
				when read_add =>
					if(clken='1') then
						state <= waiting1;
					end if;
				when waiting1 =>
					state <= waiting2;
				when waiting2 =>
					state <= output;
				when output =>
					dataok <= '1';
					state <= read_add;
				when others =>
					state <= read_add;
			end case;
		end if;
	end process;

	data_address: process(x, y, img, img2v)
		variable xint, yint: integer; -- range addint'low to addint'high;
	begin
		xint := conv_integer(x);
		yint := conv_integer(y);
		addint <= offset_dic(img) + xint + yint * width_dic(img);
		addint2v <= offset_dic2v(img2v) + xint + yint * width_dic2v(img2v);
	end process;
end bhv;