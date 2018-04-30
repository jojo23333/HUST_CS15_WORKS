`timescale 1ns/1ps

module WB ( alu_v, mem_v, memread, 
            reg_write_data);

    input [31:0] alu_v, mem_v;
    input memread;
    output [31:0] reg_write_data;
    
    assign reg_write_data = (memread == 0) ? alu_v : mem_v;

endmodule 