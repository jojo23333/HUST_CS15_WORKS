`timescale 1ns/1ps

module NPC ( pc_in, pcjump_in, jump_in, equal_in, beq_in, bne_in, 
    bltz_in, jr_in, extendimm_in, da_in, nextpc_out, jmp, bsuccess);
    input wire [31:0] pc_in;
    input wire [31:0] pcjump_in;
    input wire jump_in, equal_in, beq_in, bne_in, bltz_in, jr_in;
    input wire [31:0] extendimm_in, da_in;
    output wire [31:0] nextpc_out;
    output wire jmp, bsuccess;

    wire cmp;
    wire [31:0] jump_addr,branch_addr;
    wire [31:0] jump_after_addr,branch_after_addr,pc_4;
    wire branch_control;

    assign cmp = ($signed(da_in) > $signed(0))? 1:0;

    assign pc_4 = pc_in + 4;
    assign jump_addr[31:28] = pc_4[31:28];
    assign jump_addr[27:0] = pcjump_in[27:0];
    assign branch_addr = (extendimm_in << 2) + pc_4;

    assign branch_control = ((bltz_in && cmp) || (bne_in && (~equal_in)) || (beq_in && equal_in))? 1: 0;
    assign jmp = jr_in | jump_in;
    assign bsuccess = branch_control;

    // jr select
    MUX2_32 jr_select (.in0(jump_after_addr), .in1(da_in), 
                        .control(jr_in), .out(nextpc_out));
    // jump select
    MUX2_32 jump_select (.in0(branch_after_addr), .in1(jump_addr), 
                        .control(jump_in) ,.out(jump_after_addr));
    // branch select
    MUX2_32 branch_select (.in0(pc_4), .in1(branch_addr), 
                        .control(branch_control), .out(branch_after_addr));
endmodule