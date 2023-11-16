//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
//
// Library:
// Filename: ipsxe_floating_point_multiplier_v1_0.v
// Function: This module multiplies the mantissa parts of the floating-point
//           numbers a and b without rounding.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_multiplier_single_v1_0 #(parameter EXP_WIDTH = 8, MAN_WIDTH = 23, APM_USAGE = 0, LATENCY_CONFIG = 1, PIPE_STAGE_NUM_MAX = 1) (
    input i_clk,
    input i_aclken,
    input i_rst_n,
    input [(1+EXP_WIDTH+MAN_WIDTH)-1:0] i_a,
    input [(1+EXP_WIDTH+MAN_WIDTH)-1:0] i_b,
    output [2*(MAN_WIDTH+1) + (EXP_WIDTH+1):0] o_a_mul_b
);

localparam WIDTH = 1+EXP_WIDTH+MAN_WIDTH; // floating-point data width

wire a_mul_b_sign, a_mul_b_sign_dly2;
wire [(EXP_WIDTH+1)-1:0] a_mul_b_exp, a_mul_b_exp_dly2;

// sign
assign a_mul_b_sign = i_a[WIDTH-1] ^ i_b[WIDTH-1];
assign o_a_mul_b[2*(MAN_WIDTH+1) + (EXP_WIDTH+1)] = a_mul_b_sign_dly2;
// exponent
assign a_mul_b_exp = i_a[MAN_WIDTH+:EXP_WIDTH] + i_b[MAN_WIDTH+:EXP_WIDTH];
assign o_a_mul_b[2*(MAN_WIDTH+1)+:(EXP_WIDTH+1)] = a_mul_b_exp_dly2; // o_a_mul_b[56:48] - 2*127 = real exp of i_a*i_b, whose range is [-252, 254]. range of o_a_mul_b[56:48] is [2, 508]
// mantissa
// initially we directly do the multiplication:
// assign a_mul_b = {1'b1, i_a[MAN_WIDTH-1:0]} * {1'b1, i_b[MAN_WIDTH-1:0]};
// however, the above calculation brings too much latency, so we divide a_mul_b into a_mul_b_hi and a_mul_b_lo
//ipsxe_floating_point_4_2_multiplier_fma_v1_0 #(MAN_WIDTH + 1, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 1, 1 + (EXP_WIDTH+1), APM_USAGE) u_4_2_multiplier_a_mul_b(
//    .i_clk(i_clk),
//    .i_aclken(i_aclken),
//    .i_rst_n(i_rst_n),
//    .i_a({1'b1, i_a[MAN_WIDTH-1:0]}),
//    .i_b({1'b1, i_b[MAN_WIDTH-1:0]}),
//    .i_user({a_mul_b_sign     , a_mul_b_exp     }),
//    .o_user({a_mul_b_sign_dly2, a_mul_b_exp_dly2}),
//    .o_product(o_a_mul_b[2*(MAN_WIDTH+1)-1:0])
//);



