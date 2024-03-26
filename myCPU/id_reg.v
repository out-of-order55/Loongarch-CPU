module id_reg (
    input               clk     ,
    input               rst     ,
    
    input               i_if_valid ,
    input               i_id_ready ,
    output              o_if_ready ,
    output              o_id_valid ,

    input               br_taken,
    input[31:0]         if_pc   ,
    input[31:0]         if_inst ,
    output[31:0]        id_pc   ,
    output[31:0]        id_inst
);
    reg         valid_r;
    reg[31:0]   id_pc_temp  ;
    reg[31:0]   id_inst_temp;
    wire        if_ready_go = 'b1;
    assign      o_if_ready = (!valid_r)|((i_id_ready)&if_ready_go);
    always @(posedge clk) begin
        if(rst)begin
            valid_r <= 'b0;
        end
        else if(o_if_ready)begin
            valid_r <= i_if_valid;
        end

    end
    assign   o_id_valid= valid_r&if_ready_go;
    always @(posedge clk) begin
        if(rst)begin
            id_pc_temp   <= 'b0;
            id_inst_temp <= 'b0;
        end
        else if(br_taken)begin
            id_pc_temp   <= if_pc  ;
            id_inst_temp <= 'b0;
        end
        else if(i_if_valid&o_if_ready)begin
            id_pc_temp   <= if_pc  ;
            id_inst_temp <= if_inst;
        end
    end
    assign  id_pc   = id_pc_temp  ;
    assign  id_inst = id_inst_temp;
endmodule