library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use work.sgm_stereo_package.all;
USE work.two_stage_package.all;

entity im_buf is

generic(depth: positive:=line_width/2);

port(shiftin: in std_logic_vector(N - 1 downto 0);
	  clk, clken, resetn: in std_logic;
	  shiftout: out std_logic_vector(N - 1 downto 0));
end im_buf;	  

architecture shift_im of im_buf is
begin

	process(clk, resetn)
	variable q: OneD_im(0 to depth - 1);
	begin
	
	if resetn = '0' then
	
		q:= (OTHERS=>(OTHERS=>'0'));
	
	elsif clk'event AND clk = '1' then
	
	gen0: if clken ='1' then
	
				for i in depth - 1 downto 1 loop
				
					q(i) := q(i-1);
				
				end loop;
				
				q(0) := shiftin;
			
			end if;	
	
	end if;
	
	shiftout <= q(depth - 1);

	end process;
	
end shift_im;