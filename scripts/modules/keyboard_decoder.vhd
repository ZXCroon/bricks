library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.key_coding.all;

entity keyboard_decoder is
port(
	-- datain: ps2data; clkin: ps2 clock; fclk: filter clock;
	datain,clkin,fclk,rst_in: in std_logic;
	board_speed: out integer;
	-- 游戏流程的确认，取消
	confirm, quit, upp, downp: out std_logic
);
end keyboard_decoder;

architecture behave of keyboard_decoder is
	component KeyboardReader is
	port (
		datain, clkin : in std_logic ; -- PS2 clk and data
		fclk, rst : in std_logic ;  -- filter clock
		scancode : out std_logic_vector(7 downto 0) -- scan code signal output
	);
	end component;
	
	signal scancode, lastscancode: KeyVector;
	signal rst : std_logic;
	-- p stands for pressed
	signal leftp, rightp, shiftp: std_logic := '0';
begin
	rst<=not rst_in;
	kb: KeyboardReader port map(datain,clkin,fclk,rst,scancode);
	
	scancode_decoder: process(scancode, fclk) is
		variable isbreak: std_logic := '0';
	begin
		if(rising_edge(fclk)) then
			lastscancode <= scancode;
			if(scancode /= lastscancode) then
				case scancode is
					when key_break => isbreak := '1';
					when key_left =>
						leftp <= not isbreak;
						isbreak := '0';
					when key_right =>
						rightp <= not isbreak;
						isbreak := '0';
					when key_up =>
						upp <= not isbreak;
						isbreak := '0';
					when key_down =>
						downp <= not isbreak;
						isbreak := '0';
					when key_lshift =>
						shiftp <= not isbreak;
						isbreak := '0';
					when key_z =>
						confirm <= not isbreak;
						isbreak := '0';
					when key_x =>
						quit <= not isbreak;
						isbreak := '0';
					when others =>
				end case;
			end if;
		end if;
	end process;
	
	speed_converter: process(leftp, rightp, shiftp) is
		constant lowspeed: integer := 10;
		constant highspeed: integer := 5;
		variable link: std_logic_vector(1 downto 0);
	begin
		link := leftp & rightp;
		if(shiftp='0')then
			case link is
				when "00"|"11" => board_speed <= 0;
				when "01" => board_speed <= highspeed;
				when "10" => board_speed <= -highspeed;
			end case;
		else
			case link is
				when "00"|"11" => board_speed <= 0;
				when "01" => board_speed <= lowspeed;
				when "10" => board_speed <= -lowspeed;
			end case;
		end if;
	end process;
end behave;







