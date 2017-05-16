library ieee;
use ieee.std_logic_1164.all;
use work.basic_settings.all;

entity serial_to_parallel is
	port(
		clk: in std_logic;
		ena: in std_logic;
		input: in std_logic;
		valid: out std_logic;
		output: out std_logic_vector(0 to GRIDS_BITS - 1)
	);
end serial_to_parallel;


architecture bhv of serial_to_parallel is
	type state is (initiation_state, reading_state, termination_state);
	
	signal temp_valid: std_logic;
	signal temp_output: std_logic_vector(0 to GRIDS_BITS - 1);
	shared variable final_output: std_logic_vector(0 to GRIDS_BITS - 1);
	signal current_state: state := initiation_state;
begin
	valid <= ena and temp_valid;
	output <= final_output;

	process(clk)
		variable flag: integer := 0;
	begin
		if (clk'event and clk = '1') then
			case current_state is
				when initiation_state =>
					if (input = INITIATION_CODE(CODE_BITS - 1 - flag)) then
						if (flag = CODE_BITS - 1) then
							flag := 0;
							current_state <= reading_state;
						else
							flag := flag + 1;
						end if;
					else
						flag := 0;
					end if;
				when reading_state =>
					temp_output(flag) <= input;
					if (flag = GRIDS_BITS - 1) then
						flag := 0;
						current_state <= termination_state;
					else
						flag := flag + 1;
					end if;
				when termination_state =>
					if (input = TERMINATION_CODE(CODE_BITS - 1 - flag)) then
						if (flag = CODE_BITS - 1) then
							flag := 0;
							current_state <= initiation_state;
							final_output := temp_output;
							temp_valid <= '1';
						else
							flag := flag + 1;
						end if;
					else
						flag := 0;
						current_state <= initiation_state;
					end if;
				when others =>
					flag := 0;
					current_state <= initiation_state;
			end case;
		end if;
	end process;
end bhv;