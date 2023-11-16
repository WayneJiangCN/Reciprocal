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
// Filename:ipsxe_floating_point_addsub_v1_0.v
// Function: p=a+/-b
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_addsub_v1_0 #(parameter E = 8, F = 24, APM_USAGE = 0, RNE = 6, LATENCY_CONFIG = 7)(
    i_aclk,
    i_aclken,
    i_rst_n,
    i_axis_aboperation_tvalid,
    i_axis_operation_tdata,
    i_axis_a_tdata,
    i_axis_b_tdata,

    o_axis_result_tdata,
    o_axis_result_tvalid,
    o_invalid_op,
    o_overflow,
    o_underflow
    );

input i_aclk;
input i_aclken;
input i_rst_n;
input i_axis_aboperation_tvalid;
input i_axis_operation_tdata;
input [LENTH-1:0] i_axis_a_tdata;
input [LENTH-1:0] i_axis_b_tdata;

output [LENTH-1:0] o_axis_result_tdata;
output o_overflow;
output o_underflow;
output o_invalid_op;
output o_axis_result_tvalid;

generate
if (E+F==64)begin
    if (APM_USAGE = 0)begin
        ipsxe_floating_point_addsub_64bit_v1_0#(E,F,APM_USAGE,8,LATENCY_CONFIG) inst_64(i_aclk,i_aclken,i_rst_n,i_axis_aboperation_tvalid,i_axis_operation_tdata,i_axis_a_tdata,i_axis_b_tdata,o_axis_result_tdata,o_axis_result_tvalid,o_invalid_op,o_overflow,o_underflow);
    end
    else begin
    ipsxe_floating_point_addsub_64bit_APM_v1_0#(E,F,APM_USAGE,8,LATENCY_CONFIG) inst_64_1APM(i_aclk,i_aclken,i_rst_n,i_axis_aboperation_tvalid,i_axis_operation_tdata,i_axis_a_tdata,i_axis_b_tdata,o_axis_result_tdata,o_axis_result_tvalid,o_invalid_op,o_overflow,o_underflow);
    end
end
else begin
    if (APM_USAGE = 0)begin
    ipsxe_floating_point_addsub_32bit_v1_0#(E,F,APM_USAGE,7,LATENCY_CONFIG) inst_32(i_aclk,i_aclken,i_rst_n,i_axis_aboperation_tvalid,i_axis_operation_tdata,i_axis_a_tdata,i_axis_b_tdata,o_axis_result_tdata,o_axis_result_tvalid,o_invalid_op,o_overflow,o_underflow);
    end
    else begin
    ipsxe_floating_point_addsub_32bit_APM_v1_0#(E,F,APM_USAGE,7,LATENCY_CONFIG) inst_32_1APM(i_aclk,i_aclken,i_rst_n,i_axis_aboperation_tvalid,i_axis_operation_tdata,i_axis_a_tdata,i_axis_b_tdata,o_axis_result_tdata,o_axis_result_tvalid,o_invalid_op,o_overflow,o_underflow);
    end
end
endgenerate



endmodule