----------------------------------------------------------------------------------
-- Engineer: Joe Fong and Akash Patel
-- 
-- Create Date:    22:33:53 11/29/2023 
-- Design Name: Multiplier 
-- Module Name:    Multiplier - Behavioral 
-- Project Name: Multiplier
-- Description: System controller based 4bit x 4bit multiplier circuit.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Multiplier is
    Port ( Start : in  STD_LOGIC; -- Start arithmetic signal
           clk : in  STD_LOGIC; -- Clock signal
			  Mplier : in STD_LOGIC_VECTOR (3 downto 0); -- Multiplier value
           Mcand : in STD_LOGIC_VECTOR (3 downto 0); -- Multiplicand value
			  Output : out STD_LOGIC_VECTOR (7 downto 0); -- Output of calculation
			  Done : out STD_LOGIC -- Done with calculation signal
			  );
end Multiplier;

architecture Behavioral of Multiplier is

	-- 4 bit shift register
    component LS194
			Port (clk : in STD_LOGIC;
					clr : in STD_LOGIC;
               s1, s0 : in STD_LOGIC;
               sil, sir : in STD_LOGIC;
               data_in : in STD_LOGIC_VECTOR (3 downto 0);
               data_out : out STD_LOGIC_VECTOR (3 downto 0));
    end component;
	 
	-- 4 bit counter
    component LS163
			Port (clk : in STD_LOGIC;
               clr : in STD_LOGIC;
               load : in STD_LOGIC;
               enable : in STD_LOGIC;
               data_in : in STD_LOGIC_VECTOR (3 downto 0);
               count_out : out STD_LOGIC_VECTOR (3 downto 0));
    end component;
	 
	-- 4 bit adder with carry out
	 component ParallelAdder
			Port (A : in STD_LOGIC_VECTOR (3 downto 0);
					B : in STD_LOGIC_VECTOR (3 downto 0);
					Sum : out STD_LOGIC_VECTOR (3 downto 0);
					CarryOut : out STD_LOGIC);
	 end component;

	-- 9 bit shift register
	 component Custom9BitSR
			Port (clk : in STD_LOGIC;
					clr : in STD_LOGIC;
					s1, s0 : in STD_LOGIC; -- Shift control inputs
					sil, sir : in STD_LOGIC; -- Serial inputs for left and right shifts
					data_in : in STD_LOGIC_VECTOR (8 downto 0); -- Parallel load data
					data_out : out STD_LOGIC_VECTOR (8 downto 0) -- Output of the shift register
           );
	  end component;
	  
	 -- System controller
	  component syscntl
			Port (Start : in  STD_LOGIC;
					clk : in  STD_LOGIC;
					C4 : in  STD_LOGIC;
					lsb : in  STD_LOGIC;
					S10 : out  STD_LOGIC;
					S11 : out  STD_LOGIC;
					S20 : out  STD_LOGIC;
					S21 : out  STD_LOGIC;
					S30 : out  STD_LOGIC;
					S31 : out  STD_LOGIC;
					Done : out  STD_LOGIC;
					CLR_RES_L : out  STD_LOGIC;
					CLR_CNTR_L : out  STD_LOGIC;
					EN_CNTR : out  STD_LOGIC);
		end component;
		
    signal S10 : STD_LOGIC; -- Interconnents systemcontroller and Mcand shift register
    signal S11 : STD_LOGIC; -- Interconnents systemcontroller and Mcand shift register
    signal S20 : STD_LOGIC; -- Interconnents systemcontroller and Mplier shift register
    signal S21 : STD_LOGIC; -- Interconnents systemcontroller and Mplier shift register
    signal S30 : STD_LOGIC; -- Interconnents systemcontroller and 9bit shift register
    signal S31 : STD_LOGIC; -- Interconnents systemcontroller and 9bit shift register
	 signal CLR_RES_L : STD_LOGIC; -- Clear signal for 9bit Shift Register
	 signal CLR_CNTR_L : STD_LOGIC; -- Clear signal for counter
	 signal EN_CNTR : STD_LOGIC; -- Enable counting signal for counter

	 signal counter_value : STD_LOGIC_VECTOR (3 downto 0); -- counter value register
	 signal LSB_Register : STD_LOGIC_VECTOR (3 downto 0); -- Mplier shift register value
	 signal AdderA : STD_LOGIC_VECTOR (3 downto 0); -- The value of the Mcand connected to the adder
	 
	 signal Input9bit : STD_LOGIC_VECTOR (8 downto 0); -- Register for the input of the 9 bit SR
	 signal Result : STD_LOGIC_VECTOR (8 downto 0); -- Output of the 9 bit shift register


begin
    counter: LS163
		port map (
            clk => clk,
            clr => CLR_CNTR_L, -- Clears when system controller sets
            load => '0',  -- Never need to load
            enable => EN_CNTR, -- Counts when system controller sets
            data_in => "0000", -- Never need to load
            count_out => counter_value -- Output of counter
        );
		  
	U1_LS194 : LS194 -- Multiplier Shift Register
		port map (
			clk => clk,
			clr => '0', -- Never clear
			s1 => S21, -- Control bits set by system controller
			s0 => S20, 
			sil => '0', -- always shift in 0
			sir => '0', -- always shift in 0
			data_in => Mplier,
			data_out => LSB_Register -- Data goes to system controller LSB
  );
  
  	U2_LS194 : LS194 -- Multiplicand Shift Register
		port map (
			clk => clk,
			clr => '0', -- Never clear
			s1 => S11, -- Control bits set by system controller
			s0 => S10,
			sil => '0', -- always shift in 0
			sir => '0', -- always shift in 0
			data_in => Mcand,
			data_out => AdderA -- Data goes to adder
	);
	
   -- Instantiation of the ParallelAdder component	
	U_ParallelAdder : ParallelAdder
		port map (
			A => AdderA, -- Multiplicand
			B => Result(7 downto 4), -- 4 MSB of output
			Sum => Input9bit(7 downto 4), -- goes to 5 MSB of output
			CarryOut => Input9bit(8)  
	);
	
	-- Instantiation of Custom9BitSR
   Custom9BitSR_inst : Custom9BitSR
        port map (
            clk => clk,
            clr => CLR_RES_L, -- Clear signal from system controller
            s1 => S31, -- Control bits set by system controller
            s0 => S30,
            sil => '0', -- always shift in 0
            sir => '0', -- always shift in 0
            data_in => Input9bit, -- Filled by adder and by self
            data_out => Result -- outputs final computation
        );
		  
	U_syscntl : syscntl
		port map (
			Start => Start, -- Start signal
			clk => clk, -- Clock signal (falling edge)
			C4 => counter_value(2) AND counter_value(0), 
			-- C4 activated when counter = 0101 due to timing error
			--C4 => counter_value(2),
			lsb => LSB_Register(0), -- LSB of Mplier SR
			S10 => S10, -- Mcand SR control input
			S11 => S11, -- Mcand SR control input
			S20 => S20, -- Mplier SR control input
			S21 => S21, -- Mplier SR control input
			S30 => S30, -- 9bit SR control input
			S31 => S31, -- 9bit SR control input
			Done => Done, -- output Done signal
			CLR_RES_L => CLR_RES_L, -- Clear 9bit SR
			CLR_CNTR_L => CLR_CNTR_L, -- Clear counter
			EN_CNTR => EN_CNTR -- Enable counting
		);

	Input9bit(3 downto 0) <= Result(3 downto 0); -- feeds output to input of 9bit SR
	Output <= Result(7 downto 0); -- Output given by bottom 8 bits of 9bit SR

end Behavioral;
