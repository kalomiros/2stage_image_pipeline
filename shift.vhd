library ieee;
USE ieee.std_logic_1164.all;
--USE work.sgm_stereo_package.all;
USE work.two_stage_package.all;
--------------------------------
entity shift is
generic(pix_depth: positive := line_width/(2*line_width_div));
	port(im_in1, im_in2: in std_logic_vector(N - 1 downto 0);
		  clk, clken, resetn: in std_logic;
		  im_shift1, im_shift2: out std_logic_vector(N - 1 downto 0));
		  
end shift;

architecture shift_line of shift is
begin

im_shift1 <= im_in1;

my_buffer: im_buf generic map (depth => pix_depth) port map(shiftin => im_in2, clk => clk, resetn => resetn, 
																	     clken => clken, shiftout => im_shift2);
																		  
end shift_line;