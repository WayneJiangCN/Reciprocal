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
// Filename: ipsxe_floating_point_fl2fl_top_v1_0.v
// Function: this module transfers a floating-point number to another
//           floating precision
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns
module ipsxe_floating_point_fl2fl_top_v1_0 #(
    parameter FLOAT_IN_EXP = 8,
    parameter FLOAT_IN_FRAC = 24,//include the hidden one
    parameter FLOAT_OUT_EXP = 11,
    parameter FLOAT_OUT_FRAC = 53,//include the hidden one
    parameter PRECISION_INPUT = 0,
    parameter LATENCY_CONFIG = 1
)(
    input i_aclk,
    input i_aclken,
    input i_areset_n,
    input [FLOAT_IN_EXP+FLOAT_IN_FRAC-1:0]i_axi4s_a_tdata,
    input i_axi4s_or_abcoperation_tvalid,
    output [FLOAT_OUT_EXP+FLOAT_OUT_FRAC-1:0] o_axi4s_result_tdata,
    output o_axi4s_result_tvalid,
    output reg o_overflow,
    output reg o_underflow
);

generate
if (PRECISION_INPUT == 0) begin // half
ipsxe_floating_point_fl2fl_half_v1_0 #(
    FLOAT_IN_EXP,
    FLOAT_IN_FRAC,//include the hidden one
    FLOAT_OUT_EXP,
    FLOAT_OUT_FRAC,//include the hidden one
    LATENCY_CONFIG
) u_fl2fl_half (
    .i_aclk(i_aclk),
    .i_aclken(i_aclken),
    .i_areset_n(i_areset_n),
    .i_axi4s_a_tdata(i_axi4s_a_tdata),
    .i_axi4s_or_abcoperation_tvalid(i_axi4s_or_abcoperation_tvalid),
    .o_axi4s_result_tdata(o_axi4s_result_tdata),
    .o_axi4s_result_tvalid(o_axi4s_result_tvalid),
    .o_overflow(o_overflow),
    .o_underflow(o_underflow)
);
end else begin // single, double, custom precision
ipsxe_floating_point_fl2fl_nothalf_v1_0 #(
    FLOAT_IN_EXP,
    FLOAT_IN_FRAC,//include the hidden one
    FLOAT_OUT_EXP,
    FLOAT_OUT_FRAC,//include the hidden one
    LATENCY_CONFIG
) u_fl2fl_nothalf (
    .i_aclk(i_aclk),
    .i_aclken(i_aclken),
    .i_areset_n(i_areset_n),
    .i_axi4s_a_tdata(i_axi4s_a_tdata),
    .i_axi4s_or_abcoperation_tvalid(i_axi4s_or_abcoperation_tvalid),
    .o_axi4s_result_tdata(o_axi4s_result_tdata),
    .o_axi4s_result_tvalid(o_axi4s_result_tvalid),
    .o_overflow(o_overflow),
    .o_underflow(o_underflow)
);
end
endgenerate

endmodule