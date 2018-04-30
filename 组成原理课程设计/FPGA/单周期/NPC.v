`timescale 1ns/1ps

module NPC ( pc_in, pcjump_in, jump_in, equal_in, beq_in, bne_in, 
    bgez_in, jr_in, extendimm_in, da_in, pcjar_out, nextpc_out);
    input wire [31:0] pc_in;
    input wire [27:0] pcjump_in;
    input wire jump_in, equal_in, beq_in, bne_in, bgez_in, jr_in;
    input wire [31:0] extendimm_in, da_in;
    output wire [31:0] pcjar_out, nextpc_out;

    wire cmp;
    wire [31:0] jump_addr,branch_addr;
    wire [31:0] jump_after_addr,branch_after_addr;
    wire branch_control;

    assign cmp = (da_in[31] == 0)? 1:0;

    assign pcjar_out = pc_in + 4;
    assign jump_addr[31:28] = pcjar_out[31:28];
    assign jump_addr[27:0] = pcjump_in;
    assign branch_addr = (extendimm_in << 2) + pcjar_out;

    assign branch_control = (bgez_in & cmp) | (bne_in & (~equal_in)) | (beq_in & equal_in);

    // jr select
    MUX2_32 jr_select (.in0(jump_after_addr), .in1(da_in), 
                        .control(jr_in), .out(nextpc_out));
    // jump select
    MUX2_32 jump_select (.in0(branch_after_addr), .in1(jump_addr), 
                        .control(jump_in) ,.out(jump_after_addr));
    // branch select
    MUX2_32 branch_select (.in0(pcjar_out), .in1(branch_addr), 
                        .control(branch_control), .out(branch_after_addr));

endmodule