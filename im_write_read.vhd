library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
--USE work.sgm_stereo_package.all;
USE work.two_stage_package.all;
--------------------------------
entity im_write_read is
generic(M: natural range 0 to 1024 := line_width/2);
	port(image_in: in std_logic_vector(N - 1 downto 0);
		  clk, clk2, clken, resetn: in std_logic;
		  image_mux1, image_mux2: out std_logic_vector(N - 1 downto 0));
end im_write_read;

architecture memory of im_write_read is

component mem_2clk is
generic (mem_depth: positive range 1 to 2048 := line_width);
	port(mem_in: in std_logic_vector(N - 1 downto 0);
		  rd, wr: in std_logic;
		  clk, clk2, clken, resetn: in std_logic;
		  address_wr, address_rd: in natural range 0 to mem_depth + 2;
		  mem_out: out std_logic_vector(N - 1 downto 0));
end component;

component mem_in_control is
generic(C: positive range 1 to 2048 := line_width/2);
	port(clk, clk2, clken, resetn: in std_logic;
		  address_rd, address_wr: out natural range 0 to C + 2;
		  rd, wr: out std_logic);
end component;

--signal cp1, cp2: OneD_im(0 to M) := (OTHERS => (OTHERS => '0'));
signal image_shift: std_logic_vector(N - 1 downto 0); 
signal rd_mem1, wr_mem1: std_logic;
signal address_wr1, address_rd1: natural range 0 to line_width + 2;
begin

my_buffer: im_buf generic map (depth => M) port map(shiftin => image_in, clk => clk, resetn => resetn, 
																	     clken => clken, shiftout => image_shift);
																		  
control_12: mem_in_control generic map(C => M) port map(clk => clk, clk2 => clk2, clken => clken, resetn => resetn, 
											                       address_rd => address_rd1, address_wr => address_wr1, rd => rd_mem1, wr => wr_mem1);																		  

mem1: mem_2clk generic map(mem_depth => M) port map(mem_in => image_in, rd => rd_mem1, wr => wr_mem1, clk => clk, clk2 => clk2, clken => clken, resetn => resetn, 
								                            address_wr => address_wr1, address_rd => address_rd1, mem_out => image_mux1);	
			
mem2: mem_2clk generic map(mem_depth => M) port map(mem_in => image_shift, rd => rd_mem1, wr => wr_mem1, clk => clk, clk2 => clk2, clken => clken, resetn => resetn, 
								                            address_wr => address_wr1, address_rd => address_rd1, mem_out => image_mux2);		

end memory;	
	
		  