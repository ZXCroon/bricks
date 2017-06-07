library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.basic_settings.all;

entity draw_bricks is
	port(
		x: in std_logic_vector(9 downto 0);
		y: in std_logic_vector(8 downto 0);
		grids_map: in std_logic_vector(0 to (GRIDS_BITS - 1));
		
		inside_which: out std_logic_vector(0 to (GRID_BITS - 1));
		x_r: out std_logic_vector(9 downto 0);
		y_r: out std_logic_vector(8 downto 0)
	);
end draw_bricks;

architecture bhv of draw_bricks is
	type int_array is array(0 to (GRIDS_AMOUNT - 1)) of integer;
	signal which_row, which_column: int_array;
	signal lt_x_array, lt_y_array: int_array;
	signal filtrated_grids_map: std_logic_vector(0 to (GRIDS_BITS - 1));
	signal summarized_grids_map: std_logic_vector(0 to (GRIDS_BITS - 1));
	signal summarized_grid: std_logic_vector(0 to (GRID_BITS - 1));
	signal zeros: std_logic_vector(0 to (GRID_BITS - 1));
begin
	zeros <= (others => '0');
	
--	gen_filter:
--	for k in 0 to GRIDS_AMOUNT - 1 generate
--		which_row(k) <= k / GRIDS_COLUMNS;
--		which_column(k) <= k rem GRIDS_COLUMNS;
--		lt_x_array(k) <= GRIDS_LT_X + which_column(k) * BRICK_WIDTH;
--		lt_y_array(k) <= GRIDS_LT_Y + which_row(k) * BRICK_HEIGHT;
--		filtrated_grids_map((k * GRID_BITS) to (k * GRID_BITS + GRID_BITS - 1)) <= 
--		          grids_map((k * GRID_BITS) to (k * GRID_BITS + GRID_BITS - 1))
--			when x >= conv_std_logic_vector(lt_x_array(k) + 1, 10) and
--				  x <= conv_std_logic_vector(lt_x_array(k) + BRICK_WIDTH - 1, 10) and
--				  y >= conv_std_logic_vector(lt_y_array(k) + 1, 9) and
--				  y <= conv_std_logic_vector(lt_y_array(k) + BRICK_HEIGHT - 1, 9)
--			else (others => '0');
--	end generate gen_filter;
--	
--	process(filtrated_grids_map)
--	begin
--		for k in 0 to GRIDS_AMOUNT - 1 loop
--			if (filtrated_grids_map((k * GRID_BITS) to (k * GRID_BITS + GRID_BITS - 1)) /= zeros) then
--				inside_which <= filtrated_grids_map((k * GRID_BITS) to (k * GRID_BITS + GRID_BITS - 1));
--				x_r <= x - conv_std_logic_vector(lt_x_array(k), 10);
--				y_r <= y - conv_std_logic_vector(lt_y_array(k), 9);
--			end if;
--		end loop;
--	end process;
	process(x, y, grids_map)
		variable r, c, k: integer;
	begin
		if (x >= GRIDS_LT_X and x <= GRIDS_LT_X + BRICK_WIDTH * GRIDS_COLUMNS and
		    y >= GRIDS_LT_Y and y <= GRIDS_LT_Y + BRICK_HEIGHT * GRIDS_ROWS) then
			c := conv_integer(x - GRIDS_LT_X) / BRICK_WIDTH;
			r := conv_integer(y - GRIDS_LT_Y) / BRICK_HEIGHT;
			k := r * GRIDS_COLUMNS + c;
			inside_which <= grids_map((k * GRID_BITS) to (k * GRID_BITS + GRID_BITS - 1));
			x_r <= x - conv_std_logic_vector(BRICK_WIDTH * c, 10);
			y_r <= y - conv_std_logic_vector(BRICK_HEIGHT * r, 9);
		else
			inside_which <= (others => '0');
			x_r <= (others => '0');
			y_r <= (others => '0');
		end if;
	end process;
end bhv;