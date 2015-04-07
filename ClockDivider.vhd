library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--N must be less than or equal to 31
entity ClockDivider is
    Port ( CLK : in  STD_LOGIC;
				N : in integer;
           SLOW_CLK : out  STD_LOGIC);
end ClockDivider;

architecture Behavioral of ClockDivider is
signal counter : std_logic_vector(31 downto 0) := x"00000000";

begin

	process (CLK, N)
	begin
		if(rising_edge(CLK)) then
			if counter(N) = '1' then
				SLOW_CLK <= '1';
				counter <= x"00000000";
			else
			SLOW_CLK <= '0';
			counter <= counter + 1;
			end if;
		end if;
		
		end process;


end Behavioral;

