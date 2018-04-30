`timescale 1ns / 1ps
/*
writer: liuyuting
input: 
    clk_in : clock frequency, 1 bit
    Jump,Jal... : control instructions, 1 bit
output:
    Conditional_out[31:0]...: instruction statistics
	
*/

module InstructionStas(
    input isJmp,
    input bSuc,
    input enable,
    input stall,
    input pc_enable,
    input clk,
    input rst,
    output reg [31:0] Unconditional_out,
    output reg [31:0] Bubbles,
	output reg [31:0] branchsucc_out,
	output reg [31:0] Totalcycle_out
    );

	initial begin
        Unconditional_out <= 0;
		Bubbles <= 0;
		branchsucc_out <= 0;
		Totalcycle_out <= 0;
	end

always @(posedge clk) 
begin
        if(rst)
		begin 
            Unconditional_out <= 0;
			Bubbles <= 0;
			branchsucc_out <= 0;
			Totalcycle_out <= 0;
		end
        else begin
            if (enable)
			    Totalcycle_out <= Totalcycle_out + 1;
			if(isJmp && pc_enable)
				Unconditional_out <= Unconditional_out + 1;
			if(bSuc && pc_enable)
				branchsucc_out <= branchsucc_out + 1;
			if(enable && stall)
				Bubbles <= Bubbles + 1;
		end
end

endmodule
