`include "define.v"
module mycpu_top(
    input  wire        clk,
    input  wire        resetn,
    // inst sram interface
    output wire [3:0]  inst_sram_we,
    output wire [31:0] inst_sram_addr,
    output wire [31:0] inst_sram_wdata,
    output wire        inst_sram_en,
    input  wire [31:0] inst_sram_rdata,
    // data sram interface
    output wire [3:0]  data_sram_we,
    output wire [31:0] data_sram_addr,
    output wire [31:0] data_sram_wdata,
    output wire        data_sram_en,
    input  wire [31:0] data_sram_rdata,
    // trace debug interface
    output wire [31:0] debug_wb_pc,
    output wire [ 3:0] debug_wb_rf_we,
    output wire [ 4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata
);
    reg         reset;
    always @(posedge clk) reset <= ~resetn;
///////////////////////////val define //////////////////////
    wire              ex_to_mem_mem_signal;
    wire[31:0]        mem_rdata;
    wire              exu_active   ;
    wire[31:0]        mem_rf_wdata;
    wire[31:0]        exu_mem_addr ;
    wire[3:0]         exu_mem_re   ;
    wire[31:0]        exu_mem_wdata;
    wire[3:0]         exu_mem_we   ;
    wire[31:0]        mem_to_wb_rf_wdata;
    wire              if_to_id_valid       ;
    wire              br_stall             ;
    wire              br_taken             ;
    wire[31:0]        br_target            ;

    wire[31:0]        if_to_id_pc          ;
    wire[31:0]        if_to_id_inst        ;
    wire[31:0]        id_to_ex_src1        ;
    wire[31:0]        id_to_ex_src2        ;
    wire[31:0]        id_to_ex_pc          ;
    wire[31:0]        id_to_ex_inst        ;
    wire[`ALU_OP-1:0]        id_to_ex_alu_op      ;
    wire[4:0]         id_to_ex_rf_waddr    ;
    wire[31:0]        id_to_ex_mem_wdata   ;

    wire[31:0]        ex_to_mem_mem_addr   ;
    wire[31:0]        ex_to_mem_alu_res    ;
    wire[31:0]        ex_to_mem_mem_wdata  ;
    wire[4:0]         ex_to_mem_rf_waddr   ;
    wire              ex_to_mem_rf_we      ;
    wire[3:0]         ex_to_mem_mem_re     ;
    wire[3:0]         ex_to_mem_mem_we     ;
    wire[31:0]        ex_to_mem_pc         ;
    wire[31:0]        ex_to_mem_inst       ;   

    wire[31:0]        mem_to_wb_rf_rdata          ;
    wire[4:0]         mem_to_wb_rf_waddr          ;
    wire              mem_to_wb_rf_we             ;
    wire[31:0]        mem_to_wb_pc                ;
    wire[31:0]        mem_to_wb_inst              ;
    wire              mem_to_wb_mem_re            ;
    wire[31:0]        wb_rf_wdata;
    wire[4:0]         wb_rf_waddr;
    wire              wb_rf_we;
    wire[31:0]        wb_pc  ;    
    wire[31:0]        wb_inst;    
    wire[31:0]         rf_rdata1;
    wire[31:0]         rf_rdata2;
    wire[4:0]          rf_raddr1;
    wire[4:0]          rf_raddr2;
    wire[4:0]          id_to_ex_rf_raddr1;
    wire[4:0]          id_to_ex_rf_raddr2;

    wire[31:0]         id_src1    ;
    wire[31:0]         id_src2    ;
    wire[31:0]         idu_src1    ;
    wire[31:0]         idu_src2    ;
    wire               idu_nready_go;
    wire[31:0]         ex_rf_wdata;
    wire    i_ex_ready = o_ex_ready;
    wire    i_id_ready = o_id_ready;
    wire    i_mem_ready = o_mem_ready;
    wire              i_wb_ready;
    wire              o_wb_ready;
    wire              id_to_ex_valid;
    wire              wb_active;
