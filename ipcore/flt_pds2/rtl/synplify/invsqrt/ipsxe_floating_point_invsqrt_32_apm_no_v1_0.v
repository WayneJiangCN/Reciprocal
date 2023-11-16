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
// Filename: ipsxe_floating_point_invsqrt_32_v1_0.v
// Function: This module calculates the inverse square-root
//           of the single precision floating-point numbers.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_invsqrt_32_apm_no_v1_0 #(parameter EXP_WIDTH = 8, MAN_WIDTH = 23, RNE = 2, RNE1 = 20, RNE2 = 21, LATENCY_CONFIG = 1) (
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
// According to the precision requirement, this "single precision" module uses the first 5 terms of the Taylor-series
// Reference paper: Floating-Point Inverse Square Root Algorithm Based on Taylor-Series Expansion, Author: Jianglin Wei et al.

// RNE, RNE1, RNE2 are the round-off bits at different pipeline stages
// MAN_WIDTH, RNE, RNE1, RNE2 should satisfy:
// 1. ((MAN_WIDTH+1)+RNE+RNE1)/2 is an integer, so (MAN_WIDTH+1)+RNE+RNE1 should be even
// 2. ((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2 is an integer, so (((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2 should be even
// 3. these two expressions cannot be greater than MAN_WIDTH

localparam WIDTH = 1+EXP_WIDTH+MAN_WIDTH;
localparam A_PREC = 64;
localparam PIPE_STAGE_NUM_MAX = 10; // the last pipeline stage of this module

