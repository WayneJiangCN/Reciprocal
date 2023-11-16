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
// Filename: ipsxe_floating_point_sqrt_man_v1_0.v
// Function: This module calculates the square-root of a binary number
//           and then round it.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_sqrt_man_v1_0 #(parameter BINARY_SIZE = 106, MANTISSA_SIZE = 52, RNE = 5, LATENCY_CONFIG = 1, PIPE_STAGE_NUM_MAX = 1) (
    input i_clk,
    input i_aclken,
    input i_rst_n,
    input [BINARY_SIZE - 1:0] i_man,
    output [MANTISSA_SIZE - 1:0] o_sqrt_man
);

wire [BINARY_SIZE/2-1:0] bin_sqrt_out, bin_sqrt_out_dly;
wire [MANTISSA_SIZE - 1:0] sqrt_man;

// calculate the square-root of mantissa
// pipeline stage 3 to (BINARY_SIZE/2) + 1
ipsxe_floating_point_sqrt_binary_v1_0 #(BINARY_SIZE, (BINARY_SIZE/2), MANTISSA_SIZE, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX) u_sqrt_binary (
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_p(i_man),
    .o_u(bin_sqrt_out)
);

// determine whether a pipeline stage should be inserted,
// according to the parameter LATENCY_CONFIG
// this pipeline stage number is (BINARY_SIZE/2) + 2
generate
if (((BINARY_SIZE/2) + 2) % 2 != 0)
    if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (((BINARY_SIZE/2) + 2) / 2))
        ipsxe_floating_point_register_v1_0 #(BINARY_SIZE/2) u_reg_bin_sqrt_out(
            .i_clk(i_clk), // input clock
            .i_aclken(i_aclken), // input clock enable
            .i_rst_n(i_rst_n), // input reset
            .i_d(bin_sqrt_out),
            .o_q(bin_sqrt_out_dly));
    else
        assign bin_sqrt_out_dly = bin_sqrt_out;
else if (((BINARY_SIZE/2) + 2) % 4 != 0)
    if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/2) - (((BINARY_SIZE/2) + 2) / 4))
        ipsxe_floating_point_register_v1_0 #(BINARY_SIZE/2) u_reg_bin_sqrt_out(
            .i_clk(i_clk), // input clock
            .i_aclken(i_aclken), // input clock enable
            .i_rst_n(i_rst_n), // input reset
            .i_d(bin_sqrt_out),
            .o_q(bin_sqrt_out_dly));
    else
        assign bin_sqrt_out_dly = bin_sqrt_out;
else if (((BINARY_SIZE/2) + 2) % 8 != 0)
    if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/4) - (((BINARY_SIZE/2) + 2) / 8))
        ipsxe_floating_point_register_v1_0 #(BINARY_SIZE/2) u_reg_bin_sqrt_out(
            .i_clk(i_clk), // input clock
            .i_aclken(i_aclken), // input clock enable
            .i_rst_n(i_rst_n), // input reset
            .i_d(bin_sqrt_out),
            .o_q(bin_sqrt_out_dly));
    else
        assign bin_sqrt_out_dly = bin_sqrt_out;
else if (((BINARY_SIZE/2) + 2) % 16 != 0)
    if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/8) - (((BINARY_SIZE/2) + 2) / 16))
        ipsxe_floating_point_register_v1_0 #(BINARY_SIZE/2) u_reg_bin_sqrt_out(
            .i_clk(i_clk), // input clock
            .i_aclken(i_aclken), // input clock enable
            .i_rst_n(i_rst_n), // input reset
            .i_d(bin_sqrt_out),
            .o_q(bin_sqrt_out_dly));
    else
        assign bin_sqrt_out_dly = bin_sqrt_out;
else if (((BINARY_SIZE/2) + 2) % 32 != 0)
    if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/16) - (((BINARY_SIZE/2) + 2) / 32))
        ipsxe_floating_point_register_v1_0 #(BINARY_SIZE/2) u_reg_bin_sqrt_out(
            .i_clk(i_clk), // input clock
            .i_aclken(i_aclken), // input clock enable
            .i_rst_n(i_rst_n), // input reset
            .i_d(bin_sqrt_out),
            .o_q(bin_sqrt_out_dly));
    else
        assign bin_sqrt_out_dly = bin_sqrt_out;
