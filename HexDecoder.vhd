library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity HexDecoder is
    Port ( Hex_In : in  STD_LOGIC_VECTOR (3 downto 0);
           SSEG_Out : out  STD_LOGIC_VECTOR (6 downto 0));
end HexDecoder;

architecture Behavioral of HexDecoder is

begin
process(Hex_In)
	begin
	case Hex_In is
		when x"0" => SSEG_Out <= "0000001"; --0
		when x"1" => SSEG_Out <= "1001111"; --1
		when x"2" => SSEG_Out <= "0010010"; --2
		when x"3" => SSEG_Out <= "0000110"; --3
		when x"4" => SSEG_Out <= "1001100"; --4
		when x"5" => SSEG_Out <= "0100100"; --5
		when x"6" => SSEG_Out <= "0100000"; --6
		when x"7" => SSEG_Out <= "0001101"; --7
		when x"8" => SSEG_Out <= "0000000"; --8
		when x"9" => SSEG_Out <= "0000100"; --9
		when x"a" => SSEG_Out <= "0001000"; --a
		when x"b" => SSEG_Out <= "1100000"; --b
		when x"c" => SSEG_Out <= "0110001"; --c
		when x"d" => SSEG_Out <= "1000010"; --d
		when x"e" => SSEG_Out <= "0110000"; --e
		when others => SSEG_Out <= "0111000"; --f
		end case;
	end process;

end Behavioral;

