----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/26/2025 06:32:51 PM
-- Design Name: 
-- Module Name: IFetch - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IFetch is
    Port ( Jump : in STD_LOGIC;
           JumpAddress : in STD_LOGIC_VECTOR (31 downto 0);
           PCSrc : in STD_LOGIC;
           BranchAddress : in STD_LOGIC_VECTOR (31 downto 0);
           Enable : in STD_LOGIC;
           Reset : in STD_LOGIC;
           clk : in STD_LOGIC;
           PCPlus : out STD_LOGIC_VECTOR (31 downto 0);
           Instruction : out STD_LOGIC_VECTOR (31 downto 0));
end IFetch;

architecture Behavioral of IFetch is

signal PC: STD_LOGIC_VECTOR(31 downto 0);
signal PC_plus: STD_LOGIC_VECTOR(31 downto 0);
signal PC_branch: STD_LOGIC_VECTOR(31 downto 0);
signal PC_next: STD_LOGIC_VECTOR(31 downto 0);

type ROM_array is array(0 to 63) of std_logic_vector(31 downto 0);
signal mem: ROM_array := (
    0  => B"000000_00000_00000_01000_00000_100000", -- Hexa: 0x00004020 | Pozitie: 0x00000004 | Assembly: add $8, $zero, $zero | Ce face: Initializeaza contorul ($8) cu 0 | PCp: 0x00000004
    1  => B"100011_00000_01001_0000000000000100", -- Hexa: 0x8C090004 | Pozitie: 0x00000008 | Assembly: lw $9, 4($zero) | Ce face: Citeste lungimea vectorului din memorie | PCp: 0x00000008
    2  => B"000000_00000_00000_01010_00000_100000", -- Hexa: 0x00005020 | Pozitie: 0x0000000c | Assembly: add $10, $zero, $zero | Ce face: Initializeaza indexul pentru parcurgere ($10) cu 0 | PCp: 0x0000000C
    3  => B"001000_00000_01011_0000000000001000", -- Hexa: 0x200B0008 | Pozitie: 0x00000010 | Assembly: addi $11, $zero, 8 | Ce face: Salveaza adresa de start a vectorului (offset 8) | PCp: 0x00000010
    4  => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x00000014
    5  => B"000100_01010_01001_0000000000011111", -- Hexa: 0x1149000B | Pozitie: 0x00000014 | Assembly: beq $10, $9, end (offset=31) | Ce face: Daca indexul a ajuns la dimensiunea vectorului, merge la final | PCp: 0x00000018
    6  => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x0000001C
    7  => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x00000020
    8  => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x00000024
    9  => B"000000_00000_01010_01100_00010_000000", -- Hexa: 0x000A6020 | Pozitie: 0x00000018 | Assembly: sll $12, $10, 2 | Ce face: Calculam in $12 offsetul la care se afla elementul fata de origine | PCp: 0x00000028
    10 => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x0000002C
    11 => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x00000030
    12 => B"000000_01011_01100_01101_00000_100000", -- Hexa: 0x016C6820 | Pozitie: 0x0000001c | Assembly: add $13, $11, $12 | Ce face: Aflam adresa din memorie a elementului | PCp: 0x00000034
    13 => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x00000038
    14 => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x0000003C
    15 => B"100011_01101_01110_0000000000000000", -- Hexa: 0x8DAE0000 | Pozitie: 0x00000020 | Assembly: lw $14, $13 | Ce face: Ia valoarea elementului din memorie | PCp: 0x00000040
    16 => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x00000044
    17 => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x00000048
    18 => B"000111_01110_00000_0000000000000101", -- Hexa: 0x1DC00005 | Pozitie: 0x00000024 | Assembly: bgtz $14, check_even (offset=5) | Ce face: Verificam daca numarul e pozitiv, daca da, sare peste jump | PCp: 0x0000004C
    19 => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x00000050
    20 => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x00000054
    21 => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x00000058
    22 => B"000010_00000000000000000000100011", -- Hexa: 0x08000023 | Pozitie: 0x00000028 | Assembly: j next (addr = 35 / 4 = 8.sth) | Ce face: Daca e negativ, trece la urmatorul numar | PCp: 0x0000005C
    23 => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x00000060
    24 => B"001100_01110_01111_0000000000000001", -- Hexa: 0x38EF0001 | Pozitie: 0x0000002c | Assembly: andi $15, $14, 1 | Ce face: Verificam bitul cel mai putin semnificativ pentru paritate | PCp: 0x00000064
    25 => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x00000068
    26 => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x0000006C
    27 => B"001010_01111_11000_0000000000000001", -- Hexa: 0x29F80001 | Pozitie: 0x00000030 | Assembly: slti $24, $15, 1 | Ce face: Inversam rezultatul, astfel ca avem in registrul $24 1 daca numarul e par, 0 in caz contrar | PCp: 0x00000070
    28 => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x00000074
    29 => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x00000078
    30 => B"000100_11000_00000_0000000000000100", -- Hexa: 0x13000001 | Pozitie: 0x00000034 | Assembly: beq $24, $zero, next (off=4) | Ce face: Daca $24 e 0, numarul e  impar, incrementam doar indexul, nu si contorul | PCp: 0x0000007C
    31 => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x00000080
    32 => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x00000084
    33 => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x00000088
    34 => B"001000_01000_01000_0000000000000001", -- Hexa: 0x21080001 | Pozitie: 0x00000038 | Assembly: addi $8, $8, 1 | Ce face: Daca e par, incrementam contorul | PCp: 0x0000008C
    35 => B"001000_01010_01010_0000000000000001", -- Hexa: 0x214A0001 | Pozitie: 0x0000003c | Assembly: addi $10, $10, 1 | Ce face: Incrementam indexul | PCp: 0x00000090
    36 => B"000010_00000_00000_0000000000000100", -- Hexa: 0x08000004 | Pozitie: 0x00000040 | Assembly: j loop (addr = 4 / 4 = 1) | Ce face: Revine la inceputul buclei | PCp: 0x00000094
    37 => B"000000_00000_00000_00000_00000_100000", -- NoOp | PCp: 0x00000098
    38 => B"101011_00000_01000_0000000000000000",  -- Hexa: 0xAC080000 | Pozitie: 0x00000044 | Assembly: sw $8, 0($zero) | Ce face: Cand bucla e gata, salvam counterul | PCp: 0x0000009C
    others => X"00000000"
);


begin

    PC_plus <= PC + 4;

    --Mux 1 pt branch
    PC_branch <= BranchAddress when PCSrc = '1' else PC_plus;

    --Mux 2 pt jump
    PC_next <= JumpAddress when Jump = '1' else PC_branch;

    process(clk,Reset)
    begin
        if Reset = '1' then
           PC<=(others => '0');
        elsif rising_edge(clk) then
           if Enable = '1' then
               PC<=PC_next;
            end if;
        end if;
    end process;

    Instruction <= mem(conv_integer(PC(7 downto 2)));
    PCPlus <= PC_plus;

end Behavioral;
