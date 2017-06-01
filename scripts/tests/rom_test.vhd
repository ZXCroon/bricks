library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity rom_test is
	port (
		
	);
end rom_test;

architecture bhv of rom_test is
	component rom_reader IS
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (12 DOWNTO 0);
			clken		: IN STD_LOGIC;
			clock		: IN STD_LOGIC;
			q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
		);
	END component;
begin
	
end bhv;