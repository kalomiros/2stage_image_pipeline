--This module produces consecutive addresses and rd/wr signals for mem_2clk
--mem_2clk is a two clock domain memory. It writes with clk2 and reads with clk.
--clk2 has hafl the frequency of clk
--By John Kalomiros
--date: 3/12/2023

library ieee;
USE ieee.std_logic_1164.all;
--USE ieee.numeric_std.all;
--USE work.sgm_stereo_package.all;
USE work.two_stage_package.all;
--------------------------------
entity mem_out_control is
generic(C: positive range 1 to 2048 := line_width);
	port(clk, clk2, clken, resetn: in std_logic;
		  address_rd, address_wr1, address_wr2: out natural range 0 to C + 2;
		  rd, wr: out std_logic);
end mem_out_control;

architecture control of mem_out_control is

component counter_enable is
generic(max: positive := line_width/2);
	port(clk, resetn, enable: in std_logic;
		  counter_enable: out std_logic:= '0');
end component;

signal address_rd1: natural range 0 to C + 2;
signal count_enable: std_logic:='0';
begin

count_en: counter_enable generic map (max => C) port map(clk => clk2, resetn => resetn, enable => clken, counter_enable => count_enable);

--write process
 process(clk2, resetn)

variable address_write1, address_write2: natural range 0 to C + 2;--

begin

if resetn = '0' then --OR (pixel_counter1 = (C) AND mem = '1') then --mem2 resets write address at first half line

	address_write1 := 0; address_write2 := 0;	
	
elsif rising_edge(clk2) then

	if (clken = '1') then
		
		address_write1 := address_write1 + 1; --first memory address
		
		address_write2 := address_write2 + 1; --second memory address
			
			if (address_write1 = C + 1 OR count_enable = '0') then -- start counting after the shift interval
			
					address_write1 := 1;--
						
			end if;
			
			if (address_write2 = C + 1 OR (address_write1 = C/2 + 1)) then -- was address_write1 = C/2 + 1
			
					address_write2 := 1;--
						
			end if;
			
	end if;
		
end if;
		
address_wr1 <= address_write1; 

address_wr2 <= address_write2; 
		
end process;

--read process
process(clk, resetn)

variable address_read: natural range 0 to C + 2; --

begin

if resetn = '0' then

	address_read := 0;
	
elsif rising_edge(clk) then

	if (clken = '1') then
	
		address_read := address_read + 1;
			
			if (address_read = C + 1) then --
			
					address_read := 1;--
						
			end if;
			
	end if;
		
end if;
		
address_rd1 <= address_read;
		
end process;

process(clk) --address_rd needs to be one step after address_write till the end of line

begin

	if rising_edge(clk) then
	
		address_rd <= address_rd1;
		
	end if;
	
end process;

--produce write/read control signals

process(resetn)

begin

if (resetn = '0') then

	rd <= '0'; wr <= '0'; 
	
else

	rd <= '1'; wr <= '1';
		
end if;

end process;

end control;