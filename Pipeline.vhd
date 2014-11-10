----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Nguyen Ngoc Nhu Thao
-- 
-- Create Date:    20:43:00 11/06/2014 
-- Design Name: 
-- Module Name:    Pipeline - Behavioral 
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

----------------------------------------------------------------------------------
-- IF_ID Pipeline Register
----------------------------------------------------------------------------------
entity IF_ID is
Port (CLK					: 	in STD_LOGIC;
		IFID_Flush			: 	in STD_LOGIC;
		IFID_Stall			: 	in STD_LOGIC;
		IFID_PCPlus4In		:	in STD_LOGIC_VECTOR(31 downto 0);
		IFID_InstrIn		:	in STD_LOGIC_VECTOR(31 downto 0);
		
		IFID_PCPlus4Out	:	out STD_LOGIC_VECTOR(31 downto 0);
		IFID_InstrOut		: 	out STD_LOGIC_VECTOR(31 downto 0)
		);
end IF_ID;

architecture arch_IFID of IF_ID is
begin
process (CLK)
begin
	if rising_edge(CLK) then
		if IFID_Flush = '1' then
			IFID_PCPlus4Out <= x"00000000";
			IFID_InstrOut <= x"00000000";
		elsif IFID_Stall = '0' then
			IFID_PCPlus4Out <= IFID_PCPlus4In;
			IFID_InstrOut <= IFID_InstrIn;
		end if;
	end if;
end process;

end arch_IFID;

----------------------------------------------------------------------------------
-- ID_EX Pipeline Register
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ID_EX is
Port (CLK						:	in STD_LOGIC;
		IDEX_Flush				:	in STD_LOGIC;
		IDEX_Stall				:	in STD_LOGIC;
		IDEX_BranchIn			:	in STD_LOGIC;
		IDEX_ALUOpIn			:  in STD_LOGIC_VECTOR(2 downto 0);
		IDEX_MemreadIn			:  in STD_LOGIC;
		IDEX_MemtoRegIn		:	in STD_LOGIC;
		IDEX_InstrtoRegIn		:	in STD_LOGIC;
		IDEX_PCtoRegIn			:  in STD_LOGIC;
		IDEX_MemwriteIn		:  in STD_LOGIC;
		IDEX_ALUSrcIn			:	in STD_LOGIC;
		IDEX_RegDstIn			:	in STD_LOGIC;
		IDEX_RegRsIn			: 	in STD_LOGIC_VECTOR(4 downto 0);
		IDEX_RegRtIn			: 	in STD_LOGIC_VECTOR(4 downto 0);
		IDEX_RegRdIn			: 	in STD_LOGIC_VECTOR(4 downto 0);
		IDEX_PCPlus4In			:	in STD_LOGIC_VECTOR(31 downto 0);
		IDEX_ReadData1In		:	in STD_LOGIC_VECTOR(31 downto 0);
		IDEX_ReadData2In		:	in STD_LOGIC_VECTOR(31 downto 0);
		IDEX_SignExtendIn		:	in STD_LOGIC;
		IDEX_SignExtendedIn	:	in STD_LOGIC_VECTOR(31 downto 0);
		
		IDEX_BranchOut			:	out STD_LOGIC;
		IDEX_ALUOpOut			:  out STD_LOGIC_VECTOR(2 downto 0);
		IDEX_MemreadOut		:  out STD_LOGIC;
		IDEX_MemtoRegOut		:	out STD_LOGIC;
		IDEX_InstrtoRegOut	:	out STD_LOGIC;
		IDEX_PCtoRegOut		:	out STD_LOGIC;
		IDEX_MemwriteOut		:  out STD_LOGIC;
		IDEX_ALUSrcOut			: 	out STD_LOGIC;
		IDEX_RegDstOut			:	out STD_LOGIC;
		IDEX_RegRsOut			: 	out STD_LOGIC_VECTOR(4 downto 0);
		IDEX_RegRtOut			: 	out STD_LOGIC_VECTOR(4 downto 0);
		IDEX_RegRdOut			: 	out STD_LOGIC_VECTOR(4 downto 0);
		IDEX_PCPlus4Out		:	out STD_LOGIC_VECTOR(31 downto 0);
		IDEX_ReadData1Out		:	out STD_LOGIC_VECTOR(31 downto 0);
		IDEX_ReadData2Out		:	out STD_LOGIC_VECTOR(31 downto 0);
		IDEX_SignExtendOut	:	out STD_LOGIC;
		IDEX_SignExtendedOut	:	out STD_LOGIC_VECTOR(31 downto 0)
		);