else // if (((BINARY_SIZE/2) + 2) % 64 != 0)
    if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/32) - (((BINARY_SIZE/2) + 2) / 64))
        ipsxe_floating_point_register_v1_0 #(BINARY_SIZE/2) u_reg_bin_sqrt_out(
            .i_clk(i_clk), // input clock
            .i_aclken(i_aclken), // input clock enable
            .i_rst_n(i_rst_n), // input reset
            .i_d(bin_sqrt_out),
            .o_q(bin_sqrt_out_dly));
    else
        assign bin_sqrt_out_dly = bin_sqrt_out;

endgenerate

// round to nearest even
ipsxe_floating_point_bin2man_v1_0 #(MANTISSA_SIZE, BINARY_SIZE, RNE) u_bin2man (
    .i_bin(bin_sqrt_out_dly),
    .o_man(sqrt_man)
);

// this pipeline stage number is PIPE_STAGE_NUM_MAX, also (BINARY_SIZE/2) + 3
generate
if (PIPE_STAGE_NUM_MAX % 2 != 0)
    if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (PIPE_STAGE_NUM_MAX / 2))
        ipsxe_floating_point_register_v1_0 #(MANTISSA_SIZE) u_reg_sqrt_man(
            .i_clk(i_clk), // input clock
            .i_aclken(i_aclken), // input clock enable
            .i_rst_n(i_rst_n), // input reset
            .i_d(sqrt_man),
            .o_q(o_sqrt_man));
    else
        assign o_sqrt_man = sqrt_man;
else if (PIPE_STAGE_NUM_MAX % 4 != 0)
    if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/2) - (PIPE_STAGE_NUM_MAX / 4))
        ipsxe_floating_point_register_v1_0 #(MANTISSA_SIZE) u_reg_sqrt_man(
            .i_clk(i_clk), // input clock
            .i_aclken(i_aclken), // input clock enable
            .i_rst_n(i_rst_n), // input reset
            .i_d(sqrt_man),
            .o_q(o_sqrt_man));
    else
        assign o_sqrt_man = sqrt_man;
else if (PIPE_STAGE_NUM_MAX % 8 != 0)
    if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/4) - (PIPE_STAGE_NUM_MAX / 8))
        ipsxe_floating_point_register_v1_0 #(MANTISSA_SIZE) u_reg_sqrt_man(
            .i_clk(i_clk), // input clock
            .i_aclken(i_aclken), // input clock enable
            .i_rst_n(i_rst_n), // input reset
            .i_d(sqrt_man),
            .o_q(o_sqrt_man));
    else
        assign o_sqrt_man = sqrt_man;
else if (PIPE_STAGE_NUM_MAX % 16 != 0)
    if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/8) - (PIPE_STAGE_NUM_MAX / 16))
        ipsxe_floating_point_register_v1_0 #(MANTISSA_SIZE) u_reg_sqrt_man(
            .i_clk(i_clk), // input clock
            .i_aclken(i_aclken), // input clock enable
            .i_rst_n(i_rst_n), // input reset
            .i_d(sqrt_man),
            .o_q(o_sqrt_man));
    else
        assign o_sqrt_man = sqrt_man;
else if (PIPE_STAGE_NUM_MAX % 32 != 0)
    if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/16) - (PIPE_STAGE_NUM_MAX / 32))
        ipsxe_floating_point_register_v1_0 #(MANTISSA_SIZE) u_reg_sqrt_man(
            .i_clk(i_clk), // input clock
            .i_aclken(i_aclken), // input clock enable
            .i_rst_n(i_rst_n), // input reset
            .i_d(sqrt_man),
            .o_q(o_sqrt_man));
    else
        assign o_sqrt_man = sqrt_man;
else // if (PIPE_STAGE_NUM_MAX % 64 != 0)
    if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/32) - (PIPE_STAGE_NUM_MAX / 64))
        ipsxe_floating_point_register_v1_0 #(MANTISSA_SIZE) u_reg_sqrt_man(
            .i_clk(i_clk), // input clock
            .i_aclken(i_aclken), // input clock enable
            .i_rst_n(i_rst_n), // input reset
            .i_d(sqrt_man),
            .o_q(o_sqrt_man));
    else
        assign o_sqrt_man = sqrt_man;

endgenerate

endmodule