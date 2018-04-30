`timescale 1ns / 1ps

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
    output [3:0] ALUOP,
    output Shift,
    output Zero_extend,
    output ALUSrc,
    output RegDst,
    output RegWrite,
    output Jump,
    output Beq,
    output Bne,
    output MemRead,
    output MemWrite,
    output Jal,
    output Jr,
    output Syscall,
    output Bltz,
    output Lh,
    output rBValid);

    wire addi, addiu, andi, ori, lw, sw, beq, bne, slti, j, jal, xori, lh, bltz,
         add, addu, _and, sll, sra, srl, sub, _or, _nor, slt, sltu, jr, syscall, sltiu;

    assign addi = (OPCODE == 6'h8) ? 1 : 0;
    assign addiu = (OPCODE == 6'h9) ? 1 : 0;
    assign andi = (OPCODE == 6'hc) ? 1 : 0;
    assign ori = (OPCODE == 6'hd) ? 1 : 0; 
    assign lw = (OPCODE == 6'h23) ? 1 : 0;
    assign sw = (OPCODE == 6'h2b) ? 1 : 0;
    assign beq = (OPCODE == 6'h4) ? 1 : 0;
    assign bne = (OPCODE == 6'h5) ? 1 : 0; 
    assign slti = (OPCODE == 6'ha) ? 1 : 0;
    assign j = (OPCODE == 6'h2) ? 1 : 0;
    assign jal = (OPCODE == 6'h3) ? 1 : 0;
    assign xori = (OPCODE == 6'he) ? 1 : 0;
    assign lh = (OPCODE == 6'h21) ? 1 : 0;
    assign bltz = (OPCODE == 6'h1) ? 1 : 0;
    assign sltiu = (OPCODE == 6'hb) ? 1 : 0;

    wire opzero;
    assign opzero = (OPCODE == 0) ? 1 : 0;

    assign add = (OPCODE == 0 && FUNCT == 6'h20) ? 1 : 0;
    assign addu = (OPCODE == 0 && FUNCT == 6'h21) ? 1 : 0;
    assign _and = (OPCODE == 0 && FUNCT == 6'h24) ? 1 : 0;
    assign sll = (OPCODE == 0 && FUNCT == 6'h0) ? 1 : 0; 
    assign sra = (OPCODE == 0 && FUNCT == 6'h3) ? 1 : 0;
    assign srl = (OPCODE == 0 && FUNCT == 6'h2) ? 1 : 0;
    assign sub = (OPCODE == 0 && FUNCT == 6'h22) ? 1 : 0;
    assign _or = (OPCODE == 0 && FUNCT == 6'h25) ? 1 : 0; 
    assign _nor = (OPCODE == 0 && FUNCT == 6'h27) ? 1 : 0;
    assign slt = (OPCODE == 0 && FUNCT == 6'h2a) ? 1 : 0;
    assign sltu = (OPCODE == 0 && FUNCT == 6'h2b) ? 1 : 0;
    assign jr = (OPCODE == 0 && FUNCT == 6'h8) ? 1 : 0; 
    assign syscall = (OPCODE == 0 && FUNCT == 6'hc) ? 1 : 0;

        // ALU Option
    assign ALUOP = ( sltu || sltiu) ? 12 :
            (slt || slti) ? 11 :
            _nor ? 10 :
            xori ? 9 :
            (_or || ori) ? 8 : 
            (_and || andi) ? 7 :
            sub ? 6 :
            (add || addi || addiu || addu || lw || sw || beq || bne || bltz || lh) ? 5 :
            srl ? 2 : 
            sra ? 1 :
            sll ? 0 : 0;

        // Control Message
    assign MemRead = lw | lh;
    assign MemWrite = sw;
    assign Shift = sll | sra | srl;
    assign Zero_extend = xori | andi | ori;
    assign RegDst = add | _nor | addu | _and | sll | sra | srl | _or | slt | sltu |  sub;
    assign Jump = j | jal;
    assign Beq = beq;
    assign Bne = bne;
    assign Jal = jal;
    assign Jr = jr;
    assign Syscall = syscall;
    assign Bltz = bltz;
    assign Lh = lh;
    assign ALUSrc = addi | addiu | andi | sll | sra | srl | ori | lw | sw | slti | xori | lh | sltiu;
    assign RegWrite = slt | add | addiu | addu | _and | sll | sra | _nor 
        | srl | _or | lh | sltu | sltiu | sub | addi | andi | ori | lw | slti | xori | jal; 
    assign rBValid = beq | syscall | RegDst | bne | sw ;


endmodule
