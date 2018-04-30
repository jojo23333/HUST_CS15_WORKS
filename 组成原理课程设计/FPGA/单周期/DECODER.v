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

	output reg [27:0] PC,
	output reg [5:0] OPCODE,
	output reg [5:0] FUNCT,
	output reg [4:0] RA,
	output reg [4:0] RB,
	output reg [4:0] RW,
	output reg [31:0] extend
    );

	reg [5:0]temp;
	reg [31:0]temp2;
	/*
	writer : XQ
	input CODE Ϊָ��
	input shift Ϊ��������ָ����־
	input syscall Ϊsyscallָ����־
	input RegDst Ϊ�Ĵ�����ѡ��
	input Jal Ϊ��תָ����־
	input Zero_extend Ϊ0��չָ������
	output PC Ϊ������λ������ת��ַ
	output OPCODE Ϊָ����[31:26]λ��λ��λ6
	output FUNC Ϊָ����[5:0]λ��λ��λ6
	output RA Ϊ��һ���Ĵ����ı���
	output RB Ϊ�ڶ����Ĵ����ı���
	output RW Ϊд�Ĵ����ı���
	output extend Ϊ��չ֮����������ֵ
	*/
	initial begin
		PC <= 0;
		OPCODE <= 0;
		FUNCT <= 0;
		RA <= 0;
		RB <= 0;
		RW <= 0;
		extend <= 0;
		temp <= 0;
	end
    
	always @(*) begin
		// PC��ֵ��CODE�ĵ�26λ��������0
		PC <= { CODE[25 :0], 2'b0};

		OPCODE <= CODE[31:26];
		FUNCT <= CODE[5:0];

		//RA ��ֵ
		temp = (shift == 0) ? CODE[25:21] : CODE[20:16];
		RA = (syscall == 0) ? temp : 5'b00010;

		//RB ��ֵ
		RB = (syscall == 0) ? CODE[20:16] : 5'b00100;

        //RW ��ֵ
        temp = (RegDst == 0) ? CODE[20:16] : CODE[15:11];
        RW = (Jal == 0) ? temp : 5'b11111;

        //extend ��ֵ
        temp2 = (Zero_extend == 0) ? {{16{CODE[15]}}, CODE[15:0]} : {16'b0000_0000_0000_0000, CODE[15:0]};
        extend = (shift == 0) ? temp2 : {28'b00_0000_0000_0000_0000_0000_0000, CODE[10:6]};
	end
endmodule