////////////////////////////////////////////////////////////
ifu IFU(
    .clk             (clk            ),
    .rst             (reset          ),
    .i_id_ready      (i_id_ready     ),
    .if_to_id_valid  (if_to_id_valid ),
    .inst_sram_en    (inst_sram_en   ),
    .bjp_stall       (br_stall       ),
    .bjp_taken       (br_taken       ),
    .bjp_target      (br_target      ),
    .inst_sram_rdata (inst_sram_rdata),
    .inst_sram_addr  (inst_sram_addr ),
    .if_to_id_pc     (if_to_id_pc    ),
    .if_to_id_inst   (if_to_id_inst  )
);

idu IDU(
    .clk                (clk                 ),
    .rst                (reset               ),
    .if_to_id_valid     (if_to_id_valid      ),
    .i_ex_ready         (i_ex_ready          ),
    .idu_nready_go      (idu_nready_go       ),
    .o_id_ready         (o_id_ready          ),
    .id_to_ex_valid     (id_to_ex_valid      ),
    .rf_rdata1          (idu_src1            ),
    .rf_rdata2          (idu_src2            ),
    .rf_raddr1          (rf_raddr1           ),
    .rf_raddr2          (rf_raddr2           ),
    .br_stall           (br_stall            ),
    .br_taken           (br_taken            ),
    .br_target          (br_target           ),
    .if_to_id_inst      (if_to_id_inst       ),
    .if_to_id_pc        (if_to_id_pc         ),

    .id_to_ex_pc        (id_to_ex_pc         ),
    .id_to_ex_inst      (id_to_ex_inst       ),
    .id_to_ex_src1      (id_to_ex_src1       ),
    .id_to_ex_src2      (id_to_ex_src2       ),
    .id_to_ex_alu_op    (id_to_ex_alu_op     ),
    .id_to_ex_rf_waddr  (id_to_ex_rf_waddr   )
);

bypass_net bypass_net(
    .clk                (clk            ),
    .rst                (rst            ),
    .id_rf_raddr1       (rf_raddr1      ),
    .id_rf_raddr2       (rf_raddr2      ),
    .id_src1            (rf_rdata1      ),
    .id_src2            (rf_rdata2      ),
    .idu_nready_go      (idu_nready_go  ),
    .exu_active         (exu_active     ),
    .ex_mem_re          (|exu_mem_re     ),
    .ex_rf_we           (ex_to_mem_rf_we),
    .ex_rf_wdata        (ex_to_mem_alu_res      ),
    .ex_rf_waddr        (ex_to_mem_rf_waddr     ),
    .mem_mem_re         (mem_to_wb_mem_re       ), 
    .mem_rf_we          (mem_to_wb_rf_we        ),
    .mem_rf_wdata       (mem_to_wb_rf_wdata     ),
    .mem_rf_waddr       (mem_to_wb_rf_waddr     ),
    .wb_rf_we           (wb_rf_we       ),
    .wb_rf_wdata        (wb_rf_wdata    ),
    .wb_rf_waddr        (wb_rf_waddr    ),
    .id_to_ex_mem_wdata (id_to_ex_mem_wdata),
    .idu_src1           (idu_src1     ),
    .idu_src2           (idu_src2     )
);
exu EXU(
    .clk                  (clk              ),
    .rst                  (reset            ),
    .exu_active           (exu_active       ), 
    .id_to_ex_valid       (id_to_ex_valid   ),
    .i_mem_ready          (i_mem_ready      ),
    .o_ex_ready           (o_ex_ready       ),
    .ex_to_mem_valid      (ex_to_mem_valid  ),


    .id_to_ex_pc          (id_to_ex_pc       ),
    .id_to_ex_inst        (id_to_ex_inst     ),
    .id_to_ex_mem_wdata   (id_to_ex_mem_wdata),
    .id_to_ex_src1        (id_to_ex_src1     ),
    .id_to_ex_src2        (id_to_ex_src2     ),
    .id_to_ex_alu_op      (id_to_ex_alu_op   ),
    .id_to_ex_rf_waddr    (id_to_ex_rf_waddr ),

    .exu_mem_addr         (exu_mem_addr      ), 
    .exu_mem_re           (exu_mem_re        ), 
    .exu_mem_wdata        (exu_mem_wdata     ), 
    .exu_mem_we           (exu_mem_we        ), 
    .ex_to_mem_mem_signal (ex_to_mem_mem_signal),
    .ex_to_mem_mem_re     (ex_to_mem_mem_re  ),
    .ex_to_mem_alu_res    (ex_to_mem_alu_res ),
    .ex_to_mem_rf_waddr   (ex_to_mem_rf_waddr),
    .ex_to_mem_rf_we      (ex_to_mem_rf_we   ),
    .ex_to_mem_pc         (ex_to_mem_pc      ),
    .ex_to_mem_inst       (ex_to_mem_inst    )  
);
    assign  i_wb_ready = o_wb_ready;
