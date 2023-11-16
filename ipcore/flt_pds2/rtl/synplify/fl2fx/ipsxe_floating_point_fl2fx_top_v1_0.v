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
// Filename: ipsxe_floating_point_fl2fx_top_v1_0.v
// Function: this module transfers a floating-point number to the fixed-
//           point number
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_fl2fx_top_v1_0 #(
    parameter FLOAT_EXP_BIT = 8,
    parameter FLOAT_FRAC_BIT = 24, //include the hidden one
    parameter FIXED_INT_BIT = 32, //include sign bit
    parameter FIXED_FRAC_BIT = 0,
    parameter PRECISION_INPUT = 0,
    parameter LATENCY_CONFIG = 1
) (
    input i_aclk,
    input i_aclken,
    input i_areset_n,
    input [FLOAT_EXP_BIT+FLOAT_FRAC_BIT-1:0] i_axi4s_a_tdata,
    input i_axi4s_or_abcoperation_tvalid,
    output reg [FIXED_INT_BIT+FIXED_FRAC_BIT-1:0] o_axi4s_result_tdata, //with 1 sign bit
    output o_axi4s_result_tvalid,
    output o_invalid_op,
    output o_overflow
);

generate
if (PRECISION_INPUT == 0) begin // half
ipsxe_floating_point_fl2fx_half_v1_0 #(
    FLOAT_EXP_BIT,
    FLOAT_FRAC_BIT, //include the hidden one
    FIXED_INT_BIT, //include sign bit
    FIXED_FRAC_BIT,
    LATENCY_CONFIG
) u_fl2fx_half (
    .i_aclk(i_aclk),
    .i_aclken(i_aclken),
    .i_areset_n(i_areset_n),
    .i_axi4s_a_tdata(i_axi4s_a_tdata),
    .i_axi4s_or_abcoperation_tvalid(i_axi4s_or_abcoperation_tvalid),
    .o_axi4s_result_tdata(o_axi4s_result_tdata),
    .o_axi4s_result_tvalid(o_axi4s_result_tvalid),
    .o_invalid_op(o_invalid_op),
    .o_overflow(o_overflow)
);
end else begin // double precision
ipsxe_floating_point_fl2fx_nothalf_v1_0 #(
    FLOAT_EXP_BIT,
    FLOAT_FRAC_BIT, //include the hidden one
    FIXED_INT_BIT, //include sign bit
    FIXED_FRAC_BIT,
    LATENCY_CONFIG
) u_fl2fx_nothalf (
    .i_aclk(i_aclk),
    .i_aclken(i_aclken),
    .i_areset_n(i_areset_n),
    .i_axi4s_a_tdata(i_axi4s_a_tdata),
    .i_axi4s_or_abcoperation_tvalid(i_axi4s_or_abcoperation_tvalid),
    .o_axi4s_result_tdata(o_axi4s_result_tdata),
    .o_axi4s_result_tvalid(o_axi4s_result_tvalid),
    .o_invalid_op(o_invalid_op),
    .o_overflow(o_overflow)
);
end
endgenerate

endmodule