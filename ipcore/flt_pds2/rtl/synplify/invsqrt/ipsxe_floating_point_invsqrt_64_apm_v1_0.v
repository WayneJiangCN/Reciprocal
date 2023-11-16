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
// Filename: ipsxe_floating_point_invsqrt_64_v1_0.v
// Function: This module calculates the inverse square-root
//           of the double precision floating-point numbers.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_invsqrt_64_apm_v1_0 #(parameter EXP_WIDTH = 11, MAN_WIDTH = 52, RNE = 2, RNE1 = 49, RNE2 = 44, LATENCY_CONFIG = 1, APM_USAGE = 2) (
    input i_clk,
    input i_aclken,
    input i_rst_n,
    input i_valid,
    input [(1+EXP_WIDTH+MAN_WIDTH)-1:0] i_x_norm_or_denorm,
    output o_valid,
    output [(1+EXP_WIDTH+MAN_WIDTH)-1:0] o_invsqrt_x,
    output o_invalid_op,
    output o_divide_by_zero
);
// This module calculates the reciprocal square-root (o_invsqrt_x) of the input single precision floating-point number (i_x_norm_or_denorm),
// using the Taylor-series expansion
// According to the precision requirement, this "single precision" module uses the first 6 terms of the Taylor-series
// Reference paper: Floating-Point Inverse Square Root Algorithm Based on Taylor-Series Expansion, Author: Jianglin Wei et al.

// RNE, RNE1, RNE2 are the round-off bits at different pipeline stages
// MAN_WIDTH, RNE, RNE1, RNE2 should satisfy:
// 1. ((MAN_WIDTH+1)+RNE+RNE1)/4 is an integer
// 2. ((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/4 is an integer
// 3. these two expressions cannot be greater than MAN_WIDTH

localparam WIDTH = 1+EXP_WIDTH+MAN_WIDTH;
localparam PIPE_STAGE_NUM_MAX = 24; // the last pipeline stage of this module

