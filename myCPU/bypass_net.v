module bypass_net(
    input        clk,
    input        rst,
    input[4:0]   id_rf_raddr1,
    input[4:0]   id_rf_raddr2,
    input[31:0]  id_src1,
    input[31:0]  id_src2,
    input        exu_active,
    input        ex_mem_re,
    input        ex_rf_we,
    input[31:0]  ex_rf_wdata,
    input[4:0]   ex_rf_waddr,
    input        mem_mem_re,
    input        mem_rf_we,
    input[31:0]  mem_rf_wdata,
    input[4:0]   mem_rf_waddr,
    input        wb_rf_we,
    input[31:0]  wb_rf_wdata,
    input[4:0]   wb_rf_waddr,
    output       idu_nready_go,
    output[31:0] id_to_ex_mem_wdata,
    output[31:0] idu_src1,
    output[31:0] idu_src2
);
    wire        src1_ex_hazard;
    wire        src1_mem_hazard;
    wire        src1_wb_hazard;
    wire        src2_ex_hazard;
    wire        src2_mem_hazard;
    wire        src2_wb_hazard;
    reg         ex_mem_re_r;
    assign      idu_nready_go = ex_rf_we&(ex_rf_waddr==id_rf_raddr1)&(ex_mem_re)
                            ;


    assign      src1_ex_hazard  = ex_rf_we&(ex_rf_waddr==id_rf_raddr1)&(~ex_mem_re);
    assign      src1_mem_hazard = mem_rf_we &(mem_rf_waddr==id_rf_raddr1);
    assign      src1_wb_hazard  = wb_rf_we &(wb_rf_waddr==id_rf_raddr1);

    assign      src2_ex_hazard  = ex_rf_we&(ex_rf_waddr==id_rf_raddr2)&(~ex_mem_re);
    assign      src2_mem_hazard = mem_rf_we &(mem_rf_waddr==id_rf_raddr2);
    assign      src2_wb_hazard  = wb_rf_we &(wb_rf_waddr==id_rf_raddr2);

    assign      idu_src1 = src1_ex_hazard?ex_rf_wdata
                            :(src1_mem_hazard)?mem_rf_wdata
                            :src1_wb_hazard?wb_rf_wdata
                            :id_src1;

    assign      idu_src2 = src2_ex_hazard?ex_rf_wdata
                        :(src2_mem_hazard)?mem_rf_wdata
                        :src2_wb_hazard?wb_rf_wdata
                        :id_src2;
    assign      id_to_ex_mem_wdata = idu_src2;
endmodule