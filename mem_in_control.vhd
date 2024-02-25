--This module produces consecutive addresses and rd/wr signals for mem_2clk
--mem_2clk is a two clock domain memory. It writes with clk2 and reads with clk.
--clk2 has hafl the frequency of clk
--By John Kalomiros
--date: 10/12/2023

library ieee;
USE ieee.std_logic_1164.all;
--USE ieee.numeric_std.all;
--USE work.sgm_stereo_package.all;
USE work.two_stage_package.all;
--------------------------------
entity mem_in_control is
generic(C: positive range 1 to 2048 := line_width/2);
	port(clk, clk2, clken, resetn: in std_logic;
		  address_rd, address_wr: out natural range 0 to C + 2;
		  rd, wr: out std_logic);
end mem_in_control;

architecture control of mem_in_control is
begin

--write process
 process(clk, resetn)

variable address_write: natural range 0 to C + 2;--

begin

if resetn = '0' then

	address_write := 0;
	
elsif rising_edge(clk) then

	if (clken = '1') then
		
		address_write := address_write + 1;
			
			if (address_write = C + 1) then --
			
					address_write := 1;--
						
			end if;
			
	end if;
		
end if;
		
address_wr <= address_write;
		
end process;

--read process
process(clk2, resetn)

variable address_read: natural range 0 to C + 2; --

begin

if resetn = '0' then

	address_read := 0;
	
elsif rising_edge(clk2) then

	if (clken = '1') then
	
		address_read := address_read + 1;
			
			if (address_read = C + 1) then --
			
					address_read := 1;--
						
			end if;
			
	end if;
		
end if;
		
address_rd <= address_read;
		
end process;

process(resetn)

begin

if (resetn = '0') then

	rd <= '0'; wr <= '0'; 
	
else

	rd <= '1'; wr <= '1'; 
	
end if;

end process;

end control;