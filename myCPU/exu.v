module exu (
    input              clk                        ,
    input              rst                        ,

    input              id_to_ex_valid             ,
    input              i_mem_ready                ,
    output             o_ex_ready                 ,
    output             ex_to_mem_valid            ,

    output             exu_active                 ,

    input[31:0]        id_to_ex_pc                ,
    input[31:0]        id_to_ex_inst              ,
    input[15:0]        id_to_ex_alu_op            ,
    input[4:0]         id_to_ex_rf_waddr          ,
    input[31:0]        id_to_ex_src1              ,
    input[31:0]        id_to_ex_src2              ,
    input[31:0]        id_to_ex_mem_wdata         ,
    
    output[31:0]       exu_mem_addr               ,//dsram
    output[3:0]        exu_mem_re                 ,//dsram
    output[31:0]       exu_mem_wdata              ,//dsram
    output[3:0]        exu_mem_we                 ,//dsram


    output             ex_to_mem_mem_re           ,
    output[31:0]       ex_to_mem_alu_res          ,
    output[4:0]        ex_to_mem_rf_waddr         ,
    output             ex_to_mem_rf_we            ,
    output[31:0]       ex_to_mem_pc               ,
    output[31:0]       ex_to_mem_inst            
);
    wire[3:0] mem_we;
    wire[3:0] res_from_mem;
    wire[31:0]    mem_wdata;
    wire[31:0]    mem_addr ;
    wire [31:0] alu_result;
    wire[31:0]        ex_mem_wdata;
    wire[31:0]        ex_src1     ;
    wire[31:0]        ex_src2     ;
    wire[31:0]        ex_pc       ;
    wire[31:0]        ex_inst     ;
    wire[15:0]        ex_alu_op   ;
    wire[4:0]         ex_rf_waddr ;
    wire[31:0]        ex_mem_wdata;
alu u_alu(
    .alu_op     (ex_alu_op      ),
    .alu_src1   (ex_src1        ),
    .alu_src2   (ex_src2        ),
    .alu_result (alu_result     )
    ); 
    assign  mem_addr      = alu_result           ;
    assign  mem_wdata     = ex_mem_wdata          ;
    assign  mem_we        = {4{ex_alu_op[12]}}   ;
    assign  res_from_mem  = {4{ex_alu_op[14]}}   ;
    assign  rf_we         = ex_alu_op[13]        ;   
    assign  ex_rf_wdata   = alu_result           ;
    assign  exu_mem_addr  = mem_addr             ;
    assign  exu_mem_re    = ex_valid?res_from_mem:'b0;
    assign  exu_mem_wdata = mem_wdata;
    assign  exu_mem_we    = ex_valid?mem_we:'b0;
mem_reg u_mem_reg(
    .clk                      (clk                 ),
    .rst                      (rst                 ),
    .id_to_ex_valid           (id_to_ex_valid      ),
    .i_mem_ready              (i_mem_ready         ),
    .o_ex_ready               (o_ex_ready          ),
    .ex_valid                 (ex_valid            ),
    .ex_to_mem_valid          (ex_to_mem_valid     ),
    
    .id_to_ex_src1            (id_to_ex_src1       ),
    .id_to_ex_src2            (id_to_ex_src2       ),
    .id_to_ex_rf_waddr        (id_to_ex_rf_waddr   ),
    .id_to_ex_alu_op          (id_to_ex_alu_op     ),
    .id_to_ex_pc              (id_to_ex_pc         ),
    .id_to_ex_inst            (id_to_ex_inst       ),
    .id_to_ex_mem_wdata       (id_to_ex_mem_wdata  ),
    
    .ex_mem_wdata             (ex_mem_wdata         ),
    .ex_src1                  (ex_src1             ),
    .ex_src2                  (ex_src2             ),
    .ex_rf_waddr              (ex_rf_waddr         ),
    .ex_alu_op                (ex_alu_op           ),
    .ex_pc                    (ex_pc               ),
    .ex_inst                  (ex_inst             )
);     
    assign ex_to_mem_mem_re   = res_from_mem;        
    assign ex_to_mem_alu_res  = alu_result;        
    assign ex_to_mem_rf_waddr = ex_rf_waddr;        
    assign ex_to_mem_rf_we    = exu_active?rf_we:'b0;        
    assign ex_to_mem_pc       = ex_pc;        
    assign ex_to_mem_inst     = ex_inst;
    assign exu_active         = ex_valid;    
endmodule