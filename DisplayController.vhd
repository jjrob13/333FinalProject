library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
entity DisplayController is
    Port ( Active_Displays : in  STD_LOGIC_VECTOR (3 downto 0);
           Hex_Disp0 : in  STD_LOGIC_VECTOR (3 downto 0);
           Hex_Disp1 : in  STD_LOGIC_VECTOR (3 downto 0);
           Hex_Disp2 : in  STD_LOGIC_VECTOR (3 downto 0);
           Hex_Disp3 : in  STD_LOGIC_VECTOR (3 downto 0);
			  CLK : in STD_LOGIC;
           SSEG : out  STD_LOGIC_VECTOR (6 downto 0);
           AX : out  STD_LOGIC_VECTOR (3 downto 0));
end DisplayController;

architecture Behavioral of DisplayController is
component ClockDivider is
    Port ( CLK : in  STD_LOGIC;
				N : in integer;
           SLOW_CLK : out  STD_LOGIC);
end component;

component HexDecoder is
    Port ( Hex_In : in  STD_LOGIC_VECTOR (3 downto 0);
           SSEG_Out : out  STD_LOGIC_VECTOR (6 downto 0));
end component;

type sseg_array is array (3 downto 0) of std_logic_vector (6 downto 0);
signal sseg_disp_array : sseg_array;
signal slowed_clk : std_logic := '0';
signal disp_counter : std_logic_vector(1 downto 0) := "00";
begin
sc: ClockDivider port map(CLK, 13, slowed_clk);

h0: HexDecoder port map(Hex_Disp0, sseg_disp_array(0));
h1: HexDecoder port map(Hex_Disp1, sseg_disp_array(1));
h2: HexDecoder port map(Hex_Disp2, sseg_disp_array(2));
h3: HexDecoder port map(Hex_Disp3, sseg_disp_array(3));

process (slowed_clk)
begin
	if rising_edge(slowed_clk) then
		disp_counter <= disp_counter + 1;
	end if;
end process;

SSEG <= sseg_disp_array(0) when disp_counter = "00" else
				sseg_disp_array(1) when disp_counter = "01" else
				sseg_disp_array(2) when disp_counter = "10" else
				sseg_disp_array(3);
				
AX <= "1110" when disp_counter = "00" and Active_Displays(3) = '1' else
		"1101" when disp_counter = "01" and Active_Displays(2) = '1' else
		"1011" when disp_counter = "10" and Active_Displays(1) = '1' else
		"0111" when disp_counter = "11" and Active_Displays(0) = '1' else
		"1111";
end Behavioral;

