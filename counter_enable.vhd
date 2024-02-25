--engineer: John kalomiros
--date: December 1, 2023
--This entity counts states 0 to 3 for a demux process which doubles the pixels in image lines

library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
--USE work.sgm_stereo_package.all;
USE work.two_stage_package.all;
--------------------------------
entity counter_enable is
generic(max: positive := line_width/2);
	port(clk, resetn, enable: in std_logic;
		  counter_enable: out std_logic:= '0');
end counter_enable;

architecture up_count_en of counter_enable is

begin

	process(clk)
	variable m: natural range 0 to (max/2)*(line_width_div - 1) + 1 := 0;
	variable count_en: std_logic := '0';
	begin 
	if rising_edge(clk) then
	if resetn = '0' then
		m := 0;
	else	
		if enable = '1' AND count_en = '0' then
			if m < (max/2)*(line_width_div - 1)  then
				m := m + 1;
				count_en := '0';
			else
				count_en := '1';
			end if;
		end if;
	end if;
	end if;
	counter_enable <= count_en;
	end process;	

end up_count_en;
	