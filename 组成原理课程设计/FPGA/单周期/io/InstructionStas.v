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
    input clk_in,
	input Jump,
	input Jal,
	input Jr,
	input Bne,
	input Beq,
	input Bgez,
    input hault_sign,
	input Equal_in,
//	input Syscall,
	input rst_in,

    output reg [31:0] Conditional_out,
    output reg [31:0] ConditionalBranch_out,
	output reg [31:0] Unconditional_out,
	output reg [31:0] Totalcycle_out
    );
	
	wire Conditional_enable;
	wire ConditionalBranch_enable;
	wire Unconditional_enable;
	
//	assign halt_sign = Equal_in && Syscall;
	assign Conditional_enable = (Bne||Beq||Bgez)&&(~hault_sign);
	assign ConditionalBranch_enable = ((Bne&&(~Equal_in))||(Beq&&Equal_in))&&(~hault_sign);
	assign Unconditional_enable = (Jal||Jump||Jr)&&(~hault_sign);

	initial begin
        Conditional_out <= 0;
		ConditionalBranch_out <= 0;
		Unconditional_out <= 0;
		Totalcycle_out <= 0;
	end

always @(posedge clk_in) 
begin
        if(rst_in)
		begin 
            Conditional_out <= 0;
			ConditionalBranch_out <= 0;
			Unconditional_out <= 0;
			Totalcycle_out <= 0;
		end
        else begin
            if (~hault_sign)
			    Totalcycle_out <= Totalcycle_out + 1;
			if(Conditional_enable)
				Conditional_out <= Conditional_out + 1;
			if(ConditionalBranch_enable)
				ConditionalBranch_out <= ConditionalBranch_out + 1;
			if(Unconditional_enable)
				Unconditional_out <= Unconditional_out + 1;
		end
end

endmodule
