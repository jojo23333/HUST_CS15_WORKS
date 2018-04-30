`timescale 1ns/1ps

module predictPC ( pcIF, next_pc, isJmp, bSucc,
                   pc_out);
    input [31:0] pcIF, next_pc;
    input isJmp, bSucc;
    output [31:0] pc_out;

    assign pc_out = ( isJmp || bSucc ) ? next_pc : pcIF + 4;

endmodule