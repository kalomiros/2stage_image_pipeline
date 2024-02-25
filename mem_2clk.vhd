library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use work.sgm_stereo_package.all;
USE work.two_stage_package.all;
----------------------------------
entity mem_2clk is
generic (mem_depth: positive range 1 to 2048 := line_width);
	port(mem_in: in std_logic_vector(N - 1 downto 0);
		  rd, wr: in std_logic;
		  clk, clk2, clken, resetn: in std_logic;
		  address_wr, address_rd: in natural range 0 to mem_depth + 2;
		  mem_out: out std_logic_vector(N - 1 downto 0):=(OTHERS => '0'));
end mem_2clk;

architecture two_clock_mem of mem_2clk is

signal arrayL1: OneD_im(0 to mem_depth);

begin

p_write: process(clk, resetn)

			begin
			
			if resetn = '0' then
			
				arrayL1 <= (OTHERS => (OTHERS => '0'));
				
			elsif rising_edge(clk) then
			
				if clken = '1' then
			
					if wr = '1' then --write L1
				
						arrayL1(address_wr) <= mem_in;
					
					end if;	
				
				end if;	
			
			end if;
			
			end process p_write;
			
p_read:  process(clk2)

			begin
			
			if rising_edge(clk2) then
			
				if clken = '1' then
			
					if rd = '1' then
				
						mem_out <= arrayL1(address_rd);
						
					end if;
				
				end if;	
				
			end if;
			
			end process p_read;
				
end two_clock_mem;				
				
				