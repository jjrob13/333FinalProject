library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity Vending is port(
	BTN_CLK, RES, CLK, coin_ret, restock_switch, stats_switch: in std_logic;
	SEL : in std_logic_vector(3 downto 0);
	LED : out std_logic_vector(3 downto 0);
	AX : out std_logic_vector(3 downto 0);
	SSEG : out std_logic_vector(6 downto 0));
end entity;


architecture behav of Vending is
constant start_coin_stock : integer := 5;
constant start_product_stock : integer := 3;
constant Aprice : integer := 5;
constant Bprice : integer := 10;
constant Cprice : integer := 15;
constant Dprice : integer := 20;
constant Eprice : integer := 25;
constant Fprice : integer := 30;

signal Astock, Bstock, Cstock, Dstock, Estock, Fstock : integer range 0 to 9 := start_product_stock;
signal Asold, Bsold, Csold, Dsold, Esold, Fsold : integer := 0;
signal quarter_stock, dime_stock, nickel_stock : integer := start_coin_stock; 
signal money_in, prev_money_in, money_made : integer := 0;

type state is (start, buy, change, restock, stats);
signal curr_state : state := start;
signal next_state : state := start;

signal to_disp : std_logic_vector(15 downto 0) := x"0000";

component Counter is
    Port ( N_IN : in  integer;
				CLK : in STD_LOGIC;
				RES : in STD_LOGIC;
           CNT : out  integer);
end component;

component DisplayController is
    Port ( Active_Displays : in  STD_LOGIC_VECTOR (3 downto 0);
           Hex_Disp0 : in  STD_LOGIC_VECTOR (3 downto 0);
           Hex_Disp1 : in  STD_LOGIC_VECTOR (3 downto 0);
           Hex_Disp2 : in  STD_LOGIC_VECTOR (3 downto 0);
           Hex_Disp3 : in  STD_LOGIC_VECTOR (3 downto 0);
			  CLK : in STD_LOGIC;
           SSEG : out  STD_LOGIC_VECTOR (6 downto 0);
           AX : out  STD_LOGIC_VECTOR (3 downto 0));
end component;

-- SSEG setup
signal active_disps : std_logic_vector(3 downto 0) :=  x"F";
signal seven_segs : std_logic_vector(15 downto 0) := x"0000";

-- BCD
component bcd_16 is
  port(
    clk: in  std_logic;
    int_n : in integer;
	 bcd_out : out std_logic_vector(15 downto 0)
    );
end component;
signal bcd_in : integer := 0;
signal bcd_out : std_logic_vector(15 downto 0);

signal timer_start_val : integer := 9;
signal timer_res : std_logic := '1';
signal countdown : integer;

-- Debounce

component DEBOUNCE IS
PORT (
  Clk      : IN STD_LOGIC;
  PB       : IN STD_LOGIC;  -- active low input
  pulse    : OUT STD_LOGIC);
end component;
signal deb_clk : std_logic := '0';


--led output
signal temp_led : std_logic_vector(3 downto 0) := x"0";


--change maker
signal change_to_give : std_logic_vector(2 downto 0) := "000";
signal cm_en : std_logic := '0';

----------------------------------------------------------------
--------------------Start Architecture--------------------------
----------------------------------------------------------------

begin
LED <= temp_led;

-- port maps
deb_instance : Debounce port map(
	clk => clk,
	pb => btn_clk,
	pulse => deb_clk
);

t_instance : Counter port map(
	N_IN => timer_start_val,
	CLK => CLK,
	RES => timer_res,
	CNT => countdown
);

bcd : bcd_16 port map(
	clk => clk,
	int_n => bcd_in,
	bcd_out => bcd_out
);

disp_cont : DisplayController port map(
	Active_Displays  => active_disps,
	Hex_Disp0 => seven_segs(15 downto 12),
	Hex_Disp1 => seven_segs(11 downto 8),
	Hex_Disp2 => seven_segs(7 downto 4),
	Hex_Disp3 => seven_segs(3 downto 0),
	CLK => clk,
	SSEG => SSEG,
	AX => AX
);


