`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/13 08:39:37
// Design Name: 
// Module Name: RAM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
/*
writer: ccz
input: 
    AddrLED_in : 4λ,LED?ʾģ??????
    Addr_in : 32λ??ݵ??
    Data_in : ???�????    MemWrite_in: ?洢�????    MemRead_in : ?�??????    clk     : ʱ????output:
    Data_out : ?????????    DataLED_out: LED?ʾģ???ר?
others: ...
*/
module RAM(AddrLED_in,Addr_in,Data_in,MemWrite_in,MemRead_in,clk,Data_out,DataLED_out);
	input [31:0] Addr_in;
	input [31:0] Data_in;
	input [3:0]  AddrLED_in;
	input MemWrite_in;
	input MemRead_in;
	input clk;
	output [31:0] Data_out;
	output [31:0] DataLED_out;
	reg [31:0] memory[31:0];

	always @(posedge clk) begin
		if(MemWrite_in) begin
			memory[Addr_in[21:2]] = Data_in;
		end
	end
	assign Data_out[31:0] = memory[Addr_in[21:2]];
	assign DataLED_out[31:0] = memory[AddrLED_in];
endmodule
