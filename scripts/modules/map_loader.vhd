library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.basic_settings.all;

entity map_loader is
	port (
		clk, ena: in std_logic; -- 25m
		grids_map_load: out std_logic_vector(0 to (GRIDS_BITS - 1))
	);
end map_loader;

architecture bhv of map_loader is
	component convert_risingedge is
		port(
			-- fclk: filter clock, clkin: 想检测上升沿的时钟
			fclk, clkin: in std_logic;
			clk: out std_logic
		);
	end component;

	component rom_reader_map
		PORT (
			address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			clken		: IN STD_LOGIC  := '1';
			clock		: IN STD_LOGIC  := '1';
			q		: OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
		);
	end component;

	signal ena_narrow, ena_load, clken: std_logic := '0';
	signal address: std_logic_vector(7 downto 0) := (others=>'0');
	signal q: std_logic_vector(0 downto 0);
	signal romdata: std_logic;

	signal addint: integer range 0 to GRIDS_BITS+2;
	signal dataint: integer range -2 to GRIDS_BITS;
begin
	clken <= ena_load;
	dataint <= addint-2;
	romdata <= '0' when q="0" else '1';

	process(clk, ena_narrow, addint, dataint, ena_load)
	begin
		if(rising_edge(clk) and ena_narrow='1') then
			ena_load <= '1';
			addint <= 0;
		end if;

		if(rising_edge(clk) and ena_load='1') then
			addint <= addint + 1;
			-- 读取完毕，终止
			if(dataint=GRIDS_BITS-1) then
				ena_load <= '0';
			end if;
			if(dataint>=0) then
				grids_map_load(dataint) <= romdata;
			end if;
		end if;
	end process;

	address <= conv_std_logic_vector(addint, address'length);

	map_rom: rom_reader_map port map(address, clken, clk, q);
	cvt_ena: convert_risingedge port map(clk, ena, ena_narrow);
end bhv;