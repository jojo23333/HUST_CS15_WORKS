`timescale 1ns/1ps

module IF ( clk, rst, nextpc, pcenable,
            pc_out, ir_out);
    
    input clk, rst, pcenable;
    input [31:0] nextpc;
    output [31:0] pc_out, ir_out;

    // pc
    PC cpu_pc( .nextpc_in(nextpc), .enable_in(pcenable), .clk_in(clk), .rst_in(rst), 
            .pc_out(pc_out));

    // instruction ram
    ROM cpu_instruction_ram( .addr_in(pc_out),      //input 
                        .instruction_out(ir_out)); //output    


endmodule