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
// Filename: ipsxe_floating_point_latency_config_v1_0.v
// Function: This module generates a register or a wire.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_latency_config_v1_0 #(parameter N = 64, LATENCY_CONFIG = 1, PIPE_STAGE_NUM_MAX = 1, PIPE_STAGE_NUM = 1) (
    input i_clk,
    input i_aclken,
    input i_rst_n,
    input [N-1:0] i_d,
    output [N-1:0] o_q
);

// determine whether a pipeline stage should be inserted,
// according to the parameter LATENCY_CONFIG
generate
    if (PIPE_STAGE_NUM % 2 != 0)
        if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (PIPE_STAGE_NUM / 2))
            ipsxe_floating_point_register_v1_0 #(N) u_reg_stage(
                .i_clk(i_clk), // input clock
                .i_aclken(i_aclken), // input clock enable
                .i_rst_n(i_rst_n), // input reset
                .i_d(i_d), // input data
                .o_q(o_q) // output data
            );
        else
            assign o_q = i_d;
    else if (PIPE_STAGE_NUM % 4 != 0)
        if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/2) - (PIPE_STAGE_NUM / 4))
            ipsxe_floating_point_register_v1_0 #(N) u_reg_stage(
                .i_clk(i_clk), // input clock
                .i_aclken(i_aclken), // input clock enable
                .i_rst_n(i_rst_n), // input reset
                .i_d(i_d), // input data
                .o_q(o_q) // output data
            );
        else
            assign o_q = i_d;
    else if (PIPE_STAGE_NUM % 8 != 0)
        if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/4) - (PIPE_STAGE_NUM / 8))
            ipsxe_floating_point_register_v1_0 #(N) u_reg_stage(
                .i_clk(i_clk), // input clock
                .i_aclken(i_aclken), // input clock enable
                .i_rst_n(i_rst_n), // input reset
                .i_d(i_d), // input data
                .o_q(o_q) // output data
            );
        else
            assign o_q = i_d;
    else if (PIPE_STAGE_NUM % 16 != 0)
        if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/8) - (PIPE_STAGE_NUM / 16))
            ipsxe_floating_point_register_v1_0 #(N) u_reg_stage(
                .i_clk(i_clk), // input clock
                .i_aclken(i_aclken), // input clock enable
                .i_rst_n(i_rst_n), // input reset
                .i_d(i_d), // input data
                .o_q(o_q) // output data
            );
        else
            assign o_q = i_d;
    else if (PIPE_STAGE_NUM % 32 != 0)
        if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/16) - (PIPE_STAGE_NUM / 32))
            ipsxe_floating_point_register_v1_0 #(N) u_reg_stage(
                .i_clk(i_clk), // input clock
                .i_aclken(i_aclken), // input clock enable
                .i_rst_n(i_rst_n), // input reset
                .i_d(i_d), // input data
                .o_q(o_q) // output data
            );
        else
            assign o_q = i_d;
    else if (PIPE_STAGE_NUM % 64 != 0)
        if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/32) - (PIPE_STAGE_NUM / 64))
            ipsxe_floating_point_register_v1_0 #(N) u_reg_stage(
                .i_clk(i_clk), // input clock
                .i_aclken(i_aclken), // input clock enable
                .i_rst_n(i_rst_n), // input reset
                .i_d(i_d), // input data
                .o_q(o_q) // output data
            );
        else
            assign o_q = i_d;
    else // if (PIPE_STAGE_NUM % 128 != 0)
        if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/64) - (PIPE_STAGE_NUM / 128))
            ipsxe_floating_point_register_v1_0 #(N) u_reg_stage(
                .i_clk(i_clk), // input clock
                .i_aclken(i_aclken), // input clock enable
                .i_rst_n(i_rst_n), // input reset
                .i_d(i_d), // input data
                .o_q(o_q) // output data
            );
        else
            assign o_q = i_d;
endgenerate

endmodule