wire [8:0] a0_hi;
wire [((MAN_WIDTH+1)+RNE-9)-1:0] a0_lo;
wire [((MAN_WIDTH+1)+RNE+RNE1)/2-1-1:0] a1;
wire [7:0] a2_hi;
wire [(((MAN_WIDTH+1)+RNE+RNE1)/2)-9-1:0] a2_lo;
wire [((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2-1-1:0] a3, a4;
wire [((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2/2-2-1:0] a5, a6;
wire x_is_denorm, i_valid_dly1;
wire [WIDTH-1:0] x, x_dly1;
wire x_is_neg, x_is_zero, x_is_nan_zero_neg, x_is_pos_inf, x_is_nan_zero_neg_dly8, x_is_pos_inf_dly8;
wire [EXP_WIDTH-1:0] invsqrt_x_exp_minus1, invsqrt_x_exp_plus1, invsqrt_x_exp_minus1_dly1, invsqrt_x_exp_plus1_dly1;
wire [((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2-1-1:0] a4_plus_a6_z, group1;
wire [(((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2-15-1:0] z_rne2_dlt15zeros;
wire [(((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2-17-1:0] z_group1_rne2_dlt17zeros;
wire [(((MAN_WIDTH+1)+RNE+RNE1)/2)-17-1:0] z_group1_dlt17zeros;
wire [(((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2-9-1:0] a3_y_rne2_dlt9zeros;
wire [47:0] a2lo_minus_a3y;
wire [7:0] a2_hi_plus_cin1;
wire [47:0] group2_lo, group2_lo_dly1;
wire [7:0] group2_hi;
wire [(((MAN_WIDTH+1)+RNE+RNE1)/2)-1-1:0] group2;
wire [47:0] a0lo_minus_a1y;
wire [47:0] a0lo_minus_a1y_plus_zgroup2;
wire [9:0] a0_hi_plus_cin1;
wire [47:0] group3_lo, group3_lo_dly1;
wire [9:0] a0_hi_plus_cin1_cin2;
wire [9:0] group3_hi;
wire [(1+(MAN_WIDTH+1))-1:0] group3;
wire [(MAN_WIDTH+1)+RNE+RNE1-9-1:0] a1_y_rne1_dlt9zeros;
wire [((MAN_WIDTH+1)+RNE+RNE1)/2-15-1:0] z_dlt15zeros;
wire [((MAN_WIDTH+1)+RNE+RNE1)/2-9-1:0] a3_y_dlt9zeros;
wire [(MAN_WIDTH+1)+RNE-9-1:0] a1_y_dlt9zeros;
wire [(MAN_WIDTH+1)+RNE+RNE1-17-1:0] z_group2_rne1_dlt17zeros;
wire [(MAN_WIDTH+1)+RNE-17-1:0] z_group2_dlt17zeros;
wire [1 + (MAN_WIDTH+1)-1:0] invsqrt_x_taylor_dly1;
wire [WIDTH-1:0] invsqrt_x_valid_or_not;
wire [4:0] special_cases, special_cases_dly1, special_cases_dly2, special_cases_dly3, special_cases_dly4, special_cases_dly5, special_cases_dly6, special_cases_dly7, special_cases_dly8, special_cases_dly9, special_cases_dly10, special_cases_dly11, special_cases_dly12, special_cases_dly13, special_cases_dly14, special_cases_dly15, special_cases_dly16, special_cases_dly17, special_cases_dly18, special_cases_dly19, special_cases_dly20, special_cases_dly21, special_cases_dly22;
wire x_minus_a_is_pos, x_minus_a_is_pos_dly1, x_minus_a_is_pos_dly2, x_minus_a_is_pos_dly3, x_minus_a_is_pos_dly4, x_minus_a_is_pos_dly5, x_minus_a_is_pos_dly6, x_minus_a_is_pos_dly7, x_minus_a_is_pos_dly8, x_minus_a_is_pos_dly9, x_minus_a_is_pos_dly10, x_minus_a_is_pos_dly11, x_minus_a_is_pos_dly12, x_minus_a_is_pos_dly13, x_minus_a_is_pos_dly14, x_minus_a_is_pos_dly15, x_minus_a_is_pos_dly16, x_minus_a_is_pos_dly17, x_minus_a_is_pos_dly18;
wire [EXP_WIDTH-1:0] invsqrt_x_exp, invsqrt_x_exp_dly1, invsqrt_x_exp_dly2, invsqrt_x_exp_dly3, invsqrt_x_exp_dly4, invsqrt_x_exp_dly5, invsqrt_x_exp_dly6, invsqrt_x_exp_dly7, invsqrt_x_exp_dly8, invsqrt_x_exp_dly9, invsqrt_x_exp_dly10, invsqrt_x_exp_dly11, invsqrt_x_exp_dly12, invsqrt_x_exp_dly13, invsqrt_x_exp_dly14, invsqrt_x_exp_dly15, invsqrt_x_exp_dly16, invsqrt_x_exp_dly17, invsqrt_x_exp_dly18, invsqrt_x_exp_dly19, invsqrt_x_exp_dly20, invsqrt_x_exp_dly21, invsqrt_x_exp_dly22, invsqrt_x_exp_dly23;
wire [MAN_WIDTH-7-1:0] y_dlt7zeros, y_dlt7zeros_dly1, y_dlt7zeros_dly2, y_dlt7zeros_dly3, y_dlt7zeros_dly4, y_dlt7zeros_dly5, y_dlt7zeros_dly6, y_dlt7zeros_dly7, y_dlt7zeros_dly8, y_dlt7zeros_dly9, y_dlt7zeros_dly10, y_dlt7zeros_dly11, y_dlt7zeros_dly12;
wire [7:0] x_hi8, x_hi8_dly1, x_hi8_dly2, x_hi8_dly3, x_hi8_dly4, x_hi8_dly5, x_hi8_dly6, x_hi8_dly7, x_hi8_dly8, x_hi8_dly9, x_hi8_dly10, x_hi8_dly11, x_hi8_dly12, x_hi8_dly13, x_hi8_dly14, x_hi8_dly15, x_hi8_dly16, x_hi8_dly17, x_hi8_dly18, x_hi8_dly19;
wire no_outreg_o_valid;
wire [(((MAN_WIDTH+1)+RNE+RNE1)/2)+1-15-1:0] z_1_dlt15zeros, z_1_dlt15zeros_dly1, z_1_dlt15zeros_dly2, z_1_dlt15zeros_dly3, z_1_dlt15zeros_dly4, z_1_dlt15zeros_dly5, z_1_dlt15zeros_dly6, z_1_dlt15zeros_dly7;
wire [(1+EXP_WIDTH+MAN_WIDTH)-1:0] no_outreg_o_invsqrt_x;
wire no_outreg_o_invalid_op;
wire no_outreg_o_divide_by_zero;

// determine whether x is a denormalized number, if so, set it to zero
assign x_is_denorm = (i_x_norm_or_denorm[WIDTH-2-:EXP_WIDTH] == {EXP_WIDTH{1'b0}}) & (i_x_norm_or_denorm[MAN_WIDTH-1:0] != {MAN_WIDTH{1'b0}});
assign x = x_is_denorm ? {WIDTH{1'b0}} : i_x_norm_or_denorm;

// determine whether x is a special floating point number, such as NaN or Inf
assign x_is_neg = (x_dly1[WIDTH-1] == 1'b1) & (((x_dly1[WIDTH-2-:EXP_WIDTH] == {EXP_WIDTH{1'b1}}) & (x_dly1[MAN_WIDTH-1:0] == {MAN_WIDTH{1'b0}})) | ((x_dly1[WIDTH-2-:EXP_WIDTH] <= ({EXP_WIDTH{1'b1}} - 1'b1)) & (x_dly1[WIDTH-2-:EXP_WIDTH] >= 1'b1)));
assign x_is_zero = (x_dly1[WIDTH-2:0] == {(WIDTH-1){1'b0}});
assign x_is_nan_zero_neg = ((x_dly1[WIDTH-2-:EXP_WIDTH] == {EXP_WIDTH{1'b1}}) & (x_dly1[MAN_WIDTH-1:0] != {MAN_WIDTH{1'b0}})) | x_is_zero | x_is_neg;
assign x_is_pos_inf = (x_dly1[WIDTH-1] == 1'b0) & (x_dly1[WIDTH-2-:EXP_WIDTH] == {EXP_WIDTH{1'b1}}) & (x_dly1[MAN_WIDTH-1:0] == {MAN_WIDTH{1'b0}});

// calculate the square-root of exp
ipsxe_floating_point_exp_invsqrt_minus1_v1_0 #(EXP_WIDTH) u_exp_invsqrt_minus1(
        .i_exp(x_dly1[WIDTH-2-:EXP_WIDTH]),
        .o_exp_invsqrt_minus1(invsqrt_x_exp)
);

// pipeline stage 1
ipsxe_floating_point_latency_config_v1_0 #((1 + WIDTH), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 1) u_reg_stage1(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({i_valid     , x     }),
    .o_q({i_valid_dly1, x_dly1})
);

// next, calculate the Taylor-series expression, but in several pipeline stages
// assign a = {x[MAN_WIDTH-1-:7], 1'b1};
// o_invsqrt_x = a0 - a1 * (x - a) + a2 * (x - a)^2 - a3 * (x - a)^3 + a4 * (x - a)^4 - a5 * (x - a)^5 + a6 * (x - a)^6
// set y = x - a, z = y^2
// o_invsqrt_x = a0 - a1 * y + a2 * y^2 - a3 * y^3 + a4 * y^4 - a5 * y^5 + a6 * y^6
//             = a0 - a1 * y + z * (a2 - a3 * y + z * (a4 - a5 * y + a6 * z))
// note: the post-fix _rne or _rne1 or _rne2 means this signal keeps RNE or RNE1 or RNE2 more bits,
// and these bits will be rounded off later by calling the "ipsxe_floating_point_rne_v1_0" module

// if x minus a is positive, then x_minus_a_is_pos is 1
assign x_minus_a_is_pos = x_dly1[MAN_WIDTH-8]; // which means: x[MAN_WIDTH-1:0] >= {a, {(MAN_WIDTH-8){1'b0}}};
// the selection according to x_minus_a_is_pos makes sure that y is positive
// y = (x - a) or (a - x)
assign y_dlt7zeros = x_minus_a_is_pos ? {1'b0, x_dly1[MAN_WIDTH-9:0]} : ({1'b1, {(MAN_WIDTH-8){1'b0}}} - {1'b0, x_dly1[MAN_WIDTH-9:0]}); // which means: x_minus_a_is_pos ? x[MAN_WIDTH-1:0] - {a, {(MAN_WIDTH-7){1'b0}}} : {a, {(MAN_WIDTH-7){1'b0}}} - x[MAN_WIDTH-1:0];

assign x_hi8 = x_dly1[MAN_WIDTH-:8];

// gather all special cases signals
assign special_cases = {i_valid_dly1, x_is_neg, x_is_zero, x_is_nan_zero_neg, x_is_pos_inf};

// pipeline stage 2
ipsxe_floating_point_latency_config_v1_0 #((5*1 + 1 + EXP_WIDTH + MAN_WIDTH-7 + 8), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 2) u_reg_stage2(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases     , x_minus_a_is_pos     , invsqrt_x_exp     , y_dlt7zeros     , x_hi8     }), // input
    .o_q({special_cases_dly1, x_minus_a_is_pos_dly1, invsqrt_x_exp_dly1, y_dlt7zeros_dly1, x_hi8_dly1})  // output
);

// pipeline stage 3
ipsxe_floating_point_latency_config_v1_0 #((5*1 + 1 + EXP_WIDTH + MAN_WIDTH-7 + 8), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 3) u_reg_stage3(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly1, x_minus_a_is_pos_dly1, invsqrt_x_exp_dly1, y_dlt7zeros_dly1, x_hi8_dly1}), // input
    .o_q({special_cases_dly2, x_minus_a_is_pos_dly2, invsqrt_x_exp_dly2, y_dlt7zeros_dly2, x_hi8_dly2})  // output
);

// pipeline stage 4
ipsxe_floating_point_latency_config_v1_0 #((5*1 + 1 + EXP_WIDTH + MAN_WIDTH-7 + 8), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 4) u_reg_stage4(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly2, x_minus_a_is_pos_dly2, invsqrt_x_exp_dly2, y_dlt7zeros_dly2, x_hi8_dly2}), // input
    .o_q({special_cases_dly3, x_minus_a_is_pos_dly3, invsqrt_x_exp_dly3, y_dlt7zeros_dly3, x_hi8_dly3})  // output
);

// pipeline stage 5
ipsxe_floating_point_latency_config_v1_0 #((5*1 + 1 + EXP_WIDTH + MAN_WIDTH-7 + 8), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 5) u_reg_stage5(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly3, x_minus_a_is_pos_dly3, invsqrt_x_exp_dly3, y_dlt7zeros_dly3, x_hi8_dly3}), // input
    .o_q({special_cases_dly4, x_minus_a_is_pos_dly4, invsqrt_x_exp_dly4, y_dlt7zeros_dly4, x_hi8_dly4})  // output
);

// z = y^2
// pipeline stages 2 3 4 5
y_y_mul u_y_y_mul (
  .a(y_dlt7zeros[MAN_WIDTH-7-1-:(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2-7)]),        // input [40:0]
  .b(y_dlt7zeros[MAN_WIDTH-7-1-:(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2-7)]),        // input [40:0]
  .clk(i_clk),    // input
  .rst(~i_rst_n),    // input
  .ce(1'b1),      // input
  .p(z_rne2_dlt15zeros)         // output [81:0]
);

// the lowest bits are useless for later calculation
assign z_1_dlt15zeros = z_rne2_dlt15zeros[(((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2-15-1:(RNE2-1)];

// a6
ipsxe_floating_point_a6_v1_0 u_a6(
    .i_x_hi8(x_hi8_dly4),
    .o_a6(a6)
);

// pipeline stage 6
ipsxe_floating_point_latency_config_v1_0 #((5*1 + 1 + EXP_WIDTH + MAN_WIDTH-7 + 8 + (((MAN_WIDTH+1)+RNE+RNE1)/2)+1-15), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 6) u_reg_stage6(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly4, x_minus_a_is_pos_dly4, invsqrt_x_exp_dly4, y_dlt7zeros_dly4, x_hi8_dly4, z_1_dlt15zeros     }), // input
    .o_q({special_cases_dly5, x_minus_a_is_pos_dly5, invsqrt_x_exp_dly5, y_dlt7zeros_dly5, x_hi8_dly5, z_1_dlt15zeros_dly1})  // output
);

// a3, a4, a5
ipsxe_floating_point_a3_a4_a5_v1_0 u_a3_a4_a5(
    .i_x_hi8(x_hi8_dly5),
    .o_a3(a3),
    .o_a4(a4),
    .o_a5(a5)
);

// pipeline stage 7
ipsxe_floating_point_latency_config_v1_0 #((5*1 + 1 + EXP_WIDTH + MAN_WIDTH-7 + 8 + (((MAN_WIDTH+1)+RNE+RNE1)/2)+1-15), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 7) u_reg_stage7(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly5, x_minus_a_is_pos_dly5, invsqrt_x_exp_dly5, y_dlt7zeros_dly5, x_hi8_dly5, z_1_dlt15zeros_dly1}), // input
    .o_q({special_cases_dly6, x_minus_a_is_pos_dly6, invsqrt_x_exp_dly6, y_dlt7zeros_dly6, x_hi8_dly6, z_1_dlt15zeros_dly2})  // output
);

// a4 + a6 * z
// pipeline stages 6 7
ipsxe_floating_point_apm_primitive_a4_plus_a6_z_v1_0 #(MAN_WIDTH, RNE, RNE1, RNE2, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX) u_a4_plus_a6_z (
    .i_clk(i_clk),
    .i_a4(a4),
    .i_a6(a6),
    .i_z(z_1_dlt15zeros[(((MAN_WIDTH+1)+RNE+RNE1)/2)+1-15-1-:(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2/2-15)]),
    .o_a4_plus_a6_z(a4_plus_a6_z)
);

// pipeline stage 8
ipsxe_floating_point_latency_config_v1_0 #((5*1 + 1 + EXP_WIDTH + MAN_WIDTH-7 + 8 + (((MAN_WIDTH+1)+RNE+RNE1)/2)+1-15), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 8) u_reg_stage8(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly6, x_minus_a_is_pos_dly6, invsqrt_x_exp_dly6, y_dlt7zeros_dly6, x_hi8_dly6, z_1_dlt15zeros_dly2}), // input
    .o_q({special_cases_dly7, x_minus_a_is_pos_dly7, invsqrt_x_exp_dly7, y_dlt7zeros_dly7, x_hi8_dly7, z_1_dlt15zeros_dly3})  // output
);

// a4_plus_a6_z +- a5 * y
// pipeline stages 7 8
ipsxe_floating_point_apm_primitive_a4a6z_minus_a5_y_v1_0 #(MAN_WIDTH, RNE, RNE1, RNE2, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX) u_a4a6z_minus_a5_y (
    .i_clk(i_clk),
    .i_a4_plus_a6_z(a4_plus_a6_z),
    .i_x_minus_a_is_pos(x_minus_a_is_pos_dly6),
    .i_a5(a5),
    .i_y(y_dlt7zeros_dly5[MAN_WIDTH-7-1-:(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2/2-7)]),
    .o_group1(group1)
);

// pipeline stage 9
ipsxe_floating_point_latency_config_v1_0 #((5*1 + 1 + EXP_WIDTH + MAN_WIDTH-7 + 8 + (((MAN_WIDTH+1)+RNE+RNE1)/2)+1-15), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 9) u_reg_stage9(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly7, x_minus_a_is_pos_dly7, invsqrt_x_exp_dly7, y_dlt7zeros_dly7, x_hi8_dly7, z_1_dlt15zeros_dly3}), // input
    .o_q({special_cases_dly8, x_minus_a_is_pos_dly8, invsqrt_x_exp_dly8, y_dlt7zeros_dly8, x_hi8_dly8, z_1_dlt15zeros_dly4})  // output
);

// pipeline stage 10
ipsxe_floating_point_latency_config_v1_0 #((5*1 + 1 + EXP_WIDTH + MAN_WIDTH-7 + 8 + (((MAN_WIDTH+1)+RNE+RNE1)/2)+1-15), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 10) u_reg_stage10(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly8, x_minus_a_is_pos_dly8, invsqrt_x_exp_dly8, y_dlt7zeros_dly8, x_hi8_dly8, z_1_dlt15zeros_dly4}), // input
    .o_q({special_cases_dly9, x_minus_a_is_pos_dly9, invsqrt_x_exp_dly9, y_dlt7zeros_dly9, x_hi8_dly9, z_1_dlt15zeros_dly5})  // output
);

// a3 * y
// pipeline stages 7 8 9 10
a3_y_mul u_a3_y_mul (
  .a(a3),        // input [46:0]
  .b(y_dlt7zeros_dly5[MAN_WIDTH-7-1-:(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2-7)]),        // input [40:0]
  .clk(i_clk),    // input
  .rst(~i_rst_n),    // input
  .ce(1'b1),      // input
  .p(a3_y_rne2_dlt9zeros)         // output [87:0]
);

// pipeline stage 11
ipsxe_floating_point_latency_config_v1_0 #((5*1 + 1 + EXP_WIDTH + MAN_WIDTH-7 + 8 + (((MAN_WIDTH+1)+RNE+RNE1)/2)+1-15), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 11) u_reg_stage11(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly9 , x_minus_a_is_pos_dly9 , invsqrt_x_exp_dly9 , y_dlt7zeros_dly9 , x_hi8_dly9 , z_1_dlt15zeros_dly5}), // input
    .o_q({special_cases_dly10, x_minus_a_is_pos_dly10, invsqrt_x_exp_dly10, y_dlt7zeros_dly10, x_hi8_dly10, z_1_dlt15zeros_dly6})  // output
);

// z * group1
// pipeline stages 9 10 11
z_group1_mul u_z_group1_mul (
  .a(z_1_dlt15zeros_dly3[(((MAN_WIDTH+1)+RNE+RNE1)/2)+1-15-1-:(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2-15)]),        // input [32:0]
  .b(group1),        // input [46:0]
  .clk(i_clk),    // input
  .rst(~i_rst_n),    // input
  .ce(1'b1),      // input
  .p(z_group1_rne2_dlt17zeros)         // output [79:0]
);

// a3 * y round to nearest even
// pipeline stage 11
ipsxe_floating_point_apm_primitive_a3_y_rne_v1_0 #(MAN_WIDTH, RNE, RNE1, RNE2, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX) u_a3_y_rne (
    .i_clk(i_clk),
    .i_a3_y_rne2_dlt9zeros(a3_y_rne2_dlt9zeros),
    .o_a3_y_dlt9zeros(a3_y_dlt9zeros)
);

// a2_lo
ipsxe_floating_point_a2_lo_v1_0 u_a2_lo(
    .i_x_hi8(x_hi8_dly10),
    .o_a2_lo(a2_lo)
);

// pipeline stage 12
ipsxe_floating_point_latency_config_v1_0 #((5*1 + 1 + EXP_WIDTH + MAN_WIDTH-7 + 8 + (((MAN_WIDTH+1)+RNE+RNE1)/2)+1-15), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 12) u_reg_stage12(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly10, x_minus_a_is_pos_dly10, invsqrt_x_exp_dly10, y_dlt7zeros_dly10, x_hi8_dly10, z_1_dlt15zeros_dly6}), // input
    .o_q({special_cases_dly11, x_minus_a_is_pos_dly11, invsqrt_x_exp_dly11, y_dlt7zeros_dly11, x_hi8_dly11, z_1_dlt15zeros_dly7})  // output
);

// z * group1 round to nearest even
// pipeline stage 12
ipsxe_floating_point_apm_primitive_z_group1_rne_v1_0 #(MAN_WIDTH, RNE, RNE1, RNE2, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX) u_z_group1_rne (
    .i_clk(i_clk),
    .i_z_group1_rne2_dlt17zeros(z_group1_rne2_dlt17zeros),
    .o_z_group1_dlt17zeros(z_group1_dlt17zeros)
);

// a2lo +- a3_y_dlt9zeros
// pipeline stage 12
ipsxe_floating_point_apm_primitive_a2lo_minus_a3_y_v1_0 #(MAN_WIDTH, RNE, RNE1, RNE2, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX) u_a2lo_minus_a3_y (
    .i_clk(i_clk),
    .i_a2_lo(a2_lo),
    .i_x_minus_a_is_pos(x_minus_a_is_pos_dly10),
    .i_a3_y_dlt9zeros(a3_y_dlt9zeros),
    .o_a2lo_minus_a3y(a2lo_minus_a3y)
);

// a2_hi
ipsxe_floating_point_a2_hi_v1_0 u_a2_hi(
    .i_x_hi8(x_hi8_dly11),
    .o_a2_hi(a2_hi)
);

// pipeline stage 13
ipsxe_floating_point_latency_config_v1_0 #((5*1 + 1 + EXP_WIDTH + MAN_WIDTH-7 + 8), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 13) u_reg_stage13(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly11, x_minus_a_is_pos_dly11, invsqrt_x_exp_dly11, y_dlt7zeros_dly11, x_hi8_dly11}), // input
    .o_q({special_cases_dly12, x_minus_a_is_pos_dly12, invsqrt_x_exp_dly12, y_dlt7zeros_dly12, x_hi8_dly12})  // output
);

// a2lo_minus_a3y_lo + z_group1
// pipeline stage 13
ipsxe_floating_point_apm_primitive_group2_lo_v1_0 #(MAN_WIDTH, RNE, RNE1, RNE2, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX) u_group2_lo (
    .i_clk(i_clk),
    .i_a2lo_minus_a3y_lo(a2lo_minus_a3y[42:0]),
    .i_z_group1_dlt17zeros(z_group1_dlt17zeros),
    .o_group2_lo(group2_lo)
);

// a2_hi + cin1
// pipeline stage 13
ipsxe_floating_point_apm_primitive_a2hi_plus_cin1_v1_0 #(MAN_WIDTH, RNE, RNE1, RNE2, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX) u_a2_hi_plus_cin1 (
    .i_clk(i_clk),
    .i_a2lo_minus_a3y_hi(a2lo_minus_a3y[47:43]),
    .i_a2_hi(a2_hi),
    .o_a2_hi_plus_cin1(a2_hi_plus_cin1)
);

// a1
ipsxe_floating_point_a1_v1_0 u_a1(
    .i_x_hi8(x_hi8_dly12),
    .o_a1(a1)
);

// pipeline stage 14
ipsxe_floating_point_latency_config_v1_0 #((5*1 + 1 + EXP_WIDTH + 8 + 48), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 14) u_reg_stage14(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly12, x_minus_a_is_pos_dly12, invsqrt_x_exp_dly12, x_hi8_dly12, group2_lo     }), // input
    .o_q({special_cases_dly13, x_minus_a_is_pos_dly13, invsqrt_x_exp_dly13, x_hi8_dly13, group2_lo_dly1})  // output
);

// a2_hi + cin1 + cin2
// pipeline stage 14
ipsxe_floating_point_apm_primitive_group2_hi_v1_0 #(MAN_WIDTH, RNE, RNE1, RNE2, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX) u_a2_hi_plus_cin1_cin2 (
    .i_clk(i_clk),
    .i_group2_lo_hi(group2_lo[47:43]),
    .i_a2_hi_plus_cin1(a2_hi_plus_cin1),
    .o_group2_hi(group2_hi)
);

assign group2 = {group2_hi, group2_lo_dly1[42:0]};

// round to nearest even: z_dlt15zeros
// pipeline stage 13 14
ipsxe_floating_point_apm_primitive_z_rne_v1_0 #(MAN_WIDTH, RNE, RNE1, RNE2, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX) u_z_rne (
    .i_clk(i_clk),
    .i_z_1_dlt15zeros(z_1_dlt15zeros_dly7),
    .o_z_dlt15zeros(z_dlt15zeros)
);

