----------------------------------------------------------------------------------
-- Engineer: Joe Fong and Akash Patel
-- 
-- Create Date:    20:31:23 11/29/2023 
-- Design Name: LS163 Counter
-- Module Name:    LS163 - Behavioral 
-- Description: Standard LS163 counter recreated for multiplier
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: Based off standard LS163
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity LS163 is
    Port ( clk : in STD_LOGIC; -- clock
           clr : in STD_LOGIC; -- clears count output
           load : in STD_LOGIC; -- not used
           enable : in STD_LOGIC; -- Enables counting when on
           data_in : in STD_LOGIC_VECTOR (3 downto 0); -- not used
           count_out : out STD_LOGIC_VECTOR (3 downto 0)); -- count value
end LS163;

architecture Behavioral of LS163 is
    signal temp_count : STD_LOGIC_VECTOR (3 downto 0); -- temp output variable
begin
    process (clk, clr) -- at clk or clr
    begin
        if clr = '1' then
            temp_count <= "0000"; -- clears output 
        elsif rising_edge(clk) then
            if load = '1' then
                temp_count <= data_in; -- This never happens
            elsif enable = '1' then
                temp_count <= temp_count + 1; -- Count up if enable = '1'
            end if;
        end if;
    end process;

    count_out <= temp_count; -- assigns temporary to output

end Behavioral;