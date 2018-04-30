`timescale 1ns / 1ps
module displaySwitch(input cp, input [6:0]switch, 
                     input [31:0]syscallOut, input [31:0]mem, 
                     input [31:0]pc, input [31:0]cycle0, 
                     input [31:0]cycle1, input [31:0]cycle2, input [31:0]cycle3, 
                     output [7:0]sel, output [7:0]seg);
reg [31:0]data;
reg [31:0]hexdata;
wire [31:0]decdata;
display disp(cp, data, sel, seg);
TRANS16to10 h2d(hexdata, decdata);
initial begin
    data=0;
    hexdata=0;
end
always @ (posedge cp) begin
    case(switch[5:0])
        6'b0:hexdata=syscallOut;
        6'b1:hexdata=mem;
        6'b10:hexdata=pc;
        6'b100:hexdata=cycle0;
        6'b1000:hexdata=cycle1;
        6'b10000:hexdata=cycle2;
        6'b100000:hexdata=cycle3;
        default:hexdata=0;
    endcase
    if(switch[6]) data=decdata;
    else data=hexdata;
end
endmodule

module display(input cp, input [31:0]data, output [7:0]sel, output [7:0]seg);
wire ncp;
divider d1(cp, ncp);
sel sel1(ncp, sel);
seg seg1(data, sel, seg);
endmodule
/*
module divider(input ck_100M, output reg clk_20K);
    parameter LOW_COUNT = 2500;   //100MHz / 5000 = 20kHz for seg_display and low clk
    reg count;
    
    initial begin
        clk_20K <= 0;
        count <= 0;
    end
    
    always @(posedge ck_100M) begin
        if (count == LOW_COUNT) begin   //Realization of clock reversal and reset count
            clk_20K = ~clk_20K;
            count = 0;
        end
        else begin  //if count < LOW_COUNT, increse count
            count = count + 1;
        end
    end
endmodule
*/
module divider(input cp,output reg ncp);//used toget a slower clock
reg [17:0]cnt;
initial begin
    cnt=0;
    ncp=0;
end
always@(posedge cp) begin
    cnt<=cnt+1'b1;
    ncp<=cnt[17];//when cnt[17] reach 1 the new clock gets 1
end
endmodule

module cpu_divider_slow(input cp,output reg ncp);//used toget a slower clock
reg [24:0]cnt;
initial begin
    cnt=0;
    ncp=0;
end
always@(posedge cp) begin
    cnt<=cnt+1'b1;
    ncp<=cnt[24];//when cnt[17] reach 1 the new clock gets 1
end
endmodule

module sel(input ncp, output reg [7:0]sel);
initial begin
    sel=8'b11111110;
end
always @ (posedge ncp) begin
    if(sel==8'b01111111) begin
        sel<=8'b11111110;
    end
    else sel<=(sel<<1)+1'b1;//move zero left for one bit
end
endmodule

module seg(input [31:0]data, input [7:0]sel, output reg [7:0]seg);
reg [3:0]seg_val;
initial begin
    seg_val=0;
    seg=8'hFF;
end
always @ (sel) begin
    case(sel)//represents a specific tube
    8'b01111111:seg_val<=data[31:28];
    8'b10111111:seg_val<=data[27:24];
    8'b11011111:seg_val<=data[23:20];
    8'b11101111:seg_val<=data[19:16];
    8'b11110111:seg_val<=data[15:12];
    8'b11111011:seg_val<=data[11:8];
    8'b11111101:seg_val<=data[7:4];
    8'b11111110:seg_val<=data[3:0];
    endcase
end
always @ (seg_val) begin
    case(seg_val)//represent the exact content used to display
    4'h0: seg<=8'hC0;
    4'h1: seg<=8'hF9;    
    4'h2: seg<=8'hA4;    
    4'h3: seg<=8'hB0;    
    4'h4: seg<=8'h99;    
    4'h5: seg<=8'h92;    
    4'h6: seg<=8'h82;    
    4'h7: seg<=8'hF8;    
    4'h8: seg<=8'h80;    
    4'h9: seg<=8'h90;    
    4'hA: seg<=8'h88;  
    4'hB: seg<=8'h83;
    4'hC: seg<=8'hC6; 
    4'hD: seg<=8'hA1;
    4'hE: seg<=8'h86;
    4'hF: seg<=8'h8E;   
    default:seg<=8'hFF;
    endcase
end
endmodule
/*
module TRANS16to10(
    input [31:0] SOURCE_IN,
    output reg [31:0] TARGET_OUT
    );
	
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
endmodule*/