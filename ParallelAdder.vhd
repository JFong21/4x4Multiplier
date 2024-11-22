----------------------------------------------------------------------------------
-- Engineer: Joe Fong and Akash Patel
-- 
-- Create Date:    22:31:59 11/29/2023 
-- Design Name: 4 bit parallel adder
-- Module Name: ParallelAdder - Behavioral 
-- Description: 4 bit adder with carry out. Takes two different input busses and 
-- adds their values to create a sum with carry. 
--
-- Revision: 
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ParallelAdder is
    Port ( A : in STD_LOGIC_VECTOR (3 downto 0); -- Multiplicand
           B : in STD_LOGIC_VECTOR (3 downto 0); -- Partial sum output bits (7-4)
           Sum : out STD_LOGIC_VECTOR (3 downto 0); -- Sum of A and B
           CarryOut : out STD_LOGIC); -- Carry bit
end ParallelAdder;

architecture Behavioral of ParallelAdder is
begin
    process (A, B) -- When A or B see change
    variable sum_temp : STD_LOGIC_VECTOR(4 downto 0); -- 5 bit vector
    begin
        sum_temp := ('0' & A) + ('0' & B); -- Extend to 5 bits to accommodate carry
        Sum <= sum_temp(3 downto 0);       -- Assign lower 4 bits to Sum
        CarryOut <= sum_temp(4);           -- Assign the 5th bit as Carry Out
    end process;

end Behavioral;