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
// Filename: ipsxe_floating_point_sqrt_binary_v1_0.v
// Function: This module calculates the square-root of a binary number.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_sqrt_binary_v1_0 #(parameter SIZE = 8'd108, HALF_SIZE = 8'd54, MANTISSA_SIZE = 23, LATENCY_CONFIG = 1, PIPE_STAGE_NUM_MAX = 1) (
    input i_clk,
    input i_aclken,
    input i_rst_n,
    input [SIZE-1 : 0] i_p,
    output [HALF_SIZE - 1:0] o_u
);
// This module calculates the square-root (o_u) of a binary number (i_p),
// using the modified non-restoring square-root algorithm
// Reference paper: An Efficient Implementation of the Non Restoring Square Root Algorithm in Gate Level. Author: Tole Sutikno

wire [SIZE-1:0] p [HALF_SIZE-1:0]; // p[i] keeps the "differences of remainder and guessed subtractor" in pipeline stage i, and the remaining lower bits of the radicand
wire [SIZE-1:0] r [HALF_SIZE-1-1:0]; // r[i] = p[i] delay 1 i_clk
wire [HALF_SIZE-1:0] u [HALF_SIZE-1:0]; // keep sqrt outputs of each pipeline stage

assign o_u = u[HALF_SIZE-1];

