--This code is courtesy of Dr. Bassam Matar, EEE 333 instructor.

--The approach uses a counter to time how long the switch signal has been low. 
--If the signal has been low continuously for a set amount of time(3 clock cycles in this code), 
--then it is considered pressed and stable.
--PB is the push button signal, its an active low when you press the button and active high when 
--it remains unpressed.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY DEBOUNCE IS
PORT (
  Clk      : IN STD_LOGIC;
  PB       : IN STD_LOGIC;  -- active low input
  pulse    : OUT STD_LOGIC);

END DEBOUNCE;
ARCHITECTURE clean_pulse OF DEBOUNCE IS
SIGNAL cnt       : STD_LOGIC_VECTOR (1 DOWNTO 0);
signal clk_n     : std_logic;


BEGIN
clk_n <= not(clk);

  PROCESS (Clk_n,PB,cnt)
  BEGIN
    IF PB = '1' THEN
      cnt <= "00";
    ELSIF (clk_n'EVENT AND Clk_n = '1') THEN
      IF (cnt /= "11") THEN cnt <= cnt + 1; END IF;
    END IF;
    
	 IF (cnt = "01") AND (PB = '0') THEN 
	 pulse <= '1'; 
	 ELSE pulse <= '0'; 
	 END IF;
  END PROCESS;
END clean_pulse;