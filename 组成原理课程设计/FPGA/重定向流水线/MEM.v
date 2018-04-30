`timescale 1ns/1ps

module MEM ( result, rb_v, sig_mem, addr_ledin, clk, rst,
             rw_en ,rW ,memread ,mem_v, led_out);

    input [31:0] result, rb_v;
    input [3:0] addr_ledin;
    input [8:0] sig_mem;
    input clk ,rst;
    output [31:0] mem_v, led_out;
    output [4:0] rW;
    output rw_en ,memread;

    wire lh, memw;
    assign { rw_en, lh, memread, memw, rW } = sig_mem;
    RAM cpu_ram ( .AddrLED_in(addr_ledin), .Addr_in(result), .Data_in(rb_v), .MemWrite_in(memw), .clk(clk), .lh(lh),// input
            .Data_out(mem_v), .DataLED_out(led_out));   

endmodule