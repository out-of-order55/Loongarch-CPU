module mem_reg (
    input               clk                 ,
    input               rst                 ,
    
    input               i_mem_valid         ,
    input               i_wb_ready          ,
    output              o_mem_ready         ,
    output              o_wb_valid          ,


    input[31:0]         mem_alu_res         ,
    input[31:0]         mem_mem_rdata       ,
    input[4:0]          mem_rf_waddr        ,
    input               mem_rf_we           ,
    input[31:0]         mem_pc              ,
    input[31:0]         mem_inst            ,


    output reg[31:0]    wb_alu_res          ,
    output reg[31:0]    wb_mem_rdata        ,
    output reg[4:0]     wb_rf_waddr         ,
    output reg          wb_rf_we            ,
    output reg[31:0]    wb_pc               ,
    output reg[31:0]    wb_inst                     
);
    reg         valid_r;
    wire        mem_ready_go = 'b1;
    assign      o_mem_ready = (~valid_r)|((i_wb_ready)&mem_ready_go);
    always @(posedge clk) begin
        if(rst)begin
            valid_r <= 'b0;
        end
        else if(i_wb_ready)begin
            valid_r <= i_mem_valid;
        end
        if(i_mem_valid&o_mem_ready)begin
            wb_alu_res   <= mem_alu_res   ;
            wb_mem_rdata <= mem_mem_rdata ;
            wb_rf_waddr  <= mem_rf_waddr  ;
            wb_rf_we     <= mem_rf_we     ;
            wb_pc        <= mem_pc        ;
            wb_inst      <= mem_inst      ;
        end
    end
endmodule