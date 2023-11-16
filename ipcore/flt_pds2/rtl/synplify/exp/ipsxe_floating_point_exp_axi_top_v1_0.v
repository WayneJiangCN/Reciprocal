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
// Filename:ipsxe_floating_point_exp_axi_top_v1_0.v
// Function: p=e^z
//           zsize:z < 8
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_exp_axi_top_v1_0 #(
    parameter FLOAT_EXP_WIDTH = 8,
    parameter FLOAT_FRAC_WIDTH = 24,
    parameter DATA_WIDTH = 29,
    parameter DATA_WIDTH_CUT = 29,
    parameter ITERATION_NUM = 10,
    parameter PRECISION_INPUT = 0,
    parameter LATENCY_CONFIG = 1
)
(
    input i_clk,
    input i_aclken,
    input i_rst_n, //aresetn
    input [FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1:0] i_data_float, //s_axis_a_tdata
    input i_valid, //s_axis_a_tvalid
    output [FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1:0] o_exp_float, //m_axis_result_tdata
    output o_overflow, 
    output o_underflow,
    output o_valid //m_axis_result_tvalid
);

    generate
        genvar exp;
        if (PRECISION_INPUT == 0) begin // half precision
/*
            ipsxe_floating_point_exp_16_axi_v1_0 #(
                FLOAT_EXP_WIDTH,
                FLOAT_FRAC_WIDTH,
                11,
                11,
                7,
                0,
                LATENCY_CONFIG
            ) u_exp_32_axi(
                i_clk,
                i_aclken,
                i_rst_n, //aresetn
                i_data_float, //s_axis_a_tdata
                i_valid, //s_axis_a_tvalid
                o_exp_float, //m_axis_result_tdata
                o_overflow, 
                o_underflow,
                o_valid //m_axis_result_tvalid
            );
*/
        end
        else if (PRECISION_INPUT == 1) begin // single precision
            ipsxe_floating_point_exp_32_axi_v1_0 #(
                FLOAT_EXP_WIDTH,
                FLOAT_FRAC_WIDTH,
                24,
                24,
                9,
                5,
                LATENCY_CONFIG
            ) u_exp_32_axi(
                i_clk,
                i_aclken,
                i_rst_n, //aresetn
                i_data_float, //s_axis_a_tdata
                i_valid, //s_axis_a_tvalid
                o_exp_float, //m_axis_result_tdata
                o_overflow, 
                o_underflow,
                o_valid //m_axis_result_tvalid
            );
        end
        else begin // double precision
            ipsxe_floating_point_exp_64_axi_v1_0 #(
            FLOAT_EXP_WIDTH,
            FLOAT_FRAC_WIDTH,
            53,
            53,
            17,
            0,
            LATENCY_CONFIG
            ) u_exp_64_axi(
            i_clk,
            i_aclken,
            i_rst_n, //aresetn
            i_data_float, //s_axis_a_tdata
            i_valid, //s_axis_a_tvalid
            o_exp_float, //m_axis_result_tdata
            o_overflow, 
            o_underflow,
            o_valid //m_axis_result_tvalid
            );
        end
    endgenerate


endmodule