library ieee;
use ieee.std_logic_1164.all;

package basic_settings is
	constant SCREEN_WIDTH: integer := 640;
	constant SCREEN_HEIGHT: integer := 480;

	constant GRIDS_ROWS: integer := 1;
	constant GRIDS_COLUMNS: integer := 2;
	constant GRIDS_AMOUNT: integer := GRIDS_ROWS * GRIDS_COLUMNS;
	constant GRIDS_LT_X: integer := 60;
	constant GRIDS_LT_Y: integer := 80;
	constant GRID_BITS: integer := 2;
	constant GRIDS_BITS: integer := GRID_BITS * GRIDS_AMOUNT;
	
	constant BRICK_WIDTH: integer := 40;
	constant BRICK_HEIGHT: integer := 30;
	
	constant CODE_BITS: integer := 6;
	constant INITIATION_CODE: std_logic_vector((CODE_BITS - 1) downto 0) := "110101";
	constant TERMINATION_CODE: std_logic_vector((CODE_BITS - 1) downto 0) := "111011";
end basic_settings;