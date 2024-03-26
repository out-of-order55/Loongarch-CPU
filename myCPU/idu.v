module idu (
    input               clk         ,
    input               rst         ,

    input               if_to_id_valid  ,
    input               i_ex_ready  ,
    input               idu_nready_go,
    output              o_id_ready  ,
    output              id_to_ex_valid  ,

    input[31:0]         rf_rdata1   ,
    input[31:0]         rf_rdata2   ,
    output[4:0]         rf_raddr1   ,
    output[4:0]         rf_raddr2   ,

    // output[31:0]        id_src1     ,
    // output[31:0]        id_src2     ,
    // input[31:0]         idu_src1    ,
    // input[31:0]         idu_src2    ,
    output              br_stall    ,
    output              br_taken    ,
    output[31:0]        br_target   ,

    input[31:0]         if_to_id_inst     ,
    input[31:0]         if_to_id_pc       ,

    output[31:0]        id_to_ex_pc       ,
    output[31:0]        id_to_ex_inst     ,
    output[31:0]        id_to_ex_src1     ,
    output[31:0]        id_to_ex_src2     ,
    output[`ALU_OP-1:0]        id_to_ex_alu_op   ,
    output[4:0]         id_to_ex_rf_waddr 
);

wire        rf_we   ;
wire [ 4:0] rf_waddr;
wire        id_valid;
wire [31:0] inst;
wire [31:0] pc;
wire [`ALU_OP-1:0] alu_op;
wire        load_op;
wire        src1_is_pc;
wire        src2_is_imm;
wire        res_from_mem;
wire        dst_is_r1;
wire        gr_we;
wire        mem_we;
wire        src_reg_is_rd;
wire [4: 0] dest;
wire [31:0] rj_value;
wire [31:0] rkd_value;
wire [31:0] imm;
wire [31:0] br_offs;
wire [31:0] jirl_offs;

wire [ 5:0] op_31_26;
wire [ 3:0] op_25_22;
wire [ 1:0] op_21_20;
wire [ 4:0] op_19_15;
wire [ 4:0] rd;
wire [ 4:0] rj;
wire [ 4:0] rk;
wire [4:0]  ui5;
wire [11:0] i12;
wire [19:0] i20;
wire [15:0] i16;
wire [25:0] i26;

wire [63:0] op_31_26_d;
wire [15:0] op_25_22_d;
wire [ 3:0] op_21_20_d;
wire [31:0] op_19_15_d;


wire        inst_mul_w      ;
wire        inst_mulh_w     ;
wire        inst_mulh_wu    ;
wire        inst_div_w      ;
wire        inst_mod_w      ;
wire        inst_div_wu     ;
wire        inst_mod_wu     ;

wire        inst_blt;
wire        inst_bltu;
wire        inst_bge;
wire        inst_bgeu;

wire        inst_ld_b;
wire        inst_ld_h;
wire        inst_ld_bu;
wire        inst_ld_hu;
wire        inst_st_b;
wire        inst_st_h;

wire        inst_slti;
wire        inst_sltui;
wire        inst_andi;
wire        inst_ori;
wire        inst_xori;
wire        inst_sll;
wire        inst_srl;
wire        inst_sra;
wire        inst_pcaddu12i;      
wire        inst_add_w;
wire        inst_sub_w;
wire        inst_slt;
wire        inst_sltu;
wire        inst_nor;
wire        inst_and;
wire        inst_or;
wire        inst_xor;
wire        inst_slli_w;
wire        inst_srli_w;
wire        inst_srai_w;
wire        inst_addi_w;
wire        inst_ld_w;
wire        inst_st_w;
wire        inst_jirl;
wire        inst_b;
wire        inst_bl;
wire        inst_beq;
wire        inst_bne;
wire        inst_lu12i_w;

wire        need_ui5;
wire        need_si12;
wire        need_si16;
wire        need_si20;
wire        need_si26;
wire        need_ui12;
wire        src2_is_4;
wire        br_op;

wire [31:0] mem_wdata   ;
wire [31:0] alu_src1   ;
wire [31:0] alu_src2   ;


assign inst            = id_to_ex_inst  ;
assign pc              = id_to_ex_pc    ;

assign op_31_26  = inst[31:26];
assign op_25_22  = inst[25:22];
assign op_21_20  = inst[21:20];
assign op_19_15  = inst[19:15];

assign rd   = inst[ 4: 0];
assign rj   = inst[ 9: 5];
assign rk   = inst[14:10];

assign ui5  = inst[14:10];
assign i12  = inst[21:10];
assign i20  = inst[24: 5];
assign i16  = inst[25:10];
assign i26  = {inst[ 9: 0], inst[25:10]};

decoder_6_64 u_dec0(.in(op_31_26 ), .out(op_31_26_d ));
decoder_4_16 u_dec1(.in(op_25_22 ), .out(op_25_22_d ));
decoder_2_4  u_dec2(.in(op_21_20 ), .out(op_21_20_d ));
decoder_5_32 u_dec3(.in(op_19_15 ), .out(op_19_15_d ));

assign inst_mul_w   = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h18];
assign inst_mulh_w  = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h19];
assign inst_mulh_wu = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h1a];
assign inst_div_w   = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h2] & op_19_15_d[5'h00];
assign inst_mod_w   = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h2] & op_19_15_d[5'h01];
assign inst_div_wu  = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h2] & op_19_15_d[5'h02];
assign inst_mod_wu  = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h2] & op_19_15_d[5'h03];

assign inst_add_w  = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h00];
assign inst_sub_w  = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h02];
assign inst_slt    = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h04];
assign inst_sltu   = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h05];
assign inst_sll    = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h0e];
assign inst_srl    = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h0f];
assign inst_sra    = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h10];

