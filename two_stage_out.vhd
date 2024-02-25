library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
--USE work.sgm_stereo_package.all;
USE work.two_stage_package.all;
--------------------------------
entity two_stage_out is
	port(im1_post, im2_post: in std_logic_vector(N - 1 downto 0);
		  clk, clk2, clken, resetn: in std_logic;
		  im_processed: out std_logic_vector(N - 1 downto 0));
		  
end two_stage_out;

architecture out_construct of two_stage_out is


signal im12, im21: OneD_im(natural range 0 to (2*Log2(line_width_div) + 1)):=(OTHERS => (OTHERS => '0')) ;
signal im_out12, im_out21: OneD_im(natural range 0 to (2*Log2(line_width_div) + 1)):=(OTHERS => (OTHERS => '0')) ;
signal im1_out_stage, im2_out_stage, im1_out, im2_out: std_logic_vector(N - 1 downto 0):=(OTHERS => '0') ;
signal pixel_counter2, pixel_count1, pixel_count2: natural range 0 to 2*line_width + 2;
signal pixel_count: OneD_counter(1 to Log2(line_width_div));
signal pixel_count_in, pixel_count_out: OneD_counter(0 to 2*Log2(line_width_div) + 1);  
signal rep: natural range 0 to 16;
begin

rep <= Log2(line_width_div);


pix_counter2: my_counter generic map(max => line_width) port map(clk => clk2, resetn => resetn, enable => clken, counter_out => pixel_counter2);


process(clk2)
begin
	if rising_edge(clk2) then
		pixel_count1 <= pixel_count2;
	end if;
end process;																				

----line_width/(2*line_width_div) needs to be an integer number
							

--The two double-pixel lines im1_post and im2_post have been processed by the two-stage pipeline and now they are output to the rolling algorithm that folds back the mux process

im_out12(0) <= im1_post when pixel_counter2 <= line_width/2 else im2_post; --first out-swap 

im_out21(0) <= im2_post when pixel_counter2 <= line_width/2 else im1_post;

--fold according to reverse process to produce output 

gen_out: for i in  0 to Log2(line_width_div) - 1 generate 

pixel_count_i: my_counter generic map(max => line_width/(2**(i + 1))) port map(clk => clk2, resetn => resetn, enable => clken, counter_out => pixel_count_in(i));


pixel_count_out(i) <= pixel_count_in(i);
																								
																				  
shift_i_o: shift generic map(pix_depth => line_width/(2*(2**(i + 1)))) port map(im_in1 => im_out21(2*i), im_in2 => im_out12(2*i), clk => clk2, clken => clken, 
																										  resetn => resetn, im_shift1 => im_out21(2*i + 1), im_shift2 => im_out12(2*i + 1));	--im12 is shifted																							

swap_i_o: swap_out generic map(D => line_width/(2*(2**(i + 1)))) port map(im_in1 => im_out12(2*i + 1), im_in2 => im_out21(2*i + 1), pixel_counter => pixel_count_out(i), 
																								  im_sw1 => im_out12(2*i + 2), im_sw2 => im_out21(2*i + 2));
																								
end generate gen_out;


im_out12(2*Log2(line_width_div) + 1) <= im_out21(2*rep) when pixel_count2 <= line_width/(2*(2**rep)) else im_out12(2*rep); --final out-stage swap 

im_out21(2*Log2(line_width_div) + 1) <= im_out12(2*rep) when pixel_count2 <= line_width/(2*(2**rep)) else im_out21(2*rep);

im1_out_stage <= im_out21(2*rep + 1);
im2_out_stage <= im_out12(2*rep + 1);

--After this final swap, im1_out_stage and im2_out_stage are input to the im_mem_out out_stage. Out_stage outputs im1_out and im2_out.

out_stage: im_mem_out generic map(M => line_width/(line_width_div)) port map(im1 => im1_out_stage, im2 => im2_out_stage, clk => clk, clk2 => clk2,   
																									  clken => clken, resetn => resetn, count_out => pixel_count2, 
																									  image_mem1 => im1_out, image_mem2 => im2_out);



--recontruction of original image

im_processed <= im1_out when pixel_count1 > line_width/(2*line_width_div) else im2_out;

end out_construct;