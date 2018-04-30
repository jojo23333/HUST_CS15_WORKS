`timescale 1ns/1ps

module EX ( pc, imm, pcjump, nRB, nRA, rW, aluop, contorl_sigs, clk, rst,
            nrb_v, result, next_pc, syscall_out, to_mem, hault, isJmp, bSuc);   

    input [31:0] pc, imm, pcjump, nRB, nRA;
    input [4:0] rW;
    input [3:0] aluop;
    // jal, syscall, alusrc, rw_en, rbvalid, jump, beq, bne, memw, jr, bltz, lh, memread
    input [12:0] contorl_sigs;
    input clk, rst;
    output [31:0] nrb_v, result, next_pc, syscall_out;
    output [8:0] to_mem;    //rw_en,lh,memread,memw,rW
    output hault, isJmp, bSuc;

    wire jal, syscall, alusrc, rw_en, rbvalid, jump, beq, bne, memw, jr, bltz, lh, memread;
    assign {syscall, jal, alusrc, rw_en,jump, beq, bne, memw ,jr, bltz, lh, memread, rbvalid} = contorl_sigs;
    
    wire equal;
    wire [31:0] result_alu;

    // npc
    NPC cpu_npc (.pc_in(pc), .pcjump_in(pcjump), .jump_in(jump), .equal_in(equal), .beq_in(beq), //input
                 .bne_in(bne), .bltz_in(bltz), .jr_in(jr), .extendimm_in(imm), .da_in(nRA),
                 .nextpc_out(next_pc), .jmp(isJmp), .bsuccess(bSuc));   // output

    wire [31:0] y0, result2;
    assign y0 = (alusrc == 0)? nRB : imm;
    ALU cpu_alu ( .X(nRA), .Y(y0), .ALU_OP(aluop),                        // input
            .Result(result_alu), .Result2(result2), .Equal(equal));// output

    SYSCALL cpu_syscall ( .RA(nRA), .RB(nRB), .syscall(syscall), .clk(clk), .rst(rst),
                .hault(hault), .syscall_out(syscall_out) );

    assign result = ( jal == 1 ) ? pc + 4 : result_alu; 
    assign nrb_v = nRB;
    assign to_mem = {rw_en, lh, memread, memw, rW};

endmodule