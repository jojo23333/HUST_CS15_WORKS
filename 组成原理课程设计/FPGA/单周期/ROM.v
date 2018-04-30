// Create Date: 2018/03/12 14:48:00
/*
writer: �޴���
input: 
    Addr_in : ....
output:
    Instruction_out : ...
others: ָ���ļ�"my_rom_data.coe"
*/
`timescale 1ns / 1ps

module ROM(addr_in,instruction_out);
    input [31:0] addr_in;
    output reg [31:0] instruction_out;
    reg [31:0] mem [0:255];
//    reg [9:0] addr;
    initial begin
    	$readmemb("D:/benchmark",mem);
    end
    always @(addr_in)
    begin
        instruction_out[31:0] = mem[addr_in[11:2]];
    end
endmodule
