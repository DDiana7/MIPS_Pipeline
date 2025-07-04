----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2025 06:45:31 PM
-- Design Name: 
-- Module Name: test_env - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Adapted test environment for instruction fetch and decode
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
-- use IEEE.NUMERIC_STD.ALL; -- Optional, not used in current design

entity test_env is
    Port (
        clk : in STD_LOGIC;
        btn : in STD_LOGIC_VECTOR(4 downto 0);
        sw  : in STD_LOGIC_VECTOR(15 downto 0);
        led : out STD_LOGIC_VECTOR(15 downto 0);
        an  : out STD_LOGIC_VECTOR(7 downto 0);
        cat : out STD_LOGIC_VECTOR(6 downto 0)
    );
end test_env;

architecture Behavioral of test_env is

     component MPG is
        Port (
            enable : out STD_LOGIC;
            btn : in STD_LOGIC;
            clk : in STD_LOGIC
        );
    end component;

    component SSD is
        Port (
            clk : in STD_LOGIC;
            digits : in STD_LOGIC_VECTOR(31 downto 0);
            an : out STD_LOGIC_VECTOR(7 downto 0);
            cat : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    component IFetch is
        Port (
            Jump : in STD_LOGIC;
            JumpAddress : in STD_LOGIC_VECTOR(31 downto 0);
            PCSrc : in STD_LOGIC;
            BranchAddress : in STD_LOGIC_VECTOR(31 downto 0);
            Enable : in STD_LOGIC;
            Reset : in STD_LOGIC;
            clk : in STD_LOGIC;
            PCPlus : out STD_LOGIC_VECTOR(31 downto 0);
            Instruction : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    component UC is
        Port ( 
            Instr : in STD_LOGIC_VECTOR (5 downto 0);
            RegDst: out STD_LOGIC;
            ExtOp: out STD_LOGIC;
            ALUSrc: out STD_LOGIC;
            Branch: out STD_LOGIC;
            Jump: out STD_LOGIC;
            ALUOp: out STD_LOGIC_VECTOR (2 downto 0);
            MemWrite: out STD_LOGIC;
            MemtoReg: out STD_LOGIC;
            RegWrite: out STD_LOGIC;
            Br_GTZ: out STD_LOGIC);
    end component;

    component ID is
        Port ( 
           clk: in STD_LOGIC;
           RegWrite : in STD_LOGIC;
           Instr : in STD_LOGIC_VECTOR (25 downto 0);
           EN : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           WD : in STD_LOGIC_VECTOR (31 downto 0);
           wa : in STD_LOGIC_VECTOR (4 downto 0);
           RD1 : out STD_LOGIC_VECTOR (31 downto 0);
           RD2 : out STD_LOGIC_VECTOR (31 downto 0);
           Ext_Imm : out STD_LOGIC_VECTOR (31 downto 0);
           func : out STD_LOGIC_VECTOR (5 downto 0);
           sa : out STD_LOGIC_VECTOR (4 downto 0);
           rt : out STD_LOGIC_VECTOR (4 downto 0);
           rd : out STD_LOGIC_VECTOR (4 downto 0));
    end component;

 component EX is
        Port ( 
            rd1 : in std_logic_vector(31 downto 0);
            rd2 : in std_logic_vector(31 downto 0);
            ALUSrc : in std_logic;
            Ext_imm : in std_logic_vector(31 downto 0);
            sa : in std_logic_vector(4 downto 0);
            func : in std_logic_vector(5 downto 0);
            ALUOp : in std_logic_vector(2 downto 0);
            pcp : in std_logic_vector(31 downto 0);
            gtz : out std_logic;
            zero : out std_logic;
            ALURes : out std_logic_vector(31 downto 0);
            badd : out std_logic_vector(31 downto 0);
            rt : in STD_LOGIC_VECTOR (4 downto 0);
            rd : in STD_LOGIC_VECTOR (4 downto 0);
            RegDst : in std_logic;
            rWA : out STD_LOGIC_VECTOR (4 downto 0));
    end component;

    component MEM is
        Port (
        clk           : in std_logic;
        mw            : in std_logic;  
        en            : in std_logic;
        ALUResultIn   : in std_logic_vector(31 downto 0);
        RD2           : in std_logic_vector(31 downto 0);
        MemData       : out std_logic_vector(31 downto 0);
        ALUResultOut  : out std_logic_vector(31 downto 0));
    end component;

    signal do : STD_LOGIC_VECTOR(31 downto 0);
    signal enable : STD_LOGIC;
    signal pcp : STD_LOGIC_VECTOR(31 downto 0);
    signal instr : STD_LOGIC_VECTOR(31 downto 0);

    signal ALUOp : STD_LOGIC_VECTOR(2 downto 0);
    signal RegDst : STD_LOGIC;
    signal ExtOp : STD_LOGIC;
    signal ALUSrc : STD_LOGIC;
    signal Branch : STD_LOGIC;
    signal Br_GTZ : STD_LOGIC;
    signal Jmp : STD_LOGIC;
    signal MemWrite : STD_LOGIC;
    signal MemtoReg : STD_LOGIC;
    signal RegWrite : STD_LOGIC;
    
    signal RD1, RD2, WD : STD_LOGIC_VECTOR(31 downto 0);
    signal Ext_Imm : STD_LOGIC_VECTOR(31 downto 0);
    signal func : STD_LOGIC_VECTOR(5 downto 0);
    signal sa : STD_LOGIC_VECTOR(4 downto 0);
    
    signal ALURes : std_logic_vector(31 downto 0);
    signal ALUResOut : std_logic_vector(31 downto 0);
    signal zero, gtz : std_logic;
    signal BranchAddress : std_logic_vector(31 downto 0);
    signal memData : std_logic_vector(31 downto 0);
    
    signal BranchAddrCalc : std_logic_vector(31 downto 0);
    signal PCSrc : std_logic;
    signal jumpAddr : std_logic_vector(31 downto 0);

    signal rt : STD_LOGIC_VECTOR (4 downto 0);
    signal rd : STD_LOGIC_VECTOR (4 downto 0);

    signal rWa : std_logic_vector(4 downto 0);
    -- Semnale pentru IF/ID
    signal Instruction_IF_ID : std_logic_vector(31 downto 0);
    signal PCp4_IF_ID        : std_logic_vector(31 downto 0);

    -- Semnale pentru ID/EX
    signal RegDst_ID_EX     : std_logic;
    signal ALUSrc_ID_EX     : std_logic;
    signal Branch_ID_EX     : std_logic;
    signal Br_GTZ_ID_EX     : std_logic;
    signal ALUOp_ID_EX      : std_logic_vector(2 downto 0);
    signal MemWrite_ID_EX   : std_logic;
    signal MemtoReg_ID_EX   : std_logic;
    signal RegWrite_ID_EX   : std_logic;
    signal RD1_ID_EX        : std_logic_vector(31 downto 0);
    signal RD2_ID_EX        : std_logic_vector(31 downto 0);
    signal Ext_Imm_ID_EX    : std_logic_vector(31 downto 0);
    signal func_ID_EX       : std_logic_vector(5 downto 0);
    signal sa_ID_EX         : std_logic_vector(4 downto 0);
    signal rd_ID_EX         : std_logic_vector(4 downto 0);
    signal rt_ID_EX         : std_logic_vector(4 downto 0);
    signal PCp4_ID_EX       : std_logic_vector(31 downto 0);

    -- Semnale pentru EX/MEM
    signal Branch_EX_MEM     : std_logic;
    signal Br_GTZ_EX_MEM     : std_logic;
    signal MemWrite_EX_MEM   : std_logic;
    signal MemtoReg_EX_MEM   : std_logic;
    signal RegWrite_EX_MEM   : std_logic;
    signal zero_EX_MEM       : std_logic;
    signal gtz_EX_MEM        : std_logic;
    signal badd_EX_MEM       : std_logic_vector(31 downto 0);
    signal ALURes_EX_MEM     : std_logic_vector(31 downto 0);
    signal WA_EX_MEM         : std_logic_vector(4 downto 0);
    signal RD2_EX_MEM        : std_logic_vector(31 downto 0);
    
    -- Semnale pentru MEM/WB
    signal RegWrite_MEM_WB   : std_logic;
    signal MemtoReg_MEM_WB   : std_logic;
    signal ALURes_MEM_WB     : std_logic_vector(31 downto 0);
    signal MemData_MEM_WB    : std_logic_vector(31 downto 0);
    signal WA_MEM_WB         : std_logic_vector(4 downto 0);

begin

     -- Instan?iere MPG
    MPG_inst : MPG
        port map (
            enable => enable,
            btn => btn(0),
            clk => clk
        );

    -- Instan?iere SSD
    SSD_inst : SSD
        port map (
            clk => clk,
            digits => do,
            an => an,
            cat => cat
        );

    -- IFetch
    IFetch_inst : IFetch
        port map (
            Jump => Jmp,
            JumpAddress => jumpAddr,
            PCSrc => PCSrc,
            BranchAddress => badd_EX_MEM,
            Enable => enable,
            Reset => btn(1),
            clk => clk,
            PCPlus => pcp,
            Instruction => instr
        );

    -- ID
    ID_inst : ID
        port map (
            clk => clk,
            RegWrite => RegWrite_MEM_WB,
            Instr => Instruction_IF_ID(25 downto 0),
            EN => enable,
            ExtOp => ExtOp,
            WD => WD,
            wa => WA_MEM_WB,
            RD1 => RD1,
            RD2 => RD2,
            Ext_Imm => Ext_Imm,
            func => func,
            sa => sa,
            rt => rt,
            rd => rd
        );
        
    -- EX
    EX_inst : EX
        port map (
            rd1 => RD1_ID_EX,
            rd2 => RD2_ID_EX,
            ALUSrc => ALUSrc_ID_EX,
            Ext_imm => Ext_Imm_ID_EX,
            sa => sa_ID_EX,
            func => func_ID_EX,
            ALUOp => ALUOp_ID_EX,
            pcp => PCp4_ID_EX,
            gtz => gtz,
            zero => zero,
            ALURes => ALURes,
            badd => BranchAddrCalc,
            rt => rt_ID_EX,
            rd => rd_ID_EX,
            RegDst => RegDst_ID_EX,
            rWA => rWA
        );
          
    -- MEM
    MEM_inst : MEM
        port map (
            clk => clk,
            en => enable,
            mw => MemWrite_EX_MEM,
            ALUResultIn => ALURes_EX_MEM,
            RD2 => RD2_EX_MEM,
            MemData => memData,
            ALUResultOut => ALUResOut
        );
        
    -- Unit Control
    UC_inst : UC
        port map (
            Instr => Instruction_IF_ID(31 downto 26),
            RegDst => RegDst,
            ExtOp => ExtOp,
            ALUSrc => ALUSrc,
            Branch => Branch,
            ALUOp => ALUOp,
            MemWrite => MemWrite,
            MemtoReg => MemtoReg,
            RegWrite => RegWrite,
            Jump => Jmp,
            Br_GTZ => Br_GTZ
        );
    
    --Proces pentru IF/ID   
    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                Instruction_IF_ID <= instr;
                PCp4_IF_ID        <= pcp;
            end if;
        end if;
    end process;
   
    --Proces pentru ID/EX   
    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                RegDst_ID_EX     <= RegDst;
                ALUSrc_ID_EX     <= ALUSrc;
                Branch_ID_EX     <= Branch;
                Br_GTZ_ID_EX     <= Br_GTZ;
                ALUOp_ID_EX      <= ALUOp;
                MemWrite_ID_EX   <= MemWrite;
                MemtoReg_ID_EX   <= MemtoReg;
                RegWrite_ID_EX   <= RegWrite;
                RD1_ID_EX        <= RD1;
                RD2_ID_EX        <= RD2;
                Ext_Imm_ID_EX    <= Ext_Imm;
                func_ID_EX       <= func;
                sa_ID_EX         <= sa;
                rd_ID_EX         <= rd;
                rt_ID_EX         <= rt;
                PCp4_ID_EX       <= PCp4_IF_ID;
                end if;
        end if;
    end process;
        
    --Proces pentru EX/MEM
    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                Branch_EX_MEM    <= Branch_ID_EX;
                Br_GTZ_EX_MEM <= Br_GTZ_ID_EX;
                MemWrite_EX_MEM  <= MemWrite_ID_EX;
                MemtoReg_EX_MEM  <= MemtoReg_ID_EX;
                RegWrite_EX_MEM  <= RegWrite_ID_EX;
                zero_EX_MEM      <= zero;
                gtz_EX_MEM       <= gtz;
                badd_EX_MEM      <= BranchAddrCalc;
                ALURes_EX_MEM    <= ALURes;
                WA_EX_MEM        <= rWA; 
                RD2_EX_MEM       <= RD2_ID_EX;
            end if;
        end if;
    end process;

    --Proces pentru MEM/WB
    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                RegWrite_MEM_WB   <= RegWrite_EX_MEM;
                MemtoReg_MEM_WB   <= MemtoReg_EX_MEM;
                ALURes_MEM_WB     <= ALUResOut;
                MemData_MEM_WB    <= memData;
                WA_MEM_WB         <= WA_EX_MEM;
            end if;
        end if;
    end process;

        
    WD <= MemData_MEM_WB when MemtoReg_MEM_WB = '1' else ALURes_MEM_WB ;    
    
    PCSrc <= (Branch_EX_MEM and zero_EX_MEM) or (Br_GTZ_EX_MEM and gtz_EX_MEM);
    
    jumpAddr <= PCp4_IF_ID (31 downto 28) & Instruction_IF_ID(25 downto 0) & "00";

    
    do <= instr     when sw(7 downto 5) = "000" else
          PCp4_IF_ID       when sw(7 downto 5) = "001" else
          RD1_ID_EX       when sw(7 downto 5) = "010" else
          RD2_ID_EX       when sw(7 downto 5) = "011" else
          Ext_Imm_ID_EX        when sw(7 downto 5) = "100" else
          ALURes_EX_MEM    when sw(7 downto 5) = "101" else
          MemData_MEM_WB when sw(7 downto 5) = "110" else
          WD   when sw(7 downto 5) = "111" else
          (others => '0');

    
    led(15 downto 9) <= (others => '0');  
    led(8)  <= RegDst;
    led(7)  <= ExtOp;
    led(6)  <= ALUSrc;
    led(5)  <= Branch;
    led(4)  <= Jmp;
    led(3)  <= MemWrite;
    led(2)  <= MemtoReg;
    led(1)  <= RegWrite;
    led(0)  <= Br_GTZ;      
    led(11) <= Br_GTZ_EX_MEM;
    led(10) <= gtz_EX_MEM;
    led(9) <= PCSrc;

end Behavioral;