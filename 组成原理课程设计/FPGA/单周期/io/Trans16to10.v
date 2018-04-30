`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/13 09:27:17
// Design Name: 
// Module Name: TRANS16to10
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


module TRANS16to10(
    input [31:0] SOURCE_IN,
    output reg [31:0] TARGET_OUT
    );
	// reg [4:0]i;
	// reg [2:0]power_16[29:0];
	// initial begin
	// 	i <= 0;
	// 	power_16[0] = 30'h1;
	// 	power_16[1] = 30'h10;
	// 	power_16[2] = 30'h100;
	// 	power_16[3] = 30'h1000;
	// 	power_16[4] = 30'h10000;
	// 	power_16[5] = 30'h100000;
	// 	power_16[6] = 30'h1000000;
	// 	power_16[7] = 30'h10000000;
	// end

	// always @(SOURCE_IN) begin
	// 	for (i = 0; i < 8; i++)begin
	// 		case SOURCE_IN[4*i+3, 4*i]:

	// 	end
	// end
	
	integer sum;
	initial begin
		TARGET_OUT <= 0;
		sum <= 0;
	end

	always @(SOURCE_IN) begin
		sum = SOURCE_IN[31:28];
		sum = sum * 16 + SOURCE_IN[27:24];
		sum = sum * 16 + SOURCE_IN[23:20];
		sum = sum * 16 + SOURCE_IN[19:16];
		sum = sum * 16 + SOURCE_IN[15:12];
		sum = sum * 16 + SOURCE_IN[11:8];
		sum = sum * 16 + SOURCE_IN[7:4];
		sum = sum * 16 + SOURCE_IN[3:0];
		
		TARGET_OUT[3:0] = sum % 10;
		sum = sum / 10;
		TARGET_OUT[7:4] = sum % 10;
        sum = sum / 10;
        TARGET_OUT[11:8] = sum % 10;
        sum = sum / 10;
        TARGET_OUT[15:12] = sum % 10;
        sum = sum / 10;
        TARGET_OUT[19:16] = sum % 10;
        sum = sum / 10;
        TARGET_OUT[23:20] = sum % 10;
        sum = sum / 10;
        TARGET_OUT[27:24] = sum % 10;
        sum = sum / 10;
        TARGET_OUT[31:28] = sum % 10;
	end
endmodule