// pipeline stage 15
ipsxe_floating_point_latency_config_v1_0 #((5*1 + 1 + EXP_WIDTH + 8), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 15) u_reg_stage15(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly13, x_minus_a_is_pos_dly13, invsqrt_x_exp_dly13, x_hi8_dly13}), // input
    .o_q({special_cases_dly14, x_minus_a_is_pos_dly14, invsqrt_x_exp_dly14, x_hi8_dly14})  // output
);

// pipeline stage 16
ipsxe_floating_point_latency_config_v1_0 #((5*1 + 1 + EXP_WIDTH + 8), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 16) u_reg_stage16(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly14, x_minus_a_is_pos_dly14, invsqrt_x_exp_dly14, x_hi8_dly14}), // input
    .o_q({special_cases_dly15, x_minus_a_is_pos_dly15, invsqrt_x_exp_dly15, x_hi8_dly15})  // output
);

// pipeline stage 17
ipsxe_floating_point_latency_config_v1_0 #((5*1 + 1 + EXP_WIDTH + 8), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 17) u_reg_stage17(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly15, x_minus_a_is_pos_dly15, invsqrt_x_exp_dly15, x_hi8_dly15}), // input
    .o_q({special_cases_dly16, x_minus_a_is_pos_dly16, invsqrt_x_exp_dly16, x_hi8_dly16})  // output
);

