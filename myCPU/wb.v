module wb(
    input wire              clk                   ,
    input wire              rst                   ,
    input wire              mem_to_wb_valid       ,
    output wire             o_wb_ready            ,

    input wire[31:0]    mem_to_wb_rf_wdata    ,
    input wire[4:0]     mem_to_wb_rf_waddr    ,
    input wire          mem_to_wb_rf_we       ,
    input wire[31:0]    mem_to_wb_pc          ,
    input wire[31:0]    mem_to_wb_inst        ,

    output wire         wb_active             ,
    output wire[31:0]   wb_rf_wdata           ,
    output wire[4:0]    wb_rf_waddr           ,
    output wire         wb_rf_we              ,
    output wire[31:0]   wb_pc                 ,
    output wire[31:0]   wb_inst               

);
    reg[31:0]   wb_rf_wdata_temp;
    reg[4:0]    wb_rf_waddr_temp;
    reg         wb_rf_we_temp   ;
    reg[31:0]   wb_pc_temp      ;
    reg[31:0]   wb_inst_temp    ;
    reg     wb_valid;
    wire    wb_ready_go='b1;
    assign  o_wb_ready = !wb_valid || wb_ready_go;
    always @(posedge clk) begin
        if(rst)begin
            wb_valid <= 'b0;
        end
        else if(o_wb_ready)begin
            wb_valid <= mem_to_wb_valid;
        end 
    end
    always @(posedge clk) begin
        if(rst)begin
            wb_rf_wdata_temp <= 'b0;
            wb_rf_waddr_temp <= 'b0;
            wb_rf_we_temp    <= 'b0;
            wb_pc_temp       <= 'b0;
            wb_inst_temp     <= 'b0;
        end
        else if(mem_to_wb_valid&o_wb_ready)begin
            wb_rf_wdata_temp <= mem_to_wb_rf_wdata ;
            wb_rf_waddr_temp <= mem_to_wb_rf_waddr ;
            wb_rf_we_temp    <= mem_to_wb_rf_we    ;
            wb_pc_temp       <= mem_to_wb_pc       ;
            wb_inst_temp     <= mem_to_wb_inst     ;
        end
    end
    assign wb_active = wb_valid;
    assign wb_rf_wdata = wb_rf_wdata_temp;
    assign wb_rf_waddr = wb_valid?wb_rf_waddr_temp:'b0;
    assign wb_rf_we    = wb_valid?wb_rf_we_temp:'b0;
    assign wb_pc       = wb_pc_temp      ;
    assign wb_inst     = wb_inst_temp    ;
endmodule