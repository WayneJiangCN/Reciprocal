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
// Filename: ipsxe_floating_point_invsqrt_v1_0.v
// Function: This module calculates the inverse square-root
//           of the single or double precision floating-point numbers.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_invsqrt_v1_0 #(parameter EXP_WIDTH = 11, MAN_WIDTH = 52, RNE = 2, RNE1 = 49, RNE2 = 52, APM_USAGE = 0, PRECISION_INPUT = 0, LATENCY_CONFIG = 1) (
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

generate
if (PRECISION_INPUT == 0 || PRECISION_INPUT == 1) begin // half or single precision
if (APM_USAGE == 0) begin
ipsxe_floating_point_invsqrt_32_apm_no_v1_0 #(EXP_WIDTH, MAN_WIDTH, RNE, RNE1, RNE2, LATENCY_CONFIG) u_invsqrt_32 (
    .i_clk(i_clk), // input clock
    .i_aclken(i_aclken), // input clock enable
    .i_rst_n(i_rst_n), // input reset
    .i_valid(i_valid), // input valid
    .i_x_norm_or_denorm(i_x_norm_or_denorm), // input data
    .o_valid(o_valid), // output valid
    .o_invsqrt_x(o_invsqrt_x), // output data
    .o_invalid_op(o_invalid_op), // output invalid operation signal
    .o_divide_by_zero(o_divide_by_zero) // output divide by zero signal
);
end else begin // APM_USAGE == 2
ipsxe_floating_point_invsqrt_32_apm_full_v1_0 #(EXP_WIDTH, MAN_WIDTH, RNE, RNE1, RNE2, LATENCY_CONFIG) u_invsqrt_32 (
    .i_clk(i_clk), // input clock
    .i_aclken(i_aclken), // input clock enable
    .i_rst_n(i_rst_n), // input reset
    .i_valid(i_valid), // input valid
    .i_x_norm_or_denorm(i_x_norm_or_denorm), // input data
    .o_valid(o_valid), // output valid
    .o_invsqrt_x(o_invsqrt_x), // output data
    .o_invalid_op(o_invalid_op), // output invalid operation signal
    .o_divide_by_zero(o_divide_by_zero) // output divide by zero signal
);
end
end else begin // double precision
ipsxe_floating_point_invsqrt_64_apm_v1_0 #(EXP_WIDTH, MAN_WIDTH, RNE, RNE1, RNE2, LATENCY_CONFIG, APM_USAGE) u_invsqrt_64 (
    .i_clk(i_clk), // input clock
    .i_aclken(i_aclken), // input clock enable
    .i_rst_n(i_rst_n), // input reset
    .i_valid(i_valid), // input valid
    .i_x_norm_or_denorm(i_x_norm_or_denorm), // input data
    .o_valid(o_valid), // output valid
    .o_invsqrt_x(o_invsqrt_x), // output data
    .o_invalid_op(o_invalid_op), // output invalid operation signal
    .o_divide_by_zero(o_divide_by_zero) // output divide by zero signal
);
end
endgenerate

endmodule