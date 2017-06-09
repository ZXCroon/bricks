library ieee;
use ieee.std_logic_1164.all;

package basic_settings is
	constant SCREEN_WIDTH: integer := 640;
	constant SCREEN_HEIGHT: integer := 480;

	constant GRIDS_ROWS: integer := 7;
	constant GRIDS_COLUMNS: integer := 13;

	constant GRIDS_AMOUNT: integer := GRIDS_ROWS * GRIDS_COLUMNS;
	constant GRIDS_LT_X: integer := 60;
	constant GRIDS_LT_Y: integer := 80;
	constant GRID_BITS: integer := 2;
	constant GRIDS_BITS: integer := GRID_BITS * GRIDS_AMOUNT;
	
	constant BRICK_WIDTH: integer := 40;
	constant BRICK_HEIGHT: integer := 15;
	
	constant NORMAL_BALL_RADIUS: integer := 8;
	constant SMALL_BALL_RADIUS: integer := 4;
	constant BIG_BALL_RADIUS: integer := 12;
	
	constant NORMAL_PLATE_LEN: integer := 100;
	constant SHORT_PLATE_LEN: integer := 70;
	constant LONG_PLATE_LEN: integer := 130;
	constant PLATE_WIDTH: integer := 5;
	
	constant CODE_BITS: integer := 6;
	constant INITIATION_CODE: std_logic_vector((CODE_BITS - 1) downto 0) := "110101";
	constant TERMINATION_CODE: std_logic_vector((CODE_BITS - 1) downto 0) := "111011";
	
	constant MIN_VELOCITY_VALUE_X: integer := 100;
	
	constant CARD_SIDE: integer := 20;
	constant CARD_GENS: integer := 3;
end basic_settings;