assign inst_nor    = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h08];
assign inst_and    = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h09];
assign inst_or     = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h0a];
assign inst_xor    = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h0b];
assign inst_slli_w = op_31_26_d[6'h00] & op_25_22_d[4'h1] & op_21_20_d[2'h0] & op_19_15_d[5'h01];
assign inst_srli_w = op_31_26_d[6'h00] & op_25_22_d[4'h1] & op_21_20_d[2'h0] & op_19_15_d[5'h09];
assign inst_srai_w = op_31_26_d[6'h00] & op_25_22_d[4'h1] & op_21_20_d[2'h0] & op_19_15_d[5'h11];
assign inst_slti   = op_31_26_d[6'h00] & op_25_22_d[4'h8];
assign inst_sltui  = op_31_26_d[6'h00] & op_25_22_d[4'h9];
assign inst_addi_w = op_31_26_d[6'h00] & op_25_22_d[4'ha];
assign inst_andi   = op_31_26_d[6'h00] & op_25_22_d[4'hd];
assign inst_ori    = op_31_26_d[6'h00] & op_25_22_d[4'he]; 
assign inst_xori   = op_31_26_d[6'h00] & op_25_22_d[4'hf]; 
assign inst_ld_w   = op_31_26_d[6'h0a] & op_25_22_d[4'h2];
assign inst_st_w   = op_31_26_d[6'h0a] & op_25_22_d[4'h6];
assign inst_jirl   = op_31_26_d[6'h13];
assign inst_b      = op_31_26_d[6'h14];
assign inst_bl     = op_31_26_d[6'h15];
assign inst_beq    = op_31_26_d[6'h16];
assign inst_bne    = op_31_26_d[6'h17];
assign inst_lu12i_w= op_31_26_d[6'h05] & ~inst[25];
assign inst_pcaddu12i= op_31_26_d[6'h07]&~inst[25];

assign br_op       = inst_bne | inst_beq;
assign alu_op[ 0] = inst_add_w | inst_addi_w | inst_ld_w | inst_st_w
                    | inst_jirl | inst_bl |inst_pcaddu12i;
assign alu_op[ 1] = inst_sub_w;
assign alu_op[ 2] = inst_slt | inst_slti;
assign alu_op[ 3] = inst_sltu | inst_sltui ;
assign alu_op[ 4] = inst_and | inst_andi;
assign alu_op[ 5] = inst_nor ;
assign alu_op[ 6] = inst_or | inst_ori;
assign alu_op[ 7] = inst_xor |inst_xori;
assign alu_op[ 8] = inst_slli_w | inst_sll;
assign alu_op[ 9] = inst_srli_w |inst_srl;
assign alu_op[10] = inst_srai_w |inst_sra;
assign alu_op[11] = inst_lu12i_w;
assign alu_op[12] = mem_we;
assign alu_op[13] = gr_we; 
assign alu_op[14] = res_from_mem;
assign alu_op[15] = inst_mul_w;
assign alu_op[16] = inst_mulh_w;
assign alu_op[17] = inst_mulh_wu;//mulh
assign alu_op[18] = inst_div_w;
assign alu_op[19] = inst_div_wu;
assign alu_op[20] = inst_mod_w;
assign alu_op[21] = inst_mod_wu;



assign need_ui5   =  inst_slli_w | inst_srli_w | inst_srai_w;
assign need_ui12  =  inst_andi |inst_ori|inst_xori;
assign need_si12  =  inst_addi_w | inst_ld_w | inst_st_w | inst_slti |inst_sltui;
assign need_si16  =  inst_jirl | inst_beq | inst_bne;
assign need_si20  =  inst_lu12i_w|inst_pcaddu12i;
assign need_si26  =  inst_b | inst_bl;
assign src2_is_4  =  inst_jirl | inst_bl;

assign imm = src2_is_4 ? 32'h4                      :
            need_si20 ? {i20[19:0], 12'b0}          :
            need_ui5  ? {27'b0,ui5}                 :
            need_ui12 ? {20'b0, i12[11:0]}          :
            {{20{i12[11]}}, i12[11:0]} ;

assign br_offs = need_si26 ? {{ 4{i26[25]}}, i26[25:0], 2'b0} :
                            {{14{i16[15]}}, i16[15:0], 2'b0} ;

assign jirl_offs = {{14{i16[15]}}, i16[15:0], 2'b0};

assign src_reg_is_rd = (inst_beq | inst_bne | inst_st_w);

assign src1_is_pc    = (inst_jirl | inst_bl | inst_pcaddu12i);

assign src2_is_imm   = (inst_slli_w |
                    inst_srli_w |
                    inst_srai_w |
                    inst_addi_w |
                    inst_slti   |
                    inst_sltui  |
                    inst_pcaddu12i|
                    inst_andi   |
                    inst_ori    |
                    inst_xori   |
                    inst_ld_w   |
                    inst_st_w   |
                    inst_lu12i_w|
                    inst_jirl   |
                    inst_bl)     ;

assign res_from_mem  = inst_ld_w&id_valid;
assign dst_is_r1     = inst_bl&id_valid;
assign gr_we         = (dest!='b0)&~inst_st_w & ~inst_beq & ~inst_bne & ~inst_b &id_valid ;
assign mem_we        = inst_st_w &id_valid;
assign dest          = dst_is_r1&id_valid ? 5'd1 : rd;

assign rf_raddr1 = id_valid?rj:'b0;
assign rf_raddr2 = id_valid?(src_reg_is_rd ? rd :src2_is_imm?'b0:rk):'b0;

assign rj_value  = rf_rdata1;
assign rkd_value = rf_rdata2;

assign rj_eq_rd = (rj_value == rkd_value);
assign br_taken = (   inst_beq  &&  rj_eq_rd
                    || inst_bne  && !rj_eq_rd
                    || inst_jirl
                    || inst_bl
                    || inst_b
                    )&id_valid;
assign br_target = (inst_beq || inst_bne || inst_bl || inst_b) ? (pc + br_offs) :
                                                /*inst_jirl*/ (rj_value + jirl_offs);

assign alu_src1 = src1_is_pc  ? pc[31:0] : rj_value;
assign alu_src2 = src2_is_imm ? imm : rkd_value;
// assign id_src1  = alu_src1;
// assign id_src2  = alu_src2;
assign rf_waddr = dest;
assign mem_wdata = mem_we?rkd_value:'b0;
assign id_ready_go = ~idu_nready_go;
assign br_stall    = idu_nready_go&br_op&id_valid;

ex_reg u_ex_reg(
    .clk                (clk           ),
    .rst                (rst           ),
    .br_taken           (br_taken      ),
    .id_ready_go        (id_ready_go   ),
    .if_to_id_valid     (if_to_id_valid),
    .id_valid           (id_valid       ),
    .i_ex_ready         (i_ex_ready    ),
    .o_id_ready         (o_id_ready    ),
    .id_to_ex_valid     (id_to_ex_valid),

    .if_to_id_pc        (if_to_id_pc    ),
    .if_to_id_inst      (if_to_id_inst  ),

    .id_pc              (id_to_ex_pc   ),
    .id_inst            (id_to_ex_inst )
);
assign id_to_ex_src1        = alu_src1  ; 
assign id_to_ex_src2        = alu_src2  ; 
assign id_to_ex_alu_op      = alu_op    ; 
assign id_to_ex_rf_waddr    = dest      ; 
endmodule