`timescale 1ns/1ps

module MEM_WB (mem_v, alu_v, rW, rw_en, memread, hault, clk, rst,
               mem_v_out, alu_v_out, rW_out, rw_en_out, memread_out, hault_out);
    input [31:0] mem_v, alu_v;
    input [4:0] rW;
    input rw_en, memread, hault, clk, rst;
    output reg [31:0] mem_v_out, alu_v_out;
    output reg [4:0] rW_out;
    output reg rw_en_out, memread_out, hault_out;

    initial begin
        mem_v_out <= 0;
        alu_v_out <= 0;
        rW_out <= 0;
        rw_en_out <= 0;
        memread_out <= 0;
        hault_out <= 0;
    end

    always @( posedge clk) begin
        if (rst) begin
            mem_v_out <= 0;
            alu_v_out <= 0;
            rW_out <= 0;
            rw_en_out <= 0;
            memread_out <= 0;
            hault_out <= 0;
        end
        else begin
            mem_v_out <= mem_v;
            alu_v_out <= alu_v;
            rW_out <= rW;
            rw_en_out <= rw_en;
            memread_out <= memread;
            hault_out <= hault;
        end
    end 

endmodule