// pipeline stage 18
ipsxe_floating_point_latency_config_v1_0 #((5*1 + 1 + EXP_WIDTH + 8), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 18) u_reg_stage18(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly16, x_minus_a_is_pos_dly16, invsqrt_x_exp_dly16, x_hi8_dly16}), // input
    .o_q({special_cases_dly17, x_minus_a_is_pos_dly17, invsqrt_x_exp_dly17, x_hi8_dly17})  // output
);

// a1 * y
a1_y_mul u_a1_y_mul (
  .a(a1),        // input [50:0]
  .b(y_dlt7zeros_dly12[MAN_WIDTH-7-1-:(((MAN_WIDTH+1)+RNE+RNE1)/2-7)]),        // input [44:0]
  .clk(i_clk),    // input
  .rst(~i_rst_n),    // input
  .ce(1'b1),      // input
  .p(a1_y_rne1_dlt9zeros)         // output [95:0]
);

// pipeline stage 19
ipsxe_floating_point_latency_config_v1_0 #((5*1 + 1 + EXP_WIDTH + 8), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 19) u_reg_stage19(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly17, x_minus_a_is_pos_dly17, invsqrt_x_exp_dly17, x_hi8_dly17}), // input
    .o_q({special_cases_dly18, x_minus_a_is_pos_dly18, invsqrt_x_exp_dly18, x_hi8_dly18})  // output
);

