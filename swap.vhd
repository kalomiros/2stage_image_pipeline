library ieee;
USE ieee.std_logic_1164.all;
--USE work.sgm_stereo_package.all;
USE work.two_stage_package.all;
--------------------------------
entity swap is
generic(D: positive := line_width/(2*line_width_div));
	port(im_in1, im_in2: in std_logic_vector(N - 1 downto 0);
		  pixel_counter: in natural range 0 to 2*line_width + 2;
		  im_sw1, im_sw2: out std_logic_vector(N - 1 downto 0));
		  
end swap;

architecture interchange of swap is

begin

im_sw1 <= im_in1 when pixel_counter <= D else im_in2; --swap

im_sw2 <= im_in2 when pixel_counter <= D else im_in1;

end interchange;