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
        else
            pc_out = pc_out;
    end

endmodule

module REG ( data_in, enable_in, clk_in, rst_in, data_out);
    input wire [31:0] data_in;
    input wire enable_in;
    input wire clk_in;
    input wire rst_in;
    output reg [31:0] data_out;
 
    initial begin
        data_out = 0;
    end

    always @(posedge clk_in) begin
        if ( rst_in )
            data_out = 32'h00000000;
        else if ( enable_in )
            data_out = data_in;
    end

endmodule