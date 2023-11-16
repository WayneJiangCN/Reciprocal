
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
// Filename:ipsxe_floating_point_log_axi_top_v1_0.v
// Function: p=ln(z)
//           zsize:z > 0
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_log_axi_top_v1_0 #(
    parameter FLOAT_EXP_WIDTH = 8,
    parameter FLOAT_FRAC_WIDTH = 24,
    parameter ITERATION_NUM = 32,
    parameter PRECISION_INPUT = 0
)
(
    input i_clk, //aclk
    input i_aclken,
    input i_rst_n, //aresetn
    input [FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1:0] i_data, //s_axis_a_tdata
    input i_valid, //s_axis_a_tvalid
    output [FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1:0] o_ln_float, //m_axis_result_tdata
    output o_invalid_op,
    output o_overflow, 
    output o_underflow,
    output o_valid //m_axis_result_tvalid
);

    generate
        genvar log;
        if (PRECISION_INPUT == 0) begin // half precision
            ipsxe_floating_point_log_32_axi_v1_0 #(
            FLOAT_EXP_WIDTH,
            FLOAT_FRAC_WIDTH,
            12,
            13
            ) u_log_32_axi(
                i_clk, //aclk
                i_aclken,
                i_rst_n, //aresetn
                i_data, //s_axis_a_tdata
                i_valid, //s_axis_a_tvalid
                o_ln_float, //m_axis_result_tdata
                o_invalid_op,
                o_overflow, 
                o_underflow,
                o_valid //m_axis_result_tvalid
            );
        end
        if (PRECISION_INPUT == 1) begin // single precision
            ipsxe_floating_point_log_32_axi_v1_0 #(
            FLOAT_EXP_WIDTH,
            FLOAT_FRAC_WIDTH,
            12,
            10
            ) u_log_32_axi(
                i_clk, //aclk
                i_aclken,
                i_rst_n, //aresetn
                i_data, //s_axis_a_tdata
                i_valid, //s_axis_a_tvalid
                o_ln_float, //m_axis_result_tdata
                o_invalid_op,
                o_overflow, 
                o_underflow,
                o_valid //m_axis_result_tvalid
            );
        end
        else begin // double precision
            ipsxe_floating_point_log_64_axi_v1_0 #(
            FLOAT_EXP_WIDTH,
            FLOAT_FRAC_WIDTH,
            3
            ) u_log_64_axi(
                i_clk, //aclk
                i_aclken,
                i_rst_n, //aresetn
                i_data, //s_axis_a_tdata
                i_valid, //s_axis_a_tvalid
                o_ln_float, //m_axis_result_tdata
                o_invalid_op,
                o_overflow, 
                o_underflow,
                o_valid //m_axis_result_tvalid
            );
        end
    endgenerate


endmodule