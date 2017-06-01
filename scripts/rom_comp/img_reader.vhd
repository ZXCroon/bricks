library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.img_coding.all;

entity img_reader is
	port (
		x: in std_logic_vector(9 downto 0);
		y: in std_logic_vector(8 downto 0);
		img: in img_info;
		clk: in std_logic;
		r, g, b: out std_logic_vector(2 downto 0);
		dataok: out std_logic
	);
end img_reader;

architecture bhv of img_reader is
	component rom_reader
		port (
			address		: in std_logic_vector (13 downto 0);
			clken		: in std_logic;
			clock		: in std_logic;
			q		: out std_logic_vector (8 downto 0)
		);
	end component;

	type statetype is (reading, output);
	signal state: statetype := reading;

	signal address: std_logic_vector(13 downto 0) := (others=>'0');
	signal add_int: integer range 0 to 2**14-1 := 0;
	signal romdata: std_logic_vector(8 downto 0);
	signal clken: std_logic := '0';
begin
	romreader: rom_reader port map(address, '1', clk, romdata);
	r <= romdata(8 downto 6);
	g <= romdata(5 downto 3);
	b <= romdata(2 downto 0);

	state_machine: process(state)
	begin
		if(rising_edge(clk)) then
			dataok <= '0';
			case state is
				when reading =>
					
		end if;
	end process;
end bhv;