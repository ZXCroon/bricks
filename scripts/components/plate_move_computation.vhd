library ieee;
use ieee.std_logic_1164.all;
use work.geometry.all;
use work.info.all;

entity plate_move_computation is
	port(
		clk: in std_logic;
		plate: in plate_info;
		plate_move: in integer;
		set: out std_logic;
		plate_next: out plate_info
	);
end plate_move_computation;

architecture bhv of plate_move_computation is
	signal move_abs: integer;
	signal delta: vector;
	signal set_t: std_logic := '0';
begin
	set <= set_t;

	move_abs <= plate_move when plate_move >= 0 else -plate_move;
	delta <= (1, 0) when plate_move >= 0 else (-1, 0);
	
	process(clk)
		variable cnt: integer := 0;
	begin
		if (clk'event and clk = '1') then
			if (cnt >= move_abs - 1) then
				cnt := 0;
				plate_next <= construct_plate_info(plate.l_position + delta, plate.len, plate.class);
			else
				cnt := cnt + 1;
				plate_next <= plate;
			end if;
			
			set_t <= '1';
		end if;
	end process;
end bhv;