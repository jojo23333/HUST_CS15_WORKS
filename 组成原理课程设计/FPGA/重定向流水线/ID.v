`timescale 1ns/1ps


/*
syscall, jal, alusrc, rw_en,jump, beq, bne, memw ,jr, bltz, lh, memread, rbvalid
*/

module ID ( pc, ir, clk, reg_write_value, reg_write_select, reg_write_enable,
         alu_op, control_sig, imm, pcjump, rA, rB, rW, ra_v, rb_v, rbvalid);

    input [31:0] pc, ir, reg_write_value;
    input [4:0] reg_write_select;
    input clk, reg_write_enable;

    output [31:0] imm, pcjump, ra_v, rb_v;
    output [12:0] control_sig;
    output [4:0] rA, rB, rW;
    output [3:0] alu_op;
    output wire rbvalid;

    
    // cpu decoder output //pcjump,extend,rW connect directly to the output
    wire [5:0] opcode, funct; 
    // cpu control output
    wire shift, zero_extend, reg_dst;
    wire syscall, jal, alu_src, rw_en,jump, beq, bne, memw ,jr, bltz, lh, memread;

    // decoder
    DECODER cpu_decoder ( .CODE(ir), .shift(shift), .syscall(syscall), 
                        .RegDst(reg_dst), .Jal(jal), .Zero_extend(zero_extend), //input
                        .PCjump(pcjump), .OPCODE(opcode), .FUNCT(funct), .RA(rA), 
                        .RB(rB), .RW(rW), .extend(imm) );    //ouput
    
    // controller
    CONTROL cpu_control ( .OPCODE(opcode), .FUNCT(funct) ,  // input
                        .ALUOP(alu_op), .Shift(shift), .Zero_extend(zero_extend), .ALUSrc(alu_src),
                        .RegDst(reg_dst),.RegWrite(rw_en), .Jump(jump), .Beq(beq),.Bne(bne),
                        .MemRead(memread), .MemWrite(memw), .Jal(jal), .Jr(jr), .Syscall(syscall), .Bltz(bltz), .Lh(lh), .rBValid(rbvalid)); //output

    assign rev_clk = ~clk;
    REGFILE cpu_register ( .w(reg_write_value), .we(reg_write_enable), .clk(rev_clk), .rw(reg_write_select), .ra_index(rA), .rb_index(rB),
                        .A(ra_v), .B(rb_v));
    
    assign control_sig = {syscall, jal, alu_src, rw_en,jump, beq, bne, memw ,jr, bltz, lh, memread, rbvalid};

endmodule