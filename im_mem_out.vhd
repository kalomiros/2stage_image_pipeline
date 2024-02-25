library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
--USE work.sgm_stereo_package.all;
USE work.two_stage_package.all;
--------------------------------
entity im_mem_out is
generic(M: natural range 0 to 2048 := line_width);
	port(im1, im2: in std_logic_vector(N - 1 downto 0);
		  clk, clk2, clken, resetn: in std_logic;
		  count_out: out natural range 0 to M + 2;
		  image_mem1, image_mem2: out std_logic_vector(N - 1 downto 0));
end im_mem_out;

architecture two_mem_stage of im_mem_out is

component mem_2clk is
generic (mem_depth: positive range 1 to 2048 := line_width);
	port(mem_in: in std_logic_vector(N - 1 downto 0);
		  rd, wr: in std_logic;
		  clk, clk2, clken, resetn: in std_logic;
		  address_wr, address_rd: in natural range 0 to mem_depth + 2;
		  mem_out: out std_logic_vector(N - 1 downto 0));
end component;

component mem_out_control is
generic(C: positive range 1 to 2048 := line_width);
	port(clk, clk2, clken, resetn: in std_logic;
		  address_rd, address_wr1, address_wr2: out natural range 0 to C + 2;
		  rd, wr: out std_logic);
end component;
 
signal rd_mem, wr_mem: std_logic;
signal address_wr1, address_wr2, address_rd: natural range 0 to M + 2;
begin
																		  
control_1: mem_out_control generic map(C => M) port map(clk => clk, clk2 => clk2, clken => clken, resetn => resetn,
																		  address_rd => address_rd, address_wr1 => address_wr1, address_wr2 => address_wr2, rd => rd_mem, wr => wr_mem);																		  

mem1: mem_2clk generic map(mem_depth => M) port map(mem_in => im1, rd => rd_mem, wr => wr_mem, clk => clk2, clk2 => clk, clken => clken, resetn => resetn, 
								                            address_wr => address_wr1, address_rd => address_rd, mem_out => image_mem1);	
			
mem2: mem_2clk generic map(mem_depth => M) port map(mem_in => im2, rd => rd_mem, wr => wr_mem, clk => clk2, clk2 => clk, clken => clken, resetn => resetn, 
								                            address_wr => address_wr2, address_rd => address_rd, mem_out => image_mem2);		

count_out <= address_wr1;
																	 
end two_mem_stage;	
	
		  