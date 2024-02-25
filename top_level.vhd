--top level
--horizontal dir
--Dec 22, 2023
--Serres, by John Kalomiros

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sgm_stereo_package.all;
------------------------------------
entity top_level is
	port(image_in: in std_logic_vector(N - 1 downto 0);
		  clk, clken, resetn: in std_logic;
		  image_out: out std_logic_vector(7 downto 0)); --8 bits
end top_level;

architecture all_blocks of top_level is
signal clk2: std_logic;
signal im_stage1, im_stage2: std_logic_vector(N - 1 downto 0);

component two_stage_in is
	port(image_in: in std_logic_vector(N - 1 downto 0);
		  clk, clk2, clken, resetn: in std_logic;
		  stage1, stage2: out std_logic_vector(N - 1 downto 0));
end component;

component two_stage_out is
	port(im1_post, im2_post: in std_logic_vector(N - 1 downto 0);
		  clk, clk2, clken, resetn: in std_logic;
		  im_processed: out std_logic_vector(N - 1 downto 0));		  
end component;

begin

--Create the two stages for left and right image

clk_inst: clk_div port map(clk => clk, clk2 => clk2); --clk/2

input_2stage: two_stage_in port map(image_in => image_in, clk => clk, clk2 => clk2, clken => clken, resetn => resetn, stage1 => im_stage1, stage2 => im_stage2);

							 					
final_out_stage: two_stage_out port map(im1_post => im_stage1, im2_post => im_stage2, clk => clk, clk2 => clk2, clken => clken, resetn => resetn, im_processed => image_out);
						
	 
end all_blocks;										 

		  