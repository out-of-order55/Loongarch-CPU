module if_reg (
    input               clk     ,
    input               rst     ,
    
    input               i_if_valid ,
    input               i_id_ready ,
    output              o_if_ready ,
    output              o_id_valid ,

    input[31:0]         if_pc   ,
    input[31:0]         if_inst ,
    output reg[31:0]    id_pc   ,
    output reg[31:0]    id_inst
);
    reg         valid_r;
    wire        if_ready_go = 'b1;
    assign      o_if_ready = (~valid_r)|((i_id_ready)&if_ready_go);
    always @(posedge clk) begin
        if(rst)begin
            valid_r <= 'b0;
        end
        else if(i_id_ready)begin
            valid_r <= i_if_valid;
        end
        if(i_if_valid&o_if_ready)begin
            id_pc   <= if_pc  ;
            id_inst <= if_inst;
        end
    end
endmodule