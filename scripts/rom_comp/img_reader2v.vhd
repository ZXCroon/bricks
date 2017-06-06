library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.img_coding2v.all;

-- 使用方式
-- 在rising_edge(dataok)时, 读取romdata, 并且准备好下一个请求的address
-- 之后在间隔一个clk跳变之后即可读取到新的data

entity img_reader2v is
	port (
		x: in std_logic_vector(9 downto 0);
		y: in std_logic_vector(8 downto 0);
		img2v: in img_info2v;
		-- outclk frequnceny = inclk freq * 2
		inclk: in std_logic;
		clken: in std_logic;
		filled: out std_logic;
		dataok: out std_logic := '0'
	);
end img_reader2v;

architecture bhv of img_reader2v is
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

	signal address: std_logic_vector(15 downto 0) := (others=>'0');
	signal romdata: std_logic_vector(0 downto 0);

	signal addint: integer range 0 to 2**address'length-1 := 0;
begin
	romreader: rom_reader_1 port map(address, inclk, romdata);
	address <= conv_std_logic_vector(addint, address'length);
	filled <= romdata(0);

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

	data_address: process(x, y, img2v)
		variable xint, yint: integer; -- range addint'low to addint'high;
	begin
		xint := conv_integer(x);
		yint := conv_integer(y);
		addint <= offset_dic2v(img2v) + xint + yint * width_dic2v(img2v);
	end process;
end bhv;