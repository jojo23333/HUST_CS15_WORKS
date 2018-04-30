`timescale 1ns/1ps

module REDIRECT ( RAEX, RBEX, resultMEM, resultWB, rAEX, rBEX, rWMEM, rWWB, rW_enMEM, rW_enWB, rBValidEX,
                    nRA, nRB);
    input [31:0] RAEX, RBEX, resultMEM, resultWB;
    input [4:0] rAEX, rBEX, rWMEM, rWWB;
    input rW_enMEM, rW_enWB, rBValidEX;
    output [31:0] nRA, nRB;

    wire a_mem_r_select, b_mem_r_select, a_wb_r_select, b_wb_r_select;

    assign a_mem_r_select = ( rWMEM == rAEX  && rW_enMEM) ? 1 : 0;
    assign b_mem_r_select = ( rWMEM == rBEX  && rW_enMEM && rBValidEX) ? 1 : 0;

    assign a_wb_r_select = ( rWWB == rAEX  && rW_enWB) ? 1 : 0;
    assign b_wb_r_select = ( rWWB == rBEX  && rW_enWB && rBValidEX) ? 1 : 0;

    assign nRA = ( a_mem_r_select == 1 )? resultMEM : 
                 ( a_wb_r_select == 1 )? resultWB : RAEX;

    assign nRB = ( b_mem_r_select == 1 )? resultMEM : 
                 ( b_wb_r_select == 1 )? resultWB : RBEX;

endmodule