transition: process(deb_clk, res)
	begin
		if res = '1' then
			curr_state <= start;
		elsif rising_edge(deb_clk) then
			curr_state <= next_state;
		end if;
end process transition;


FSM_transition: process(curr_state, sel, coin_ret)
	begin
		case curr_state is 
			when start =>
				if SEL(3) = '1' then
					next_state <= start;
				elsif restock_switch = '1' then
					next_state <= restock;
				elsif stats_switch = '1' then
					next_state <= stats;
				else
					next_state <= buy;
				end if;
			when buy =>
				if coin_ret = '1' then
					next_state <= change;
				elsif countdown /= 0 then
					next_state <= buy;
				else
					next_state <= change;
				end if;
			when change =>
				if money_in > 0 then
					next_state <= change;
				else
					next_state <= start;
				end if;
			when restock =>
				if restock_switch = '1' then
					next_state <= restock;
				elsif stats_switch = '1' then
					next_state <= stats;
				else
					next_state <= start;
				end if;
			when stats =>
				if stats_switch = '1' then
					next_state <= stats;
				elsif restock_switch = '1' then
					next_state <= restock;
				else
					next_state <= start;

				end if;
			when others => null;
		end case;
end process FSM_transition;


FSM_OUTPUT: process(curr_state, sel)
	begin
		Case curr_state is
			when start =>
				Case SEL is
					when x"A" =>
						bcd_in <= Aprice;
						seven_segs <= x"A" & conv_std_logic_vector(Astock, 4) & bcd_out(7 downto 0);
					when x"B" =>
						bcd_in <= Bprice;
						seven_segs <= x"B" & conv_std_logic_vector(Bstock, 4) & bcd_out(7 downto 0);
					when x"C" =>
						bcd_in <= Cprice;
						seven_segs <= x"C" & conv_std_logic_vector(Cstock, 4) & bcd_out(7 downto 0);
					when x"D" =>
						bcd_in <= Dprice;
						seven_segs <= x"D" & conv_std_logic_vector(Dstock, 4) & bcd_out(7 downto 0);
					when x"E" =>
						bcd_in <= Eprice;
						seven_segs <= x"E" & conv_std_logic_vector(Estock, 4) & bcd_out(7 downto 0);
					when x"F" =>
						bcd_in <= Fprice;
						seven_segs <= x"F" & conv_std_logic_vector(Fstock, 4) & bcd_out(7 downto 0);
					when others => seven_segs <= conv_std_logic_vector(0, 16);
				end case;
			when buy =>
				bcd_in <= money_in;
				if SEL < x"A" then
					seven_segs <= conv_std_logic_vector(countdown, 4) & bcd_out(11 downto 0);
				else
					Case SEL is
						when x"A" =>
							bcd_in <= Aprice;
							seven_segs <= x"A" & conv_std_logic_vector(Astock, 4) & bcd_out(7 downto 0);
						when x"B" =>
							bcd_in <= Bprice;
							seven_segs <= x"B" & conv_std_logic_vector(Bstock, 4) & bcd_out(7 downto 0);
						when x"C" =>
							bcd_in <= Cprice;
							seven_segs <= x"C" & conv_std_logic_vector(Cstock, 4) & bcd_out(7 downto 0);
						when x"D" =>
							bcd_in <= Dprice;
							seven_segs <= x"D" & conv_std_logic_vector(Dstock, 4) & bcd_out(7 downto 0);
						when x"E" =>
							bcd_in <= Eprice;
							seven_segs <= x"E" & conv_std_logic_vector(Estock, 4) & bcd_out(7 downto 0);
						when x"F" =>
							bcd_in <= Fprice;
							seven_segs <= x"F" & conv_std_logic_vector(Fstock, 4) & bcd_out(7 downto 0);
						when others => seven_segs <= conv_std_logic_vector(0, 16);
					end case;
				end if;
			when change =>
				bcd_in <= money_in;
				seven_segs <= bcd_out;
			when restock =>
				CASE SEL is
					--nickel case
					when x"1" =>
						bcd_in <= nickel_stock;
						seven_segs <= bcd_out;
					--dime case
					when x"2" =>
						bcd_in <= dime_stock;
						seven_segs <= bcd_out;
					when x"4" =>
						bcd_in <= quarter_stock;
						seven_segs <= bcd_out;
					--each product
					when x"A" =>
						bcd_in <= Aprice;
						seven_segs <= x"A" & conv_std_logic_vector(Astock, 4) & bcd_out(7 downto 0);
					when x"B" =>
						bcd_in <= Bprice;
						seven_segs <= x"B" & conv_std_logic_vector(Bstock, 4) & bcd_out(7 downto 0);
					when x"C" =>
						bcd_in <= Cprice;
						seven_segs <= x"C" & conv_std_logic_vector(Cstock, 4) & bcd_out(7 downto 0);
					when x"D" =>
						bcd_in <= Dprice;
						seven_segs <= x"D" & conv_std_logic_vector(Dstock, 4) & bcd_out(7 downto 0);
					when x"E" =>
						bcd_in <= Eprice;
						seven_segs <= x"E" & conv_std_logic_vector(Estock, 4) & bcd_out(7 downto 0);
					when x"F" =>
						bcd_in <= Fprice;
						seven_segs <= x"F" & conv_std_logic_vector(Fstock, 4) & bcd_out(7 downto 0);
					when others => seven_segs <= conv_std_logic_vector(0, 16);
				end case;
			when stats => 
				Case SEL is
					when x"A" =>
						bcd_in <= Asold;
						seven_segs <= x"A" & bcd_out(11 downto 0);
					when x"B" =>
						bcd_in <= Bsold;
						seven_segs <= x"B" & bcd_out(11 downto 0);
					when x"C" =>
						bcd_in <= Csold;
						seven_segs <= x"C" & bcd_out(11 downto 0);
					when x"D" =>
						bcd_in <= Dsold;
						seven_segs <= x"D" & bcd_out(11 downto 0);
					when x"E" =>
						bcd_in <= Esold;
						seven_segs <= x"E" & bcd_out(11 downto 0);
					when x"F" =>
						bcd_in <= Fsold;
						seven_segs <= x"F" & bcd_out(11 downto 0);
					when others => 
						bcd_in <= money_made;
						seven_segs <= bcd_out;
				end case;
			when others => null;
		end case;
