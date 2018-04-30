`timescale 1ns/1ps

module PC ( nextpc_in, enable_in, clk_in, rst_in, pc_out);
    input wire [31:0] nextpc_in;
    input wire enable_in;
    input wire clk_in;
    input wire rst_in;
    output reg [31:0] pc_out;
 
    initial begin
        pc_out = 0;
    end

    always @(posedge clk_in) begin
        if ( rst_in )
            pc_out = 32'h00000000;
        else if ( enable_in )
            pc_out = nextpc_in;
    end

endmodule