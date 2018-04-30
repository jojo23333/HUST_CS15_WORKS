`timescale 1ns/1ps

module EX_MEM(rb_v, result, hault, to_mem_sig, clk, rst,
              rb_v_out, result_out, hault_out, to_mem_sig_out);

    input wire [31:0] rb_v, result;
    input wire [8:0] to_mem_sig;//rw_en, lh, memread, memw, rW
    input wire hault, clk, rst;
    output reg [31:0] rb_v_out, result_out;
    output reg [8:0] to_mem_sig_out;
    output reg hault_out;
        
    initial begin
        rb_v_out <= 0;
        result_out <= 0;
        hault_out <= 0;
        to_mem_sig_out <= 0;
    end

    always @( posedge clk ) begin
        if (rst) begin
            rb_v_out <= 0;
            result_out <= 0;
            hault_out <= 0;
            to_mem_sig_out <= 0;            
        end
        else begin
            rb_v_out <= rb_v;
            result_out <= result;
            hault_out <= hault;
            to_mem_sig_out <= to_mem_sig;
        end
    end

        
endmodule