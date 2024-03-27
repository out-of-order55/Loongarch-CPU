`include "define.v"
module mem(
    input wire              clk                     ,
    input wire              rst                     ,
    input wire              ex_to_mem_valid         ,
    input wire              i_wb_ready              ,
    output wire             o_mem_ready             ,
    output wire             mem_to_wb_valid         ,

    input wire               ex_to_mem_mem_signal    ,
    input wire[3:0]          ex_to_mem_mem_re        ,
    input wire[31:0]         ex_to_mem_alu_res       ,
    input wire[4:0]          ex_to_mem_rf_waddr      ,
    input wire               ex_to_mem_rf_we         ,
    input wire[31:0]         ex_to_mem_pc            ,
    input wire[31:0]         ex_to_mem_inst          ,
    input wire[31:0]         mem_rdata               ,

    output wire              mem_to_wb_mem_re        ,//bypass
    output wire[31:0]        mem_to_wb_rf_wdata      ,//bypass and ->wb
    output wire[4:0]         mem_to_wb_rf_waddr      ,
    output wire              mem_to_wb_rf_we         ,
    output wire[31:0]        mem_to_wb_pc            ,
    output wire[31:0]        mem_to_wb_inst           
);
wire              mem_mem_rsignal   ;
wire[3:0]         mem_mem_re        ;
wire[31:0]        mem_rdata_temp    ;
wire[31:0]        mem_rf_wdata      ;
wire[31:0]        mem_alu_res       ;
wire[4:0]         mem_rf_waddr      ;
wire              mem_rf_we         ;
wire[31:0]        mem_pc            ;
wire[31:0]        mem_inst          ;
wb_reg u_wb_reg(
    .clk                 (clk           ),
    .rst                 (rst           ),
    .ex_to_mem_valid     (ex_to_mem_valid),
    .i_wb_ready          (i_wb_ready    ),
    .o_mem_ready         (o_mem_ready   ),
    .mem_to_wb_valid     (mem_to_wb_valid),

    .ex_to_mem_mem_signal(ex_to_mem_mem_signal),
    .ex_to_mem_mem_re    (ex_to_mem_mem_re  ),
    .ex_to_mem_alu_res   (ex_to_mem_alu_res ),
    .ex_to_mem_rf_waddr  (ex_to_mem_rf_waddr),
    .ex_to_mem_rf_we     (ex_to_mem_rf_we   ),
    .ex_to_mem_pc        (ex_to_mem_pc      ),
    .ex_to_mem_inst      (ex_to_mem_inst    ),

    .mem_mem_rsignal      (mem_mem_rsignal   ),
    .mem_mem_re           (mem_mem_re        ),
    .mem_alu_res          (mem_alu_res       ),
    .mem_rf_waddr         (mem_rf_waddr      ),
    .mem_rf_we            (mem_rf_we         ),
    .mem_pc               (mem_pc            ),
    .mem_inst             (mem_inst          )     
);
    assign mem_rdata_temp     = (mem_mem_re==4'b1111)?mem_rdata
                            :   (mem_mem_re==4'b0011)?(mem_mem_rsignal?{16'b0,mem_rdata[15:0]}:{{16{mem_rdata[15]}},mem_rdata[15:0]})
                            :   (mem_mem_re==4'b0110)?(mem_mem_rsignal?{16'b0,mem_rdata[23:8]}:{{16{mem_rdata[23]}},mem_rdata[23:8]})
                            :   (mem_mem_re==4'b1100)?(mem_mem_rsignal?{16'b0,mem_rdata[31:16]}:{{16{mem_rdata[31]}},mem_rdata[31:16]})
                            :   (mem_mem_re==4'b0001)?(mem_mem_rsignal?{24'b0,mem_rdata[7:0]}:{{24{mem_rdata[7]}},mem_rdata[7:0]})
                            :   (mem_mem_re==4'b0010)?(mem_mem_rsignal?{24'b0,mem_rdata[15:8]}:{{24{mem_rdata[15]}},mem_rdata[15:8]})
                            :   (mem_mem_re==4'b0100)?(mem_mem_rsignal?{24'b0,mem_rdata[23:16]}:{{24{mem_rdata[23]}},mem_rdata[23:16]})
                            :   (mem_mem_re==4'b1000)?(mem_mem_rsignal?{24'b0,mem_rdata[31:24]}:{{24{mem_rdata[31]}},mem_rdata[31:24]})
                            :'b0;
    assign mem_to_wb_mem_re   = |mem_mem_re  ;
    assign mem_to_wb_rf_wdata = (|mem_mem_re)?mem_rdata_temp:mem_alu_res ;
    assign mem_to_wb_rf_waddr = mem_rf_waddr;
    assign mem_to_wb_rf_we    = mem_rf_we   ;
    assign mem_to_wb_pc       = mem_pc      ;
    assign mem_to_wb_inst     = mem_inst    ;
endmodule