library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
entity Counter is
    Port ( N_IN : in  integer;
				CLK : in STD_LOGIC;
				RES : in STD_LOGIC;
           CNT : out  integer);
end Counter;

architecture Behavioral of Counter is
component ClockDivider is
    Port ( CLK : in  STD_LOGIC;
				N : in integer;
           SLOW_CLK : out  STD_LOGIC);
end component;
signal slowed_clock : std_logic := '0';
signal temp_count : integer := N_IN;
signal prev_N_IN : integer := N_IN;
begin
sc: ClockDivider port map(CLK, 26, slowed_clock);

process(slowed_clock, N_IN)
begin
	if N_IN /= prev_N_IN or RES = '1' then
		temp_count <= N_IN;
		prev_N_IN <= N_IN;
	elsif rising_edge(slowed_clock) and temp_count > 0 then
		temp_count <= temp_count - 1;
	end if;
end process;


CNT <= temp_count;
end Behavioral;