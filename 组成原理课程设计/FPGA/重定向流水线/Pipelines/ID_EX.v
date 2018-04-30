`timescale 1ns/1ps

module ID_EX (pc, imm, ra_v, rb_v, pcjump, aluop,
              control_sig_in,rA, rB, rW, bubid, clk, rst, 
              pc_out, imm_out, ra_v_out, rb_v_out, pcjump_out,
              rA_out, rB_out, rW_out, aluop_out, control_sigs, memread, rbvalid);

    input wire [31:0] pc, imm, ra_v, rb_v, pcjump;
    input wire [4:0] rA, rB, rW;
    input wire [3:0] aluop;
    input wire [12:0] control_sig_in;
    input wire bubid, clk, rst;
    output reg [31:0] pc_out, imm_out, ra_v_out, rb_v_out, pcjump_out;
    output reg [4:0] rA_out, rB_out, rW_out;
    output reg [3:0] aluop_out;
    output reg [12:0] control_sigs;
    output wire memread, rbvalid;

    wire jal, syscall, alusrc, rw_en, jump, beq, bne, memw, jr, bltz, lh;
    wire [31:0] pc_s, imm_s, ra_v_s, rb_v_s, pcjump_s;
    wire [4:0] rA_s, rB_s, rW_s;
    wire [3:0] aluop_s;
    wire [12:0] control_sigs_s;

    assign pc_s = ( bubid == 1 ) ? 0 : pc;
    assign imm_s = ( bubid == 1 ) ? 0 : imm;
    assign ra_v_s = ( bubid == 1 ) ? 0 : ra_v;
    assign rb_v_s = ( bubid == 1 ) ? 0 : rb_v;
    assign pcjump_s = ( bubid == 1 ) ? 0 : pcjump;
    assign rA_s = ( bubid == 1 ) ? 0 : rA;
    assign rB_s = ( bubid == 1 ) ? 0 : rB;
    assign rW_s = ( bubid == 1 ) ? 0 : rW;
    assign aluop_s = ( bubid == 1 ) ? 0 : aluop;
    assign control_sigs_s = (bubid == 1) ? 0 : control_sig_in;

    initial begin
        pc_out <= 0;
        imm_out <= 0;
        ra_v_out <= 0;
        rb_v_out <= 0;
        pcjump_out <= 0;
        aluop_out <= 0;
        rA_out <= 0;
        rB_out <= 0;
        rW_out <= 0;
        control_sigs <= 0;  
    end

    always @(posedge clk) begin
        if (rst) begin
            pc_out <= 0;
            imm_out <= 0;
            ra_v_out <= 0;
            rb_v_out <= 0;
            pcjump_out <= 0;
            aluop_out <= 0;
            rA_out <= 0;
            rB_out <= 0;
            rW_out <= 0;
            control_sigs <= 0;
        end
        else begin
            pc_out <= pc_s;
            imm_out <= imm_s;
            ra_v_out <= ra_v_s;
            rb_v_out <= rb_v_s;
            pcjump_out <= pcjump_s;
            aluop_out <= aluop_s;
            rA_out <= rA_s;
            rB_out <= rB_s;
            rW_out <= rW_s;
            control_sigs <= control_sigs_s;
        end
    end
    
    assign  {syscall, jal, alusrc, rw_en,jump, beq, bne, memw ,jr, bltz, lh, memread, rbvalid} =  control_sigs;

endmodule

            //   jal_out, syscall_out, alusrc_out, rw_en_out, rbvalid_out, aluop_out,
            //   rA_out, rB_out, rW_out, jump_out, beq_out, bne_out, memw_out, jr_out, bltz_out, lh_out, memread_out);


    // output reg jal_out, syscall_out, alusrc_out, rw_en_out, rbvalid_out, jump_out, beq_out, 
    //     bne_out, memw_out, jr_out, bltz_out, lh_out, memread_out;

    // wire jal_s, syscall_s, alusrc_s, rw_en_s, rbvalid_s, jump_s, beq_s, bne_s, memw_s, jr_s, bltz_s, lh_s, memread_s;

    // assign jal_s = ( bubid == 1 ) ? 0 : jal;
    // assign syscall_s = ( bubid == 1 ) ? 0 : syscall;
    // assign alusrc_s = ( bubid == 1 ) ? 0 : alusrc;
    // assign rw_en_s = ( bubid == 1 ) ? 0 : rw_en;
    // assign rbvalid_s = ( bubid == 1 ) ? 0 : rbvalid;
    // assign jump_s = ( bubid == 1 ) ? 0 : jump;
    // assign beq_s = ( bubid == 1 ) ? 0 : beq;
    // assign bne_s = ( bubid == 1 ) ? 0 : bne;
    // assign memw_s = ( bubid == 1 ) ? 0 : memw;
    // assign jr_s = ( bubid == 1 ) ? 0 : jr;
    // assign bltz_s = ( bubid == 1 ) ? 0 : bltz;
    // assign lh_s = ( bubid == 1 ) ? 0 : lh;
    // assign memread_s = ( bubid == 1 ) ? 0 : memread;
    
            // jal_out <= jal_s;
        // syscall_out <= syscall_s;
        // alusrc_out <= alusrc_s;
        // rw_en_out <= rw_en_s;
        // rbvalid_out <= rbvalid_s;
        // jump_out <= jump_s;
        // beq_out <= beq_s;
        // bne_out <= bne_s;
        // memw_out <= memw_s;
        // jr_out <= jr_s;
        // bltz_out <= bltz_s;
        // lh_out <= lh_s;
        // memread_out <= memread_s;