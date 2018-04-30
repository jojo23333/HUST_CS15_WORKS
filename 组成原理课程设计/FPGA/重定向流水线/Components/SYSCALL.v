`timescale 1ns/1ps

module SYSCALL ( RA, RB, syscall, clk, rst,
                hault, syscall_out);
    input [31:0] RA, RB;
    input syscall, clk, rst;
    output [31:0] syscall_out;
    output hault;

    wire reg_enable;

    assign reg_enable = ( syscall && ~(RA == 32'ha) ) ? 1 : 0;
    assign hault = ( syscall && (RA == 32'ha) ) ? 1 : 0;

    REG register ( .data_in(RB), .clk_in(clk), .rst_in(rst), .enable_in(reg_enable), .data_out(syscall_out) );
endmodule