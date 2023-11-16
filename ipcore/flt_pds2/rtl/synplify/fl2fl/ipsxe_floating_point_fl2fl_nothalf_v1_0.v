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
// Filename: ipsxe_floating_point_fl2fl_nothalf_v1_0.v
// Function: this module transfers a floating-point number to another
//           floating precision
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_fl2fl_nothalf_v1_0 #(
    parameter FLOAT_IN_EXP = 11,
    parameter FLOAT_IN_FRAC = 53, //include the hidden one
    parameter FLOAT_OUT_EXP = 8,
    parameter FLOAT_OUT_FRAC = 24, //include the hidden one
    parameter LATENCY_CONFIG = 1
)
(
    input i_aclk,
    input i_aclken,
    input i_areset_n,
    input [FLOAT_IN_EXP+FLOAT_IN_FRAC-1:0] i_axi4s_a_tdata,
    input i_axi4s_or_abcoperation_tvalid,
    output [FLOAT_OUT_EXP+FLOAT_OUT_FRAC-1:0] o_axi4s_result_tdata,
    output o_axi4s_result_tvalid,
    output o_overflow,
    output o_underflow
);

////////////////////////////////////////////////////////////////
wire sign;
wire [FLOAT_IN_EXP-1:0] exp_in;
wire [FLOAT_IN_FRAC-2:0] frac_in;

wire [1:0] case_judge;

////////////////////////////////////////////////////////////////
ipsxe_floating_point_input_decode_v1_0 #(
    .FLOAT_IN_EXP   ( FLOAT_IN_EXP   ),
    .FLOAT_IN_FRAC  ( FLOAT_IN_FRAC  ),
    .FLOAT_OUT_EXP  ( FLOAT_OUT_EXP  ),
    .FLOAT_OUT_FRAC ( FLOAT_OUT_FRAC )
) u_input_decode (
    .i_aclk(i_aclk),
    .i_aclken(i_aclken),
    .i_areset_n(i_areset_n),
    .data_in(i_axi4s_a_tdata),

    .sign(sign),
    .exp_in(exp_in),
    .frac_in(frac_in),
    .case_judge(case_judge),
    .o_overflow(o_overflow),
    .o_underflow(o_underflow)
);

////////////////////////////////////////////////////////////////
generate
    if(FLOAT_IN_FRAC > FLOAT_OUT_FRAC) begin
        wire [FLOAT_OUT_FRAC-1:0] frac_mid;

        ipsxe_floating_point_frac_round_v1_0 #(
            .FLOAT_IN_FRAC  ( FLOAT_IN_FRAC  ),
            .FLOAT_OUT_FRAC ( FLOAT_OUT_FRAC )
        ) u_frac_round (
            .frac_in(frac_in),
            .frac_mid(frac_mid)
        );

        ipsxe_floating_point_output_encode_v1_0 #(
            .FRAC_MID_WIDTH ( FLOAT_OUT_FRAC ), 
            .FLOAT_IN_EXP   ( FLOAT_IN_EXP   ), 
            .FLOAT_IN_FRAC  ( FLOAT_IN_FRAC  ),
            .FLOAT_OUT_EXP  ( FLOAT_OUT_EXP  ), 
            .FLOAT_OUT_FRAC ( FLOAT_OUT_FRAC )
        ) u_output_encode (
            .i_aclk(i_aclk),
            .i_aclken(i_aclken),
            .i_areset_n(i_areset_n),
            .sign(sign),
            .frac_mid(frac_mid),
            .exp_in(exp_in),
            .case_judge(case_judge),

            .data_out(o_axi4s_result_tdata)
        );
    end
    else begin
        ipsxe_floating_point_output_encode_v1_0 #(
            .FRAC_MID_WIDTH ( FLOAT_IN_FRAC-1 ), 
            .FLOAT_IN_EXP   ( FLOAT_IN_EXP    ), 
            .FLOAT_IN_FRAC  ( FLOAT_IN_FRAC   ),
            .FLOAT_OUT_EXP  ( FLOAT_OUT_EXP   ), 
            .FLOAT_OUT_FRAC ( FLOAT_OUT_FRAC  )
        ) u_output_encode (
            .i_aclk(i_aclk),
            .i_aclken(i_aclken),
            .i_areset_n(i_areset_n),
            .sign(sign),
            .frac_mid(frac_in),
            .exp_in(exp_in),
            .case_judge(case_judge),

            .data_out(o_axi4s_result_tdata)
        );
    end
endgenerate

////////////////////////////////////////////////////////////////
    ipsxe_floating_point_register_v1_0 #(1) u_reg_m_axis_result_tvalid(
        .i_clk(i_aclk),
        .i_aclken(i_aclken),
        .i_rst_n(i_areset_n),
        .i_d(i_axi4s_or_abcoperation_tvalid),
        .o_q(o_axi4s_result_tvalid)
    );



endmodule