end ID_EX;

architecture arch_IDEX of ID_EX is
begin
process (CLK)
begin
	if rising_edge(CLK) then
		if IDEX_Flush = '1' then
			IDEX_BranchOut			<= '0';
			IDEX_ALUOpOut			<= "000";
			IDEX_MemreadOut		<= '0';
			IDEX_MemtoRegOut		<= '0';
			IDEX_InstrtoRegOut	<= '0';
			IDEX_PCtoRegOut		<= '0';
			IDEX_MemwriteOut		<= '0';
			IDEX_ALUSrcOut			<= '0';
			IDEX_RegDstOut			<= '0';
			IDEX_RegRsOut			<= "00000";
			IDEX_RegRtOut			<= "00000";
			IDEX_RegRdOut			<= "00000";
			IDEX_PCPlus4Out		<= x"00000000";
			IDEX_ReadData1Out		<= x"00000000";
			IDEX_ReadData2Out		<= x"00000000";
			IDEX_SignExtendOut	<= '0';
			IDEX_SignExtendedOut	<= x"00000000";
			
		elsif IDEX_Stall = '0' then
			IDEX_BranchOut			<= IDEX_BranchIn;
			IDEX_ALUOpOut			<= IDEX_ALUOpIn;
			IDEX_MemreadOut		<= IDEX_MemreadIn;
			IDEX_MemtoRegOut		<= IDEX_MemtoRegIn;
			IDEX_InstrtoRegOut	<=	IDEX_InstrtoRegIn;
			IDEX_PCtoRegOut		<= IDEX_PCtoRegIn;
			IDEX_MemwriteOut		<= IDEX_MemwriteIn;
			IDEX_ALUSrcOut			<= IDEX_ALUSrcIn;
			IDEX_RegDstOut			<= IDEX_RegDstIn;
			IDEX_RegRsOut			<= IDEX_RegRsIn;
			IDEX_RegRtOut			<= IDEX_RegRtIn;
			IDEX_RegRdOut			<= IDEX_RegRdIn;
			IDEX_PCPlus4Out		<= IDEX_PCPlus4In;
			IDEX_ReadData1Out		<= IDEX_ReadData1In;
			IDEX_ReadData2Out		<= IDEX_ReadData2In;
			IDEX_SignExtendOut	<= IDEX_SignExtendIn;
			IDEX_SignExtendedOut	<= IDEX_SignExtendedIn;
		end if;
	end if;
end process;

end arch_IDEX;

----------------------------------------------------------------------------------
-- EX_MEM Pipeline Register
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity EX_MEM is
Port (CLK							:	in STD_LOGIC;
		EXMEM_Flush					:	in STD_LOGIC;
		EXMEM_Stall					:	in STD_LOGIC;
		EXMEM_BranchIn				:	in STD_LOGIC;
		EXMEM_BranchTargetIn		:	in STD_LOGIC_VECTOR(31 downto 0);
		EXMEM_MemreadIn			:	in STD_LOGIC;
		EXMEM_MemtoRegIn			:	in STD_LOGIC;
		EXMEM_MemwriteIn			:	in STD_LOGIC;
		EXMEM_ALUZeroIn			:	in STD_LOGIC;
		EXMEM_ALUResult1In		:	in STD_LOGIC_VECTOR(31 downto 0);
		EXMEM_ALUResult2In		:  in STD_LOGIC_VECTOR(31 downto 0);
		EXMEM_WriteDataMemIn		:	in STD_LOGIC_VECTOR(31 downto 0);
		EXMEM_WriteAddrRegIn		:	in STD_LOGIC_VECTOR(4 downto 0);

		EXMEM_BranchOut			:	out STD_LOGIC;
		EXMEM_BranchTargetOut	:	out STD_LOGIC_VECTOR(31 downto 0);
		EXMEM_MemreadOut			:	out STD_LOGIC;
		EXMEM_MemtoRegOut			:	out STD_LOGIC;
		EXMEM_MemwriteOut			:	out STD_LOGIC;
		EXMEM_ALUZeroOut			:	out STD_LOGIC;
		EXMEM_ALUResult1Out		:	out STD_LOGIC_VECTOR(31 downto 0);
		EXMEM_ALUResult2Out		:  out STD_LOGIC_VECTOR(31 downto 0);
		EXMEM_WriteDataMemOut	:	out STD_LOGIC_VECTOR(31 downto 0);
		EXMEM_WriteAddrRegOut	:	out STD_LOGIC_VECTOR(4 downto 0)
		);
