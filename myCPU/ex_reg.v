module ex_reg (
    input               clk                 ,
    input               rst                 ,
    
    input               i_ex_valid          ,
    input               i_mem_ready         ,
    output              o_ex_ready          ,
    output              o_mem_valid         ,


    input[31:0]         ex_alu_res          ,
    input[31:0]         ex_mem_wdata        ,
    input[4:0]          ex_rf_waddr         ,
    input               ex_rf_we            ,
    input               ex_res_from_mem     ,
    input               ex_mem_we           ,
    input[31:0]         ex_pc               ,
    input[31:0]         ex_inst             ,

    output reg[31:0]    mem_alu_res         ,
    output reg[31:0]    mem_mem_wdata       ,
    output reg[4:0]     mem_rf_waddr        ,
    output reg          mem_rf_we           ,
    output reg          mem_res_from_mem    ,
    output reg          mem_mem_we          ,
    output reg[31:0]    mem_pc              ,
    output reg[31:0]    mem_inst            
);
    reg         valid_r;
    wire        ex_ready_go = 'b1;
    assign      o_ex_ready = (~valid_r)|((i_mem_ready)&ex_ready_go);
    always @(posedge clk) begin
        if(rst)begin
            valid_r <= 'b0;
        end
        else if(i_mem_ready)begin
            valid_r <= i_ex_valid;
        end
        if(i_ex_valid&o_ex_ready)begin
            mem_alu_res       <= ex_alu_res      ;
            mem_mem_wdata     <= ex_mem_wdata    ;
            mem_rf_waddr      <= ex_rf_waddr     ;
            mem_rf_we         <= ex_rf_we        ;
            mem_res_from_mem  <= ex_res_from_mem ;
            mem_mem_we        <= ex_mem_we       ;
            mem_pc            <= ex_pc           ;
            mem_inst          <= ex_inst         ;
        end
    end
endmodule