wire [(((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2-7-1:0] z_rne2_dlt7zeros /*synthesis syn_dspstyle = "logic" */;
wire [(((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2-5-1:0] a3_y_rne2_dlt5zeros /*synthesis syn_dspstyle = "logic" */;
wire [(MAN_WIDTH+1)+RNE+RNE1-5-1:0] a1_y_rne1_dlt5zeros /*synthesis syn_dspstyle = "logic" */;
wire [((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2-6-1:0] a5_y_dlt6zeros /*synthesis syn_dspstyle = "logic" */;
wire [(((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2-10-1:0] a4_z_rne2_dlt10zeros /*synthesis syn_dspstyle = "logic" */;
wire [(MAN_WIDTH+1)+RNE+RNE1-9-1:0] z_group_rne1_dlt9zeros /*synthesis syn_dspstyle = "logic" */;

reg [((MAN_WIDTH+1)+RNE)-1:0] a0;
reg [(((MAN_WIDTH+1)+RNE+RNE1)/2)-1:0] a1, a2;
reg [(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2)-1:0] a3, a4;
reg [(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2/2)-1:0] a5;
wire x_is_denorm, i_valid_dly1;
wire [WIDTH-1:0] x, x_dly1;
wire x_is_neg, x_is_zero, x_is_nan_zero_neg, x_is_nan_zero_neg_dly8, x_is_pos_inf, x_is_pos_inf_dly8;
wire [EXP_WIDTH-1:0] invsqrt_x_exp, invsqrt_x_exp_dly1, invsqrt_x_exp_dly1p25, invsqrt_x_exp_dly2, invsqrt_x_exp_dly3, invsqrt_x_exp_dly4, invsqrt_x_exp_dly5, invsqrt_x_exp_dly6, invsqrt_x_exp_dly7, invsqrt_x_exp_dly8, invsqrt_x_exp_minus1, invsqrt_x_exp_plus1;
wire x_minus_a_is_pos, x_minus_a_is_pos_dly1, x_minus_a_is_pos_dly1p25, x_minus_a_is_pos_dly2, x_minus_a_is_pos_dly3, x_minus_a_is_pos_dly4, x_minus_a_is_pos_dly5, x_minus_a_is_pos_dly6, x_minus_a_is_pos_dly7;
wire [MAN_WIDTH-3-1:0] y_dlt3zeros, y_dlt3zeros_dly1;
wire [(MAN_WIDTH+1)+RNE-1:0] a0_dly1, a0_dly1p25, a0_dly2, a0_dly3, a0_dly4, a0_dly5, a0_dly6, a0_dly7;
wire [((MAN_WIDTH+1)+RNE+RNE1)/2-1:0] a1_dly1, a2_dly1, a2_dly1p25, a2_dly2, a2_dly3, a2_dly4;
wire [((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2-6-1:0] a5_y_dlt6zeros_dly1;
wire [((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2-1:0] a3_dly1, a4_dly1, a4_dly1p25;
wire [((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2/2-1:0] a5_dly1;
wire [(MAN_WIDTH+1)+RNE+RNE1-5-1:0] a1_y_rne1_dlt5zeros_dly1, a1_y_rne1_dlt5zeros_dly2;
wire [(((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2-7-1:0] z_rne2_dlt7zeros_dly1, z_rne2_dlt7zeros_dly2;
wire [(((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2-5-1:0] a3_y_rne2_dlt5zeros_dly1, a3_y_rne2_dlt5zeros_dly2;
wire [((MAN_WIDTH+1)+RNE+RNE1)/2-7-1:0] z_dlt7zeros, z_dlt7zeros_dly1, z_dlt7zeros_dly2, z_dlt7zeros_dly3;
wire [((MAN_WIDTH+1)+RNE+RNE1)/2-5-1:0] a3_y_dlt5zeros, a3_y_dlt5zeros_dly1, a3_y_dlt5zeros_dly2;
wire [(MAN_WIDTH+1)+RNE-5-1:0] a1_y_dlt5zeros, a1_y_dlt5zeros_dly1, a1_y_dlt5zeros_dly2, a1_y_dlt5zeros_dly3, a1_y_dlt5zeros_dly4, a1_y_dlt5zeros_dly5;
wire [(((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2-10-1:0] a4_z_rne2_dlt10zeros_dly1;
wire [((MAN_WIDTH+1)+RNE+RNE1)/2-10-1:0] a4_z_dlt10zeros, a4_z_dlt10zeros_dly1;
wire [((MAN_WIDTH+1)+RNE+RNE1)/2-1-1:0] a2_plus_a4z, a2_plus_a3y_plus_a4z_dlt1zero, a2_plus_a3y_plus_a4z_dlt1zero_dly1;
wire [(MAN_WIDTH+1)+RNE+RNE1-9-1:0] z_group_rne1_dlt9zeros_dly1;
wire [(MAN_WIDTH+1)+RNE-9-1:0] z_group_dlt9zeros, z_group_dlt9zeros_dly1;
wire [1+(MAN_WIDTH+1)+RNE-1:0] invsqrt_x_taylor_rne, invsqrt_x_taylor_rne_dly1;
wire [1 + (MAN_WIDTH+1)-1:0] invsqrt_x_taylor;
wire [WIDTH-1:0] invsqrt_x_valid_or_not;
wire [4:0] special_cases, special_cases_dly1, special_cases_dly1p25, special_cases_dly2, special_cases_dly3, special_cases_dly4, special_cases_dly5, special_cases_dly6, special_cases_dly7;
wire [((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2-2-1:0] a4_plus_a5_y_dlt2zeros, a4_plus_a5_y_dlt2zeros_dly1;
wire no_outreg_o_valid;
wire [(1+EXP_WIDTH+MAN_WIDTH)-1:0] no_outreg_o_invsqrt_x;
wire no_outreg_o_invalid_op;
wire no_outreg_o_divide_by_zero;

// determine whether x is a denormalized number, if so, set it to zero
assign x_is_denorm = (i_x_norm_or_denorm[WIDTH-2-:EXP_WIDTH] == 0) & (i_x_norm_or_denorm[MAN_WIDTH-1:0] != 0);
assign x = x_is_denorm ? 0 : i_x_norm_or_denorm;

// determine whether x is a special floating point number, such as NaN or Inf
assign x_is_neg = (x_dly1[WIDTH-1] == 1) & (((x_dly1[WIDTH-2-:EXP_WIDTH] == {EXP_WIDTH{1'b1}}) & (x_dly1[MAN_WIDTH-1:0] == 0)) | ((x_dly1[WIDTH-2-:EXP_WIDTH] <= ({EXP_WIDTH{1'b1}} - 1)) & (x_dly1[WIDTH-2-:EXP_WIDTH] >= 1)));
assign x_is_zero = (x_dly1[WIDTH-2:0] == 0);
assign x_is_nan_zero_neg = ((x_dly1[WIDTH-2-:EXP_WIDTH] == {EXP_WIDTH{1'b1}}) & (x_dly1[MAN_WIDTH-1:0] != 0)) | x_is_zero | x_is_neg;
assign x_is_pos_inf = (x_dly1[WIDTH-1] == 0) & (x_dly1[WIDTH-2-:EXP_WIDTH] == {EXP_WIDTH{1'b1}}) & (x_dly1[MAN_WIDTH-1:0] == 0);

// calculate the square-root of exp
ipsxe_floating_point_exp_invsqrt_minus1_v1_0 #(EXP_WIDTH) u_exp_invsqrt_minus1(
        .i_exp(x_dly1[WIDTH-2-:EXP_WIDTH]),
        .o_exp_invsqrt_minus1(invsqrt_x_exp)
);

generate
if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (1 / 2)) begin
// pipeline stage 0.5 (actually 1)
ipsxe_floating_point_register_v1_0 #(1 + WIDTH) u_reg_stage0p5(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({i_valid     , x     }),
    .o_q({i_valid_dly1, x_dly1})
);
end
else begin
assign {i_valid_dly1, x_dly1} = {i_valid     , x     };
end
endgenerate

// find the center a of the Taylor-series according to the 3 most significand bits of the man part of x, and then use the pre-calculated a0-a4 in the LUTs
always @(*) begin
    if(x_dly1[MAN_WIDTH]) // real exp is even
        case(x_dly1[MAN_WIDTH-1-:3])
            3'b000: {a0, a1, a2, a3, a4, a5} = {26'h3e16d09, 23'h3a6fd3, 23'h293fe0, 22'h102d21, 22'hd5257, 11'h169};
            3'b001: {a0, a1, a2, a3, a4, a5} = {26'h3abafd5, 23'h31750b, 23'h1f3c73, 22'haf5c5 , 22'h81369, 11'hc4 };
            3'b010: {a0, a1, a2, a3, a4, a5} = {26'h37dd20b, 23'h2a9019, 23'h185257, 22'h7b89e , 22'h525bf, 11'h71 };
            3'b011: {a0, a1, a2, a3, a4, a5} = {26'h3561336, 23'h25223a, 23'h135fc5, 22'h59d9d , 22'h36b12, 11'h44 };
            3'b100: {a0, a1, a2, a3, a4, a5} = {26'h3333333, 23'h20c49c, 23'hfba88 , 22'h431be , 22'h2594c, 11'h2b };
            3'b101: {a0, a1, a2, a3, a4, a5} = {26'h314468c, 23'h1d3205, 23'hcf9c9 , 22'h33432 , 22'h1a949, 11'h1c };
            3'b110: {a0, a1, a2, a3, a4, a5} = {26'h2f89bad, 23'h1a3a55, 23'hada58 , 22'h27eb3 , 22'h13457, 11'h13 };
           default: {a0, a1, a2, a3, a4, a5} = {26'h2dfa9cf, 23'h17bb28, 23'h92fac , 22'h1f9bc , 22'he466 , 11'hd  };
        endcase
    else // real exp is odd
        case(x_dly1[MAN_WIDTH-1-:3])
            3'b000: {a0, a1, a2, a3, a4, a5} = {26'h2be754d, 23'h295232, 23'h1d2af6, 22'hb7038, 22'h96b7a, 11'hff};
            3'b001: {a0, a1, a2, a3, a4, a5} = {26'h298757d, 23'h22f8b6, 23'h161658, 22'h7bffb, 22'h5b5e1, 11'h8a};
            3'b010: {a0, a1, a2, a3, a4, a5} = {26'h27806ca, 23'h1e18b4, 23'h1132b0, 22'h575ae, 22'h3a3c9, 11'h50};
            3'b011: {a0, a1, a2, a3, a4, a5} = {26'h25bec19, 23'h1a41eb, 23'hdb316 , 22'h3f88c, 22'h26ac5, 11'h30};
            3'b100: {a0, a1, a2, a3, a4, a5} = {26'h243430a, 23'h172ba4, 23'hb1f30 , 22'h2f740, 22'h1a92e, 11'h1f};
            3'b101: {a0, a1, a2, a3, a4, a5} = {26'h22d651f, 23'h14a4ee, 23'h92cdc , 22'h243f7, 22'h12cb9, 11'h14};
            3'b110: {a0, a1, a2, a3, a4, a5} = {26'h219d4c6, 23'h128bc0, 23'h7ac96 , 22'h1c3a1, 22'hda07 , 11'he };
           default: {a0, a1, a2, a3, a4, a5} = {26'h2083149, 23'h10c7c9, 23'h67ee2 , 22'h1659c, 22'ha180 , 11'h9 };
        endcase
end

// next, calculate the Taylor-series expression, but in several pipeline stages
// assign a = {x[MAN_WIDTH-1-:3], 1'b1};
// o_invsqrt_x = a0 - a1 * (x - a) + a2 * (x - a)^2 - a3 * (x - a)^3 + a4 * (x - a)^4 - a5 * (x - a)^5
// set y = x - a, z = y^2
// o_invsqrt_x = a0 - a1 * y + a2 * y^2 - a3 * y^3 + a4 * y^4
//           = a0 - a1 * y + z * (a2 - a3 * y + z * (a4 - a5 * y))
// note: the post-fix _rne or _rne1 or _rne2 means this signal keeps RNE or RNE1 or RNE2 more bits,
// and these bits will be rounded off later by calling the "ipsxe_floating_point_rne_v1_0" module

// if x minus a is positive, then x_minus_a_is_pos is 1
assign x_minus_a_is_pos = x_dly1[MAN_WIDTH-4]; // which means: x[MAN_WIDTH-1:0] >= {a, {(MAN_WIDTH-4){1'b0}}};
// the selection according to x_minus_a_is_pos makes sure that y is positive
// y = (x - a) or (a - x)
assign y_dlt3zeros = x_minus_a_is_pos ? {1'b0, x_dly1[MAN_WIDTH-5:0]} : ({1'b1, {(MAN_WIDTH-4){1'b0}}} - {1'b0, x_dly1[MAN_WIDTH-5:0]}); // which means: x_minus_a_is_pos ? x[MAN_WIDTH-1:0] - {a, {(MAN_WIDTH-4){1'b0}}} : {a, {(MAN_WIDTH-4){1'b0}}} - x[MAN_WIDTH-1:0];

// gather all special cases signals
assign special_cases = {i_valid_dly1, x_is_neg, x_is_zero, x_is_nan_zero_neg, x_is_pos_inf};

generate
if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/2) - (2 / 4)) begin
// pipeline stage 2
ipsxe_floating_point_register_v1_0 #(6*1 + EXP_WIDTH + (MAN_WIDTH+1)+RNE + 2*((MAN_WIDTH+1)+RNE+RNE1)/2 + 2*((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2 + ((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2/2 + MAN_WIDTH-3) u_reg_stage1(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases     , x_minus_a_is_pos     , invsqrt_x_exp     , a0     , a1     , a2     , a3     , a4     , a5     , y_dlt3zeros     }),
    .o_q({special_cases_dly1, x_minus_a_is_pos_dly1, invsqrt_x_exp_dly1, a0_dly1, a1_dly1, a2_dly1, a3_dly1, a4_dly1, a5_dly1, y_dlt3zeros_dly1})
);
end
else begin
assign {special_cases_dly1, x_minus_a_is_pos_dly1, invsqrt_x_exp_dly1, a0_dly1, a1_dly1, a2_dly1, a3_dly1, a4_dly1, a5_dly1, y_dlt3zeros_dly1} = {special_cases     , x_minus_a_is_pos     , invsqrt_x_exp     , a0     , a1     , a2     , a3     , a4     , a5     , y_dlt3zeros     };
end
endgenerate

generate
if (((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2 > MAN_WIDTH) begin
    // z = y^2
    assign z_rne2_dlt7zeros = {y_dlt3zeros_dly1, {(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2 - MAN_WIDTH){1'b0}}} * {y_dlt3zeros_dly1, {(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2 - MAN_WIDTH){1'b0}}};
    // a3 * y
    assign a3_y_rne2_dlt5zeros = a3_dly1 * {y_dlt3zeros_dly1, {(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2 - MAN_WIDTH){1'b0}}};
end
else begin
    // z = y^2
    assign z_rne2_dlt7zeros = y_dlt3zeros_dly1[MAN_WIDTH-3-1-:(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2 - 3)] * y_dlt3zeros_dly1[MAN_WIDTH-3-1-:(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2 - 3)];
    // a3 * y
    assign a3_y_rne2_dlt5zeros = a3_dly1 * y_dlt3zeros_dly1[MAN_WIDTH-3-1-:(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2 - 3)];
end
endgenerate

generate
if (((MAN_WIDTH+1)+RNE+RNE1)/2 > MAN_WIDTH) begin
    // a1 * y
    assign a1_y_rne1_dlt5zeros = a1_dly1 * {y_dlt3zeros_dly1, {(((MAN_WIDTH+1)+RNE+RNE1)/2 - MAN_WIDTH){1'b0}}};
end
else begin
    // a1 * y
    assign a1_y_rne1_dlt5zeros = a1_dly1 * y_dlt3zeros_dly1[MAN_WIDTH-3-1-:(((MAN_WIDTH+1)+RNE+RNE1)/2 - 3)];
end
endgenerate

// a5 * y
assign a5_y_dlt6zeros = a5_dly1 * y_dlt3zeros_dly1[MAN_WIDTH-3-1-:(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2/2 - 3)];

generate
if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (3 / 2)) begin
// pipeline stage 1.25 (actually 3)
ipsxe_floating_point_register_v1_0 #(6*1 + EXP_WIDTH + (MAN_WIDTH+1)+RNE + ((MAN_WIDTH+1)+RNE+RNE1)/2 + ((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2 + (((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2-6) + ((MAN_WIDTH+1)+RNE+RNE1-5) + ((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2-7) + ((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2-5)) u_reg_stage1p25(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly1,    x_minus_a_is_pos_dly1,    invsqrt_x_exp_dly1,    a0_dly1,    a2_dly1,    a4_dly1,    a5_y_dlt6zeros,      a1_y_rne1_dlt5zeros     , z_rne2_dlt7zeros     , a3_y_rne2_dlt5zeros     }),
    .o_q({special_cases_dly1p25, x_minus_a_is_pos_dly1p25, invsqrt_x_exp_dly1p25, a0_dly1p25, a2_dly1p25, a4_dly1p25, a5_y_dlt6zeros_dly1, a1_y_rne1_dlt5zeros_dly1, z_rne2_dlt7zeros_dly1, a3_y_rne2_dlt5zeros_dly1})
);
end
else begin
assign {special_cases_dly1p25, x_minus_a_is_pos_dly1p25, invsqrt_x_exp_dly1p25, a0_dly1p25, a2_dly1p25, a4_dly1p25, a5_y_dlt6zeros_dly1, a1_y_rne1_dlt5zeros_dly1, z_rne2_dlt7zeros_dly1, a3_y_rne2_dlt5zeros_dly1} = {special_cases_dly1,    x_minus_a_is_pos_dly1,    invsqrt_x_exp_dly1,    a0_dly1,    a2_dly1,    a4_dly1,    a5_y_dlt6zeros,      a1_y_rne1_dlt5zeros     , z_rne2_dlt7zeros     , a3_y_rne2_dlt5zeros     };
end
endgenerate

// minus or plus according to x_minus_a_is_pos
// a4 - a5 * y
assign a4_plus_a5_y_dlt2zeros = x_minus_a_is_pos_dly1p25 ? a4_dly1p25[((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2-2-1:0] - a5_y_dlt6zeros_dly1 : a4_dly1p25[((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2-2-1:0] + a5_y_dlt6zeros_dly1;

generate
if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/4) - (4 / 8)) begin
// pipeline stage 4
ipsxe_floating_point_register_v1_0 #(6*1 + EXP_WIDTH + (MAN_WIDTH+1)+RNE + ((MAN_WIDTH+1)+RNE+RNE1)/2 + (((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2-2) + ((MAN_WIDTH+1)+RNE+RNE1-5) + ((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2-7) + ((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2-5)) u_reg_stage3(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly1p25, x_minus_a_is_pos_dly1p25, invsqrt_x_exp_dly1p25, a0_dly1p25, a2_dly1p25, a4_plus_a5_y_dlt2zeros,      a1_y_rne1_dlt5zeros_dly1, z_rne2_dlt7zeros_dly1, a3_y_rne2_dlt5zeros_dly1}),
    .o_q({special_cases_dly2,    x_minus_a_is_pos_dly2,    invsqrt_x_exp_dly2,    a0_dly2,    a2_dly2,    a4_plus_a5_y_dlt2zeros_dly1, a1_y_rne1_dlt5zeros_dly2, z_rne2_dlt7zeros_dly2, a3_y_rne2_dlt5zeros_dly2})
);
end
else begin
assign {special_cases_dly2,    x_minus_a_is_pos_dly2,    invsqrt_x_exp_dly2,    a0_dly2,    a2_dly2,    a4_plus_a5_y_dlt2zeros_dly1, a1_y_rne1_dlt5zeros_dly2, z_rne2_dlt7zeros_dly2, a3_y_rne2_dlt5zeros_dly2} = {special_cases_dly1p25, x_minus_a_is_pos_dly1p25, invsqrt_x_exp_dly1p25, a0_dly1p25, a2_dly1p25, a4_plus_a5_y_dlt2zeros,      a1_y_rne1_dlt5zeros_dly1, z_rne2_dlt7zeros_dly1, a3_y_rne2_dlt5zeros_dly1};
end
endgenerate

// z * (a4 - a5 * y)
assign a4_z_rne2_dlt10zeros = a4_plus_a5_y_dlt2zeros_dly1 * z_rne2_dlt7zeros_dly2[(((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2-7-1-:(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2 - 7)];

// round to nearest even: z
ipsxe_floating_point_rne_v1_0 #(((MAN_WIDTH+1)+RNE+RNE1)/2-7, RNE2) u_rne_z   (   z_rne2_dlt7zeros_dly2,    z_dlt7zeros);
// round to nearest even: a3 * y
ipsxe_floating_point_rne_v1_0 #(((MAN_WIDTH+1)+RNE+RNE1)/2-5, RNE2) u_rne_a3_y(a3_y_rne2_dlt5zeros_dly2, a3_y_dlt5zeros);

// round to nearest even: a1 * y
ipsxe_floating_point_rne_v1_0 #((MAN_WIDTH+1)+RNE-5, RNE1) u_rne_a1_y(a1_y_rne1_dlt5zeros_dly2, a1_y_dlt5zeros);

generate
if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (5 / 2)) begin
// pipeline stage 5
ipsxe_floating_point_register_v1_0 #(6*1 + EXP_WIDTH + (MAN_WIDTH+1)+RNE + ((MAN_WIDTH+1)+RNE+RNE1)/2 + ((MAN_WIDTH+1)+RNE-5) + (((MAN_WIDTH+1)+RNE+RNE1)/2-7) + (((MAN_WIDTH+1)+RNE+RNE1)/2-5) + ((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2 - 10)) u_reg_stage4(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly2, x_minus_a_is_pos_dly2, invsqrt_x_exp_dly2, a0_dly2, a2_dly2, a1_y_dlt5zeros     , z_dlt7zeros     , a3_y_dlt5zeros     , a4_z_rne2_dlt10zeros     }),
    .o_q({special_cases_dly3, x_minus_a_is_pos_dly3, invsqrt_x_exp_dly3, a0_dly3, a2_dly3, a1_y_dlt5zeros_dly1, z_dlt7zeros_dly1, a3_y_dlt5zeros_dly1, a4_z_rne2_dlt10zeros_dly1})
);
end
else begin
assign {special_cases_dly3, x_minus_a_is_pos_dly3, invsqrt_x_exp_dly3, a0_dly3, a2_dly3, a1_y_dlt5zeros_dly1, z_dlt7zeros_dly1, a3_y_dlt5zeros_dly1, a4_z_rne2_dlt10zeros_dly1} = {special_cases_dly2, x_minus_a_is_pos_dly2, invsqrt_x_exp_dly2, a0_dly2, a2_dly2, a1_y_dlt5zeros     , z_dlt7zeros     , a3_y_dlt5zeros     , a4_z_rne2_dlt10zeros     };
end
endgenerate

// round to nearest even: z * (a4 - a5 * y)
ipsxe_floating_point_rne_v1_0 #(((MAN_WIDTH+1)+RNE+RNE1)/2-10, RNE2) u_rne_a4_z(a4_z_rne2_dlt10zeros_dly1, a4_z_dlt10zeros);

generate
if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/2) - (6 / 4)) begin
// pipeline stage 6
ipsxe_floating_point_register_v1_0 #(6*1 + EXP_WIDTH + (MAN_WIDTH+1)+RNE + ((MAN_WIDTH+1)+RNE+RNE1)/2 + ((MAN_WIDTH+1)+RNE-5) + (((MAN_WIDTH+1)+RNE+RNE1)/2-7) + (((MAN_WIDTH+1)+RNE+RNE1)/2-5) + (((MAN_WIDTH+1)+RNE+RNE1)/2-10)) u_reg_stage5(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly3, x_minus_a_is_pos_dly3, invsqrt_x_exp_dly3, a0_dly3, a2_dly3, a1_y_dlt5zeros_dly1, z_dlt7zeros_dly1, a3_y_dlt5zeros_dly1, a4_z_dlt10zeros     }),
    .o_q({special_cases_dly4, x_minus_a_is_pos_dly4, invsqrt_x_exp_dly4, a0_dly4, a2_dly4, a1_y_dlt5zeros_dly2, z_dlt7zeros_dly2, a3_y_dlt5zeros_dly2, a4_z_dlt10zeros_dly1})
);
end
else begin
assign {special_cases_dly4, x_minus_a_is_pos_dly4, invsqrt_x_exp_dly4, a0_dly4, a2_dly4, a1_y_dlt5zeros_dly2, z_dlt7zeros_dly2, a3_y_dlt5zeros_dly2, a4_z_dlt10zeros_dly1} = {special_cases_dly3, x_minus_a_is_pos_dly3, invsqrt_x_exp_dly3, a0_dly3, a2_dly3, a1_y_dlt5zeros_dly1, z_dlt7zeros_dly1, a3_y_dlt5zeros_dly1, a4_z_dlt10zeros     };
end
endgenerate

// minus or plus according to x_minus_a_is_pos
// a2 - a3 * y + z * (a4 - a5 * y)
assign a2_plus_a4z = a2_dly4[((MAN_WIDTH+1)+RNE+RNE1)/2-1-1:0] + {9'b0, a4_z_dlt10zeros_dly1};
assign a2_plus_a3y_plus_a4z_dlt1zero = x_minus_a_is_pos_dly4 ? (a2_plus_a4z - {4'b0, a3_y_dlt5zeros_dly2}) : (a2_plus_a4z + {4'b0, a3_y_dlt5zeros_dly2});

generate
if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (7 / 2)) begin
// pipeline stage 7
ipsxe_floating_point_register_v1_0 #(6*1 + EXP_WIDTH + (MAN_WIDTH+1)+RNE + ((MAN_WIDTH+1)+RNE-5) + (((MAN_WIDTH+1)+RNE+RNE1)/2-7) + (((MAN_WIDTH+1)+RNE+RNE1)/2-1)) u_reg_stage6(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly4, x_minus_a_is_pos_dly4, invsqrt_x_exp_dly4, a0_dly4, a1_y_dlt5zeros_dly2, z_dlt7zeros_dly2, a2_plus_a3y_plus_a4z_dlt1zero     }),
    .o_q({special_cases_dly5, x_minus_a_is_pos_dly5, invsqrt_x_exp_dly5, a0_dly5, a1_y_dlt5zeros_dly3, z_dlt7zeros_dly3, a2_plus_a3y_plus_a4z_dlt1zero_dly1})
);
end
else begin
assign {special_cases_dly5, x_minus_a_is_pos_dly5, invsqrt_x_exp_dly5, a0_dly5, a1_y_dlt5zeros_dly3, z_dlt7zeros_dly3, a2_plus_a3y_plus_a4z_dlt1zero_dly1} = {special_cases_dly4, x_minus_a_is_pos_dly4, invsqrt_x_exp_dly4, a0_dly4, a1_y_dlt5zeros_dly2, z_dlt7zeros_dly2, a2_plus_a3y_plus_a4z_dlt1zero     };
end
endgenerate

// z * (a2 - a3 * y + z * (a4 - a5 * y))
assign z_group_rne1_dlt9zeros = z_dlt7zeros_dly3 * a2_plus_a3y_plus_a4z_dlt1zero_dly1;

generate
if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/8) - (8 / 16)) begin
// pipeline stage 8
ipsxe_floating_point_register_v1_0 #(6*1 + EXP_WIDTH + (MAN_WIDTH+1)+RNE + ((MAN_WIDTH+1)+RNE-5) + ((MAN_WIDTH+1)+RNE+RNE1-9)) u_reg_stage7(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly5, x_minus_a_is_pos_dly5, invsqrt_x_exp_dly5, a0_dly5, a1_y_dlt5zeros_dly3, z_group_rne1_dlt9zeros     }),
    .o_q({special_cases_dly6, x_minus_a_is_pos_dly6, invsqrt_x_exp_dly6, a0_dly6, a1_y_dlt5zeros_dly4, z_group_rne1_dlt9zeros_dly1})
);
end
else begin
assign {special_cases_dly6, x_minus_a_is_pos_dly6, invsqrt_x_exp_dly6, a0_dly6, a1_y_dlt5zeros_dly4, z_group_rne1_dlt9zeros_dly1} = {special_cases_dly5, x_minus_a_is_pos_dly5, invsqrt_x_exp_dly5, a0_dly5, a1_y_dlt5zeros_dly3, z_group_rne1_dlt9zeros     };
end
endgenerate

// round to nearest even: z * (a2 - a3 * y + z * (a4 - a5 * y))
ipsxe_floating_point_rne_v1_0 #((MAN_WIDTH+1)+RNE-9, RNE1) u_rne_z_group(z_group_rne1_dlt9zeros_dly1, z_group_dlt9zeros);

generate
if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (9 / 2)) begin
// pipeline stage 9
ipsxe_floating_point_register_v1_0 #(6*1 + EXP_WIDTH + ((MAN_WIDTH+1)+RNE) + ((MAN_WIDTH+1)+RNE-5) + ((MAN_WIDTH+1)+RNE-9)) u_reg_stage8(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly6, x_minus_a_is_pos_dly6, invsqrt_x_exp_dly6, a0_dly6, a1_y_dlt5zeros_dly4, z_group_dlt9zeros     }),
    .o_q({special_cases_dly7, x_minus_a_is_pos_dly7, invsqrt_x_exp_dly7, a0_dly7, a1_y_dlt5zeros_dly5, z_group_dlt9zeros_dly1})
);
end
else begin
assign {special_cases_dly7, x_minus_a_is_pos_dly7, invsqrt_x_exp_dly7, a0_dly7, a1_y_dlt5zeros_dly5, z_group_dlt9zeros_dly1} = {special_cases_dly6, x_minus_a_is_pos_dly6, invsqrt_x_exp_dly6, a0_dly6, a1_y_dlt5zeros_dly4, z_group_dlt9zeros     };
end
endgenerate

// minus or plus according to x_minus_a_is_pos
// a0 - a1 * y + z * (a2 - a3 * y + a4 * z)
assign invsqrt_x_taylor_rne = x_minus_a_is_pos_dly7 ? a0_dly7 - a1_y_dlt5zeros_dly5 + z_group_dlt9zeros_dly1 : a0_dly7 + a1_y_dlt5zeros_dly5 + z_group_dlt9zeros_dly1;

generate
if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/2) - (10 / 4)) begin
// pipeline stage 10
ipsxe_floating_point_register_v1_0 #(5*1 + EXP_WIDTH + (1+(MAN_WIDTH+1)+RNE)) u_reg_stage9(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly7                                                                                                     , invsqrt_x_exp_dly7, invsqrt_x_taylor_rne     }),
    .o_q({no_outreg_o_valid    , no_outreg_o_invalid_op   , no_outreg_o_divide_by_zero, x_is_nan_zero_neg_dly8, x_is_pos_inf_dly8, invsqrt_x_exp_dly8, invsqrt_x_taylor_rne_dly1})
);
end
else begin
assign {no_outreg_o_valid    , no_outreg_o_invalid_op   , no_outreg_o_divide_by_zero, x_is_nan_zero_neg_dly8, x_is_pos_inf_dly8, invsqrt_x_exp_dly8, invsqrt_x_taylor_rne_dly1} = {special_cases_dly7                                                                                                     , invsqrt_x_exp_dly7, invsqrt_x_taylor_rne     };
end
endgenerate

// round to nearest even: a0 - a1 * y + z * (a2 - a3 * y + a4 * z)
ipsxe_floating_point_rne_v1_0 #((1 + MAN_WIDTH+1), RNE) u_rne_invsqrt_x(invsqrt_x_taylor_rne_dly1, invsqrt_x_taylor);

assign invsqrt_x_exp_minus1 = invsqrt_x_exp_dly8 - 1;
assign invsqrt_x_exp_plus1 = invsqrt_x_exp_dly8 + 1;
// normalization of the result according to invsqrt_x_taylor[MAN_WIDTH+1] and invsqrt_x_taylor[MAN_WIDTH]
assign invsqrt_x_valid_or_not = invsqrt_x_taylor[MAN_WIDTH+1] ? {1'b0, invsqrt_x_exp_plus1, invsqrt_x_taylor[MAN_WIDTH:1]} : invsqrt_x_taylor[MAN_WIDTH] ? {1'b0, invsqrt_x_exp_dly8, invsqrt_x_taylor[MAN_WIDTH-1:0]} : {1'b0, invsqrt_x_exp_minus1, invsqrt_x_taylor[MAN_WIDTH-2:0], 1'b0};

// set the result to special numbers in special cases
assign no_outreg_o_invsqrt_x = x_is_nan_zero_neg_dly8 ? {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}} : x_is_pos_inf_dly8 ? {WIDTH{1'b0}} : invsqrt_x_valid_or_not;

generate
if (LATENCY_CONFIG < PIPE_STAGE_NUM_MAX + 1) begin
assign {o_valid, o_invalid_op, o_divide_by_zero, o_invsqrt_x} = {no_outreg_o_valid, no_outreg_o_invalid_op, no_outreg_o_divide_by_zero, no_outreg_o_invsqrt_x};
end
else if (LATENCY_CONFIG == PIPE_STAGE_NUM_MAX + 1) begin
wire [(3*1 + WIDTH-1)*(LATENCY_CONFIG-PIPE_STAGE_NUM_MAX)-1:0] out_delay;
// pipeline stage PIPE_STAGE_NUM_MAX + 1
ipsxe_floating_point_register_v1_0 #((3*1 + WIDTH-1)*(LATENCY_CONFIG-PIPE_STAGE_NUM_MAX)-(3*1 + WIDTH-1) + (3*1 + WIDTH-1)) u_reg_stage_max(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({no_outreg_o_valid, no_outreg_o_invalid_op, no_outreg_o_divide_by_zero, no_outreg_o_invsqrt_x[WIDTH-1-1:0]}),
    .o_q(out_delay)
);
assign {o_valid, o_invalid_op, o_divide_by_zero, o_invsqrt_x[WIDTH-1-1:0]} = out_delay[(3*1 + WIDTH-1)*(LATENCY_CONFIG-PIPE_STAGE_NUM_MAX)-1-:(3*1 + WIDTH-1)];
assign o_invsqrt_x[WIDTH-1] = 1'b0;
end
else begin // LATENCY_CONFIG > PIPE_STAGE_NUM_MAX + 1
wire [(3*1 + WIDTH-1)*(LATENCY_CONFIG-PIPE_STAGE_NUM_MAX)-1:0] out_delay;
// pipeline stage PIPE_STAGE_NUM_MAX + 1 to ...
ipsxe_floating_point_register_v1_0 #((3*1 + WIDTH-1)*(LATENCY_CONFIG-PIPE_STAGE_NUM_MAX)-(3*1 + WIDTH-1) + (3*1 + WIDTH-1)) u_reg_stage_max_more(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({out_delay[(3*1 + WIDTH-1)*(LATENCY_CONFIG-PIPE_STAGE_NUM_MAX)-1-(3*1 + WIDTH-1):0], no_outreg_o_valid, no_outreg_o_invalid_op, no_outreg_o_divide_by_zero, no_outreg_o_invsqrt_x[WIDTH-1-1:0]}),
    .o_q(out_delay)
);
assign {o_valid, o_invalid_op, o_divide_by_zero, o_invsqrt_x[WIDTH-1-1:0]} = out_delay[(3*1 + WIDTH-1)*(LATENCY_CONFIG-PIPE_STAGE_NUM_MAX)-1-:(3*1 + WIDTH-1)];
assign o_invsqrt_x[WIDTH-1] = 1'b0;
end
endgenerate

endmodule