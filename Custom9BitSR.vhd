---------------------------------------------------------------------------------- 
-- Engineer: Joe Fong and Akash Patel
-- 
-- Create Date:    19:42:31 11/30/2023 
-- Design Name: 9 bit shift register
-- Module Name:    Custom9BitSR - Behavioral 
-- Description: Standard shift register with 9 bits
--
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: Based off LS194 with 9 bits
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Custom9BitSR is
    Port ( clk : in STD_LOGIC;
           clr : in STD_LOGIC;
           s1, s0 : in STD_LOGIC; -- Shift control inputs
           sil, sir : in STD_LOGIC; -- Serial inputs for left and right shifts
           data_in : in STD_LOGIC_VECTOR (8 downto 0); -- Parallel load data
           data_out : out STD_LOGIC_VECTOR (8 downto 0) -- Output of the shift register
           );
end Custom9BitSR;

architecture Behavioral of Custom9BitSR is
    signal temp_data : STD_LOGIC_VECTOR (8 downto 0);
	 signal temp_cntrl : STD_LOGIC_VECTOR (1 downto 0) := s1&s0;

begin
    process (clk, clr)
    begin
        if clr = '1' then
            temp_data <= (others => '0'); -- Clear register
        elsif rising_edge(clk) then
            case temp_cntrl is
                when "00" =>  -- No operation, hold data
                    temp_data <= temp_data;
                when "01" =>  -- Shift right
                    temp_data <= sir & temp_data(8 downto 1);
                when "10" =>  -- Shift left
                    temp_data <= temp_data(7 downto 0) & sil;
                when "11" =>  -- Parallel load
                    temp_data <= data_in;
                when others =>
                    temp_data <= (others => '0'); -- Undefined state, clear register
            end case;
        end if;
    end process;

    data_out <= temp_data; -- Output assignment
	 temp_cntrl <= s1 & s0;

end Behavioral;

