library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ProcesadorMonociclo is
	Port ( clk_in : in  STD_LOGIC;
           reset_in : in  STD_LOGIC;
           ALUresult : out  STD_LOGIC_VECTOR (31 downto 0));
end ProcesadorMonociclo;

architecture Behavioral of ProcesadorMonociclo is

COMPONENT nProgramCounter
	PORT(
		nPC_in : IN std_logic_vector(31 downto 0);
		clk : IN std_logic;
		reset : IN std_logic;          
		nPC_out : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

COMPONENT PC
	PORT(
		CLK : IN std_logic;
		CLR : IN std_logic;          
		entrada_pc : IN std_logic_vector(31 downto 0);
		salida_pc : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

COMPONENT sumador_32b
	PORT(
		A : IN std_logic_vector(31 downto 0);
		B : IN std_logic_vector(31 downto 0);          
		SUM : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

COMPONENT Instruction_Memory
	PORT(
		address : IN std_logic_vector(31 downto 0);
		reset : IN std_logic;          
		outInstruction : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

COMPONENT ucontrol
	PORT(
		op : IN std_logic_vector(1 downto 0);
		op3 : IN std_logic_vector(5 downto 0);          
		ucout : OUT std_logic_vector(5 downto 0)
		);
	END COMPONENT;

COMPONENT registerFile
	PORT(
		rs1 : IN std_logic_vector(4 downto 0);
		rs2 : IN std_logic_vector(4 downto 0);
		rd : IN std_logic_vector(4 downto 0);
		DWR : IN std_logic_vector(31 downto 0);
		reset : IN std_logic;          
		crs1 : OUT std_logic_vector(31 downto 0);
		crs2 : OUT std_logic_vector(31 downto 0)
		
		);
	END COMPONENT;

COMPONENT seu_32
	PORT(
		inme13 : IN std_logic_vector(12 downto 0);          
		seu_out : OUT std_logic_vector(31 downto 0)
		);
END COMPONENT;

COMPONENT MUX_32
	PORT(
		clk : IN std_logic;
		opcion : IN std_logic_vector(0 downto 0);
		entrada1 : IN std_logic_vector(31 downto 0);
		entrada2 : IN std_logic_vector(31 downto 0);       
		salida : INOUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

COMPONENT alu32
	PORT(
		crs1 : IN std_logic_vector(31 downto 0);
		crs2 : IN std_logic_vector(31 downto 0);
		ucalu : IN std_logic_vector(5 downto 0);          
		alu_result : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

signal ADD_to_nPC: std_logic_vector(31 downto 0);
signal nPC_to_PC: std_logic_vector(31 downto 0);
signal PC_to_IM: std_logic_vector(31 downto 0);
signal IM_to_RF: std_logic_vector(31 downto 0);
signal RF_to_ALU: std_logic_vector(31 downto 0);
signal RF_to_MUX: std_logic_vector(31 downto 0);
signal SEU_to_MUX: std_logic_vector(31 downto 0);
signal MUX_to_ALU: std_logic_vector(31 downto 0);
signal UC_to_ALU: std_logic_vector(5 downto 0);
signal ALU_to_RF: std_logic_vector(31 downto 0);

begin
ALUresult <= ALU_to_RF;

Inst_nProgramCounter: nProgramCounter PORT MAP(
		nPC_in => ADD_to_nPC,
		nPC_out => nPC_to_PC,
		clk => clk_in,
		reset => reset_in
	);

Inst_PC: PC PORT MAP(
		CLK => clk_in,
		CLR => reset_in,
		entrada_pc => nPC_to_PC,
		salida_pc => PC_to_IM
	);

Inst_sumador_32b: sumador_32b PORT MAP(
		A => "00000000000000000000000000000001",
		B => nPC_to_PC,
		SUM => ADD_to_nPC
	);

Inst_Instruction_Memory: Instruction_Memory PORT MAP(
		address => PC_to_IM,
		reset => reset_in,
		outInstruction => IM_to_RF 
	);

Inst_ucontrol: ucontrol PORT MAP(
		op => IM_to_RF(31 downto 30),
		op3 => IM_to_RF(24 downto 19),
		ucout => UC_to_ALU
	);

Inst_registerFile: registerFile PORT MAP(
		rs1 => IM_to_RF(18 downto 14),
		rs2 => IM_to_RF(4 downto 0),
		rd => IM_to_RF(29 downto 25),
		DWR => ALU_to_RF,
		reset => reset_in,
		crs1 => RF_to_ALU,
		crs2 => RF_to_MUX
	);

Inst_seu_32: seu_32 PORT MAP(
		inme13 => IM_to_RF(12 downto 0),
		seu_out => SEU_to_MUX
	);

Inst_MUX_32: MUX_32 PORT MAP(
		clk => clk_in,
		opcion => IM_to_RF(13 downto 13),
		entrada1 => RF_to_MUX,
		entrada2 => SEU_to_MUX,
		salida => MUX_to_ALU
	);

Inst_alu32: alu32 PORT MAP(
		crs1 => RF_to_ALU,
		crs2 => MUX_to_ALU,
		ucalu => UC_to_ALU,
		alu_result => ALU_to_RF
	);
	
end Behavioral;