// z * group2
// pipeline stages 15 16 17 18 19
z_group2_mul u_z_group2_mul (
  .a(z_dlt15zeros),        // input [36:0]
  .b(group2),        // input [50:0]
  .clk(i_clk),    // input
  .rst(~i_rst_n),    // input
  .ce(1'b1),      // input
  .p(z_group2_rne1_dlt17zeros)         // output [87:0]
);

// round to nearest even: a1 * y
// pipeline stage 19
ipsxe_floating_point_apm_primitive_a1_y_rne_v1_0 #(MAN_WIDTH, RNE, RNE1, RNE2, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX) u_a1_y_rne (
    .i_clk(i_clk),
    .i_a1_y_rne1_dlt9zeros(a1_y_rne1_dlt9zeros),
    .o_a1_y_dlt9zeros(a1_y_dlt9zeros)
);

// a0_lo
ipsxe_floating_point_a0_lo_v1_0 u_a0_lo(
    .i_x_hi8(x_hi8_dly18),
    .o_a0_lo(a0_lo)
);

// pipeline stage 20
ipsxe_floating_point_latency_config_v1_0 #((5*1 + EXP_WIDTH + 8), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 20) u_reg_stage20(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly18, invsqrt_x_exp_dly18, x_hi8_dly18}), // input
    .o_q({special_cases_dly19, invsqrt_x_exp_dly19, x_hi8_dly19})  // output
);