wire    [MAN_WIDTH:0]       i_a_mul;
wire    [MAN_WIDTH:0]       i_b_mul;
assign i_a_mul =  {1'b1, i_a[MAN_WIDTH-1:0]};
assign i_b_mul =  {1'b1, i_b[MAN_WIDTH-1:0]};

wire    [16:0]                  i_b_mul_lo;
wire    [MAN_WIDTH-17:0]        i_b_mul_hi;
wire    [2*MAN_WIDTH-16:0]      p_hi;
assign i_b_mul_lo = i_b_mul[16:0];
assign i_b_mul_hi = i_b_mul[MAN_WIDTH:17];
assign p_hi = i_a_mul * i_b_mul_hi;

wire    [MAN_WIDTH:0]            i_a_mul_dly1;
wire    [16:0]            i_b_mul_lo_dly1;
wire    [2*MAN_WIDTH-16:0]       p_hi_dly1;
ipsxe_floating_point_register_v1_0 #(MAN_WIDTH+1)         u_a_reg     (i_clk, i_aclken, i_rst_n, i_a_mul, i_a_mul_dly1);
ipsxe_floating_point_register_v1_0 #(17)                u_b_mul_lo  (i_clk, i_aclken, i_rst_n, i_b_mul_lo, i_b_mul_lo_dly1);
ipsxe_floating_point_register_v1_0 #(2*MAN_WIDTH-15)    u_p_hi      (i_clk, i_aclken, i_rst_n, p_hi, p_hi_dly1);

GTP_APM_E2 #(
.GRS_EN ("TRUE"),
.USE_POSTADD (1), //enable postadder 0/1
.USE_PREADD (0),  //enable preadder 0/1
.PREADD_REG (0), //preadder reg 0/1

.CXO_REG (2'b0), // X¼¶ÁªÊä³ö¼Ä´æÆ÷ÑÓ³Ù, 0/1/2/3
.XB_REG (1'b0),
.X_REG (1),
.Y_REG (1),
.Z_REG (1),
.MULT_REG (1), //Ê¹ÓÃMULT_REG
.P_REG (1), //²»Ê¹ÄÜÀÛ¼Ó¼Ä´æÆ÷
.MODEY_REG (0),
.MODEZ_REG (0),
.MODEIN_REG (0),
.X_SEL (0),
.XB_SEL (0),
.ASYNC_RST (0),
.USE_SIMD (0),
.P_INIT0 (48'd0),
.P_INIT1 (48'd0),
.ROUNDMODE_SEL (0),
.CPO_REG (0), // PO,CPO²»Ê¹ÄÜ¼Ä´æÆ÷
.USE_ACCLOW (0), // ÀÛ¼Ó½öÊ¹ÓÃµÍ17bit×÷Îª·´À¡²»Ê¹ÄÜ
.CIN_SEL (0) // ²»Ñ¡ÔñCPI×÷ÎªÀÛ¼ÓµÄÊäÈë
)
u0_GTP_APM_E2
(
.P(o_a_mul_b[2*(MAN_WIDTH+1)-1:0]),
.CPO(),
.COUT(),
.CXO(),
.CXBO(),
.X(i_a_mul),
.CXI(),
.CXBI(),
.Y(i_b_mul_lo),
.Z({p_hi_dly1, {17{1'b0}}}),
.CPI(),
.CIN(),
.XB (),
.MODEIN(5'b00010),
.MODEY(3'b001),
.MODEZ(4'b0010),
.CLK(i_clk),
.RSTX(!i_rst_n),
.RSTXB(!i_rst_n),
.RSTY(!i_rst_n),
.RSTZ(!i_rst_n),
.RSTM(!i_rst_n),
.RSTP(!i_rst_n),
.RSTPRE(!i_rst_n),
.RSTMODEIN(!i_rst_n),
.RSTMODEY(!i_rst_n),
.RSTMODEZ(!i_rst_n),
.CEX1(1'b1),
.CEX2(1'b0),
.CEX3(1'b0),
.CEXB(1'b0),
.CEY1(1'b1),
.CEY2(1'b0),
.CEZ(1'b1),
.CEM(1'b1),
.CEP(1'b1),
.CEPRE(1'b0),
.CEMODEIN(1'b0),
.CEMODEY(1'b0),
.CEMODEZ(1'b0)
);

wire a_mul_b_sign_dly0, a_mul_b_sign_dly1;
wire [(EXP_WIDTH+1)-1:0] a_mul_b_exp_dly0, a_mul_b_exp_dly1;

ipsxe_floating_point_register_v1_0 #(1) u_a_mul_b_sign_dly0 (i_clk, i_aclken, i_rst_n, a_mul_b_sign, a_mul_b_sign_dly0);
ipsxe_floating_point_register_v1_0 #(1) u_a_mul_b_sign_dly1 (i_clk, i_aclken, i_rst_n, a_mul_b_sign_dly0, a_mul_b_sign_dly1);
ipsxe_floating_point_register_v1_0 #(1) u_a_mul_b_sign_dly2 (i_clk, i_aclken, i_rst_n, a_mul_b_sign_dly1, a_mul_b_sign_dly2);
ipsxe_floating_point_register_v1_0 #(EXP_WIDTH+1) u_a_mul_b_exp_dly0 (i_clk, i_aclken, i_rst_n, a_mul_b_exp, a_mul_b_exp_dly0);
ipsxe_floating_point_register_v1_0 #(EXP_WIDTH+1) u_a_mul_b_exp_dly1 (i_clk, i_aclken, i_rst_n, a_mul_b_exp_dly0, a_mul_b_exp_dly1);
ipsxe_floating_point_register_v1_0 #(EXP_WIDTH+1) u_a_mul_b_exp_dly2 (i_clk, i_aclken, i_rst_n, a_mul_b_exp_dly1, a_mul_b_exp_dly2);












endmodule