// take the 2 most significand bits of the radicand, and subtract it by the guessed subtractor 2'b01
// If the result is non-negtive, then the square-root of this two-bit number is 1,
// otherwise the square-root of this 2-bit number is 0, and the subtraction result is replaced by the original 2-bit of the radicand
assign p[0][SIZE-1:SIZE-2] = i_p[SIZE-1:SIZE-2] - 2'b01;
assign p[0][SIZE-3:0] = i_p[SIZE-3:0];
assign u[0][HALF_SIZE-1] = (i_p[SIZE-1:SIZE-2] >= 2'b01);

// add pipeline stages, and repeat the above steps
// pipeline stage 3 to HALF_SIZE + 1
generate
genvar i, j;
if (SIZE > 4) begin
for (i = 0; i <= HALF_SIZE - 2; i = 1 + i) begin: genblk_size_gt_4
    if (SIZE-1-(i+1)*2-1 > (SIZE-1-(2+MANTISSA_SIZE))) begin
        ipm_distributed_shiftregister_wrapper_v1_3 #(i+1, 2) u_shift_register (
            .din(p[0][SIZE-1-(i+1)*2-:2]),      // input [12:0]
            .clk(i_clk),      // input
            .i_aclken(i_aclken),
            .rst(~i_rst_n),      // input
            .dout(r[i][SIZE-1-(i+1)*2-:2])     // output [12:0]
        );
    end else if (SIZE-1-(i+1)*2-1 == (SIZE-1-(2+MANTISSA_SIZE))) begin
        ipm_distributed_shiftregister_wrapper_v1_3 #(i+1, 1) u_shift_register (
            .din(p[0][SIZE-1-(i+1)*2-:1]),      // input [12:0]
            .clk(i_clk),      // input
            .i_aclken(i_aclken),
            .rst(~i_rst_n),      // input
            .dout(r[i][SIZE-1-(i+1)*2-:1])     // output [12:0]
        );
    end
    // i+3 is the pipeline stage number of this register
    // the first pipeline stage is "pipeline stage 1" in the ipsxe_floating_point_sqrt_v1_0 module
    if ((i+3) % 2 != 0)
        if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - ((i+3) / 2))
            // add a pipeline stage
            if (SIZE-1-(i+1)*2 >= (SIZE-1-(2+MANTISSA_SIZE))) begin
                ipsxe_floating_point_register_v1_0 #(i+1 + i+2) u_reg_p_r_half0(
                    .i_clk(i_clk), // input clock
                    .i_aclken(i_aclken), // input clock enable
                    .i_rst_n(i_rst_n), // input reset
                    .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i-:(i+2)]}),
                    .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i-:(i+2)]}));
                assign r[i][(SIZE-1-(2+MANTISSA_SIZE)):0] = {(SIZE-(2+MANTISSA_SIZE)){1'b0}};
            end else begin
                if (MANTISSA_SIZE[0]) begin
                    if ((SIZE-1-(i+1)*2) + 1 == (SIZE-1-(2+MANTISSA_SIZE))) begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i+1) u_reg_p_r_mid0_man_odd(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+1)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+1)]}));
                        assign r[i][SIZE-1-(i+1)*2+1] = 1'b1; // r[i][SIZE-1-(i+1)*2+1] = u[i+1][HALF_SIZE-1-i] ? 1'b0 - 1'b1 : 1'b0 + 1'b1; so it is always 1'b1
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end else begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i-1) u_reg_p_r_all0_man_odd(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}));
                        assign r[i][(SIZE-1-(i+1)*2+1)+:3] = 3'b111; // r[i][(SIZE-1-(i+1)*2+1)+:3] = u[i+1][HALF_SIZE-1-i] ? 3'b100 - 3'b101 : 3'b100 + 3'b011; so it is always 3'b111
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end
                end else begin
                    if ((SIZE-1-(i+1)*2) + 2 == (SIZE-1-(2+MANTISSA_SIZE))) begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i) u_reg_p_r_mid0_man_even(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+2)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+2)]}));
                        assign r[i][(SIZE-1-(i+1)*2+1)+:2] = 2'b11; // r[i][(SIZE-1-(i+1)*2+1)+:2] = u[i+1][HALF_SIZE-1-i] ? 2'b00 - 2'b01 : 2'b00 + 2'b11; so it is always 2'b11
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end else begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i-1) u_reg_p_r_all0_man_even(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}));
                        assign r[i][(SIZE-1-(i+1)*2+1)+:3] = 3'b111; // r[i][(SIZE-1-(i+1)*2+1)+:3] = u[i+1][HALF_SIZE-1-i] ? 3'b100 - 3'b101 : 3'b100 + 3'b011; so it is always 3'b111
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end
                end
            end
        else
            assign {u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:0]} = {u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:0]};
    else if ((i+3) % 4 != 0)
        if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/2) - ((i+3) / 4))
            // add a pipeline stage
            if (SIZE-1-(i+1)*2 >= (SIZE-1-(2+MANTISSA_SIZE))) begin
                ipsxe_floating_point_register_v1_0 #(i+1 + i+2) u_reg_p_r_half0(
                    .i_clk(i_clk), // input clock
                    .i_aclken(i_aclken), // input clock enable
                    .i_rst_n(i_rst_n), // input reset
                    .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i-:(i+2)]}),
                    .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i-:(i+2)]}));
                assign r[i][(SIZE-1-(2+MANTISSA_SIZE)):0] = {(SIZE-(2+MANTISSA_SIZE)){1'b0}};
            end else begin
                if (MANTISSA_SIZE[0]) begin
                    if ((SIZE-1-(i+1)*2) + 1 == (SIZE-1-(2+MANTISSA_SIZE))) begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i+1) u_reg_p_r_mid0_man_odd(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+1)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+1)]}));
                        assign r[i][SIZE-1-(i+1)*2+1] = 1'b1; // r[i][SIZE-1-(i+1)*2+1] = u[i+1][HALF_SIZE-1-i] ? 1'b0 - 1'b1 : 1'b0 + 1'b1; so it is always 1'b1
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end else begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i-1) u_reg_p_r_all0_man_odd(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}));
                        assign r[i][(SIZE-1-(i+1)*2+1)+:3] = 3'b111; // r[i][(SIZE-1-(i+1)*2+1)+:3] = u[i+1][HALF_SIZE-1-i] ? 3'b100 - 3'b101 : 3'b100 + 3'b011; so it is always 3'b111
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end
                end else begin
                    if ((SIZE-1-(i+1)*2) + 2 == (SIZE-1-(2+MANTISSA_SIZE))) begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i) u_reg_p_r_mid0_man_even(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+2)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+2)]}));
                        assign r[i][(SIZE-1-(i+1)*2+1)+:2] = 2'b11; // r[i][(SIZE-1-(i+1)*2+1)+:2] = u[i+1][HALF_SIZE-1-i] ? 2'b00 - 2'b01 : 2'b00 + 2'b11; so it is always 2'b11
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end else begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i-1) u_reg_p_r_all0_man_even(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}));
                        assign r[i][(SIZE-1-(i+1)*2+1)+:3] = 3'b111; // r[i][(SIZE-1-(i+1)*2+1)+:3] = u[i+1][HALF_SIZE-1-i] ? 3'b100 - 3'b101 : 3'b100 + 3'b011; so it is always 3'b111
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end
                end
            end
        else
            assign {u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:0]} = {u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:0]};
    else if ((i+3) % 8 != 0)
        if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/4) - ((i+3) / 8))
            // add a pipeline stage
            if (SIZE-1-(i+1)*2 >= (SIZE-1-(2+MANTISSA_SIZE))) begin
                ipsxe_floating_point_register_v1_0 #(i+1 + i+2) u_reg_p_r_half0(
                    .i_clk(i_clk), // input clock
                    .i_aclken(i_aclken), // input clock enable
                    .i_rst_n(i_rst_n), // input reset
                    .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i-:(i+2)]}),
                    .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i-:(i+2)]}));
                assign r[i][(SIZE-1-(2+MANTISSA_SIZE)):0] = {(SIZE-(2+MANTISSA_SIZE)){1'b0}};
            end else begin
                if (MANTISSA_SIZE[0]) begin
                    if ((SIZE-1-(i+1)*2) + 1 == (SIZE-1-(2+MANTISSA_SIZE))) begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i+1) u_reg_p_r_mid0_man_odd(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+1)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+1)]}));
                        assign r[i][SIZE-1-(i+1)*2+1] = 1'b1; // r[i][SIZE-1-(i+1)*2+1] = u[i+1][HALF_SIZE-1-i] ? 1'b0 - 1'b1 : 1'b0 + 1'b1; so it is always 1'b1
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end else begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i-1) u_reg_p_r_all0_man_odd(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}));
                        assign r[i][(SIZE-1-(i+1)*2+1)+:3] = 3'b111; // r[i][(SIZE-1-(i+1)*2+1)+:3] = u[i+1][HALF_SIZE-1-i] ? 3'b100 - 3'b101 : 3'b100 + 3'b011; so it is always 3'b111
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end
                end else begin
                    if ((SIZE-1-(i+1)*2) + 2 == (SIZE-1-(2+MANTISSA_SIZE))) begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i) u_reg_p_r_mid0_man_even(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+2)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+2)]}));
                        assign r[i][(SIZE-1-(i+1)*2+1)+:2] = 2'b11; // r[i][(SIZE-1-(i+1)*2+1)+:2] = u[i+1][HALF_SIZE-1-i] ? 2'b00 - 2'b01 : 2'b00 + 2'b11; so it is always 2'b11
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end else begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i-1) u_reg_p_r_all0_man_even(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}));
                        assign r[i][(SIZE-1-(i+1)*2+1)+:3] = 3'b111; // r[i][(SIZE-1-(i+1)*2+1)+:3] = u[i+1][HALF_SIZE-1-i] ? 3'b100 - 3'b101 : 3'b100 + 3'b011; so it is always 3'b111
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end
                end
            end
        else
            assign {u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:0]} = {u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:0]};
    else if ((i+3) % 16 != 0)
        if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/8) - ((i+3) / 16))
            // add a pipeline stage
            if (SIZE-1-(i+1)*2 >= (SIZE-1-(2+MANTISSA_SIZE))) begin
                ipsxe_floating_point_register_v1_0 #(i+1 + i+2) u_reg_p_r_half0(
                    .i_clk(i_clk), // input clock
                    .i_aclken(i_aclken), // input clock enable
                    .i_rst_n(i_rst_n), // input reset
                    .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i-:(i+2)]}),
                    .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i-:(i+2)]}));
                assign r[i][(SIZE-1-(2+MANTISSA_SIZE)):0] = {(SIZE-(2+MANTISSA_SIZE)){1'b0}};
            end else begin
                if (MANTISSA_SIZE[0]) begin
                    if ((SIZE-1-(i+1)*2) + 1 == (SIZE-1-(2+MANTISSA_SIZE))) begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i+1) u_reg_p_r_mid0_man_odd(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+1)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+1)]}));
                        assign r[i][SIZE-1-(i+1)*2+1] = 1'b1; // r[i][SIZE-1-(i+1)*2+1] = u[i+1][HALF_SIZE-1-i] ? 1'b0 - 1'b1 : 1'b0 + 1'b1; so it is always 1'b1
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end else begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i-1) u_reg_p_r_all0_man_odd(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}));
                        assign r[i][(SIZE-1-(i+1)*2+1)+:3] = 3'b111; // r[i][(SIZE-1-(i+1)*2+1)+:3] = u[i+1][HALF_SIZE-1-i] ? 3'b100 - 3'b101 : 3'b100 + 3'b011; so it is always 3'b111
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end
                end else begin
                    if ((SIZE-1-(i+1)*2) + 2 == (SIZE-1-(2+MANTISSA_SIZE))) begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i) u_reg_p_r_mid0_man_even(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+2)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+2)]}));
                        assign r[i][(SIZE-1-(i+1)*2+1)+:2] = 2'b11; // r[i][(SIZE-1-(i+1)*2+1)+:2] = u[i+1][HALF_SIZE-1-i] ? 2'b00 - 2'b01 : 2'b00 + 2'b11; so it is always 2'b11
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end else begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i-1) u_reg_p_r_all0_man_even(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}));
                        assign r[i][(SIZE-1-(i+1)*2+1)+:3] = 3'b111; // r[i][(SIZE-1-(i+1)*2+1)+:3] = u[i+1][HALF_SIZE-1-i] ? 3'b100 - 3'b101 : 3'b100 + 3'b011; so it is always 3'b111
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end
                end
            end
        else
            assign {u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:0]} = {u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:0]};
    else if ((i+3) % 32 != 0)
        if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/16) - ((i+3) / 32))
            // add a pipeline stage
            if (SIZE-1-(i+1)*2 >= (SIZE-1-(2+MANTISSA_SIZE))) begin
                ipsxe_floating_point_register_v1_0 #(i+1 + i+2) u_reg_p_r_half0(
                    .i_clk(i_clk), // input clock
                    .i_aclken(i_aclken), // input clock enable
                    .i_rst_n(i_rst_n), // input reset
                    .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i-:(i+2)]}),
                    .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i-:(i+2)]}));
                assign r[i][(SIZE-1-(2+MANTISSA_SIZE)):0] = {(SIZE-(2+MANTISSA_SIZE)){1'b0}};
            end else begin
                if (MANTISSA_SIZE[0]) begin
                    if ((SIZE-1-(i+1)*2) + 1 == (SIZE-1-(2+MANTISSA_SIZE))) begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i+1) u_reg_p_r_mid0_man_odd(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+1)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+1)]}));
                        assign r[i][SIZE-1-(i+1)*2+1] = 1'b1; // r[i][SIZE-1-(i+1)*2+1] = u[i+1][HALF_SIZE-1-i] ? 1'b0 - 1'b1 : 1'b0 + 1'b1; so it is always 1'b1
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end else begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i-1) u_reg_p_r_all0_man_odd(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}));
                        assign r[i][(SIZE-1-(i+1)*2+1)+:3] = 3'b111; // r[i][(SIZE-1-(i+1)*2+1)+:3] = u[i+1][HALF_SIZE-1-i] ? 3'b100 - 3'b101 : 3'b100 + 3'b011; so it is always 3'b111
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end
                end else begin
                    if ((SIZE-1-(i+1)*2) + 2 == (SIZE-1-(2+MANTISSA_SIZE))) begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i) u_reg_p_r_mid0_man_even(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+2)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+2)]}));
                        assign r[i][(SIZE-1-(i+1)*2+1)+:2] = 2'b11; // r[i][(SIZE-1-(i+1)*2+1)+:2] = u[i+1][HALF_SIZE-1-i] ? 2'b00 - 2'b01 : 2'b00 + 2'b11; so it is always 2'b11
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end else begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i-1) u_reg_p_r_all0_man_even(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}));
                        assign r[i][(SIZE-1-(i+1)*2+1)+:3] = 3'b111; // r[i][(SIZE-1-(i+1)*2+1)+:3] = u[i+1][HALF_SIZE-1-i] ? 3'b100 - 3'b101 : 3'b100 + 3'b011; so it is always 3'b111
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end
                end
            end
        else
            assign {u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:0]} = {u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:0]};
    else // if ((i+3) % 64 != 0)
        if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/32) - ((i+3) / 64))
            // add a pipeline stage
            if (SIZE-1-(i+1)*2 >= (SIZE-1-(2+MANTISSA_SIZE))) begin
                ipsxe_floating_point_register_v1_0 #(i+1 + i+2) u_reg_p_r_half0(
                    .i_clk(i_clk), // input clock
                    .i_aclken(i_aclken), // input clock enable
                    .i_rst_n(i_rst_n), // input reset
                    .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i-:(i+2)]}),
                    .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i-:(i+2)]}));
                assign r[i][(SIZE-1-(2+MANTISSA_SIZE)):0] = {(SIZE-(2+MANTISSA_SIZE)){1'b0}};
            end else begin
                if (MANTISSA_SIZE[0]) begin
                    if ((SIZE-1-(i+1)*2) + 1 == (SIZE-1-(2+MANTISSA_SIZE))) begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i+1) u_reg_p_r_mid0_man_odd(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+1)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+1)]}));
                        assign r[i][SIZE-1-(i+1)*2+1] = 1'b1; // r[i][SIZE-1-(i+1)*2+1] = u[i+1][HALF_SIZE-1-i] ? 1'b0 - 1'b1 : 1'b0 + 1'b1; so it is always 1'b1
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end else begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i-1) u_reg_p_r_all0_man_odd(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}));
                        assign r[i][(SIZE-1-(i+1)*2+1)+:3] = 3'b111; // r[i][(SIZE-1-(i+1)*2+1)+:3] = u[i+1][HALF_SIZE-1-i] ? 3'b100 - 3'b101 : 3'b100 + 3'b011; so it is always 3'b111
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end
                end else begin
                    if ((SIZE-1-(i+1)*2) + 2 == (SIZE-1-(2+MANTISSA_SIZE))) begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i) u_reg_p_r_mid0_man_even(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+2)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+2)]}));
                        assign r[i][(SIZE-1-(i+1)*2+1)+:2] = 2'b11; // r[i][(SIZE-1-(i+1)*2+1)+:2] = u[i+1][HALF_SIZE-1-i] ? 2'b00 - 2'b01 : 2'b00 + 2'b11; so it is always 2'b11
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end else begin
                        ipsxe_floating_point_register_v1_0 #(i+1 + i-1) u_reg_p_r_all0_man_even(
                            .i_clk(i_clk), // input clock
                            .i_aclken(i_aclken), // input clock enable
                            .i_rst_n(i_rst_n), // input reset
                            .i_d({u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}),
                            .o_q({u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:((SIZE-1-(i+1)*2+1)+3)]}));
                        assign r[i][(SIZE-1-(i+1)*2+1)+:3] = 3'b111; // r[i][(SIZE-1-(i+1)*2+1)+:3] = u[i+1][HALF_SIZE-1-i] ? 3'b100 - 3'b101 : 3'b100 + 3'b011; so it is always 3'b111
                        assign r[i][SIZE-1-(i+1)*2:0] = {(SIZE-1-(i+1)*2+1){1'b0}};
                    end
                end
            end
        else
            assign {u[i+1][HALF_SIZE-1-:(i+1)], r[i][SIZE-1-i:0]} = {u[i+0][HALF_SIZE-1-:(i+1)], p[i][SIZE-1-i:0]};

    // take the lower 2 bits of the radicand, and join it at the least significand end of the subtraction result of the last step,
    // and subtract it by {already calculated square-root bits, 2'b01}
    // If the result is non-negtive, then the square-root of this two-bit number is 1,
    // otherwise the square-root of this 2-bit number is 0, and the subtraction result is replaced by the original 2-bit of the radicand
    assign p[i+1][(SIZE-1-(i+2)*2+1)+:(i+4)] = u[i+1][HALF_SIZE-1-i] ? (r[i][SIZE-1-i-:(i+4)] - {1'b0, u[i+1][HALF_SIZE-1-:(i+1)], 2'b01}) : (r[i][SIZE-1-i-:(i+4)] + {1'b0, u[i+1][HALF_SIZE-1-:(i+1)], 2'b11});
    assign u[i+1][HALF_SIZE-1-(i+1)] = ~p[i+1][SIZE-1-i];
end
end
endgenerate

endmodule