library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.key_coding.all;

entity tb is

end tb;

architecture bhv of tb is
	signal rstin: std_logic := '1';
	signal datain, clkin, fclk: std_logic := '0';
	signal confirm, quit, upp, downp: std_logic;
	signal leftp, rightp, shiftp: std_logic;
	signal board_speed: integer;

	constant HPfclk: time := 1ns;
	constant HPclkin: time := 10ns;
	constant Pclkin: time := 2*HPclkin;
	constant pause: time := 40ns;

	--function inv(vec: std_logic_vector) return std_logic_vector is
	--	variable ret: std_logic_vector(vec'range);
	--begin
	--	for i in 0 to vec'length-1 loop
	--		ret(i) := vec(vec'length - i);
	--	end loop;
	--	return ret;
	--end;

	procedure genkey(signal keydata: inout std_logic; constant coding: KeyVector) is
		variable parity: std_logic := '1';
	begin
		keydata <= '0';
		wait for Pclkin;
		for i in 0 to 7 loop
			parity := parity xor coding(i);
			keydata <= coding(i);
			wait for Pclkin;
		end loop;
		-- when data has even '1', parity=1
		keydata <= parity;
		wait for Pclkin;
		keydata <= '1';
		wait for Pclkin;
		keydata <= '0';
	end procedure;

	procedure genkeyclk(signal clk: inout std_logic) is
	begin
		for i in 0 to 10 loop
			clk <= '1';
			wait for HPclkin;
			clk <= '0';
			wait for HPclkin;
		end loop;
	end procedure;

	component keyboard_decoder is
		port(
			datain, clkin, fclk, rst_in: in std_logic;
			board_speed: out integer;
			-- 游戏流程的确认，取消
			confirm, quit, upp, downp: out std_logic
		);
	end component;
begin
	tentity: keyboard_decoder port map(datain, clkin, fclk, rstin, 
		board_speed,
		confirm, quit, upp, downp);

	fclk <= not fclk after HPfclk;

	datain_gen: process
	begin
		genkey(datain, key_z);
		wait for pause;
		genkey(datain, key_break);
		wait for pause;
		genkey(datain, key_z);
		wait;
	end process;

	clkin_gen: process
	begin
		genkeyclk(clkin);
		wait for pause;
		genkeyclk(clkin);
		wait for pause;
		genkeyclk(clkin);
		wait;
	end process;
end bhv;