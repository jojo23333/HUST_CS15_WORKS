`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/12 16:12:45
// Design Name: 
// Module Name: CONTROL
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/*
writer: tanghuichuan
input: 
    OPCODE[5:0] 
    FUNCT[5:0]
output:
    ALUOP[3:0] : ALU option
    Shift、Zero_extend... : control message, 1 bit
*/

module CONTROL(
    input [5:0] OPCODE,
    input [5:0] FUNCT,
    output reg [3:0] ALUOP,
    output reg Shift,
    output reg Zero_extend,
    output reg ALUSrc,
    output reg RegDst,
    output reg RegWrite,
    output reg Jump,
    output reg Beq,
    output reg Bne,
    output reg MemRead,
    output reg MemWrite,
    output reg Jal,
    output reg Jr,
    output reg Syscall,
    output reg Bgez,
    output reg Lh
    );

    reg addi, addiu, andi, ori, lw, sw, beq, bne, slti, j, jal, xori, lh, bgez, add, addu, _and, sll, sra, srl, sub, _or, _nor, slt, sltu, jr, syscall, subu;
    initial begin
        addi <= 0; addiu <= 0; andi <= 0; ori <= 0; lw <= 0; sw <= 0; beq <= 0; bne <= 0; slti <= 0; j <= 0; jal <= 0; xori <= 0; lh <= 0; bgez <= 0; add <= 0; addu <= 0; _and <= 0; sll <= 0; sra <= 0; srl <= 0; sub <= 0; _or <= 0; _nor <= 0; slt <= 0; sltu <= 0; jr <= 0; syscall <= 0; subu <= 0;
    end

    always @(OPCODE or FUNCT) begin

        addi = (OPCODE == 6'h8) ? 1 : 0;
        addiu = (OPCODE == 6'h9) ? 1 : 0;
        andi = (OPCODE == 6'hc) ? 1 : 0;
        ori = (OPCODE == 6'hd) ? 1 : 0; 
        lw = (OPCODE == 6'h23) ? 1 : 0;
        sw = (OPCODE == 6'h2b) ? 1 : 0;
        beq = (OPCODE == 6'h4) ? 1 : 0;
        bne = (OPCODE == 6'h5) ? 1 : 0; 
        slti = (OPCODE == 6'ha) ? 1 : 0;
        j = (OPCODE == 6'h2) ? 1 : 0;
        jal = (OPCODE == 6'h3) ? 1 : 0;
        xori = (OPCODE == 6'he) ? 1 : 0; 
        lh = (OPCODE == 6'h21) ? 1 : 0;
        bgez = (OPCODE == 6'h1) ? 1 : 0;

        if (OPCODE != 0)begin
            add = 0; addu = 0; _and = 0; sll = 0; sra = 0; srl = 0; sub = 0; _or = 0; _nor = 0; slt = 0; sltu = 0; jr = 0; syscall = 0; subu = 0;
        end
        else begin
            add = (FUNCT == 6'h20) ? 1 : 0;
            addu = (FUNCT == 6'h21) ? 1 : 0;
            _and = (FUNCT == 6'h24) ? 1 : 0;
            sll = (FUNCT == 6'h0) ? 1 : 0; 
            sra = (FUNCT == 6'h3) ? 1 : 0;
            srl = (FUNCT == 6'h2) ? 1 : 0;
            sub = (FUNCT == 6'h22) ? 1 : 0;
            _or = (FUNCT == 6'h25) ? 1 : 0; 
            _nor = (FUNCT == 6'h27) ? 1 : 0;
            slt = (FUNCT == 6'h2a) ? 1 : 0;
            sltu = (FUNCT == 6'h2b) ? 1 : 0;
            jr = (FUNCT == 6'h8) ? 1 : 0; 
            syscall = (FUNCT == 6'hc) ? 1 : 0;
            subu = (FUNCT == 6'h23) ? 1 : 0;
        end

        // ALU Option
        ALUOP <= sltu ? 12 :
                (slt || slti) ? 11 :
                _nor ? 10 :
                xori ? 9 :
                (_or || ori) ? 8 : 
                (_and || andi) ? 7 :
                (sub || subu) ? 6 :
                (add || addi || addiu || addu || lw || sw || beq || bne || bgez || lh) ? 5 :
                srl ? 2 : 
                sra ? 1 :
                sll ? 0 : 0;

        // Control Message
        MemRead = (lw || lh) ? 1 : 0;
        MemWrite = sw;
        Shift = (sll || sra || srl) ? 1 : 0;
        Zero_extend = (xori || andi || ori) ? 1 : 0;
        RegDst = (add || _nor || addu || _and || sll || sra || srl || _or || slt || sltu || subu || sub) ? 1 : 0;
        Jump = (j || jal);
        Beq = beq;
        Bne = bne;
        Jal = jal;
        Jr = jr;
        Syscall = syscall;
        Bgez = bgez;
        Lh = lh;
        ALUSrc = (addi || addiu || andi || sll || sra || srl || ori || lw || sw || slti || xori || lh) ? 1 : 0;
        RegWrite = (slt || add || addiu || addu || _and || sll || sra || _nor || srl || _or || lh || sltu || subu || sub || addi || andi || ori || lw || slti || xori || jal) ? 1 : 0; 
    end 

endmodule
