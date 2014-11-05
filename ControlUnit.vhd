----------------------------------------------------------------------------------
-- Company: NUS
-- Engineer: Rajesh Panicker
-- 
-- Create Date:   21:06:18 14/10/2014
-- Design Name: 	ControlUnit
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool versions: ISE 14.7
-- Description: Control Unit for the basic MIPS processor
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: The interface (entity) as well as implementation (architecture) can be modified
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity ControlUnit is
    Port ( 	opcode 		: in   STD_LOGIC_VECTOR (5 downto 0);
				ALUOp 		: out  STD_LOGIC_VECTOR (1 downto 0);
				Branch 		: out  STD_LOGIC;		
				Jump	 		: out  STD_LOGIC;	
				MemRead 		: out  STD_LOGIC;	
				MemtoReg 	: out  STD_LOGIC;	
				InstrtoReg	: out  STD_LOGIC;
				MemWrite		: out  STD_LOGIC;	
				ALUSrc 		: out  STD_LOGIC;	
				SignExtend 	: out  STD_LOGIC;
				RegWrite		: out  STD_LOGIC;	
				RegDst		: out  STD_LOGIC);
end ControlUnit;

architecture arch_ControlUnit of ControlUnit is 
begin

process(opcode)
begin 
	case opcode is
		when "000000" => -- R type
			ALUOp <= "10";
			Branch <= '0';
			Jump <= '0';
			MemRead <= '0';
			MemToReg <= '0';
			InstrtoReg <= '0';
			MemWrite <= '0';
			ALUSrc <= '0';
			SignExtend <= 'X';
			RegWrite <= '1';
			RegDst <= '1';
		when "100011" => -- LW
			ALUOp <= "00";
			Branch <= '0';
			Jump <= '0';
			MemRead <= '1';
			MemToReg <= '1';
			InstrtoReg <= '0';
			MemWrite <= '0';
			ALUSrc <= '1';
			SignExtend <= '1';
			RegWrite <= '1';
			RegDst <= '0';
		when "101011" => -- SW
			ALUOp <= "00";
			Branch <= '0';
			Jump <= '0';
			MemRead <= '0';
			MemToReg <= 'X';
			InstrtoReg <= '0';
			MemWrite <= '1';
			ALUSrc <= '1';
			SignExtend <= '1';
			RegWrite <= '0';
			RegDst <= 'X';
		when "001111" => -- LUI
			ALUOp <= "XX";
			Branch <= '0';
			Jump <= '0';
			MemRead <= '0';
			MemToReg <= '0';
			InstrtoReg <= '1';
			MemWrite <= '0';
			ALUSrc <= '1';
			SignExtend <= '0';
			RegWrite <= '1';
			RegDst <= '0';
		when "001000" => -- ADDI
			ALUOp <= "00";
			Branch <= '0';
			Jump <= '0';
			MemRead <= '0';
			MemToReg <= '0';
			InstrtoReg <= '0';
			MemWrite <= '0';
			ALUSrc <= '1';
			SignExtend <= '1';
			RegWrite <= '1';
			RegDst <= '0';
		when "001001" => -- ADDIU
			ALUOp <= "00";
			Branch <= '0';
			Jump <= '0';
			MemRead <= '0';
			MemToReg <= '0';
			InstrtoReg <= '0';
			MemWrite <= '0';
			ALUSrc <= '1';
			SignExtend <= '0';
			RegWrite <= '1';
			RegDst <= '0';
		when "001010" => -- SLTI
			ALUOp <= "10";
			Branch <= '0';
			Jump <= '0';
			MemRead <= '0';
			MemToReg <= '0';
			InstrtoReg <= '0';
			MemWrite <= '0';
			ALUSrc <= '1';
			SignExtend <= '1';
			RegWrite <= '1';
			RegDst <= '0';
		when "001101" => -- ORI
			ALUOp <= "11";
			Branch <= '0';
			Jump <= '0';
			MemRead <= '0';
			MemToReg <= '0';
			InstrtoReg <= '0';
			MemWrite <= '0';
			ALUSrc <= '1';
			SignExtend <= '0';
			RegWrite <= '1';
			RegDst <= '0';
		when "000100" => -- BEQ
			ALUOp <= "01";
			Branch <= '1';
			Jump <= '0';
			MemRead <= '0';
			MemToReg <= 'X';
			InstrtoReg <= '0';
			MemWrite <= '0';
			ALUSrc <= '0';
			SignExtend <= '1';
			RegWrite <= '0';
			RegDst <= 'X';
		when "000001" => -- BGEZ
			ALUOp <= "10";
			Branch <= '1';
			Jump <= '0';
			MemRead <= '0';
			MemToReg <= 'X';
			InstrtoReg <= '0';
			MemWrite <= '0';
			ALUSrc <= '0';
			SignExtend <= '1';
			RegWrite <= '0';
			RegDst <= 'X';
		when "000010" => -- J
			ALUOp <= "XX";
			Branch <= '0';
			Jump <= '1';
			MemRead <= '0';
			MemToReg <= 'X';
			InstrtoReg <= '0';
			MemWrite <= '0';
			ALUSrc <= 'X';
			SignExtend <= '0';
			RegWrite <= '0';
			RegDst <= 'X';
		--when "000011" => -- JAL
		
		when "010000" => -- MFC0 & MTC0 & ERET
			ALUOp <= "XX";
			Branch <= '0';
			Jump <= '0';
			MemRead <= '0';
			MemToReg <= 'X';
			InstrtoReg <= '0';
			MemWrite <= '0';
			ALUSrc <= 'X';
			SignExtend <= '0';
			RegWrite <= '0';
			RegDst <= '0';
			
		when others =>
			ALUOp <= "XX";
			Branch <= '0';
			Jump <= '0';
			MemRead <= '0';
			MemToReg <= 'X';
			InstrtoReg <= '0';
			MemWrite <= '0';
			ALUSrc <= 'X';
			SignExtend <= '0';
			RegWrite <= '0';
			RegDst <= 'X';
	end case;
end process;

end arch_ControlUnit;
