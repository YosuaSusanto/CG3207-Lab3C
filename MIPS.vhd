----------------------------------------------------------------------------------
-- Company: NUS
-- Engineer: Rajesh Panicker
-- 
-- Create Date:   21:06:18 14/10/2014
-- Design Name: 	MIPS
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool versions: ISE 14.7
-- Description: MIPS processor
--
-- Dependencies: PC, ALU, ControlUnit, RegFile
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: DO NOT modify the interface (entity). Implementation (architecture) can be modified.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity MIPS is -- DO NOT modify the interface (entity)
    Port ( 	
			Addr_Instr 		: out STD_LOGIC_VECTOR (31 downto 0);
			Instr 			: in STD_LOGIC_VECTOR (31 downto 0);
			Addr_Data		: out STD_LOGIC_VECTOR (31 downto 0);
			Data_In			: in STD_LOGIC_VECTOR (31 downto 0);
			Data_Out			: out  STD_LOGIC_VECTOR (31 downto 0);
			MemRead 			: out STD_LOGIC; 
			MemWrite 		: out STD_LOGIC; 
			RESET				: in STD_LOGIC;
			CLK				: in STD_LOGIC
			);
end MIPS;


architecture arch_MIPS of MIPS is

----------------------------------------------------------------
-- Program Counter
----------------------------------------------------------------
component PC is
	Port(	
			PC_in 	: in STD_LOGIC_VECTOR (31 downto 0);
			PC_out 	: out STD_LOGIC_VECTOR (31 downto 0);
			RESET		: in STD_LOGIC;
			CLK		: in STD_LOGIC);
end component;

----------------------------------------------------------------
-- ALU
----------------------------------------------------------------
component ALU is
	 generic (width	: integer);
    Port ( 	
			CLK				: in STD_LOGIC;
			ALU_InA 			: in  STD_LOGIC_VECTOR (31 downto 0);				
			ALU_InB 			: in  STD_LOGIC_VECTOR (31 downto 0);
			ALU_Result1 	: out STD_LOGIC_VECTOR (31 downto 0);
			ALU_Result2 	: out STD_LOGIC_VECTOR (31 downto 0);
			ALU_Control		: in  STD_LOGIC_VECTOR (5 downto 0);
			ALU_Status		: out STD_LOGIC_VECTOR(2 downto 0));
end component;

----------------------------------------------------------------
-- Control Unit
----------------------------------------------------------------
component ControlUnit is
    Port ( 	
			opcode 		: in   STD_LOGIC_VECTOR (5 downto 0);
			ALUOp 		: out  STD_LOGIC_VECTOR (1 downto 0);
			Branch 		: out  STD_LOGIC;
			Jump	 		: out  STD_LOGIC;				
			MemRead 		: out  STD_LOGIC;	
			MemtoReg 	: out  STD_LOGIC;	
			InstrtoReg	: out  STD_LOGIC; -- true for LUI. When true, Instr(15 downto 0)&x"0000" is written to rt
			MemWrite		: out  STD_LOGIC;	
			ALUSrc 		: out  STD_LOGIC;	
			SignExtend 	: out  STD_LOGIC; -- false for ORI 
			RegWrite		: out  STD_LOGIC;
			RegDst		: out  STD_LOGIC);
end component;

----------------------------------------------------------------
-- Register File
----------------------------------------------------------------
component RegFile is
    Port ( 	
			ReadAddr1_Reg 	: in  STD_LOGIC_VECTOR (4 downto 0);
			ReadAddr2_Reg 	: in  STD_LOGIC_VECTOR (4 downto 0);
			ReadData1_Reg 	: out STD_LOGIC_VECTOR (31 downto 0);
			ReadData2_Reg 	: out STD_LOGIC_VECTOR (31 downto 0);				
			WriteAddr_Reg	: in  STD_LOGIC_VECTOR (4 downto 0); 
			WriteData_Reg 	: in STD_LOGIC_VECTOR (31 downto 0);
			RegWrite 		: in STD_LOGIC; 
			CLK 				: in  STD_LOGIC);
end component;

----------------------------------------------------------------
-- Hi/Lo register
----------------------------------------------------------------
component RegHiLo is
     Port ( 
           WriteData_HiLo : in  STD_LOGIC_VECTOR (63 downto 0);	-- Data write to Hi/Lo
           ReadData_HiLo  : out STD_LOGIC_VECTOR (63 downto 0);	-- Data read from Hi/Lo
			  RegWrite_HiLo  : in  STD_LOGIC;								-- 1: write, 0: not write
           CLK            : in  STD_LOGIC);
end component;