// z * group2 round to nearest even
// pipeline stage 20
ipsxe_floating_point_apm_primitive_z_group2_rne_v1_0 #(MAN_WIDTH, RNE, RNE1, RNE2, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX) u_z_group2_rne (
    .i_clk(i_clk),
    .i_z_group2_rne1_dlt17zeros(z_group2_rne1_dlt17zeros),
    .o_z_group2_dlt17zeros(z_group2_dlt17zeros)
);

// a0lo +- a1_y_dlt9zeros
// pipeline stage 20
ipsxe_floating_point_apm_primitive_a0lo_minus_a1_y_v1_0 #(MAN_WIDTH, RNE, RNE1, RNE2, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX) u_a0lo_minus_a1y (
    .i_clk(i_clk),
    .i_a0_lo(a0_lo),
    .i_x_minus_a_is_pos(x_minus_a_is_pos_dly18),
    .i_a1_y_dlt9zeros(a1_y_dlt9zeros),
    .o_a0lo_minus_a1y(a0lo_minus_a1y)
);

// a0_hi
ipsxe_floating_point_a0_hi_v1_0 u_a0_hi(
    .i_x_hi8(x_hi8_dly19),
    .o_a0_hi(a0_hi)
);

// pipeline stage 21
ipsxe_floating_point_latency_config_v1_0 #((5*1 + EXP_WIDTH), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 21) u_reg_stage21(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly19, invsqrt_x_exp_dly19}), // input
    .o_q({special_cases_dly20, invsqrt_x_exp_dly20})  // output
);