end process FSM_OUTPUT;
	

update_stock: process(res, curr_state, deb_clk, sel)
	begin
		if res = '1' then
			quarter_stock <= start_coin_stock;
			dime_stock <= start_coin_stock;
			nickel_stock <= start_coin_stock;
			Astock <= start_product_stock;
			Bstock <= start_product_stock;
			Cstock <= start_product_stock;
			Dstock <= start_product_stock;
			Estock <= start_product_stock;
			Fstock <= start_product_stock;
			Asold <= 0;
			Bsold <= 0;
			Csold <= 0;
			Dsold <= 0;
			Esold <= 0;
			Fsold <= 0;
			money_made <= 0;
			money_in <= 0;
		elsif rising_edge(deb_clk) then
			temp_LED <= x"0";
			if curr_state = buy then
				-- coin(s) inserted
				if SEL < x"A" then
					-- only allowed to add change if it has not timed out.
					if countdown /= 0 then
						money_in <= money_in + (25 * conv_integer(SEL(2)) + 10 * conv_integer(SEL(1)) + 5 * conv_integer(SEL(0)));
						quarter_stock <= quarter_stock + conv_integer(SEL(2));
						dime_stock <= dime_stock + conv_integer(SEL(1));
						nickel_stock <= nickel_stock + conv_integer(SEL(0));
					end if;
				else
					CASE SEL is
						when x"A" =>
							if money_in >= Aprice and Astock > 0 then
								temp_LED <= x"A";
								money_in <= money_in - Aprice;
								Astock <= Astock - 1;
								Asold <= Asold + 1;
								money_made <= money_made + Aprice;
							end if;

						when x"B" =>
							if money_in >= Bprice and Bstock > 0 then
								temp_LED <= x"B";
								money_in <= money_in - Bprice;
								Bstock <= Bstock - 1;
								Bsold <= Bsold + 1;
								money_made <= money_made + Bprice;
							end if;

						when x"C" =>
							if money_in >= Cprice and Cstock > 0 then
								temp_LED <= x"C";
								money_in <= money_in - Cprice;
								Cstock <= Cstock - 1;
								Csold <= Csold + 1;
								money_made <= money_made + Cprice;
							end if;


						when x"D" =>
							if money_in >= Dprice and Dstock > 0 then
								temp_LED <= x"D";
								money_in <= money_in - Dprice;
								Dstock <= Dstock - 1;
								Dsold <= Dsold + 1;
								money_made <= money_made + Dprice;
							end if;


						when x"E" =>
							if money_in >= Eprice and Estock > 0 then
								temp_LED <= x"E";
								money_in <= money_in - Eprice;
								Estock <= Estock - 1;
								Esold <= Esold + 1;
								money_made <= money_made + Eprice;
							end if;


						when x"F" =>
							if money_in >= Fprice and Fstock > 0 then
								temp_LED <= x"F";
								money_in <= money_in - Fprice;
								Fstock <= Fstock - 1;
								Fsold <= Fsold + 1;
								money_made <= money_made + Fprice;
							end if;

						when others => null;
					end case;
				end if;
			elsif curr_state = change then
				if cm_en = '1' then
					cm_en <= '0';
				else
					cm_en <= '1';
				end if;
				temp_LED <= "0" & change_to_give;
				quarter_stock <= quarter_stock - conv_integer(change_to_give(2));
				dime_stock <= dime_stock - conv_integer(change_to_give(1));
				nickel_stock <= nickel_stock - conv_integer(change_to_give(0));
				money_in <= money_in - (25 * conv_integer(change_to_give(2)) + 10 * conv_integer(change_to_give(1)) + 5 * conv_integer(change_to_give(0)));
			elsif curr_state = restock then
				CASE SEL is
					--add nickel
					when x"1" => nickel_stock <= nickel_stock + 1;
					--add dime
					when x"2" => dime_stock <= dime_stock + 1;
					--add quarter
					when x"4" => quarter_stock <= quarter_stock + 1;

					-- add products
					when x"A" => 
					if Astock /= 9 then
						Astock <= Astock + 1;
					end if;
					when x"B" => 
					if Bstock /= 9 then
						Bstock <= Bstock + 1;
					end if;
					when x"C" => 
					if Cstock /= 9 then
						Cstock <= Cstock + 1;
					end if;
					when x"D" =>
					if Dstock /= 9 then 
						Dstock <= Dstock + 1;
					end if;
					when x"E" =>
					if Estock /= 9 then 
						Estock <= Estock + 1;
					end if;
					when x"F" => 
					if Fstock /= 9 then
						Fstock <= Fstock + 1;
					end if;
					when others => null;
				end case;
			end if;
		end if;
end process update_stock;

update_timer : process(money_in, prev_money_in, curr_state)
	begin
	if curr_state = buy then
		if money_in /= prev_money_in then
			timer_res <= '1';
			prev_money_in <= money_in;
		else
			timer_res <= '0';

		end if;
	else
		timer_res <= '1';
	end if;
end process update_timer;

change_maker : process(money_in, cm_en)
	begin
		if cm_en = '0' or money_in = 0 then
			change_to_give <= "000";
		else
			--best way to give change
			if money_in >= 25 and quarter_stock > 0 then
				change_to_give <= "100";
			elsif money_in >= 10 and dime_stock > 0 then
				change_to_give <= "010";
			elsif money_in >= 5 and nickel_stock > 0 then
				change_to_give <= "001";
			end if;
		end if;
end process change_maker;
end architecture;