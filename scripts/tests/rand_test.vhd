library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity rand_test is
	port(
		clk_100m: in std_logic;
		capture_sig: in std_logic;
		rand_s: in std_logic;
		output: out std_logic_vector(5 downto 0)
	);
end rand_test;

architecture bhv of rand_test is
	component rand_generator
		generic(
			lowerbound, upperbound: integer;
			seed, a, b: integer
		);
		port(
			clk_100m: in std_logic;
			capture_sig: in std_logic;
			time_varying_factor: in integer;
			output: out integer
		);
	end component;
	
	signal output_int: integer;
	signal time_varying_factor: integer;
begin
	time_varying_factor <= 323 when rand_s = '1' else 787;
	u: rand_generator generic map(0, 63, 123, 327, 433) port map(clk_100m, capture_sig, time_varying_factor, output_int);
	output <= conv_std_logic_vector(output_int, 6);
end bhv;