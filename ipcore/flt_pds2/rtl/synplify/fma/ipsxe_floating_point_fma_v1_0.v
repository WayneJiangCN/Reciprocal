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
// Filename: ipsxe_floating_point_fma_v1_0.v
// Function: This module implements the fused multiply-add operation (a*b+c),
//           where a*b is not rounded until it is added with c.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_fma_v1_0 #(parameter PRECISION_INPUT = 1, parameter EXP_WIDTH = 8, MAN_WIDTH = 23, APM_USAGE = 0, LATENCY_CONFIG = 1) (
    input i_clk,
    input i_aclken,
    input i_rst_n,
    input i_abc_valid,
    input [(1+EXP_WIDTH+MAN_WIDTH)-1:0] i_a,
    input [(1+EXP_WIDTH+MAN_WIDTH)-1:0] i_b,
    input [(1+EXP_WIDTH+MAN_WIDTH)-1:0] i_c_without_op,
    input i_op,
    output [(1+EXP_WIDTH+MAN_WIDTH)-1:0] o_a_mul_b_plus_c,
    output o_a_mul_b_plus_c_valid,
    output o_invalid_op,
    output o_underflow,
    output o_overflow
);

localparam WIDTH = 1+EXP_WIDTH+MAN_WIDTH; // floating-point data width
localparam LEADING_0_CNT = $clog2(2*(MAN_WIDTH+1)+1); // for the module count_0s
localparam PIPE_STAGE_NUM_MAX = 12+2; // the last pipeline stage of this module

generate
if(PRECISION_INPUT ==1 ) begin  //single precision
ipsxe_floating_point_fma_single_v1_0 #(EXP_WIDTH, MAN_WIDTH, APM_USAGE, LATENCY_CONFIG) u_fma_single (
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_abc_valid(i_abc_valid),
    .i_a(i_a),
    .i_b(i_b),
    .i_c_without_op(i_c_without_op),
    .i_op(i_op),
    .o_a_mul_b_plus_c(o_a_mul_b_plus_c),
    .o_a_mul_b_plus_c_valid(o_a_mul_b_plus_c_valid),
    .o_invalid_op(o_invalid_op),
    .o_underflow(o_underflow),
    .o_overflow(o_overflow)
);
end
else begin      //double precision
ipsxe_floating_point_fma_double_v1_0 #(EXP_WIDTH, MAN_WIDTH, APM_USAGE, LATENCY_CONFIG) u_fma_double (
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_abc_valid(i_abc_valid),
    .i_a(i_a),
    .i_b(i_b),
    .i_c_without_op(i_c_without_op),
    .i_op(i_op),
    .o_a_mul_b_plus_c(o_a_mul_b_plus_c),
    .o_a_mul_b_plus_c_valid(o_a_mul_b_plus_c_valid),
    .o_invalid_op(o_invalid_op),
    .o_underflow(o_underflow),
    .o_overflow(o_overflow)
);
end
endgenerate


endmodule