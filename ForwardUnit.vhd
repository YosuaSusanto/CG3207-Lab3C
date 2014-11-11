----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:08:23 11/06/2014 
-- Design Name: 
-- Module Name:    ForwardUnit - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ForwardUnit is
    Port (EXMEM_RegWrite	:	in STD_LOGIC;
			 EXMEM_RegRd		:  in STD_LOGIC_VECTOR(31 downto 0);
			 IDEX_RegRs			:  in STD_LOGIC_VECTOR(31 downto 0);
			 IDEX_RegRt			:  in STD_LOGIC_VECTOR(31 downto 0);
			 MEMWB_RegWrite	:  in STD_LOGIC;
			 MEMWB_RegRd		:	 in STD_LOGIC;
			 ForwardA			:  out STD_LOGIC_VECTOR(1 downto 0);
			 ForwardB			:  out STD_LOGIC_VECTOR(1 downto 0);
			 )
end ForwardUnit;

architecture Behavioral of ForwardUnit is

begin
	ForwardA <= "10" when (EXMEM_RegWrite = '1' and (EXMEM_RegRd /= "00000") and (EXMEM_RegRd = IDEX_RegRs)) else 
					MEM_Result when (MEMWB_RegWrite = '1' and (MEMWB_RegRd /= "00000") and (EXMEM_RegRd /= IDEX_RegRs) 
										and (MEMWB_RegRd = IDEX_RegRs)) else
					x"00000000";
	ALU_InB <= ALU_Result when (EXMEM_RegWrite = '1' and (EXMEM_RegRd /= "00000") and (EXMEM_RegRd = IDEX_RegRt)) else 
					MEM_Result when (MEMWB_RegWrite = '1' and (MEMWB_RegRd /= "00000") and (EXMEM_RegRd /= IDEX_RegisterRt)
										and (MEMWB_RegRd = IDEX_RegisterRt)) else
					x"00000000";
end Behavioral;

