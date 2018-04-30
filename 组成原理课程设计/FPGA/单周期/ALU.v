`timescale 1ns / 1ps
module ALU(
	input [31:0] X,
	input [31:0] Y,
	input [3:0] ALU_OP,	
	
	output reg [31:0] Result,
	output reg [31:0] Result2,	
	output reg OF,
	output reg UOF,
	output Equal
	);

	wire signed [31:0] shift_x;
	wire signed [31:0] shift_y;
	
	initial begin
		Result <= 0;
		Result2 <= 0;
        OF <= 0;
        UOF <= 0;
    end

	assign shift_y = {27'b0000_0000_0000_0000_0000_0000_000,Y[4:0]};
	assign shift_x = $signed(X) >>> shift_y;
	assign Equal = (X == Y); 
    
always@(X or Y or ALU_OP)
begin 
	case(ALU_OP)
	0:
		begin            
			Result <= X << Y[4:0];
			Result2 <= 0;
		end
	1:
		begin            
			Result <= shift_x;
			Result2 <= 0;
		end
	2:
		begin            
			Result <= X >> Y[4:0];
			Result2 <= 0;
		end
	3:
		begin	
			{Result2, Result} <= $signed(X) * $signed(Y);
		end
	4:
		begin            
			Result <= X / Y;
			Result2 <= X % Y;
		end
	5:
		begin            
			Result <= X + Y;
			OF <= (X[31] & Y[31] & ~Result[31]) || (~X[31] & ~Y[31] & Result[31]);
			UOF <= (Result < X) || (Result < Y);
		end
	6:
		begin            
			Result <= X - Y;
			OF <= (X[31] & Y[31] & ~Result[31]) || (~X[31] & ~Y[31] & Result[31]);
			UOF <= Result > X;
		end
	7:
		begin            
			Result <= X & Y;
		end
	8:
		begin            
			Result <= X | Y;
		end
	9:
		begin            
			Result <= X ^ Y;
		end
	10:
		begin            
			Result <= ~(X | Y);
		end
	11:
		begin
			Result <= ($signed(X) < $signed(Y))? 1 : 0;
		end
	12:
		begin            
			Result <= (X < Y)? 1 : 0;
		end
	endcase
end
endmodule