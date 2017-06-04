library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.key_coding.all;

entity keyboard_decoder is
port(
	-- datain: ps2data; clkin: ps2 clock; fclk: filter clock;
	datain, clkin, fclk, rst_in: in std_logic;
	board_speed: out integer := 0;
	-- 游戏流程的确认，取消
	confirm, quit, upp, downp: out std_logic := '0'
);
end keyboard_decoder;

architecture behave of keyboard_decoder is
	component KeyboardReader is
	port (
		datain, clkin : in std_logic ; -- PS2 clk and data
		fclk, rst : in std_logic ;  -- filter clock
		dataok : buffer std_logic ;  -- data output enable signal
		scancode : out std_logic_vector(7 downto 0) -- scan code signal output
	);
	end component;
	
	signal scancode: KeyVector;
	signal rst, dataok: std_logic;
	-- p stands for pressed
	signal leftp, rightp, shiftp: std_logic := '0';
	signal isbreak, ise0 : std_logic := '0';
begin
	rst<=not rst_in;
	
	kb: KeyboardReader port map(datain, clkin, fclk, rst, dataok, scancode);
	
	scancode_decoder: process(scancode, fclk, rst, dataok) is
--		variable isbreak: std_logic := '0';
	begin
		if (rst='1') then
			leftp <= '0'; rightp <= '0'; shiftp <= '0';
			upp <= '0'; downp <= '0'; confirm <= '0'; quit <= '0'; 
			isbreak <= '0';
		-- dataok 0->1 means scancode has been updated
		elsif(rising_edge(dataok)) then
			case scancode is
				when key_break => isbreak <= '1';
				when key_e0 => ise0 <= '1';
				when key_up =>
					upp <= not isbreak;
					isbreak <= '0';
					ise0 <= '0';
				when key_down =>
					downp <= not isbreak;
					isbreak <= '0';
					ise0 <= '0';
				when key_left =>
					leftp <= not isbreak;
					isbreak <= '0';
					ise0 <= '0';
				when key_right =>
					rightp <= not isbreak;
					isbreak <= '0';
					ise0 <= '0';
				when key_lshift =>
					-- when holding shift and pressing arrow key
					-- keyboard will send e0 f0 12(shift breakcode)
					-- this can prevent unexpected breakcode
					if(ise0='0') then
						shiftp <= not isbreak;
					end if;
					isbreak <= '0';
					ise0 <= '0';
				when key_z =>
					confirm <= not isbreak;
					isbreak <= '0';
					ise0 <= '0';
				when key_x =>
					quit <= not isbreak;
					isbreak <= '0';
					ise0 <= '0';
				when others => null;
			end case;
		end if;
	end process;
	
	speed_converter: process(leftp, rightp, shiftp) is
		constant lowspeed: integer := 100;
		constant highspeed: integer := 50;
		variable link: std_logic_vector(1 downto 0);
	begin
		link := leftp & rightp;
		if(shiftp='0')then
			case link is
				when "00"|"11" => board_speed <= 0;
				when "01" => board_speed <= highspeed;
				when "10" => board_speed <= -highspeed;
				when others => null;
			end case;
		else
			case link is
				when "00"|"11" => board_speed <= 0;
				when "01" => board_speed <= lowspeed;
				when "10" => board_speed <= -lowspeed;
				when others => null;
			end case;
		end if;
	end process;
end behave;







