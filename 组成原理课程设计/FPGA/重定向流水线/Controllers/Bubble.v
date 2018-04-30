`timescale 1ns/1ps

module BUBBLE ( rAID, rBID, rWEX, rBValid, memReadEX, isJmp, bSucc,
                stall, Bubid, Bubif);
    input [4:0] rAID, rBID, rWEX;
    input rBValid, memReadEX, isJmp, bSucc;
    output stall, Bubid, Bubif;

    wire rW_notzero, rWrA_equal, rWrB_equal;
    assign rW_notzero = ( rWEX == 0 ) ? 0 : 1;
    assign rWrA_equal = ( rWEX == rAID ) ? 1 : 0;
    assign rWrB_equal = ( rWEX == rBID ) ? 1 : 0;
    
    assign stall = ( (rWrA_equal || (rWrB_equal && rBValid)) && rW_notzero && memReadEX ) ? 1 : 0;
    assign Bubid = ( isJmp || bSucc || stall )? 1 : 0;
    assign Bubif = ( isJmp || bSucc )? 1 : 0; 
endmodule 