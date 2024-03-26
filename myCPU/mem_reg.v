module mem_reg (
    input               clk                 ,
    input               rst                 ,
    
    input               id_to_ex_valid      ,
    input               i_mem_ready         ,
    output              ex_to_mem_valid     ,
    output              o_ex_ready          ,
    output              ex_valid            ,
    input               ex_ready_go         ,
    input[31:0]        id_to_ex_src1              ,
    input[31:0]        id_to_ex_src2              ,
    input[31:0]        id_to_ex_pc                ,
    input[31:0]        id_to_ex_inst              ,
    input[`ALU_OP-1:0]        id_to_ex_alu_op            ,
    input[4:0]         id_to_ex_rf_waddr          ,
    input[31:0]        id_to_ex_mem_wdata         ,

    output[31:0]       ex_mem_wdata               ,
    output[31:0]       ex_src1                    ,
    output[31:0]       ex_src2                    ,
    output[31:0]       ex_pc                      ,
    output[31:0]       ex_inst                    ,
    output[`ALU_OP-1:0]       ex_alu_op                  ,
    output[4:0]        ex_rf_waddr                      
);
    reg         valid_r;
    reg[31:0]   ex_src1_temp        ;      
    reg[31:0]   ex_src2_temp        ;      
    reg[31:0]   ex_pc_temp          ;        
    reg[31:0]   ex_inst_temp        ;      
    reg[`ALU_OP-1:0]   ex_alu_op_temp      ;    
    reg[4:0]    ex_rf_waddr_temp    ;
    reg[31:0]   ex_mem_wdata_temp;

    
    assign      ex_to_mem_valid = valid_r&ex_ready_go;
    assign      o_ex_ready = (~valid_r)|((i_mem_ready)&ex_ready_go);
    always @(posedge clk) begin
        if(rst)begin
            valid_r <= 'b0;
        end
        else if(o_ex_ready)begin
            valid_r <= id_to_ex_valid;
        end

    end
    always @(posedge clk) begin
        if(rst)begin
            ex_src1_temp      <= 'b0;
            ex_src2_temp      <= 'b0;
            ex_pc_temp        <= 'b0;
            ex_inst_temp      <= 'b0;
            ex_alu_op_temp    <= 'b0;
            ex_rf_waddr_temp  <= 'b0;
            ex_mem_wdata_temp <= 'b0;
        end
        else if(id_to_ex_valid&o_ex_ready)begin
            ex_src1_temp      <= id_to_ex_src1     ;
            ex_src2_temp      <= id_to_ex_src2     ;
            ex_pc_temp        <= id_to_ex_pc       ;
            ex_inst_temp      <= id_to_ex_inst     ;
            ex_alu_op_temp    <= id_to_ex_alu_op   ;
            ex_rf_waddr_temp  <= id_to_ex_rf_waddr ;
            ex_mem_wdata_temp <= id_to_ex_mem_wdata;
        end
    end
    assign ex_src1      = ex_src1_temp     ; 
    assign ex_src2      = ex_src2_temp     ; 
    assign ex_pc        = ex_pc_temp       ; 
    assign ex_inst      = ex_inst_temp     ; 
    assign ex_alu_op    = ex_alu_op_temp   ; 
    assign ex_rf_waddr  = ex_rf_waddr_temp ; 
    assign ex_mem_wdata = ex_mem_wdata_temp;
    assign ex_valid   = valid_r;
endmodule