`timescale 1ns/1ps

module CPU (input sys_clk,
input [3:0]led_in,
input clkswitch,
input [6:0]dispmode,
input cpu_rst,
output [7:0]cpu_sel,
output [7:0]cpu_seg
    );
    /*
reg sys_clk;
reg [3:0]led_in;
reg clkswitch;
reg [6:0]dispmode;
reg cpu_rst;
wire [7:0]cpu_sel;
wire [7:0]cpu_seg;
    */
    
    // pc out
    wire [31:0] pc_val;
    // instruction rom out 
    wire [31:0] cur_instruction;
    // decoder out
    wire [4:0] ra_select, rb_select, rw;
    wire [31:0] extend;
    wire [27:0] pcjump;
    wire [5:0] funct, opcode;
    // contorl out
    wire [3:0] alu_op;
    wire shift, zero_extend, alu_src, reg_dst, reg_write, jump,
         beq, bne, mem_read, mem_write, jal, jr, syscall, bgez, lh;
    // npc out
    wire [31:0] nextpc, pcjar;
    // regfile out
    wire [31:0] ra,rb;
    // alu out
    wire equal, of, cf;
    wire [31:0] result, result2;
    // ram out
    wire [31:0] ram_out, led_out;
    // syscall reg 
    reg [31:0] syscall_out;
    //
    wire [31:0] c0, c1, c2 ,c3;
    //
    reg hault;
    // test 
    wire enable;
    // clock
    wire cpu_clk, cpu_clk_slow, cpu_clk_fast;
    //reg [31:0] ledin;
//    wire [31:0] ledout;
    divider cpu_clk_d(sys_clk, cpu_clk_slow);
    assign cpu_clk = ( clkswitch == 1) ? cpu_clk_slow : sys_clk;

    // pc
    PC cpu_pc( .nextpc_in(nextpc), .enable_in(enable), .clk_in(cpu_clk), .rst_in(cpu_rst), 
            .pc_out(pc_val));

    // instruction ram
    ROM cpu_instruction_ram( .addr_in(pc_val),      //input 
                        .instruction_out(cur_instruction)); //output

    // decoder
    DECODER cpu_decoder ( .CODE(cur_instruction), .shift(shift), .syscall(syscall), 
                        .RegDst(reg_dst), .Jal(jal), .Zero_extend(zero_extend), //input
                        .PC(pcjump), .OPCODE(opcode), .FUNCT(funct), .RA(ra_select), 
                        .RB(rb_select), .RW(rw), .extend(extend) );    //ouput
    
    // controller
    CONTROL cpu_control ( .OPCODE(opcode), .FUNCT(funct) ,  // input
                        .ALUOP(alu_op), .Shift(shift), .Zero_extend(zero_extend), .ALUSrc(alu_src),
                        .RegDst(reg_dst),.RegWrite(reg_write), .Jump(jump), .Beq(beq),.Bne(bne),
                        .MemRead(mem_read), .MemWrite(mem_write), .Jal(jal), .Jr(jr), .Syscall(syscall), .Bgez(bgez), .Lh(lh)); //output

    // npc
    NPC cpu_npc (.pc_in(pc_val), .pcjump_in(pcjump), .jump_in(jump), .equal_in(equal), .beq_in(beq), //input
                 .bne_in(bne), .bgez_in(bgez), .jr_in(jr), .extendimm_in(extend), .da_in(ra),
                 .pcjar_out(pcjar), .nextpc_out(nextpc));   // output
    
    // reg  and it's input data bus 
    wire [31:0] w0, w1;
    MUX2_32 memread_select ( result, ram_out, mem_read, w0);
    MUX2_32 jal_select ( w0, pcjar, jal, w1);
    REGFILE cpu_register ( .w(w1), .we(reg_write), .clk(cpu_clk), .rw(rw), .ra_index(ra_select), .rb_index(rb_select),
                            .A(ra), .B(rb));
    
    // alu and it's input data bus 
    wire [31:0] y0, y1;
    wire [31:0] syscall_constant = 32'h0000000a;
    MUX2_32 alu_select ( rb, extend, alu_src, y0);
    MUX2_32 syscall_select ( y0, syscall_constant, syscall, y1);
    ALU cpu_alu ( .X(ra), .Y(y1), .ALU_OP(alu_op),                        // input
                .Result(result), .Result2(result2), .OF(of), .UOF(uof), .Equal(equal));// output

    // ram 
    // TODO: led in & out
    RAM cpu_ram ( .AddrLED_in(led_in), .Addr_in(result), .Data_in(rb), .MemWrite_in(mem_write), .MemRead_in(mem_read), .clk(cpu_clk), // input
                .Data_out(ram_out), .DataLED_out(led_out));                    // output 
    
    // count parameter
    InstructionStas cpu_status ( .clk_in(cpu_clk), .Jump(jump), .Jal(jal), .Jr(jr),
     .Bne(bne), .Beq(beq), .Bgez(bgez), .hault_sign(hault), .Equal_in(equal), .rst_in(cpu_rst),
     .Conditional_out(c0) , .ConditionalBranch_out(c1) ,.Unconditional_out(c2) ,.Totalcycle_out(c3));
    
    // TODO: output part
    displaySwitch cpu_display( .cp(sys_clk), .switch(dispmode), .syscallOut(syscall_out),  .mem(led_out), .pc(pc_val), 
                          .cycle0(c0), .cycle1(c1),  .cycle2(c2), .cycle3(c3), 
                          .sel(cpu_sel),  .seg(cpu_seg));

    // hault 
    always @(posedge cpu_clk) begin
        if ( cpu_rst )
            hault = 0;
        else if ( syscall && equal )
            hault = 1;
    end
    
    assign enable = ~hault;

    // syscall out part
    always @(posedge cpu_clk) begin
        if ( cpu_rst )
            syscall_out = 0;
        else if ( (~equal) && syscall) 
            syscall_out = rb;
    end


    initial begin
        hault = 0;
        syscall_out = 0;
        /*
        sys_clk=0;
        led_in=0;
        clkswitch=0;
        dispmode=0;
        cpu_rst=0;*/
    end
    /*
    always begin
        #0.1 sys_clk=~sys_clk;
    end*/
endmodule