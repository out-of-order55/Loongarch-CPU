module mul_div_alu(
    input       clk,
    input       rst,
    input[31:0] src1,
    input[31:0] src2,
    input[6:0]  alu_op,
    output       cul_done,
    output[31:0] res   
);
    wire        mul;
    wire        mulh;
    wire        mulhu;
    wire        div;
    wire        divu;
    wire        mod;
    wire        modu;
    wire[63:0]  div_data_s;
    wire[63:0]  div_data_us;
    wire[63:0]  mul_data_s;
    wire[63:0]  mul_data_us;
    wire[63:0]  mul_res;
    wire[32:0]  mul_src1;
    wire[32:0]  mul_src2;
    wire        tready_op1;
    wire        tready_op2;
    wire        tready1;
    wire        tready2;
    wire        tready3;
    wire        tready4;
    reg         tvalid;
    reg         div_latch;
    reg         mul_done;
    reg         mul_done_r;
    wire        div_done_s;
    wire        div_done_us;
    wire        mul_done_p;
    assign mul   = alu_op[0];     
    assign mulh  = alu_op[1];       
    assign mulhu = alu_op[2];   
    assign div   = alu_op[3];   
    assign divu  = alu_op[4];   
    assign mod   = alu_op[5];   
    assign modu  = alu_op[6];
    always @(posedge clk) begin
        if(rst)begin
            mul_done_r <= 'b0;
        end
        else begin
            mul_done_r <= mul_done;
        end
    end
    always @(posedge clk) begin
        if(rst)begin
            mul_done <= 'b0;
        end
        else if(mul|mulh|mulhu)begin
            mul_done <= 'b1;
        end
        else begin
            mul_done <= 'b0;
        end
    end
    always @(posedge clk) begin
        if(rst)begin
            tvalid <= 'b0;
        end
        else if(tvalid&tready_op1&tready_op2)begin
            tvalid <= 'b0;
        end
        else if((div|mod|divu|modu)&(~div_latch))begin
            tvalid <= 'b1;
        end
    end
    always @(posedge clk) begin
        if(rst)begin
            div_latch <= 'b0;
        end
        else if(tvalid&tready_op1&tready_op2)begin
            div_latch <= 'b1;
        end
        else if(cul_done)begin
            div_latch <= 'b0;
        end
    end
div_gen_0 signed_div (
  .aclk(clk),                                      // input wire aclk
  .s_axis_divisor_tvalid(tvalid),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tready(tready2),    // output wire s_axis_divisor_tready
  .s_axis_divisor_tdata(src2), // input wire [31 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(tvalid),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tready(tready1),  // output wire s_axis_dividend_tready
  .s_axis_dividend_tdata(src1),    // input wire [31 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(div_done_s),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(div_data_s)            // output wire [63 : 0] m_axis_dout_tdata
);
div_gen_1 usigned_div (
  .aclk(clk),                                      // input wire aclk
  .s_axis_divisor_tvalid(tvalid),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tready(tready4),    // output wire s_axis_divisor_tready
  .s_axis_divisor_tdata(src2), // input wire [31 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(tvalid),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tready(tready3),  // output wire s_axis_dividend_tready
  .s_axis_dividend_tdata(src1),    // input wire [31 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(div_done_us),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(div_data_us)            // output wire [63 : 0] m_axis_dout_tdata
); 
booth_multiplier booth_multiplier(
	.clk(clk),
	.rst_n(!rst),
	.data1(mul_src1),
	.data2(mul_src2),
	.res(mul_res)
);
    assign mul_done_p  = mul_done&(~mul_done_r);
    assign mul_src1    = (mul|mulh)?{src1[31],src1}
                        :(mulhu)?{'b0,src1}
                        :'b0;
    assign mul_src2    = (mul|mulh)?{src2[31],src2}
                        :(mulhu)?{'b0,src2}
                        :'b0;
    assign mul_data_s  = $signed(src1)*$signed(src2);
    assign mul_data_us = src1*src2;   
    assign tready_op1 = (div|mod)? tready1
                        :(divu|modu)?tready3
                        :'b0;
    assign tready_op2 = (div|mod)? tready2
                        :(divu|modu)?tready4
                        :'b0;
    assign res = div ? div_data_s[63:32]
                :mod ? div_data_s[31:0]
                :divu? div_data_us[63:32]
                :modu? div_data_us[31:0]
                :mul?  mul_res[31:0]
                :mulh? mul_res[63:32]
                :mulhu?mul_res[63:32]
                :'b0;
    assign  cul_done =   (div|mod) ? div_done_s
                        :(divu|modu)?div_done_us
                        :(mul|mulh|mulhu)?mul_done_p
                        :'b0;
endmodule