----------------------------------------------------------------
-- CoProcessor0
----------------------------------------------------------------
component CoProcessor0 is
     Port ( CoProAddr_Read   : in  STD_LOGIC_VECTOR(4 downto 0);
				CoProcessorIn    : in  STD_LOGIC_VECTOR(31 downto 0);
				CoProAddr_Write  : in  STD_LOGIC_VECTOR(4 downto 0);
				CoProcessorOut   : out STD_LOGIC_VECTOR(31 downto 0);
				CoProcessorWrite : in  STD_LOGIC;
				CLK              : in  STD_LOGIC);
end component;

----------------------------------------------------------------
-- SignExtender
----------------------------------------------------------------
component SignExtender is
    Port ( Input  : in  STD_LOGIC_VECTOR (15 downto 0);
           Output : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

----------------------------------------------------------------
-- IF_ID
----------------------------------------------------------------
component IF_ID is
	Port (CLK					: 	in STD_LOGIC;
			IFID_Flush			: 	in STD_LOGIC;
			IFID_Stall			: 	in STD_LOGIC;
			IFID_PCPlus4In		:	in STD_LOGIC_VECTOR(31 downto 0);
			IFID_InstrIn		:	in STD_LOGIC_VECTOR(31 downto 0);

			IFID_PCPlus4Out	:	out STD_LOGIC_VECTOR(31 downto 0);
			IFID_InstrOut		: 	out STD_LOGIC_VECTOR(31 downto 0)
			);
end component;

----------------------------------------------------------------
-- ID_EX
----------------------------------------------------------------
component ID_EX is
	Port (CLK						:	in STD_LOGIC;
			IDEX_Flush				:	in STD_LOGIC;
			IDEX_Stall				:	in STD_LOGIC;
			IDEX_BranchIn			:	in STD_LOGIC;
			IDEX_ALUOpIn			:  in STD_LOGIC_VECTOR(1 downto 0);
			IDEX_MemreadIn			:  in STD_LOGIC;
			IDEX_MemtoRegIn		:	in STD_LOGIC;
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
			IDEX_ALUOpOut			:  out STD_LOGIC_VECTOR(1 downto 0);
			IDEX_MemreadOut		:  out STD_LOGIC;
			IDEX_MemtoRegOut		:	out STD_LOGIC;
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
end component;

----------------------------------------------------------------
-- EX_MEM
----------------------------------------------------------------
component EX_MEM is
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
end component;

----------------------------------------------------------------
-- MEM_WB
----------------------------------------------------------------
component MEM_WB is
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
end component;

----------------------------------------------------------------
-- PC Signals
----------------------------------------------------------------
	signal	PC_in 		:  STD_LOGIC_VECTOR (31 downto 0) := x"00400000";
	signal	PC_out 		:  STD_LOGIC_VECTOR (31 downto 0) := x"00400000";

----------------------------------------------------------------
-- ALU Signals
----------------------------------------------------------------
	signal	ALU_InA 				:  STD_LOGIC_VECTOR (31 downto 0);
	signal	ALU_InB 				:  STD_LOGIC_VECTOR (31 downto 0);
	signal	ALU_Result1 		:  STD_LOGIC_VECTOR (31 downto 0);
	signal	ALU_Result2 		:  STD_LOGIC_VECTOR (31 downto 0);
	signal	ALU_Control			:  STD_LOGIC_VECTOR (5 downto 0);
	signal	ALU_Status			:  STD_LOGIC_VECTOR (2 downto 0);

----------------------------------------------------------------
-- Control Unit Signals
----------------------------------------------------------------				
 	signal	opcode 		:  STD_LOGIC_VECTOR (5 downto 0);
	signal	ALUOp 		:  STD_LOGIC_VECTOR (1 downto 0);
	signal	Branch 		:  STD_LOGIC;
	signal	Jump	 		:  STD_LOGIC;
	signal	CUMemread	:	STD_LOGIC;
	signal	CUMemwrite	:	STD_LOGIC;
	signal	MemtoReg 	:  STD_LOGIC;
	signal 	InstrtoReg	: 	STD_LOGIC;		
	signal	ALUSrc 		:  STD_LOGIC;	
	signal	SignExtend 	: 	STD_LOGIC;
	signal	RegWrite		: 	STD_LOGIC;
	signal	RegDst		:  STD_LOGIC;

----------------------------------------------------------------
-- Register File Signals
----------------------------------------------------------------
 	signal	ReadAddr1_Reg 	:  STD_LOGIC_VECTOR (4 downto 0);
	signal	ReadAddr2_Reg 	:  STD_LOGIC_VECTOR (4 downto 0);
	signal	ReadData1_Reg 	:  STD_LOGIC_VECTOR (31 downto 0);
	signal	ReadData2_Reg 	:  STD_LOGIC_VECTOR (31 downto 0);
	signal	WriteAddr_Reg	:  STD_LOGIC_VECTOR (4 downto 0); 
	signal	WriteData_Reg 	:  STD_LOGIC_VECTOR (31 downto 0);
	
----------------------------------------------------------------
-- Hi/Lo Register Signals
----------------------------------------------------------------								
   signal  WriteData_HiLo : STD_LOGIC_VECTOR (63 downto 0);
   signal  ReadData_HiLo  : STD_LOGIC_VECTOR (63 downto 0);
	signal  RegWrite_HiLo  : STD_LOGIC;
	
----------------------------------------------------------------
-- CoProcessor0 Signals
----------------------------------------------------------------								
   signal  CoProAddr_Read   : STD_LOGIC_VECTOR(4 downto 0);
	signal  CoProcessorIn    : STD_LOGIC_VECTOR(31 downto 0);
	signal  CoProAddr_Write  : STD_LOGIC_VECTOR(4 downto 0);
   signal  CoProcessorOut   : STD_LOGIC_VECTOR(31 downto 0);
	signal  CoProcessorWrite : STD_LOGIC;

----------------------------------------------------------------
-- SignExtend Signals
----------------------------------------------------------------
 	signal	SignEx_In 	:  STD_LOGIC_VECTOR (15 downto 0);
	signal	SignEx_Out 	:  STD_LOGIC_VECTOR (31 downto 0);
	
----------------------------------------------------------------
-- Other Signals
----------------------------------------------------------------
	--<any other signals used goes here>
	signal PCPlus4 	: STD_LOGIC_VECTOR (31 downto 0) := x"00400000";
	signal ALU_func	: STD_LOGIC_VECTOR (4 downto 0);
	
----------------------------------------------------------------
-- IF_ID Signals
----------------------------------------------------------------
	signal	IFID_Flush			: 	STD_LOGIC;
	signal	IFID_Stall			: 	STD_LOGIC;
	signal	IFID_PCPlus4In		:	STD_LOGIC_VECTOR(31 downto 0);
	signal	IFID_InstrIn		:	STD_LOGIC_VECTOR(31 downto 0);
		
	signal	IFID_PCPlus4Out	:	STD_LOGIC_VECTOR(31 downto 0);
	signal	IFID_InstrOut		:  STD_LOGIC_VECTOR(31 downto 0);
	
----------------------------------------------------------------
-- ID_EX Signals
----------------------------------------------------------------
	signal	IDEX_Flush				: STD_LOGIC;
	signal	IDEX_Stall				: STD_LOGIC;
	signal	IDEX_BranchIn			: STD_LOGIC;
	signal	IDEX_ALUOpIn			: STD_LOGIC_VECTOR(1 downto 0);
	signal	IDEX_MemreadIn			: STD_LOGIC;
	signal	IDEX_MemtoRegIn		: STD_LOGIC;
	signal	IDEX_MemwriteIn		: STD_LOGIC;
	signal	IDEX_ALUSrcIn			: STD_LOGIC;
	signal	IDEX_RegDstIn			: STD_LOGIC;
	signal	IDEX_RegRsIn			: STD_LOGIC_VECTOR(4 downto 0);
	signal	IDEX_RegRtIn			: STD_LOGIC_VECTOR(4 downto 0);
	signal	IDEX_RegRdIn			: STD_LOGIC_VECTOR(4 downto 0);
	signal	IDEX_PCPlus4In			: STD_LOGIC_VECTOR(31 downto 0);
	signal	IDEX_ReadData1In		: STD_LOGIC_VECTOR(31 downto 0);
	signal	IDEX_ReadData2In		: STD_LOGIC_VECTOR(31 downto 0);
	signal	IDEX_SignExtendIn		: STD_LOGIC;
	signal	IDEX_SignExtendedIn	: STD_LOGIC_VECTOR(31 downto 0);
		
	signal	IDEX_BranchOut			: STD_LOGIC;
	signal	IDEX_ALUOpOut			: STD_LOGIC_VECTOR(1 downto 0);
	signal	IDEX_MemreadOut		: STD_LOGIC;
	signal	IDEX_MemtoRegOut		: STD_LOGIC;
	signal	IDEX_MemwriteOut		: STD_LOGIC;
	signal	IDEX_ALUSrcOut			: STD_LOGIC;
	signal	IDEX_RegDstOut			: STD_LOGIC;
	signal 	IDEX_RegRsOut			: STD_LOGIC_VECTOR(4 downto 0);
	signal 	IDEX_RegRtOut			: STD_LOGIC_VECTOR(4 downto 0);
	signal 	IDEX_RegRdOut			: STD_LOGIC_VECTOR(4 downto 0);
	signal	IDEX_PCPlus4Out		: STD_LOGIC_VECTOR(31 downto 0);
	signal	IDEX_ReadData1Out		: STD_LOGIC_VECTOR(31 downto 0);
	signal	IDEX_ReadData2Out		: STD_LOGIC_VECTOR(31 downto 0);
	signal	IDEX_SignExtendOut	: STD_LOGIC;
	signal	IDEX_SignExtendedOut	: STD_LOGIC_VECTOR(31 downto 0);

----------------------------------------------------------------
-- EX_MEM Signals
----------------------------------------------------------------
	signal	EXMEM_Flush					: STD_LOGIC;
	signal	EXMEM_Stall					: STD_LOGIC;
	signal	EXMEM_BranchIn				: STD_LOGIC;
	signal	EXMEM_BranchTargetIn		: STD_LOGIC_VECTOR(31 downto 0);
	signal	EXMEM_MemreadIn			: STD_LOGIC;
	signal	EXMEM_MemtoRegIn			: STD_LOGIC;
	signal	EXMEM_MemwriteIn			: STD_LOGIC;
	signal	EXMEM_ALUZeroIn			: STD_LOGIC;
	signal	EXMEM_ALUResult1In		: STD_LOGIC_VECTOR(31 downto 0);
	signal	EXMEM_ALUResult2In		: STD_LOGIC_VECTOR(31 downto 0);
	signal	EXMEM_WriteDataMemIn		: STD_LOGIC_VECTOR(31 downto 0);
	signal	EXMEM_WriteAddrRegIn		: STD_LOGIC_VECTOR(4 downto 0);

	signal	EXMEM_BranchOut			: STD_LOGIC;
	signal	EXMEM_BranchTargetOut	: STD_LOGIC_VECTOR(31 downto 0);
	signal	EXMEM_MemreadOut			: STD_LOGIC;
	signal	EXMEM_MemtoRegOut			: STD_LOGIC;
	signal	EXMEM_MemwriteOut			: STD_LOGIC;
	signal	EXMEM_ALUZeroOut			: STD_LOGIC;
	signal	EXMEM_ALUResult1Out		: STD_LOGIC_VECTOR(31 downto 0);
	signal	EXMEM_ALUResult2Out		: STD_LOGIC_VECTOR(31 downto 0);
	signal	EXMEM_WriteDataMemOut	: STD_LOGIC_VECTOR(31 downto 0);
	signal	EXMEM_WriteAddrRegOut	: STD_LOGIC_VECTOR(4 downto 0);
	
----------------------------------------------------------------
-- MEM_WB Signals
----------------------------------------------------------------
	signal	MEMWB_Flush					: STD_LOGIC;
	signal	MEMWB_Stall					: STD_LOGIC;
	signal	MEMWB_MemtoRegIn			: STD_LOGIC;
	signal	MEMWB_MemReadDataIn		: STD_LOGIC_VECTOR(31 downto 0);
	signal	MEMWB_ALUResult1In		: STD_LOGIC_VECTOR(31 downto 0);
	signal	MEMWB_ALUResult2In		: STD_LOGIC_VECTOR(31 downto 0);
	signal	MEMWB_WriteAddrRegIn		: STD_LOGIC_VECTOR(4 downto 0);
	
	signal	MEMWB_MemtoRegOut			: STD_LOGIC;
	signal	MEMWB_MemReadDataOut		: STD_LOGIC_VECTOR(31 downto 0);
	signal	MEMWB_ALUResult1Out		: STD_LOGIC_VECTOR(31 downto 0);
	signal	MEMWB_ALUResult2Out		: STD_LOGIC_VECTOR(31 downto 0);
	signal	MEMWB_WriteAddrRegOut	: STD_LOGIC_VECTOR(4 downto 0);

----------------------------------------------------------------	
----------------------------------------------------------------
-- <MIPS architecture>
----------------------------------------------------------------
----------------------------------------------------------------
begin

----------------------------------------------------------------
-- PC port map
----------------------------------------------------------------
PC1				: PC port map
						(
						PC_in 	=> PC_in, 
						PC_out 	=> PC_out, 
						RESET 	=> RESET,
						CLK 		=> CLK
						);
						
----------------------------------------------------------------
-- ALU port map
----------------------------------------------------------------
ALU1 				: ALU 
					generic map (width =>  32)
					port map
						(
						CLK				=> CLK,
						ALU_InA 			=> ALU_InA, 
						ALU_InB 			=> ALU_InB, 
						ALU_Result1 	=> ALU_Result1,
						ALU_Result2 	=> ALU_Result2,
						ALU_Control 	=> ALU_Control, 
						ALU_Status  	=> ALU_Status
						);
						
----------------------------------------------------------------
-- PC port map
----------------------------------------------------------------
ControlUnit1 	: ControlUnit port map
						(
						opcode 		=> opcode, 
						ALUOp 		=> ALUOp, 
						Branch 		=> Branch, 
						Jump 			=> Jump, 
						MemRead 		=> CUMemRead, 
						MemtoReg 	=> MemtoReg, 
						InstrtoReg 	=> InstrtoReg, 
						MemWrite 	=> CUMemWrite, 
						ALUSrc 		=> ALUSrc, 
						SignExtend 	=> SignExtend, 
						RegWrite 	=> RegWrite,
						RegDst 		=> RegDst
						);
						
----------------------------------------------------------------
-- Register file port map
----------------------------------------------------------------
RegFile1			: RegFile port map
						(
						ReadAddr1_Reg 	=>  ReadAddr1_Reg,
						ReadAddr2_Reg 	=>  ReadAddr2_Reg,
						ReadData1_Reg 	=>  ReadData1_Reg,
						ReadData2_Reg 	=>  ReadData2_Reg,
						WriteAddr_Reg 	=>  WriteAddr_Reg,
						WriteData_Reg 	=>  WriteData_Reg,
						RegWrite 		=>  RegWrite,
						CLK 				=>  CLK				
						);
						
----------------------------------------------------------------
-- HiLo register port map
----------------------------------------------------------------
RegHiLo1		:   RegHiLo port map
					 (
					 ReadData_HiLo  => ReadData_HiLo,
					 WriteData_HiLo => WriteData_HiLo,
					 RegWrite_HiLo  => RegWrite_HiLo,
					 CLK            => CLK
					 );
					 
----------------------------------------------------------------
-- CoProcessor port map
----------------------------------------------------------------
CoProcessor01		:   CoProcessor0 port map
						(
						CoProAddr_Read   => CoProAddr_Read,
						CoProcessorIn    => CoProcessorIn,
						CoProAddr_Write  => CoProAddr_Write,
						CoProcessorOut   => CoProcessorOut,
						CoProcessorWrite => CoProcessorWrite,
						CLK              => CLK
						);


----------------------------------------------------------------
-- SignExtender port map
----------------------------------------------------------------
SignExtender1		:SignExtender port map
						(
						Input => SignEx_In,
						Output => SignEx_Out
						);
						
----------------------------------------------------------------
-- IF_ID port map
----------------------------------------------------------------
IF_ID1	: IF_ID port map
			(
			CLK					=> CLK,
			IFID_Flush			=> IFID_Flush,
			IFID_Stall			=> IFID_Stall,
			IFID_PCPlus4In		=> IFID_PCPlus4In,
			IFID_InstrIn		=> IFID_InstrIn,
		
			IFID_PCPlus4Out	=> IFID_PCPlus4Out,
			IFID_InstrOut		=> IFID_InstrOut
			);

----------------------------------------------------------------
-- ID_EX port map
----------------------------------------------------------------
ID_EX1: ID_EX port map
		(
		CLK						=>	CLK,
		IDEX_Flush				=> IDEX_Flush,
		IDEX_Stall				=> IDEX_Stall,
		IDEX_BranchIn			=> IDEX_BranchIn,
		IDEX_ALUOpIn			=> IDEX_ALUOpIn,
		IDEX_MemreadIn			=> IDEX_MemreadIn,
		IDEX_MemtoRegIn		=> IDEX_MemtoRegIn,
		IDEX_MemwriteIn		=> IDEX_MemwriteIn,
		IDEX_ALUSrcIn			=> IDEX_ALUSrcIn,
		IDEX_RegDstIn			=> IDEX_RegDstIn,
		IDEX_RegRsIn			=> IDEX_RegRsIn,
		IDEX_RegRtIn			=>	IDEX_RegRtIn,
		IDEX_RegRdIn			=>	IDEX_RegRdIn,
		IDEX_PCPlus4In			=> IDEX_PCPlus4In,
		IDEX_ReadData1In		=> IDEX_ReadData1In,
		IDEX_ReadData2In		=> IDEX_ReadData2In,
		IDEX_SignExtendIn		=> IDEX_SignExtendIn,
		IDEX_SignExtendedIn	=> IDEX_SignExtendedIn,
		
		IDEX_BranchOut			=> IDEX_BranchOut,
		IDEX_ALUOpOut			=> IDEX_ALUOpOut,
		IDEX_MemreadOut		=> IDEX_MemreadOut,
		IDEX_MemtoRegOut		=> IDEX_MemtoRegOut,
		IDEX_MemwriteOut		=> IDEX_MemwriteOut,
		IDEX_ALUSrcOut			=> IDEX_ALUSrcOut,
		IDEX_RegDstOut			=> IDEX_RegDstOut,
		IDEX_RegRsOut			=> IDEX_RegRsOut,
		IDEX_RegRtOut			=>	IDEX_RegRtOut,
		IDEX_RegRdOut			=>	IDEX_RegRdOut,
		IDEX_PCPlus4Out		=> IDEX_PCPlus4Out,
		IDEX_ReadData1Out		=> IDEX_ReadData1Out,
		IDEX_ReadData2Out		=> IDEX_ReadData2Out,
		IDEX_SignExtendOut	=> IDEX_SignExtendOut,
		IDEX_SignExtendedOut	=> IDEX_SignExtendedOut
		);

----------------------------------------------------------------
-- EX_MEM port map
----------------------------------------------------------------
EX_MEM1	:EX_MEM port map
		(
		CLK							=>	CLK,
		EXMEM_Flush					=>	EXMEM_Flush,
		EXMEM_Stall					=>	EXMEM_Stall,
		EXMEM_BranchIn				=>	EXMEM_BranchIn,
		EXMEM_BranchTargetIn		=>	EXMEM_BranchTargetIn,
		EXMEM_MemreadIn			=>	EXMEM_MemreadIn,
		EXMEM_MemtoRegIn			=>	EXMEM_MemtoRegIn,
		EXMEM_MemwriteIn			=>	EXMEM_MemwriteIn,
		EXMEM_ALUZeroIn			=>	EXMEM_ALUZeroIn,
		EXMEM_ALUResult1In		=>	EXMEM_ALUResult1In,
		EXMEM_ALUResult2In		=> EXMEM_ALUResult2In,
		EXMEM_WriteDataMemIn		=>	EXMEM_WriteDataMemIn,
		EXMEM_WriteAddrRegIn		=>	EXMEM_WriteAddrRegIn,

		EXMEM_BranchOut			=>	EXMEM_BranchOut,
		EXMEM_BranchTargetOut	=>	EXMEM_BranchTargetOut,
		EXMEM_MemreadOut			=>	EXMEM_MemreadOut,
		EXMEM_MemtoRegOut			=>	EXMEM_MemtoRegOut,	
		EXMEM_MemwriteOut			=>	EXMEM_MemwriteOut,
		EXMEM_ALUZeroOut			=>	EXMEM_ALUZeroOut,
		EXMEM_ALUResult1Out		=>	EXMEM_ALUResult1Out,
		EXMEM_ALUResult2Out		=> EXMEM_ALUResult2Out,
		EXMEM_WriteDataMemOut	=>	EXMEM_WriteDataMemOut,
		EXMEM_WriteAddrRegOut	=>	EXMEM_WriteAddrRegOut
		);
		
----------------------------------------------------------------
-- MEM_WB port map
----------------------------------------------------------------
MEM_WB1	:MEM_WB port map
		(
		CLK					 		=>	CLK,
		MEMWB_Flush					=>	MEMWB_Flush,
		MEMWB_Stall					=>	MEMWB_Stall,
		MEMWB_MemtoRegIn			=>	MEMWB_MemtoRegIn,
		MEMWB_MemReadDataIn		=>	MEMWB_MemReadDataIn,
		MEMWB_ALUResult1In		=>	MEMWB_ALUResult1In,
		MEMWB_ALUResult2In		=>	MEMWB_ALUResult2In,
		MEMWB_WriteAddrRegIn		=>	MEMWB_WriteAddrRegIn,
		
		MEMWB_MemtoRegOut			=> MEMWB_MemtoRegOut,
		MEMWB_MemReadDataOut		=>	MEMWB_MemReadDataOut,
		MEMWB_ALUResult1Out		=> MEMWB_ALUResult1Out,
		MEMWB_ALUResult2Out		=>	MEMWB_ALUResult2Out,
		MEMWB_WriteAddrRegOut	=>	MEMWB_WriteAddrRegOut
		);
		
----------------------------------------------------------------
-- Processor logic
----------------------------------------------------------------
--<Rest of the logic goes here>


--IF stage----------------------------------------------------------------------------------------------------------------
PCPlus4 <= PC_out + 4 when ALU_Status(2) = '0' else
			  PC_out;

-- Output to TOP
Addr_Instr <= PC_out;

-- Input for PC
PC_In <= Readdata1_Reg when ALUOp = "00" and Instr(5 downto 1) = "00100" else -- JR, JALR
			(PCPlus4(31 downto 28) & Instr(25 downto 0) & "00") when Jump = '1' else
			PCPlus4 + (SignEx_out(29 downto 0) & "00") when Branch = '1' and ALU_Status(0) = '1' else
			PCPlus4 + (SignEx_out(29 downto 0) & "00") when Branch = '1' and ALU_Result1 = x"00000000" else -- bgez
			PCPlus4;			

-- Input for IFID
IFID_PCPlus4In <= PCPlus4;
IFID_InstrIn <= Instr;
IFID_Flush <= '1' when Jump = '1' or (ALUOp = "00" and Instr(5 downto 1) = "00100") or -- Flush when jumps (all kinds)
							  (Branch = '1' and ALU_Status(0) = '1') or 								-- Flush when BEQ
							   (Branch = '1' and ALU_Result1 = x"00000000") else					-- Flush when BGEZ/BGEZAL
					'0';

--end IF stage----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

--ID stage----------------------------------------------------------------------------------------------------------------
-- Input for ControlUnit
opcode <= IFID_InstrOut(31 downto 26);

-- Input for RegFile
ReadAddr1_Reg <= IFID_InstrOut(25 downto 21);
ReadAddr2_Reg <= IFID_InstrOut(20 downto 16);
					  
-- Input for SignExtender
SignEx_In <= IFID_InstrOut(15 downto 0);

-- Input for ID/EX
IDEX_BranchIn <= Branch;
IDEX_ALUOpIn <= ALUOp;
IDEX_MemreadIn <= CUMemRead;
IDEX_MemtoRegIn <= MemtoReg;
IDEX_MemwriteIn <= CUMemWrite;
IDEX_ALUSrcIn <= ALUSrc;
IDEX_RegDstIn <= RegDst;
IDEX_RegRsIn <= IFID_InstrOut(25 downto 21);
IDEX_RegRtIn <= IFID_InstrOut(20 downto 16);
IDEX_RegRdIn <= IFID_InstrOut(15 downto 11);
IDEX_PCPlus4In <= IFID_PcPlus4Out;
IDEX_ReadData1In <= ReadData1_Reg;
IDEX_ReadData2In <= ReadData2_Reg;
IDEX_SignExtendIn <= SignExtend;
IDEX_SignExtendedIn <= SignEx_Out;
IDEX_Flush <= '1' when (Branch = '1' and ALU_Status(0) = '1') or 				-- Flush when BEQ
							  (Branch = '1' and ALU_Result1 = x"00000000") else	-- Flush when BGEZ/BGEZAL
					'0';

--end ID stage----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

--EX stage----------------------------------------------------------------------------------------------------------------
-- Input for ALU
ALU_InA <= IDEX_ReadData2Out when (IDEX_ALUOpOut = "00" and 
											  IDEX_SignExtendedOut(5 downto 3) = "000") else	-- IDEX_SignExtendedOut(5 downto 3) is Instr(5 downto 3)
			  IDEX_ReadData1Out;
			  
ALU_InB <= (x"000000" & "000" & IDEX_SignExtendedOut(10 downto 6)) when (IDEX_ALUOpOut = "00" and 
																								 IDEX_SignExtendedOut(5 downto 2) = "0000") else
				x"00000000" when Instr(31 downto 26) = "000001" else  -- BGEZ
				IDEX_ReadData1Out when (IDEX_ALUOpOut = "00" and 
												IDEX_SignExtendedOut(5 downto 2) = "0001") else
				IDEX_ReadData2Out when IDEX_ALUSrcOut = '0' else
				IDEX_SignExtendedOut when IDEX_SignExtendOut = '1' else
			  (x"0000" & IDEX_SignExtendedOut(15 downto 0));  -- for ADDIU, ORI (non sign extend imm)

ALU_Func <= "00110" when IDEX_ALUOpOut = "01" else						-- add when branch
				"00010" when IDEX_ALUOpOut = "00" else						-- add when lw, sw, addiu, addi
				"00001" when IDEX_ALUOpOut = "11" else 					-- or when ori
				"00000" when IDEX_SignExtendedOut(5 downto 0) = "100100" else	-- and
				"00001" when IDEX_SignExtendedOut(5 downto 0) = "100101" else	-- or
				"01100" when IDEX_SignExtendedOut(5 downto 0) = "100111" else	-- nor
				"00100" when IDEX_SignExtendedOut(5 downto 0) = "100110" else	-- xor
				"00010" when IDEX_SignExtendedOut(5 downto 0) = "100000" else	-- add
				"00110" when IDEX_SignExtendedOut(5 downto 0) = "100010" else	-- sub
				"00111" when (Instr(31 downto 26) = "001010" or 
								  Instr(31 downto 26) = "000001" or 
								  IDEX_SignExtendedOut(5 downto 0) = "101010") else -- slti, bgez, slt
				"01110" when IDEX_SignExtendedOut(5 downto 0) = "101011"else	-- sltu
				"00101" when (IDEX_SignExtendedOut(5 downto 0) = "000000" or 
								  IDEX_SignExtendedOut(5 downto 0) = "000100") else	-- sll, sllv
				"01101" when (IDEX_SignExtendedOut(5 downto 0) = "000010" or 
								  IDEX_SignExtendedOut(5 downto 0) = "000110") else	-- srl, srlv
				"01001" when (IDEX_SignExtendedOut(5 downto 0) = "000011" or 
								  IDEX_SignExtendedOut(5 downto 0) = "000111") else	-- sra, srav
				"10000" when IDEX_SignExtendedOut(5 downto 0) = "011000" else	-- mult
				"10001" when IDEX_SignExtendedOut(5 downto 0) = "011001" else	-- multu
				"10010" when IDEX_SignExtendedOut(5 downto 0) = "011010" else	-- div
				"10011" when IDEX_SignExtendedOut(5 downto 0) = "011011" else	-- divu
				"XXXXX";														-- unknown operation
				
ALU_Control <= RESET & ALU_Func;	

-- Input for RegHiLo
RegWrite_HiLo <= '1' when (IDEX_ALUOpOut = "00" and IDEX_SignExtendedOut(5 downto 3) = "011") else -- write HiLO when DIV/U and MULT/U
					  '0';
WriteData_HiLo <= ALU_Result2 & ALU_Result1;

-- Input to EX/MEM
EXMEM_BranchIn <= IDEX_BranchOut;
EXMEM_BranchTargetIn <= IDEX_PCPlus4Out + (IDEX_SignExtendedOut(29 downto 0) & "00");
EXMEM_MemreadIn <= IDEX_MemreadOut;
EXMEM_MemtoRegIn <= IDEX_MemtoRegOut;
EXMEM_MemwriteIn <= IDEX_MemwriteOut;
EXMEM_ALUZeroIn <= ALU_Status(0);
EXMEM_ALUResult1In <= ALU_Result1;
EXMEM_ALUResult2In <= ALU_Result2;
EXMEM_WriteDataMemIn <= IDEX_ReadData2Out;	-- Need to modify for MEM forwarding
EXMEM_WriteAddrRegIn <= IDEX_RegRtOut when IDEX_RegDstOut = '0' else
								IDEX_RegRdOut;
EXMEM_Flush <= '1' when (Branch = '1' and ALU_Status(0) = '1') or 			-- Flush when BEQ
							   (Branch = '1' and ALU_Result1 = x"00000000") else	-- Flush when BGEZ/BGEZAL
					'0';

---end EX stage---------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

---MEM stage------------------------------------------------------------------------------------------------------------------

-- Output to TOP
Addr_Data <= EXMEM_ALUResult1Out;
Data_Out <=	EXMEM_WriteDataMemOut;
Memread <= EXMEM_MemreadOut;
Memwrite <= EXMEM_MemwriteOut;

-- Input to MEM/WB
MEMWB_MemtoRegIn <= EXMEM_MemtoRegOut;
MEMWB_MemReadDataIn <= Data_In;
MEMWB_ALUResult1In <= EXMEM_ALUResult1Out;
MEMWB_ALUResult2In <= EXMEM_ALUResult2Out;
MEMWB_WriteAddrRegIn <= EXMEM_WriteAddrRegOut;

---end MEM stage---------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

---WB stage-------------------------------------------------------------------------------------------------------------------
WriteAddr_Reg <= "11111" when ((Instr(31 downto 26) = "000001" and 
						(Instr(20 downto 16) = "10001" or Instr(20 downto 16) = "10000")) or 
						Instr(31 downto 26) = "000011" or (ALUOp = "00" and Instr(5 downto 0) = "001001")) else	--bgezal or bltzal or jal or jalr
						MEMWB_WriteAddrRegOut;
WriteData_Reg <= PC_in + 4 when ((Instr(31 downto 26) = "000001" and 
						(Instr(20 downto 16) = "10001" or Instr(20 downto 16) = "10000")) or 
						Instr(31 downto 26) = "000011" or (ALUOp = "00" and Instr(5 downto 0) = "001001")) else	--bgezal or bltzal or jal or jalr
						Data_in when MemtoReg = '1' else
					  (Instr(15 downto 0) & x"0000") when InstrtoReg = '1' else
					  ReadData_HiLo(63 downto 32) when (Instr(31 downto 26) = "000000" and Instr(5 downto 0) = "010000") else
					  ReadData_HiLo(31 downto 0) when (Instr(31 downto 26) = "000000" and Instr(5 downto 0) = "010010") else
					  CoProcessorOut when (Instr(31 downto 26) = "010000" and Instr(23) = '0') else -- MFC0
					  MEMWB_ALUResult1Out;

---end WB stage---------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

-- Input for CoProcessor0
CoProAddr_Read <= Instr(15 downto 11);
CoProAddr_Write <= Instr(15 downto 11);
CoProcessorIn <= ReadData2_Reg;
CoProcessorWrite <= '1' when (Instr(31 downto 26) = "010000" and Instr(23) = '1') else -- MTC0
						  '0';
						  

end arch_MIPS;

----------------------------------------------------------------	
----------------------------------------------------------------
-- </MIPS architecture>
----------------------------------------------------------------
----------------------------------------------------------------	
