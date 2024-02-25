--engineer: John kalomiros
--date: December 1, 2023
--This entity counts states 0 to 3 for a demux process which doubles the pixels in image lines

library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
--USE work.sgm_stereo_package.all;
USE work.two_stage_package.all;
--------------------------------
entity my_counter is
generic(max: positive := line_width/2);
	port(clk, resetn, enable: in std_logic;
		  counter_out: out natural range 0 to max);
end my_counter;

architecture up_counting of my_counter is
begin

	process(clk)
	variable m: natural range 0 to max := 0;
	begin 
	if rising_edge(clk) then
	if resetn = '0' then
		m := 0;
	else	
		if enable = '1' then
			if m < max then
				m := m + 1;
			else
				m := 1;
			end if;
		end if;
	end if;
	end if;
	counter_out <= m;
	end process;	

end up_counting;
	