// a0lo_minus_a1y_lo + zgroup2
// pipeline stage 21
ipsxe_floating_point_apm_primitive_a0lo_minus_a1y_plus_zgroup2_v1_0 #(MAN_WIDTH, RNE, RNE1, RNE2, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX) u_a0lo_minus_a1y_plus_zgroup2 (
    .i_clk(i_clk),
    .i_a0lo_minus_a1y_lo(a0lo_minus_a1y[45:0]),
    .i_z_group2_dlt17zeros(z_group2_dlt17zeros),
    .o_a0lo_minus_a1y_plus_zgroup2(a0lo_minus_a1y_plus_zgroup2)
);

// a0_hi + cin1
// pipeline stage 21
ipsxe_floating_point_apm_primitive_a0hi_plus_cin1_v1_0 #(MAN_WIDTH, RNE, RNE1, RNE2, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX) u_a0_hi_plus_cin1 (
    .i_clk(i_clk),
    .i_a0lo_minus_a1y_hi(a0lo_minus_a1y[47:46]),
    .i_a0_hi(a0_hi),
    .o_a0_hi_plus_cin1(a0_hi_plus_cin1)
);

// pipeline stage 22
ipsxe_floating_point_latency_config_v1_0 #((5*1 + EXP_WIDTH), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 22) u_reg_stage22(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly20, invsqrt_x_exp_dly20}), // input
    .o_q({special_cases_dly21, invsqrt_x_exp_dly21})  // output
);

