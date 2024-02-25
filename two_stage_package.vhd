--SGM stereo processor work package
--by John Kalomiros, International Hellenic University
--February 2022
-----------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
------------------------------
package two_stage_package is

--DECLARATIONS OF CONSTANTS

constant N: natural range 0 to 32 := 8; --Number of bits in samples
constant line_width: positive range 1 to 4096 := 640;--it needs to be a multiple of 4, 8, 16, 32...
constant line_width_div: positive range 1 to 256 := 64;--it needs to be a power of 2


--TYPE DECLARATIONS
subtype std_sample is std_logic_vector(N + 1 downto 0);--8 bits
type OneD_std is array(natural range <>) of std_sample;

subtype im_sample is std_logic_vector(N - 1 downto 0);--10 bits
type OneD_im is array(natural range <>) of im_sample;

subtype count_val is natural range 0 to 2*line_width + 2;
type OneD_counter is array(natural range <>) of count_val;

--FUNCTIONS DECLARATIONS

function Log2( input:integer ) return integer; --finds the logarithm base 2 of an integer

--COMPONENT DECLARATIONS

component clk_div is
	port(clk: in std_logic;
		  clk2: out std_logic);
end component;

component my_counter is
generic(max: positive := line_width/2);
	port(clk, resetn, enable: in std_logic;
		  counter_out: out natural range 0 to max);
end component;

component im_buf is
generic(depth: positive:=line_width);
port(shiftin: in std_logic_vector(N - 1 downto 0);
	  clk, clken, resetn: in std_logic;
	  shiftout: out std_logic_vector(N - 1 downto 0));
end component;	 				  

component im_write_read is
generic(M: natural range 0 to 1024 := line_width/2);
	port(image_in: in std_logic_vector(N - 1 downto 0);
		  clk, clk2, clken, resetn: in std_logic;
		  image_mux1, image_mux2: out std_logic_vector(N - 1 downto 0));
end component;

component im_mem_out is
generic(M: natural range 0 to 2048 := line_width);
	port(im1, im2: in std_logic_vector(N - 1 downto 0);
		  clk, clk2, clken, resetn: in std_logic;
		  count_out: out natural range 0 to M + 2;
		  image_mem1, image_mem2: out std_logic_vector(N - 1 downto 0));
end component;

component swap is
generic(D: positive := line_width/(2*line_width_div));
	port(im_in1, im_in2: in std_logic_vector(N - 1 downto 0);
		  pixel_counter: in natural range 0 to 2*line_width + 2;
		  im_sw1, im_sw2: out std_logic_vector(N - 1 downto 0));	  
end component;

component swap_out is
generic(D: positive := line_width/(2*line_width_div));
	port(im_in1, im_in2: in std_logic_vector(N - 1 downto 0);
		  pixel_counter: in natural range 0 to 2*line_width + 2;
		  im_sw1, im_sw2: out std_logic_vector(N - 1 downto 0));	  
end component;

component shift is --accepts both images but shifts the second
generic(pix_depth: positive := line_width/(2*line_width_div));
	port(im_in1, im_in2: in std_logic_vector(N - 1 downto 0);
		  clk, clken, resetn: in std_logic;
		  im_shift1, im_shift2: out std_logic_vector(N - 1 downto 0));		  
end component;


component shift_im_buffer is
generic(depth: positive := line_width);
port(shiftin: in std_logic_vector(N - 1 downto 0); --OneD_std(0 to dmax - 1);
	  clk, clken, resetn: in std_logic;
	  shiftout: out std_logic_vector(N - 1 downto 0)); --OneD_std(0 to dmax - 1));
end component;

end package;
-----------------------
package body two_stage_package is

	function Log2( input:integer ) return integer is --This function finds the logarithm base 2 of an integer number
	variable temp,log:integer;
	begin
	temp:=input;
	log:=0;
	temp:=temp/2;
	while (temp /= 0) loop
	temp:=temp/2;
	log:=log+1;
	end loop;
	return log;
	end function log2;
	
end package body;