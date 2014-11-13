----------------------------------------------------------------------------------
-- Company: NUS
-- Engineer: Rajesh Panicker
-- 
-- Create Date:   10:39:18 13/09/2014
-- Design Name: 	ALU
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool versions: ISE 14.7
-- Description: ALU template for MIPS processor
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------


------------------------------------------------------------------
-- ALU Entity
------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity alu is
generic (width 		: integer := 32);
Port (CLK				: in	STD_LOGIC;
		ALU_Control		: in	STD_LOGIC_VECTOR (5 downto 0);
		ALU_InA			: in	STD_LOGIC_VECTOR (width-1 downto 0);
		ALU_InB			: in	STD_LOGIC_VECTOR (width-1 downto 0);
		ALU_Result1		: out	STD_LOGIC_VECTOR (width-1 downto 0);
		ALU_Result2		: out	STD_LOGIC_VECTOR (width-1 downto 0);
		ALU_Status		: out	STD_LOGIC_VECTOR (2 downto 0)); -- busy (multicycle only), overflow (add and sub), zero (sub)
end alu;


------------------------------------------------------------------
-- ALU Architecture
------------------------------------------------------------------

architecture Behavioral of alu is

type states is (COMBINATIONAL, MULTI_CYCLE);
signal state, n_state 	: states := COMBINATIONAL;


----------------------------------------------------------------------------
-- Adder instantiation
----------------------------------------------------------------------------
component adder is
generic (width : integer);
port (A 		: in 	std_logic_vector(width-1 downto 0);
		B 		: in 	std_logic_vector(width-1 downto 0);
		C_in 	: in 	std_logic;
		S 		: out std_logic_vector(width-1 downto 0);
		C_out	: out std_logic);
end component adder;

----------------------------------------------------------------------------
-- Adder signals
----------------------------------------------------------------------------
signal B 		: std_logic_vector(width-1 downto 0) := (others => '0'); 
signal C_in 	: std_logic := '0';
signal S 		: std_logic_vector(width-1 downto 0) := (others => '0'); 
signal C_out	: std_logic := '0'; --not used


----------------------------------------------------------------------------
-- Signals for MULTI_CYCLE_PROCESS
----------------------------------------------------------------------------
signal Result1_multi		: STD_LOGIC_VECTOR (width-1 downto 0) := (others => '0'); 
signal Result2_multi		: STD_LOGIC_VECTOR (width-1 downto 0) := (others => '0');
signal done		 			: STD_LOGIC := '0';



begin

-- <port maps>
adder32 : adder generic map (width =>  width) port map (  A=>ALU_InA, B=>B, C_in=>C_in, S=>S, C_out=>C_out );
-- </port maps>


----------------------------------------------------------------------------
-- COMBINATIONAL PROCESS
----------------------------------------------------------------------------
COMBINATIONAL_PROCESS : process (
											ALU_Control, ALU_InA, ALU_InB, state, -- external inputs
											S, -- ouput from the adder (or other components)
											C_out, --output from adder
											Result1_multi, Result2_multi, done -- from multi-cycle process(es)
											)
variable overflow : std_logic;
variable temp : std_logic_vector(width-1 downto 0) := (others => '0');
begin

-- <default outputs>
ALU_Status(2 downto 0) <= "000"; -- both ALU_Statuses '0' by default 
ALU_Result1 <= (others=>'0');
ALU_Result2 <= (others=>'0');

n_state <= state;

B <= ALU_InB;
C_in <= '0';
-- </default outputs>

--reset
if ALU_Control(5) = '1' then
	n_state <= COMBINATIONAL;
else

