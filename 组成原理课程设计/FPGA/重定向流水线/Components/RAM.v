`timescale 1ns / 1ps

/*
writer: ccz
*/
module RAM(AddrLED_in, Addr_in, Data_in, MemWrite_in, lh, clk, Data_out, DataLED_out);
	input [31:0] Addr_in;
	input [31:0] Data_in;
	input [3:0]  AddrLED_in;
	input lh, MemWrite_in, clk;
	output [31:0] Data_out;
	output [31:0] DataLED_out;
	reg [31:0] memory[31:0];
	wire [31:0] data;

	integer i;
	initial begin
		for(i=0;i<32;i=i+1)
			memory[i] <= 0;
	end

	always @(posedge clk) begin
		if(MemWrite_in) begin
			memory[Addr_in[21:2]] = Data_in;
		end
	end
	assign data = memory[Addr_in[21:2]];

	assign Data_out[31:0] = ( lh == 0 ) ? data :
							( Addr_in[1] == 0 ) ? { 16'h0 , data[15:0]} : { 16'h0, data[31:16]};
	assign DataLED_out[31:0] = memory[AddrLED_in];
endmodule