mem MEM(
    .clk                    (clk                ),
    .rst                    (reset              ),
    .ex_to_mem_valid        (ex_to_mem_valid    ),
    .i_wb_ready             (i_wb_ready         ),
    .o_mem_ready            (o_mem_ready        ),
    .mem_to_wb_valid        (mem_to_wb_valid    ),

    .ex_to_mem_mem_signal   (ex_to_mem_mem_signal),
    .ex_to_mem_alu_res      (ex_to_mem_alu_res  ),
    .ex_to_mem_rf_waddr     (ex_to_mem_rf_waddr ),
    .ex_to_mem_rf_we        (ex_to_mem_rf_we    ),
    .ex_to_mem_pc           (ex_to_mem_pc       ),
    .ex_to_mem_inst         (ex_to_mem_inst     ),
    .ex_to_mem_mem_re       (ex_to_mem_mem_re   ),

    .mem_rdata              (mem_rdata          ),

    .mem_to_wb_mem_re       (mem_to_wb_mem_re   ),      
    .mem_to_wb_rf_wdata     (mem_to_wb_rf_wdata ),      
    .mem_to_wb_rf_waddr     (mem_to_wb_rf_waddr ),      
    .mem_to_wb_rf_we        (mem_to_wb_rf_we    ),      
    .mem_to_wb_pc           (mem_to_wb_pc       ),      
    .mem_to_wb_inst         (mem_to_wb_inst     )     
);



wb WB(
    .clk                   (clk                 ),
    .rst                   (rst                 ),
    .mem_to_wb_valid       (mem_to_wb_valid     ),
    .o_wb_ready            (o_wb_ready          ),
    .wb_active             (wb_active           ),
    .mem_to_wb_rf_wdata    (mem_to_wb_rf_wdata  ),
    .mem_to_wb_rf_waddr    (mem_to_wb_rf_waddr  ),
    .mem_to_wb_rf_we       (mem_to_wb_rf_we     ),
    .mem_to_wb_pc          (mem_to_wb_pc        ),
    .mem_to_wb_inst        (mem_to_wb_inst      ),
    .wb_rf_wdata           (wb_rf_wdata         ),
    .wb_rf_waddr           (wb_rf_waddr         ),
    .wb_rf_we              (wb_rf_we            ),
    .wb_pc                 (wb_pc               ),
    .wb_inst               (wb_inst             )

);
regfile u_regfile(
    .clk    (clk        ),
    .raddr1 (rf_raddr1  ),
    .rdata1 (rf_rdata1  ),
    .raddr2 (rf_raddr2  ),
    .rdata2 (rf_rdata2  ),
    .we     (wb_rf_we   ),
    .waddr  (wb_rf_waddr),
    .wdata  (wb_rf_wdata)
);
    assign data_sram_en    = (|(exu_mem_re))|(|(exu_mem_we));
    assign data_sram_we    = exu_mem_we;
    assign data_sram_addr  = exu_mem_addr;
    assign data_sram_wdata = exu_mem_wdata;
    assign mem_rdata       = data_sram_rdata;  
// debug info generate
assign debug_wb_pc       = wb_pc;
assign debug_wb_rf_we    = wb_active?{4{wb_rf_we}}:4'b0;
assign debug_wb_rf_wnum  = wb_rf_waddr;
assign debug_wb_rf_wdata = wb_rf_wdata;

endmodule