case state is
	when COMBINATIONAL =>
		case ALU_Control(4 downto 0) is
		--and
		when "00000" =>   -- takes 0 cycles to execute
			ALU_Result1 <= ALU_InA and ALU_InB;
		--or
		when "00001" =>
			ALU_Result1 <= ALU_InA or ALU_InB;
		--nor
		when "01100" => 
			ALU_Result1 <= ALU_InA nor ALU_InB;
		--xor
		when "00100" =>
			ALU_Result1 <= ALU_InA xor ALU_InB;
			
		--add
		when "00010" =>
			ALU_Result1 <= S;
			-- overflow
			ALU_Status(1) <= ( ALU_InA(width-1) xnor  ALU_InB(width-1) )  and ( ALU_InB(width-1) xor S(width-1) );
			
		-- sub
		when "00110" =>
			B <= not(ALU_InB);
			C_in <= '1';
			ALU_Result1 <= S;
			-- overflow
			ALU_Status(1) <= ( ALU_InA(width-1) xor  ALU_InB(width-1) )  and ( ALU_InB(width-1) xnor S(width-1) );
			--zero
			if S = x"00000000" then 
				ALU_Status(0) <= '1'; 
			else
				ALU_Status(0) <= '0';
			end if;
			
		-- SLT, SLTI
		when "00111" =>
			B <= not(ALU_InB);
			C_in <= '1';
			
			overflow := ( ALU_InA(width-1) xor  ALU_InB(width-1) )  and ( ALU_InB(width-1) xnor S(width-1) );
			if (overflow = '1' and S(width-1) = '0') or (overflow = '0' and S(width-1)='1') then
				ALU_Result1 <= x"00000001";
				ALU_Status(0) <= '0';
			else
				ALU_Result1 <= x"00000000";
				ALU_Status(0) <= '1';
			end if;
		
		-- SLTU, SLTIU
		when "01110" =>
			B <= not (ALU_InB);
			C_in <= '1';
			
			if (C_out = '1') then
				ALU_Result1 <= x"00000000";
			else
				ALU_Result1 <= x"00000001";


			end if;
		
		-- SLL, SLLV
		when "00101" =>
			temp := ALU_InA;
			if ALU_InB(4) = '1' then
				temp(width-1 downto 0) := (temp(15 downto 0) & x"0000");
			end if;
			if ALU_InB(3) = '1' then
				temp(width-1 downto 0) := (temp(23 downto 0) & x"00");
			end if;
			if ALU_InB(2) = '1' then
				temp(width-1 downto 0) := (temp(27 downto 0) & x"0");
			end if;
			if ALU_InB(1) = '1' then
				temp(width-1 downto 0) := (temp(29 downto 0) & "00");
			end if;
			if ALU_InB(0) = '1' then
				temp(width-1 downto 0) := (temp(30 downto 0) & '0');
			end if;
			ALU_Result1 <= temp;
			
		--SRL, SRLV, SRA, SRAV
		when "01101" | "01001" =>
			temp := ALU_InA;
			if ALU_InB(4) = '1' then
				temp := (15 downto 0 => (not ALU_Control(2) and ALU_InA(31))) & temp(31 downto 16);
			end if;
			if ALU_InB(3) = '1' then
				temp := (7 downto 0 => (not ALU_Control(2) and ALU_InA(31))) & temp(31 downto 8);
			end if;
			if ALU_InB(2) = '1' then
				temp := (3 downto 0 => (not ALU_Control(2) and ALU_InA(31))) & temp(31 downto 4);
			end if;
			if ALU_InB(1) = '1' then
				temp := (1 downto 0 => (not ALU_Control(2) and ALU_InA(31))) & temp(31 downto 2);
			end if;
			if ALU_InB(0) = '1' then
				temp := (not ALU_Control(2) and ALU_InA(31)) & temp(31 downto 1);
			end if;
			ALU_Result1 <= temp;
		-- multi-cycle operations
		when "10000" | "10001" -- MULT | MULTU
			| "11110"           -- just show 2 operands
			| "10010" | "10011" -- DIV | DIVU
			=> 
			n_state <= MULTI_CYCLE;
			ALU_Status(2) <= '1';
		-- default cases (already covered)
		when others=> null;
		end case;
	when MULTI_CYCLE => 
		if done = '1' then
			ALU_Result1 <= Result1_multi;
			ALU_Result2 <= Result2_multi;
			n_state <= COMBINATIONAL;
			ALU_Status(2) <= '0';
		else
			ALU_Status(2) <= '1';
			n_state <= MULTI_CYCLE;
		end if;
	end case;
end if;	
end process;


----------------------------------------------------------------------------
-- STATE UPDATE PROCESS
----------------------------------------------------------------------------

