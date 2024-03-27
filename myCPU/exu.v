`include "define.v"
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
    input[`ALU_OP-1:0]        id_to_ex_alu_op            ,
    input[4:0]         id_to_ex_rf_waddr          ,
    input[31:0]        id_to_ex_src1              ,
    input[31:0]        id_to_ex_src2              ,
    input[31:0]        id_to_ex_mem_wdata         ,
    
    output[31:0]       exu_mem_addr               ,//dsram
    output[3:0]        exu_mem_re                 ,//dsram
    output[31:0]       exu_mem_wdata              ,//dsram
    output[3:0]        exu_mem_we                 ,//dsram

    output             ex_to_mem_mem_signal       ,
    output[3:0]        ex_to_mem_mem_re           ,
    output[31:0]       ex_to_mem_alu_res          ,
    output[4:0]        ex_to_mem_rf_waddr         ,
    output             ex_to_mem_rf_we            ,
    output[31:0]       ex_to_mem_pc               ,
    output[31:0]       ex_to_mem_inst            
);
    wire        mem_w_w;
    wire        mem_w_h;
    wire        mem_w_b;
    wire        mem_r_w;
    wire        mem_r_h;
    wire        mem_r_b; 
    wire[31:0]  ex_rf_wdata;
    wire[3:0] mem_we;
    wire[3:0] res_from_mem;
    wire[31:0]    mem_wdata;
    wire[31:0]    mem_addr ;
    wire [31:0] alu_result;
    wire[31:0]        mem_wdata_temp;
    wire[31:0]        ex_mem_wdata;
    wire[31:0]        ex_src1     ;
    wire[31:0]        ex_src2     ;
    wire[31:0]        ex_pc       ;
    wire[31:0]        ex_inst     ;
    wire[`ALU_OP-1:0] ex_alu_op   ;
    wire[4:0]         ex_rf_waddr ;
    wire[31:0]        ex_mem_wdata;
    wire              ex_ready_go;
    wire              cul_done;
    wire[31:0]        md_res;
alu u_alu(
    .alu_op     (ex_alu_op[`LU12I:`ADD]      ),
    .alu_src1   (ex_src1        ),
    .alu_src2   (ex_src2        ),
    .alu_result (alu_result     )
); 
mul_div_alu mul_div_alu(
    .clk        (clk),
    .rst        (rst),
    .src1       (ex_src1),
    .src2       (ex_src2),
    .alu_op     (ex_alu_op[`MODU:`MUL]),
    .cul_done   (cul_done),
    .res        (md_res)   
);
/////////////////////////MEM_OP//////////////////////////////////
    assign  mem_w_w       = ex_alu_op[`MEM_W_W];
    assign  mem_w_h       = ex_alu_op[`MEM_W_H];
    assign  mem_w_b       = ex_alu_op[`MEM_W_B];
    assign  mem_r_w       = ex_alu_op[`MEM_R_W];
    assign  mem_r_h       = ex_alu_op[`MEM_R_H];
    assign  mem_r_b       = ex_alu_op[`MEM_R_B];
    assign  mem_addr      = alu_result              ;
    assign  mem_wdata     = ex_mem_wdata            ;
    // assign  mem_we        =  mem_w_w? 4'b1111
    //                         :mem_w_h?(mem_addr[2:0]==3'b000? 4'b0011
    //                                                         :mem_addr[2:0]==3'b001? 4'b0110
    //                                                         :mem_addr[2:0]==3'b010? 4'b1100
    //                                                         :'b0)
    //                         :mem_w_b?(mem_addr[2:0]==3'b000? 4'b0001
    //                                                         :mem_addr[2:0]==3'b001?4'b0010
    //                                                         :mem_addr[2:0]==3'b010?4'b0100
    //                                                         :mem_addr[2:0]==3'b011?4'b1000
    //                                                         :'b0)
    //                         :'b0   ;
    assign  mem_we        =  {4{mem_w_w}}&(4'b1111)
                            |{4{mem_w_h&(mem_addr[1:0]==2'b00)}}&(4'b0011)
                            |{4{mem_w_h&(mem_addr[1:0]==2'b01)}}&(4'b0110)
                            |{4{mem_w_h&(mem_addr[1:0]==2'b10)}}&(4'b1100)
                            |{4{mem_w_b&(mem_addr[1:0]==2'b00)}}&(4'b0001)
                            |{4{mem_w_b&(mem_addr[1:0]==2'b01)}}&(4'b0010)
                            |{4{mem_w_b&(mem_addr[1:0]==2'b10)}}&(4'b0100)
                            |{4{mem_w_b&(mem_addr[1:0]==2'b11)}}&(4'b1000);
    assign  res_from_mem  =  {4{mem_r_w}}&(4'b1111)
                            |{4{mem_r_h&(mem_addr[1:0]==2'b00)}}&(4'b0011)
                            |{4{mem_r_h&(mem_addr[1:0]==2'b01)}}&(4'b0110)
                            |{4{mem_r_h&(mem_addr[1:0]==2'b10)}}&(4'b1100)
                            |{4{mem_r_b&(mem_addr[1:0]==2'b00)}}&(4'b0001)
                            |{4{mem_r_b&(mem_addr[1:0]==2'b01)}}&(4'b0010)
                            |{4{mem_r_b&(mem_addr[1:0]==2'b10)}}&(4'b0100)
                            |{4{mem_r_b&(mem_addr[1:0]==2'b11)}}&(4'b1000);
    // assign  res_from_mem  = mem_r_w?4'b1111
    //                         :mem_r_h?(mem_addr[2:0]==3'b000? 4'b0011
    //                                                         :mem_addr[2:0]==3'b001?4'b0110
    //                                                         :mem_addr[2:0]==3'b010?4'b1100
    //                                                         :'b0)
    //                         :mem_r_b?(mem_addr[2:0]==3'b000? 4'b0001
    //                                                         :mem_addr[2:0]==3'b001?4'b0010
    //                                                         :mem_addr[2:0]==3'b010?4'b0100
    //                                                         :mem_addr[2:0]==3'b011?4'b1000
    //                                                         :'b0)   
    //                         :'b0;   
    assign  exu_mem_addr  = mem_addr             ;
    assign  exu_mem_re    = ex_valid?res_from_mem:'b0;
    assign  exu_mem_wdata = mem_wdata_temp;
    assign  mem_wdata_temp=  (mem_we==4'b1111) ? mem_wdata
                            :(mem_we==4'b0011) ? {16'b0,mem_wdata[15:0]}
                            :(mem_we==4'b0110) ? {8'b0,mem_wdata[15:0],8'b0}
                            :(mem_we==4'b1100) ? {mem_wdata[15:0],16'b0}
                            :(mem_we==4'b0001) ? {24'b0,mem_wdata[7:0]}
                            :(mem_we==4'b0010) ? {16'b0,mem_wdata[7:0],8'b0}
                            :(mem_we==4'b0100) ? {8'b0,mem_wdata[7:0],16'b0}
                            :(mem_we==4'b1000) ? {mem_wdata[7:0],24'b0}
                            :'b0;
    assign  exu_mem_we    = ex_valid?mem_we:'b0;
////////////////////////////////////////////////////////////////
    assign  rf_we         = ex_alu_op[`GR_WE]       ;   
    assign  ex_rf_wdata   = (ex_alu_op[`MODU:`MUL]!=0)?md_res:alu_result;

    assign  ex_ready_go   = (ex_alu_op[`MODU:`MUL]!=0)?cul_done:'b1;
mem_reg u_mem_reg(
    .clk                      (clk                 ),
    .rst                      (rst                 ),
    .id_to_ex_valid           (id_to_ex_valid      ),
    .i_mem_ready              (i_mem_ready         ),
    .o_ex_ready               (o_ex_ready          ),
    .ex_valid                 (ex_valid            ),
    .ex_ready_go              (ex_ready_go         ),
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
    assign ex_to_mem_mem_re     = res_from_mem;        
    assign ex_to_mem_alu_res    = ex_rf_wdata;        
    assign ex_to_mem_rf_waddr   = ex_rf_waddr;        
    assign ex_to_mem_rf_we      = exu_active?rf_we:'b0;        
    assign ex_to_mem_pc         = ex_pc;        
    assign ex_to_mem_inst       = ex_inst;
    assign ex_to_mem_mem_signal = ex_alu_op[`MEM_RSIGNAL];
    assign exu_active           = ex_valid;    
endmodule