// round to nearest even: group3_lo
// pipeline stage 22
ipsxe_floating_point_apm_primitive_group3_lo_rne_v1_0 #(MAN_WIDTH, RNE, RNE1, RNE2, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX) u_group3_lo_rne (
    .i_clk(i_clk),
    .i_a0lo_minus_a1y_plus_zgroup2(a0lo_minus_a1y_plus_zgroup2),
    .o_group3_lo(group3_lo)
);

// a0_hi + cin1 + cin2
// pipeline stage 22
ipsxe_floating_point_apm_primitive_a0hi_plus_cin1_plus_cin2_v1_0 #(MAN_WIDTH, RNE, RNE1, RNE2, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX) u_a0hi_plus_cin1_plus_cin2 (
    .i_clk(i_clk),
    .i_a0lo_minus_a1y_plus_zgroup2_hi(a0lo_minus_a1y_plus_zgroup2[47:46]),
    .i_a0_hi_plus_cin1(a0_hi_plus_cin1),
    .o_a0_hi_plus_cin1_cin2(a0_hi_plus_cin1_cin2)
);

// pipeline stage 23
ipsxe_floating_point_latency_config_v1_0 #((5*1 + EXP_WIDTH + 48), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 23) u_reg_stage23(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly21, invsqrt_x_exp_dly21, group3_lo     }), // input
    .o_q({special_cases_dly22, invsqrt_x_exp_dly22, group3_lo_dly1})  // output
);

// a0_hi + cin1 + cin2
// pipeline stage 23
ipsxe_floating_point_apm_primitive_group3_hi_v1_0 #(MAN_WIDTH, RNE, RNE1, RNE2, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX) u_group3_hi (
    .i_clk(i_clk),
    .i_group3_lo_hi(group3_lo[47:46-RNE]),
    .i_a0_hi_plus_cin1_cin2(a0_hi_plus_cin1_cin2),
    .o_group3_hi(group3_hi)
);

assign group3 = {group3_hi, group3_lo_dly1[45-RNE:0]};

assign invsqrt_x_exp_minus1 = invsqrt_x_exp_dly22 - 1'b1;
assign invsqrt_x_exp_plus1 = invsqrt_x_exp_dly22 + 1'b1;

// pipeline stage 24
ipsxe_floating_point_latency_config_v1_0 #((5*1 + 3*EXP_WIDTH + (1+(MAN_WIDTH+1))), LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 24) u_reg_stage24(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly22                                                                                             , invsqrt_x_exp_dly22, invsqrt_x_exp_minus1     , invsqrt_x_exp_plus1     , group3               }), // input
    .o_q({no_outreg_o_valid, no_outreg_o_invalid_op, no_outreg_o_divide_by_zero, x_is_nan_zero_neg_dly8, x_is_pos_inf_dly8, invsqrt_x_exp_dly23, invsqrt_x_exp_minus1_dly1, invsqrt_x_exp_plus1_dly1, invsqrt_x_taylor_dly1})  // output
);

// normalization of the result according to invsqrt_x_taylor_dly1[MAN_WIDTH+1] and invsqrt_x_taylor_dly1[MAN_WIDTH]
assign invsqrt_x_valid_or_not = invsqrt_x_taylor_dly1[MAN_WIDTH+1] ? {1'b0, invsqrt_x_exp_plus1_dly1, invsqrt_x_taylor_dly1[MAN_WIDTH:1]} : invsqrt_x_taylor_dly1[MAN_WIDTH] ? {1'b0, invsqrt_x_exp_dly23, invsqrt_x_taylor_dly1[MAN_WIDTH-1:0]} : {1'b0, invsqrt_x_exp_minus1_dly1, invsqrt_x_taylor_dly1[MAN_WIDTH-2:0], 1'b0};

// set the result to special numbers in special cases
assign no_outreg_o_invsqrt_x = x_is_nan_zero_neg_dly8 ? {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}} : x_is_pos_inf_dly8 ? {WIDTH{1'b0}} : invsqrt_x_valid_or_not;

generate
if (LATENCY_CONFIG < PIPE_STAGE_NUM_MAX + 1) begin
assign {o_valid, o_invalid_op, o_divide_by_zero, o_invsqrt_x} = {no_outreg_o_valid, no_outreg_o_invalid_op, no_outreg_o_divide_by_zero, no_outreg_o_invsqrt_x};
end
else begin // LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX + 1
wire [(3*1 + WIDTH-1)-1:0] out_delay;
// pipeline stage PIPE_STAGE_NUM_MAX + 1 to ...
ipm_distributed_shiftregister_wrapper_v1_3 #((LATENCY_CONFIG - PIPE_STAGE_NUM_MAX), 3*1 + WIDTH-1) u_shift_register (
    .din({no_outreg_o_valid, no_outreg_o_invalid_op, no_outreg_o_divide_by_zero, no_outreg_o_invsqrt_x[WIDTH-1-1:0]}),      // input [12:0]
    .clk(i_clk),      // input
    .i_aclken(i_aclken),
    .rst(~i_rst_n),      // input
    .dout(out_delay)     // output [12:0]
);
assign {o_valid, o_invalid_op, o_divide_by_zero, o_invsqrt_x[WIDTH-1-1:0]} = out_delay;
assign o_invsqrt_x[WIDTH-1] = 1'b0;
end
endgenerate

endmodule