end EX_MEM;


architecture arch_EXMEM of EX_MEM is
begin
process (CLK)
begin
	if rising_edge(CLK) then
		if EXMEM_Flush = '1' then
			EXMEM_BranchOut			<= '0';
			EXMEM_BranchTargetOut	<= x"00000000";
			EXMEM_MemreadOut			<= '0';
			EXMEM_MemtoRegOut			<= '0';
			EXMEM_MemwriteOut			<= '0';
			EXMEM_ALUZeroOut			<= '0';
			EXMEM_ALUResult1Out		<= x"00000000";
			EXMEM_ALUResult2Out		<= x"00000000";
			EXMEM_WriteDataMemOut	<= x"00000000";
			EXMEM_WriteAddrRegOut	<= "00000";
			
		elsif EXMEM_Stall = '0' then
			EXMEM_BranchOut			<=	EXMEM_BranchIn;
			EXMEM_BranchTargetOut	<=	EXMEM_BranchTargetIn;
			EXMEM_MemreadOut			<=	EXMEM_MemreadIn;
			EXMEM_MemtoRegOut			<=	EXMEM_MemtoRegIn;
			EXMEM_MemwriteOut			<=	EXMEM_MemwriteIn;
			EXMEM_ALUZeroOut			<=	EXMEM_ALUZeroIn;
			EXMEM_ALUResult1Out		<=	EXMEM_ALUResult1In;
			EXMEM_ALUResult2Out		<= EXMEM_ALUResult2In;
			EXMEM_WriteDataMemOut	<=	EXMEM_WriteDataMemIn;
			EXMEM_WriteAddrRegOut	<=	EXMEM_WriteAddrRegIn;
		end if;
	end if;
end process;

end arch_EXMEM;

----------------------------------------------------------------------------------
-- MEM_WB Pipeline Register
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MEM_WB is
Port (CLK					 		:	in STD_LOGIC;
		MEMWB_Flush					:	in STD_LOGIC;
		MEMWB_Stall					:	in STD_LOGIC;
		MEMWB_MemtoRegIn			:	in STD_LOGIC;
		MEMWB_MemReadDataIn		:	in STD_LOGIC_VECTOR(31 downto 0);
		MEMWB_ALUResult1In		:	in STD_LOGIC_VECTOR(31 downto 0);
		MEMWB_ALUResult2In		:	in STD_LOGIC_VECTOR(31 downto 0);
		MEMWB_WriteAddrRegIn		:	in STD_LOGIC_VECTOR(4 downto 0);
		
		MEMWB_MemtoRegOut			:	out STD_LOGIC;
		MEMWB_MemReadDataOut		:	out STD_LOGIC_VECTOR(31 downto 0);
		MEMWB_ALUResult1Out		:	out STD_LOGIC_VECTOR(31 downto 0);
		MEMWB_ALUResult2Out		:	out STD_LOGIC_VECTOR(31 downto 0);
		MEMWB_WriteAddrRegOut	:	out STD_LOGIC_VECTOR(4 downto 0)
		);
end MEM_WB;

architecture arch_MEMWB of MEM_WB is
begin
process (CLK)
begin
	if rising_edge(CLK) then
		if MEMWB_Flush = '1' then
			MEMWB_MemtoRegOut			<= '0';
			MEMWB_MemReadDataOut		<= x"00000000";
			MEMWB_ALUResult1Out		<= x"00000000";
			MEMWB_ALUResult2Out		<= x"00000000";
			MEMWB_WriteAddrRegOut	<= "00000";
			
		elsif MEMWB_Stall = '0' then
			MEMWB_MemtoRegOut			<= MEMWB_MemtoRegIn;
			MEMWB_MemReadDataOut		<= MEMWB_MemReadDataIn;
			MEMWB_ALUResult1Out		<= MEMWB_ALUResult1In;
			MEMWB_ALUResult2Out		<= MEMWB_ALUResult2In;
			MEMWB_WriteAddrRegOut	<= MEMWB_WriteAddrRegIn;
		end if;
	end if;
end process;

end arch_MEMWB;
