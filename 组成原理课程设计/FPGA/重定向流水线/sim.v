`timescale 1ns/1ps

module test();

	reg [3:0] led_in;
	reg sys_clk, clkswitch, rst,conti;
	reg [6:0] dispmode;
	wire [7:0] cpu_sel, cpu_reg;
	
	CPU cpu(
		.sys_clk(sys_clk),
		.led_in(led_in),
		.clkswitch(clkswitch),
		.dispmode(dispmode),
		.rst(rst),
		.cpu_sel(cpu_sel),
		.cpu_seg(cpu_reg),
		.conti(conti)
	);
	
	initial begin
		sys_clk <= 0;
		led_in <= 0;
		clkswitch <= 0;
		dispmode <=0;
		rst <= 0;
		conti <= 0;
	end
	
	always begin
		#1 sys_clk = ~sys_clk;
	end
	
	always begin
	   #4600 conti = 1;
	end
endmodule