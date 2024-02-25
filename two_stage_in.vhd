library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.two_stage_package.all;
--------------------------------
entity two_stage_in is
	port(image_in: in std_logic_vector(N - 1 downto 0);
		  clk, clk2, clken, resetn: in std_logic;
		  stage1, stage2: out std_logic_vector(N - 1 downto 0));
		  
end two_stage_in;

architecture construct of two_stage_in is


signal im12, im21: OneD_im(natural range 0 to (2*Log2(line_width_div) + 1)):=(OTHERS => (OTHERS => '0')) ;
signal im_out12, im_out21: OneD_im(natural range 0 to (2*Log2(line_width_div) + 1)):=(OTHERS => (OTHERS => '0')) ;
signal im_double1, im_double2, im1_out, im2_out, im1_out_stage, im2_out_stage, im_test1, im_test2: std_logic_vector(N - 1 downto 0):=(OTHERS => '0') ;
signal pixel_counter2, pixel_count1, pixel_count2: natural range 0 to 2*line_width + 2;
signal pixel_count: OneD_counter(1 to Log2(line_width_div));
signal pixel_count_in: OneD_counter(0 to 2*Log2(line_width_div) + 1);  
signal rep: natural range 0 to 16;
begin

rep <= Log2(line_width_div);

pix_counter2: my_counter generic map(max => line_width) port map(clk => clk2, resetn => resetn, enable => clken, counter_out => pixel_counter2);

----Build pixel-doubling pipeline for fast processing of streaming images with data dependency

write_read_in: im_write_read generic map(M => line_width/(2*line_width_div)) port map(image_in => image_in, clk => clk, clk2 => clk2, clken => clken, resetn => resetn, 
																												  image_mux1 => im_double1, image_mux2 => im_double2);

																		

----line_width/(2*line_width_div) needs to be an integer number
																						
im12(2*Log2(line_width_div) + 1) <= im_double1; -- for line_width_div = 8, 4, 2, 1 this is 7, 5, 3, 1

im21(2*Log2(line_width_div) + 1) <= im_double2;
							

--Unfold the pixel-doubling process

gen_in: for i in Log2(line_width_div) downto 1 generate 

pixel_count_i: my_counter generic map(max => line_width/(2**i)) port map(clk => clk2, resetn => resetn, enable => clken, counter_out => pixel_count(i));

swap_i: swap generic map(D => line_width/(2*(2**i))) port map(im_in1 => im12(2*i + 1), im_in2 => im21(2*i + 1), pixel_counter => pixel_count(i), im_sw1 => im12(2*i), im_sw2 => im21(2*i));

shift_i: shift generic map(pix_depth => line_width/(2*(2**i))) port map(im_in1 => im12(2*i), im_in2 => im21(2*i), clk => clk2, clken => clken, 
																								resetn => resetn, im_shift1 => im12(2*i - 1), im_shift2 => im21(2*i - 1));

end generate gen_in;

	
im12(0) <= im12(1) when pixel_counter2 <= line_width/2 else im21(1); --final swap

im21(0) <= im21(1) when pixel_counter2 <= line_width/2 else im12(1);

stage1 <= im12(0); --final result of the pixel doubling process. These two lines give input to the two-stage pipeline
stage2 <= im21(0);

end construct;