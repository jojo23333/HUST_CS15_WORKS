`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/12 16:23:21
// Design Name: 
// Module Name: Decoder
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


module DECODER(
	input [31:0]CODE,
	input shift,
	input syscall,
	input RegDst,
	input Jal,
	input Zero_extend,

	output [31:0] PCjump,
	output [5:0] OPCODE,
	output [5:0] FUNCT,
	output [4:0] RA,
	output [4:0] RB,
	output [4:0] RW,
	output [31:0] extend
    );

	wire [4:0] temp,temp1;
	wire [31:0]temp2;


	assign PCjump = { 4'b0 ,CODE[25 :0], 2'b0};

	assign OPCODE = CODE[31:26];
	assign FUNCT = CODE[5:0];

	//RA 
	assign temp = (shift == 0) ? CODE[25:21] : CODE[20:16];
	assign RA = (syscall == 0) ? temp : 5'b00010;

	//RB 
	assign RB = (syscall == 0) ? CODE[20:16] : 5'b00100;

	//RW 
	assign temp1 = (RegDst == 0) ? CODE[20:16] : CODE[15:11];
	assign RW = (Jal == 0) ? temp1 : 5'b11111;

	//extend 
	assign temp2 = (Zero_extend == 0) ? {{16{CODE[15]}}, CODE[15:0]} : {16'b0000_0000_0000_0000, CODE[15:0]};
	assign extend = (shift == 0) ? temp2 : {28'b00_0000_0000_0000_0000_0000_0000, CODE[10:6]};


endmodule
