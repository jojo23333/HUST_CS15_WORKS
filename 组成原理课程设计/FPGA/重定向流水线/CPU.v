`timescale 1ns/1ps

module CPU (
            input sys_clk,
            input [3:0] led_in,
            input clkswitch,
            input [6:0] dispmode,
            input rst,
            output [7:0] cpu_sel,
            output [7:0] cpu_seg,
            input conti
    );
    wire pcenable, enable;
    
    wire clk, cpu_clk_slow, cpu_clk_fast;
    //reg [31:0] ledin;
//    wire [31:0] ledout;
    divider cpu_clk_d(sys_clk, cpu_clk_slow);
    assign clk = ( clkswitch == 1) ? cpu_clk_slow : sys_clk;
    // debugs
//    reg clk_test, rst_test;
//    reg [3:0] addrled_test;
//    reg conti_test;
//    initial begin
//        clk_test <= 0;
//        rst_test <= 0;
//        addrled_test <=0;
//        conti_test <= 0;
//    end
//    always begin
//        #1 clk_test = ~clk_test;
//    end
    
    // outputs
    wire [31:0] pc_if, ir_if;   //IF PART 
    
    wire [31:0] pc_id, ir_id;   //IF_ID PART
    
    wire [3:0] aluop_id;        //ID PART
    wire [12:0] sig_id;
    wire [4:0]  rA_id, rB_id, rW_id;
    wire [31:0] imm_id, pcjump_id, ra_v_id, rb_v_id; 
    wire rbvalid_id;

    wire [3:0]  aluop_ex;       //ID_EX PART
    wire [12:0] sig_ex;
    wire [4:0]  rA_ex, rB_ex, rW_ex;
    wire [31:0] pc_ex, imm_ex, ra_v_ex, rb_v_ex ,pcjump_ex;
    wire rbvalid_ex, memread_ex;

    wire [31:0] nrb_v_ex, result_ex, next_pc_ex, syscall_out;   // EX PART
    wire [8:0] to_mem_sig;
    wire hault_ex, isJmp, bSuc;

    wire [31:0] rb_v_mem, result_mem;                           // EX_MEM PART
    wire [8:0] sig_mem;
    wire hault_mem;

    wire [31:0] mem_v, led_out;     // MEM PART
    wire [4:0] rW_mem;
    wire rw_en_mem, memread_mem;

    wire [31:0] mem_v_wb, alu_v_wb; // MEM_WB PART
    wire memread_wb;
    wire [4:0] reg_ws;
    wire hault_sig, reg_we;

    wire [31:0] reg_wv;             // WB PART

    wire stall, bubid, bubif;       //BUBBLE PART

    wire [31:0] nRA, nRB;
    
    wire [31:0] tonextpc;

    IF cpu_if (.clk(clk), .rst(rst), .nextpc(tonextpc), .pcenable(pcenable),
               .pc_out(pc_if), .ir_out(ir_if) );

    IF_ID cpu_if_id (.pc(pc_if), .ir(ir_if), .enable(pcenable), .clk(clk), .bubif(bubif), .rst(rst),
            .pc_out(pc_id), .ir_out(ir_id));

    ID cpu_id (.pc(pc_id), .ir(ir_id), .clk(clk), .reg_write_value(reg_wv), .reg_write_select(reg_ws), .reg_write_enable(reg_we),
                .alu_op(aluop_id), .control_sig(sig_id), .imm(imm_id), .pcjump(pcjump_id), 
                .rA(rA_id), .rB(rB_id), .rW(rW_id), .ra_v(ra_v_id), .rb_v(rb_v_id), .rbvalid(rbvalid_id));

    ID_EX cpu_id_ex (.pc(pc_id) , .imm(imm_id), .ra_v(ra_v_id), .rb_v(rb_v_id), .pcjump(pcjump_id), .aluop(aluop_id),
                    .control_sig_in(sig_id) , .rA(rA_id), .rB(rB_id), .rW(rW_id), .bubid(bubid), .clk(clk), .rst(rst),
                    .pc_out(pc_ex), .imm_out(imm_ex), .ra_v_out(ra_v_ex), .rb_v_out(rb_v_ex), .pcjump_out(pcjump_ex),
                    .rA_out(rA_ex), .rB_out(rB_ex), .rW_out(rW_ex), .aluop_out(aluop_ex), .control_sigs(sig_ex),
                    .memread(memread_ex), .rbvalid(rbvalid_ex));

    EX cpu_ex ( .pc(pc_ex), .imm(imm_ex), .pcjump(pcjump_ex), .nRB(nRB), .nRA(nRA), .rW(rW_ex), .aluop(aluop_ex), .contorl_sigs(sig_ex), .clk(clk), .rst(rst),
            .nrb_v(nrb_v_ex), .result(result_ex), .next_pc(next_pc_ex), .syscall_out(syscall_out), .to_mem(to_mem_sig), .hault(hault_ex), .isJmp(isJmp), .bSuc(bSuc) );

    EX_MEM cpu_ex_mem (.rb_v(nrb_v_ex), .result(result_ex), .hault(hault_ex), .to_mem_sig(to_mem_sig), .clk(clk), .rst(rst),
                       .rb_v_out(rb_v_mem), .result_out(result_mem), .hault_out(hault_mem), .to_mem_sig_out(sig_mem));

    MEM cpu_mem (.result(result_mem), .rb_v(rb_v_mem), .sig_mem(sig_mem), .addr_ledin(led_in), .clk(clk), .rst(rst),
                .rw_en(rw_en_mem) ,.rW(rW_mem) ,.memread(memread_mem) ,.mem_v(mem_v), .led_out(led_out));

    MEM_WB cpu_mem_wb (.mem_v(mem_v), .alu_v(result_mem), .rW(rW_mem), .rw_en(rw_en_mem), .memread(memread_mem), .hault(hault_mem), .clk(clk), .rst(rst),
            .mem_v_out(mem_v_wb), .alu_v_out(alu_v_wb), .rW_out(reg_ws), .rw_en_out(reg_we), .memread_out(memread_wb), .hault_out(hault_sig));
    
    WB cpu_wb (.alu_v(alu_v_wb), .mem_v(mem_v_wb), .memread(memread_wb), 
                .reg_write_data(reg_wv));

    BUBBLE cpu_bubble (.rAID(rA_id), .rBID(rB_id), .rWEX(rW_ex), .rBValid(rbvalid_id), .memReadEX(memread_ex), .isJmp(isJmp), .bSucc(bSuc),
                .stall(stall), .Bubid(bubid), .Bubif(bubif));

    REDIRECT cpu_redirect (.RAEX(ra_v_ex), .RBEX(rb_v_ex), .resultMEM(result_mem), .resultWB(reg_wv), .rAEX(rA_ex), .rBEX(rB_ex),
                         .rWMEM(rW_mem), .rWWB(reg_ws), .rW_enMEM(rw_en_mem), .rW_enWB(reg_we), .rBValidEX(rbvalid_ex),
                        .nRA(nRA), .nRB(nRB));

    predictPC cpu_predict_pc ( .pcIF(pc_if), .next_pc(next_pc_ex), .isJmp(isJmp), .bSucc(bSuc),
                   .pc_out(tonextpc));

    wire [31:0] unconditional_out, bubbles, branchsucc_out, totalcycle_out;
    InstructionStas count(.isJmp(isJmp), .bSuc(bSuc), .enable(enable), .stall(stall), .pc_enable(pcenable), .clk(clk), .rst(rst), 
        .Unconditional_out(unconditional_out), .Bubbles(bubbles), .branchsucc_out(branchsucc_out), .Totalcycle_out(totalcycle_out));

    displaySwitch display(.cp(clk),.switch(dispmode), .syscallOut(syscall_out), .mem(led_out), .pc(pc_if), 
                        .cycle0(unconditional_out), .cycle1(bubbles), .cycle2(branchsucc_out), .cycle3(totalcycle_out), 
                    .sel(cpu_sel), .seg(cpu_seg));

    reg hault;
    // hault
    always @(posedge clk) begin
        if ( rst || conti)// || conti_test)
            hault = 0;
        else if (  hault_sig )
            hault = 1;
    end
    
    assign enable = ~hault;
    assign pcenable = (~stall) & (~hault);

    initial begin
        hault = 0;
    end

endmodule

    /*DEBUG
        reg sys_clk;
        reg [3:0]led_in;
        reg clkswitch;
        reg [6:0]dispmode;
        reg cpu_rst;
        wire [7:0]cpu_sel;
        wire [7:0]cpu_seg;
    */