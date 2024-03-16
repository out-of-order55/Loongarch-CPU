module id_reg (
    input               clk     ,
    input               rst     ,
    
    input               i_id_valid ,
    input               i_ex_ready ,
    output              o_id_ready ,
    output              o_ex_valid ,

    input[31:0]         id_pc       ,
    input[31:0]         id_inst     ,
    input[15:0]         id_alu_op   ,
    input[4:0]          id_rf_waddr ,
    output reg[4:0]     ex_rf_waddr ,
    output reg[15:0]    ex_alu_op   ,
    output reg[31:0]    ex_pc       ,
    output reg[31:0]    ex_inst
);
    reg         valid_r;
    wire        id_ready_go = 'b1;
    assign      o_id_ready = (~valid_r)|((i_ex_ready)&id_ready_go);
    always @(posedge clk) begin
        if(rst)begin
            valid_r <= 'b0;
        end
        else if(i_ex_ready)begin
            valid_r <= i_id_valid;
        end
        if(i_id_valid&o_id_ready)begin
            ex_pc       <= id_pc  ;
            ex_inst     <= id_inst;
            ex_alu_op   <= id_alu_op;
            ex_rf_waddr <= id_rf_waddr;
        end
    end
endmodule