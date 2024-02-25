library ieee;
USE ieee.std_logic_1164.all;
--USE work.sgm_stereo_package.all;
--------------------------------
entity clk_div is
	port(clk: in std_logic;
		  clk2: out std_logic);
end clk_div;

architecture divisor of clk_div is
signal my_clock: std_logic:='0';
begin
	process(clk)
	begin
		if rising_edge(clk) then
			my_clock <= NOT(my_clock);
		end if;
	end process;
	clk2 <= my_clock;
end divisor;	