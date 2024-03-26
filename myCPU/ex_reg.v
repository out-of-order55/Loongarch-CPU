module ex_reg (
    input               clk             ,
    input               rst             ,
    
    input               if_to_id_valid  ,
    input               i_ex_ready      ,
    input               id_ready_go     ,
    input               br_taken        ,
    output              id_valid        ,
    output              o_id_ready      ,
    output              id_to_ex_valid  ,
    input[31:0]         if_to_id_pc     ,
    input[31:0]         if_to_id_inst   ,
    output[31:0]        id_pc           ,
    output[31:0]        id_inst     
);
    reg         valid_r;
    reg[31:0]   id_to_ex_pc_temp       ;
    reg[31:0]   id_to_ex_inst_temp     ;    
    assign      id_to_ex_valid = valid_r&id_ready_go;
    assign      o_id_ready = (!valid_r)|((i_ex_ready)&id_ready_go);

    always @(posedge clk) begin
        if(rst)begin
            valid_r <= 'b0;
        end
        else if(o_id_ready)begin
            valid_r <= if_to_id_valid;
        end

    end
    always @(posedge clk) begin
        if(rst)begin
            id_to_ex_pc_temp      <= 'b0;
            id_to_ex_inst_temp     <='b0;
        end
        else if(br_taken)begin
            id_to_ex_pc_temp       <= if_to_id_pc;
            id_to_ex_inst_temp     <= 'b0;
        end
        else if(if_to_id_valid&o_id_ready)begin
            id_to_ex_pc_temp      <= if_to_id_pc  ;
            id_to_ex_inst_temp    <= if_to_id_inst;
        end
    end
    assign id_pc        = id_to_ex_pc_temp       ;
    assign id_inst      = id_to_ex_inst_temp     ;
    assign id_valid           = valid_r;
endmodule