----------------------------------------------------------------------------------
-- Engineer: Joe Fong and Akash Patel
-- 
-- Create Date:    17:27:43 11/29/2023 
-- Design Name: System controller for multiplier circuit
-- Module Name:    syscntl - Behavioral 
-- Description: System controller for multiplier circuit. 
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: Took ideas from system controller design in the textbook
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity syscntl is
    Port ( Start : in  STD_LOGIC; 	-- Start signal
           clk : in  STD_LOGIC;		-- Clock signal
           C4 : in  STD_LOGIC;		-- Finished calculation signal
			  lsb : in  STD_LOGIC;		-- lsb of multiplier
           S10 : out  STD_LOGIC;		-- Control bit of SR (Mcand)
           S11 : out  STD_LOGIC;		-- Control bit of SR (Mcand)
           S20 : out  STD_LOGIC;		-- Control bit of SR (Mplier)
           S21 : out  STD_LOGIC;		-- Control bit of SR (Mplier)
           S30 : out  STD_LOGIC;		-- Control bit of SR (9bit)
           S31 : out  STD_LOGIC;		-- Control bit of SR (9bit)
			  Done : out  STD_LOGIC;	-- Done signal
           CLR_RES_L : out  STD_LOGIC;	-- Clear output
           CLR_CNTR_L : out  STD_LOGIC;-- Clear counter
           EN_CNTR : out  STD_LOGIC);	-- Enable counter
end syscntl;
--change

architecture Behavioral of syscntl is
signal State: integer range 0 to 4 := 0; -- Initial state 0 (Init)

begin
	process(clk)
	begin
		if clk'event and clk ='1' then -- rising
			case State is
			when 0 => -- Init state
				if Start = '1' then -- If Start signal is high go to load
					State <= 1; -- Load state
					CLR_CNTR_L <= '0'; -- No clear
					CLR_RES_L <= '0';
					Done <= '0'; -- Not done
					S10 <= '1'; -- Loads multiplicand
					S11 <= '1'; 
					S20 <= '1'; -- Loads multiplier
					S21 <= '1';
					S30 <= '0'; -- Holds 9 bit
					S31 <= '0';
					EN_CNTR <= '1'; -- Counts up 1
				else -- If Start is 0 stay in init
					CLR_CNTR_L <= '1'; -- Clear counter
					CLR_RES_L <= '1'; -- Clear 9 bit
					Done <= '1'; -- Done with operation
					S10 <= '0'; -- Hold all registers
					S11 <= '0';
					S20 <= '0';
					S21 <= '0';
					S30 <= '0';
					S31 <= '0';
					EN_CNTR <='0'; -- no count
				end if;
			when 1 => -- Load Mcand and Mplier
				if lsb = '1' then -- Go to add state
					State <= 2; -- Add state
					CLR_CNTR_L <= '0'; -- No clear
					CLR_RES_L <= '0';
					Done <= '0'; -- Not Done
					S10 <= '0'; -- Hold Mcand
					S11 <= '0';
					S20 <= '0'; -- Hold Mplier
					S21 <= '0';
					S30 <= '1'; -- Load 9 bit SR
					S31 <= '1';
					EN_CNTR <='0'; -- No count
				else -- go to shift state
					State <= 3;	-- shift state
					CLR_CNTR_L <= '0'; -- No clear
					CLR_RES_L <= '0';
					Done <= '0'; -- Not Done
					S10 <= '0'; -- Hold Mcand
					S11 <= '0';
					S20 <= '1'; -- Shift Mplier
					S21 <= '0';
					S30 <= '1'; -- Shift output
					S31 <= '0';
					EN_CNTR <= '1'; -- Count up
				end if;
			when 2 => -- Add (loads addition of mcand and output(7-4) into output(8-4) )
				State <= 3; -- Go to shift state
				CLR_CNTR_L <= '0'; -- No clear
				CLR_RES_L <= '0';
				Done <= '0'; -- Not Done
				S10 <= '0'; -- Hold Mcand
				S11 <= '0';
				S20 <= '1'; -- Shift Mplier
				S21 <= '0';
				S30 <= '1'; -- Shift output
				S31 <= '0';
				EN_CNTR <= '1'; -- count up
			when 3 => -- Shifts output the left 1 bit and loads 0
				if C4 = '1' then -- If counter = "0101" go to done state
					State <= 4; -- Done state
					CLR_CNTR_L <= '0'; -- no clear
					CLR_RES_L <= '0';
					Done <= '1'; -- Done with calculation
					S10 <= '0'; -- Hold all registers
					S11 <= '0';
					S20 <= '0';
					S21 <= '0';
					S30 <= '0';
					S31 <= '0';
					EN_CNTR <= '0'; -- Stop count
				elsif lsb = '1' then -- if Mplier lsb = 1 go to add state
					State <= 2; -- add state
					CLR_CNTR_L <= '0'; -- No clear
					CLR_RES_L <= '0';
					Done <= '0'; -- Not Done
					S10 <= '0'; -- Hold Mcand 
					S11 <= '0';
					S20 <= '0'; -- Hold Mplier
					S21 <= '0';
					S30 <= '1'; -- Load output
					S31 <= '1';
					EN_CNTR <='0'; -- No count
				end if;
			when 4 => -- Done (wait for start to go low)
				if Start = '0' then -- Go to init state
					State <= 0; -- init state
					CLR_CNTR_L <= '1'; -- clear counter
					CLR_RES_L <= '1'; -- clear output
					Done <= '1'; -- Arithmetic is done
					S10 <= '0'; -- Hold all registers
					S11 <= '0';
					S20 <= '0';
					S21 <= '0';
					S30 <= '0';
					S31 <= '0';
					EN_CNTR <='0'; -- Stop count
				end if;
			end case;
		end if;
	end process;
	    
end Behavioral;

