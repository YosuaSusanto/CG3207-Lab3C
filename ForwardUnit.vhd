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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ForwardUnit is
    Port (EXMEM_RegWrite	:	in STD_LOGIC;
			 EXMEM_RegRd		:  in STD_LOGIC_VECTOR(4 downto 0);
			 IDEX_RegRs			:  in STD_LOGIC_VECTOR(4 downto 0);
			 IDEX_RegRt			:  in STD_LOGIC_VECTOR(4 downto 0);
			 MEMWB_RegWrite	:  in STD_LOGIC;
			 MEMWB_RegRd		:	in STD_LOGIC_VECTOR(4 downto 0);
			 ForwardA			:  out STD_LOGIC_VECTOR(1 downto 0);	-- 10: EX/MEM, 01: MEM/WB, 00: ID/EX
			 ForwardB			:  out STD_LOGIC_VECTOR(1 downto 0)
			 );
end ForwardUnit;

architecture Fw_arch of ForwardUnit is

begin
	ForwardA <= "10" when (EXMEM_RegWrite = '1' and 
								 (EXMEM_RegRd /= "00000") and 
								 (EXMEM_RegRd = IDEX_RegRs)) else 
					"01" when (MEMWB_RegWrite = '1' and 
								 (MEMWB_RegRd /= "00000") and 
								 (EXMEM_RegRd /= IDEX_RegRs) and 
								 (MEMWB_RegRd = IDEX_RegRs)) else
					"00";
	ForwardB <= "10" when (EXMEM_RegWrite = '1' and 
								 (EXMEM_RegRd /= "00000") and 
								 (EXMEM_RegRd = IDEX_RegRt)) else 
					"01" when (MEMWB_RegWrite = '1' and 
								 (MEMWB_RegRd /= "00000") and 
								 (EXMEM_RegRd /= IDEX_RegRt) and 
								 (MEMWB_RegRd = IDEX_RegRt)) else
					"00";
end Fw_arch;

