`timescale 1ns / 1ps


module REGFILE(input [31:0]w, input clk, input we, 
			   input [4:0]rw, input [4:0]ra_index, input [4:0]rb_index,
			   output [31:0]A, output [31:0]B);
	reg [31:0]r[0:31];
	integer i;
	initial begin
		for(i=0;i<32;i=i+1)
			r[i]=0;
	end
	
	always @ (posedge clk) begin
		if(we)
			r[rw] = w;
	end
	assign A=r[ra_index];
    assign B=r[rb_index];
endmodule