STATE_UPDATE_PROCESS : process (CLK) -- state updating
begin  
   if (CLK'event and CLK = '1') then
		state <= n_state;
   end if;
end process;

----------------------------------------------------------------------------
-- MULTI CYCLE PROCESS
----------------------------------------------------------------------------

MULTI_CYCLE_PROCESS : process (CLK) -- multi-cycle operations done here
-- assume that ALU_InA and Operand 2 do not change while multi-cycle operations are being performed
variable count : std_logic_vector(5 downto 0) := (others => '0');
variable temp : std_logic_vector(2*width-1 downto 0);
variable temp_wider : std_logic_vector(2*width downto 0);
variable temp_var : std_logic;

begin  
   if (CLK'event and CLK = '1') then 
		if ALU_Control(5) = '1' then
			count := (others => '0');
			temp := (others => '0');
			temp_wider := (others => '0');
		end if;
		done <= '0';
		if n_state = MULTI_CYCLE then
			case ALU_Control(4 downto 0) is
							
			--MULTU, MULT
			when "10001" | "10000" =>
				if state = COMBINATIONAL then
					temp_wider(2*width downto width) := (others => '0');
					temp_wider(width-1 downto 0) := ALU_InB;  --load lower half with ALU_InB (B)
					count := (others => '0');
					temp_var := '0';
				end if;
			
				count := count+1;
				
				if (ALU_Control(0) = '1' and temp_wider(0) = '1') or (ALU_Control(0) = '0' and temp_wider(0) = '0' and temp_var = '1') then
					temp_wider(2*width downto width) := temp_wider(2*width downto width) + ((ALU_InA(width-1) and (not ALU_Control(0))) & ALU_InA); 
				elsif ALU_Control(0) = '0' and temp_wider(0) = '1' and temp_var = '0' then
					temp_wider(2*width downto width) := temp_wider(2*width downto width) + not((ALU_InA(width-1) and (not ALU_Control(0))) & ALU_InA) + 1; 
				end if;

				--shift temp_sum right by 1 (this will also shift lower half, which stores ALU_InB, by 1)
				temp_var := temp_wider(0);
				temp_wider(2*width-1 downto 0) := temp_wider(2*width downto 1);
				temp_wider(2*width) := temp_wider(2*width-1) and (not ALU_Control(0));
				
				if count="100000" then	
					Result1_multi <= temp_wider(width-1 downto 0);
					Result2_multi <= temp_wider(2*width-1 downto width);
					done <= '1';	
				end if;
				
			--DIV | DIVU
			when "10010" | "10011" =>
				if state = COMBINATIONAL then
					if ALU_Control(0)='1' then
						temp(width-1 downto 0) := ALU_InA;
						temp(2*width-1 downto width) := ALU_InB;
					else
						if ALU_InA(31) = '1' then
							temp(width-1 downto 0) := not(ALU_InA) + 1;
						else
							temp(width-1 downto 0) := ALU_InA;
						end if;
						if ALU_InB(31) = '1' then
							temp(2*width-1 downto width) := not(ALU_InB) + 1;
						else
							temp(2*width-1 downto width) := ALU_InB;
						end if;
					end if;
					temp_wider := (others => '0');
					--placing dividend in temp(remainder)
					temp_wider(width-1 downto 0) := temp(width-1 downto 0);

					--shift temp left by 1 bit
					temp_wider(2*width downto 1) := temp_wider(2*width-1 downto 0);
					temp_wider(0) := '0';
					count := (others => '0');
				end if;		
				count := count+1;
				
				--substract left half of temp (remainder) with divisor
				temp_wider(2*width downto width) := temp_wider(2*width downto width) + ('1' & not(temp(2*width-1 downto width))) + 1;
			
				if (temp_wider(2*width) = '1') then --ALU_InA < ALU_InB
					temp_wider(2*width downto width) := temp_wider(2*width downto width) + ('0' & temp(2*width-1 downto width)); --restoring the remainder
					
					--shift left with '0' appended
					temp_wider(2*width downto 1) := temp_wider(2*width-1 downto 0);
					temp_wider(0) := '0';
				else
					--shift left with '1' appended
					temp_wider(2*width downto 1) := temp_wider(2*width-1 downto 0);
					temp_wider(0) := '1';	
				end if;
				
				if count="100000" then
					--shift only the left half by 1 bit to the right
					temp_wider(2*width-1 downto width) := temp_wider(2*width downto width+1);
					temp_wider(2*width) := '0';
					if ALU_Control(0) = '1' then
						Result1_multi <= temp_wider(width-1 downto 0); --quotient
						Result2_multi <= temp_wider(2*width-1 downto width); --remainder
					else
						if ALU_InA(31) = '1' then
							Result2_multi <= not(temp_wider(2*width-1 downto width)) + 1; --remainder
						else
							Result2_multi <= temp_wider(2*width-1 downto width);
						end if;			
						if (ALU_InA(31) xor ALU_InB(31)) = '1' then
							Result1_multi <= not(temp_wider(width-1 downto 0)) + 1; --quotient
						else
							Result1_multi <= temp_wider(width-1 downto 0); 
						end if;
					end if;
					done <= '1';	
				end if;
			
			-----------------------	
			when "11110" => -- takes 1 cycle to execute, just returns the operands
				if state = COMBINATIONAL then
					Result1_multi <= ALU_InA;
					Result2_multi <= ALU_InB;
					done <= '1';
				end if;
				
			when others=> null;
			end case;
		end if;
	end if;
end process;


end Behavioral;


------------------------------------------------------------------
-- Adder Entity
------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity adder is
generic (width : integer := 32);
port (A 		: in std_logic_vector(width-1 downto 0);
		B 		: in std_logic_vector(width-1 downto 0);
		C_in 	: in std_logic;
		S 		: out std_logic_vector(width-1 downto 0);
		C_out	: out std_logic);
end adder;

------------------------------------------------------------------
-- Adder Architecture
------------------------------------------------------------------

architecture adder_arch of adder is
signal S_wider : std_logic_vector(width downto 0);
begin
	S_wider <= ('0'& A) + ('0'& B) + C_in;
	S <= S_wider(width-1 downto 0);
	C_out <= S_wider(width);
end adder_arch;