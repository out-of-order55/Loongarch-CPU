module ifu (
    input  wire             clk             ,
    input  wire             rst             ,
    input  wire             i_id_ready      ,
    output wire             if_to_id_valid  ,
    input wire              bjp_stall       ,
    input wire              bjp_taken       ,
    input wire[31:0]        bjp_target      ,
    input wire[31:0]        inst_sram_rdata ,

    output wire             inst_sram_en    ,
    output wire[31:0]       inst_sram_addr  ,
    output wire[31:0]       if_to_id_pc     ,
    output wire[31:0]       if_to_id_inst         
);
    reg[31:0]       pc;
    wire[31:0]      seq_pc;
    wire[31:0]      nextpc;
    wire[31:0]      if_inst;
    wire            pre_if_ready_go;
    wire            pre_if_valid;
    reg             valid_r;
    wire             if_ready;
    wire            if_ready_go;
    always @(posedge clk) begin
        if(rst)begin
            valid_r <= 'b0;
        end
        else if(if_ready)begin
            valid_r <= pre_if_valid;
        end
    end
    assign seq_pc       = pc + 3'h4;
    assign nextpc       = bjp_taken ? bjp_target : seq_pc;

    always @(posedge clk) begin
        if (rst) begin
            pc <= 32'h1bfffffc;    
        end
        else if(pre_if_valid&if_ready)begin
            pc <= nextpc;
        end
    end
    assign  if_ready_go = 'b1;
    assign  if_ready    = (!valid_r)|(i_id_ready&(if_ready_go));
    assign  pre_if_ready_go = !bjp_stall;
    assign  pre_if_valid  = (!rst)&pre_if_ready_go;

    assign  if_inst         = inst_sram_rdata;
    assign  if_to_id_valid  = valid_r&if_ready_go; 
    
    assign  if_to_id_pc     = valid_r?pc:'b0;
    assign  if_to_id_inst   = valid_r?if_inst:'b0;

    assign  inst_sram_en    = pre_if_valid&if_ready;
    assign  inst_sram_addr  = nextpc;
// id_reg u_id_reg(
//     .clk         (clk),
//     .rst         (rst),
//     .i_if_valid  (i_if_valid),
//     .br_taken    (bjp_taken),
//     .i_id_ready  (i_id_ready),
//     .o_if_ready  (o_if_ready),
//     .o_id_valid  (o_id_valid),
//     .if_pc       (pc),
//     .if_inst     (if_inst),
//     .id_pc       (id_pc),
//     .id_inst     (id_inst)
// );
endmodule