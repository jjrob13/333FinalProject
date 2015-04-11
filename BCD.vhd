library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
entity bcd_16 is
  port(
    clk: in  std_logic;
    int_n : in integer;
	 bcd_out : out std_logic_vector(15 downto 0)
    );
end bcd_16;


architecture behav of bcd_16 is
signal temp_int : integer := int_n;
signal ones: std_logic_vector(3 downto 0) := x"0";
signal tens : std_logic_vector(3 downto 0):= x"0";
signal hundreds : std_logic_vector(3 downto 0):= x"0";
signal thousands: std_logic_vector(3 downto 0):= x"0";
signal count : integer := int_n;
signal SEL : std_logic;
signal prev_int_n : integer := int_n;
begin	
	bcd_out <= thousands & hundreds & tens & ones;
	conv_proc: process(int_n, clk)
	begin
		if prev_int_n /= int_n then
			prev_int_n <= int_n;
			temp_int <= int_n;
			
			ones <= x"0";
			tens <= x"0";
			hundreds <= x"0";
			thousands <= x"0";
		elsif rising_edge(clk) then
			if temp_int >= 1000 then
				thousands <= thousands + 1;
				temp_int <= temp_int - 1000;
			elsif temp_int >= 100 then
				hundreds <= hundreds + 1;
				temp_int <= temp_int - 100;
			
			elsif temp_int >= 10 then
				tens <= tens + 1;
				temp_int <= temp_int - 10;
			
			else
				ones <= ones + temp_int;
				temp_int <= 0;
			end if;
		end if;
	end process;

end architecture;