`timescale 1ns/1ps


module IF_ID(pc, ir, enable, clk, bubif, rst
            ,pc_out, ir_out);
    
    input wire [31:0] pc, ir;
    input wire enable, clk, bubif, rst;
    output reg [31:0] pc_out, ir_out;

    wire [31:0] pc_s, ir_s;

    // asynchronous set 0
    assign pc_s = ( bubif == 1 )? 0 : pc;
    assign ir_s = ( bubif == 1 )? 0 : ir;
    initial begin
         pc_out <= 0;
         ir_out <= 0;
    end

    always @( posedge clk ) begin
        if ( rst ) begin
            pc_out <= 0;
            ir_out <= 0;
        end
        else if ( enable ) begin
            pc_out <= pc_s;
            ir_out <= ir_s;
        end
    end

endmodule
