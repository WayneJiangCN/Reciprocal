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

module ipsxe_floating_point_multiplier_double_v1_0 #(parameter EXP_WIDTH = 8, MAN_WIDTH = 23, APM_USAGE = 0, LATENCY_CONFIG = 1, PIPE_STAGE_NUM_MAX = 1) (
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


sm53b u_sm53b
    (
	.ce     (1'b1),
	.rst    (!i_rst_n),
	.clk    (i_clk),
	.a      ({1'b1, i_a[MAN_WIDTH-1:0]}),
	.b      ({1'b1, i_b[MAN_WIDTH-1:0]}),
	.p      (o_a_mul_b[2*(MAN_WIDTH+1)-1:0])
    );



wire a_mul_b_sign_dly0, a_mul_b_sign_dly1, a_mul_b_sign_temp;
wire [(EXP_WIDTH+1)-1:0] a_mul_b_exp_dly0, a_mul_b_exp_dly1, a_mul_b_exp_temp;

//ipsxe_floating_point_register_v1_0 #(1) u_a_mul_b_sign_dly_temp (i_clk, i_aclken, i_rst_n, a_mul_b_sign, a_mul_b_sign_temp);
//ipsxe_floating_point_register_v1_0 #(1) u_a_mul_b_sign_dly0 (i_clk, i_aclken, i_rst_n, a_mul_b_sign_temp, a_mul_b_sign_dly0);
//ipsxe_floating_point_register_v1_0 #(1) u_a_mul_b_sign_dly1 (i_clk, i_aclken, i_rst_n, a_mul_b_sign_dly0, a_mul_b_sign_dly1);
//ipsxe_floating_point_register_v1_0 #(1) u_a_mul_b_sign_dly2 (i_clk, i_aclken, i_rst_n, a_mul_b_sign_dly1, a_mul_b_sign_dly2);
//ipsxe_floating_point_register_v1_0 #(EXP_WIDTH+1) u_a_mul_b_exp_dly0 (i_clk, i_aclken, i_rst_n, a_mul_b_exp, a_mul_b_exp_dly0);
//ipsxe_floating_point_register_v1_0 #(EXP_WIDTH+1) u_a_mul_b_exp_dly1 (i_clk, i_aclken, i_rst_n, a_mul_b_exp_dly0, a_mul_b_exp_dly1);
//ipsxe_floating_point_register_v1_0 #(EXP_WIDTH+1) u_a_mul_b_exp_dly2 (i_clk, i_aclken, i_rst_n, a_mul_b_exp_dly1, a_mul_b_exp_dly2);



ipm_distributed_shiftregister_wrapper_v1_3 #(4, 1) u_sr_u_a_mul_b_sign_dly2(
    .din(a_mul_b_sign),
    .clk(i_clk),      // input
    .i_aclken(i_aclken),
    .rst(~i_rst_n),      // input
    .dout(a_mul_b_sign_dly2)
);


ipm_distributed_shiftregister_wrapper_v1_3 #(4, (EXP_WIDTH+1)) u_reg_a_mul_b_exp(
    .din(a_mul_b_exp),
    .clk(i_clk),      // input
    .i_aclken(i_aclken),
    .rst(~i_rst_n),      // input
    .dout(a_mul_b_exp_dly2)
);



endmodule
