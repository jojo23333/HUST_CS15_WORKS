`timescale 1ns/1ps
/*
Multipleter with bandwith 32bit

*/
module MUX2_32 ( in0, in1, control, out);
    input wire [31:0] in0;
    input wire [31:0] in1;
    input wire control;
    output wire [31:0]out;

    assign out = (control == 1)? in1 : in0;
endmodule