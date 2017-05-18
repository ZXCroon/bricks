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
		
		inside: out boolean;
		r_out, b_out, g_out: out std_logic_vector(2 downto 0)
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
	
	gen_filter:
	for k in 0 to GRIDS_AMOUNT - 1 generate
		which_row(k) <= k / GRIDS_COLUMNS;
		which_column(k) <= k rem GRIDS_COLUMNS;
		lt_x_array(k) <= GRIDS_LT_X + which_column(k) * BRICK_WIDTH;
		lt_y_array(k) <= GRIDS_LT_Y + which_row(k) * BRICK_HEIGHT;
		filtrated_grids_map((k * GRID_BITS) to (k * GRID_BITS + GRID_BITS - 1)) <= 
		          grids_map((k * GRID_BITS) to (k * GRID_BITS + GRID_BITS - 1))
			when x >= conv_std_logic_vector(lt_x_array(k) + 1, 10) and
				  x <= conv_std_logic_vector(lt_x_array(k) + BRICK_WIDTH - 1, 10) and
				  y >= conv_std_logic_vector(lt_y_array(k) + 1, 9) and
				  y <= conv_std_logic_vector(lt_y_array(k) + BRICK_HEIGHT - 1, 9)
			else (others => '0');
	end generate gen_filter;
	
	summarized_grids_map(0 to (GRID_BITS - 1)) <= filtrated_grids_map(0 to (GRID_BITS - 1));
	gen_summary:
	for k in 1 to GRIDS_AMOUNT - 1 generate
		summarized_grids_map((k * GRID_BITS) to (k * GRID_BITS + GRID_BITS - 1)) <= 
		filtrated_grids_map((k * GRID_BITS) to (k * GRID_BITS + GRID_BITS - 1))
			when filtrated_grids_map((k * GRID_BITS) to (k * GRID_BITS + GRID_BITS - 1)) /= zeros
			else summarized_grids_map(((k - 1) * GRID_BITS) to (k * GRID_BITS - 1));
	end generate gen_summary;
	
	summarized_grid <= summarized_grids_map((GRIDS_BITS - GRID_BITS) to (GRIDS_BITS - 1));
	process(summarized_grid)
	begin
		if (summarized_grid = zeros) then
			inside <= false;
		else
			inside <= true;
			r_out <= "101";
			g_out <= "011";
			b_out <= "011";
		end if;
	end process;
end bhv;