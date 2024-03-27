module wb_reg (
    input  wire         clk                 ,
    input  wire         rst                 ,
    
    input  wire         ex_to_mem_valid     ,
    input  wire         i_wb_ready          ,
    output wire         o_mem_ready         ,
    output wire         mem_to_wb_valid     ,

    input wire               ex_to_mem_mem_signal,
    input wire[3:0]          ex_to_mem_mem_re    ,
    input wire[31:0]         ex_to_mem_alu_res   ,
    input wire[4:0]          ex_to_mem_rf_waddr  ,
    input wire               ex_to_mem_rf_we     ,
    input wire[31:0]         ex_to_mem_pc        ,
    input wire[31:0]         ex_to_mem_inst      ,

    output wire              mem_mem_rsignal     ,
    output wire[3:0]         mem_mem_re          ,//bypass
    output wire[31:0]        mem_alu_res         ,//bypass and ->wb
    output wire[4:0]         mem_rf_waddr        ,
    output wire              mem_rf_we           ,
    output wire[31:0]        mem_pc              ,
    output wire[31:0]        mem_inst                  
);
    reg              valid_r;
    reg              mem_mem_rsignal_temp;
    reg[3:0]         mem_mem_re_temp          ;//bypass
    reg[31:0]        mem_alu_res_temp         ;//bypass and ->wb
    reg[4:0]         mem_rf_waddr_temp        ;
    reg              mem_rf_we_temp           ;
    reg[31:0]        mem_pc_temp              ;
    reg[31:0]        mem_inst_temp            ;       
    wire             mem_ready_go = 'b1;
    
    
    assign      o_mem_ready = (~valid_r)|((i_wb_ready)&mem_ready_go);
    
    always @(posedge clk) begin
        if(rst)begin
            valid_r <= 'b0;
        end
        else if(o_mem_ready)begin
            valid_r <= ex_to_mem_valid;
        end

    end
    assign      mem_to_wb_valid = valid_r & mem_ready_go;
    always @(posedge clk) begin
        if(rst)begin
            mem_mem_re_temp   <= 'b0; 
            mem_alu_res_temp  <= 'b0; 
            mem_rf_waddr_temp <= 'b0; 
            mem_rf_we_temp    <= 'b0; 
            mem_pc_temp       <= 'b0; 
            mem_inst_temp     <= 'b0; 
            mem_mem_rsignal_temp <= 'b0;
        end
        else if(ex_to_mem_valid&o_mem_ready)begin
            mem_mem_re_temp   <= ex_to_mem_mem_re  ; 
            mem_alu_res_temp  <= ex_to_mem_alu_res ; 
            mem_rf_waddr_temp <= ex_to_mem_rf_waddr; 
            mem_rf_we_temp    <= ex_to_mem_rf_we   ; 
            mem_pc_temp       <= ex_to_mem_pc      ; 
            mem_inst_temp     <= ex_to_mem_inst    ; 
            mem_mem_rsignal_temp <= ex_to_mem_mem_signal;
        end
    end
    assign mem_mem_re   = mem_to_wb_valid?mem_mem_re_temp:'b0  ; 
    assign mem_alu_res  = mem_alu_res_temp ; 
    assign mem_rf_waddr = mem_rf_waddr_temp; 
    assign mem_rf_we    = mem_to_wb_valid?mem_rf_we_temp:'b0   ; 
    assign mem_pc       = mem_pc_temp      ; 
    assign mem_inst     = mem_inst_temp    ; 
    assign mem_mem_rsignal = mem_to_wb_valid?mem_mem_rsignal_temp:'b0;
endmodule