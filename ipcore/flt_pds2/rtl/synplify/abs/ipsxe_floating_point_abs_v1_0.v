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
// Filename:ipsxe_floating_point_abs_v1_0.v
// Function:calculate the absolute value of a floating-point number
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_abs_v1_0 #(parameter WIDTH = 32)(
    input [WIDTH-1:0] i_axi4s_a_tdata, //input data
    input i_axi4s_a_tvalid,
    output [WIDTH-1:0] o_axi4s_result_tdata, //output data
    output o_axi4s_result_tvalid
);

assign o_axi4s_result_tdata = {1'b0, i_axi4s_a_tdata[WIDTH-2:0]}; //change the sign to 0, which means a positive number
assign o_axi4s_result_tvalid = i_axi4s_a_tvalid;                  //change the result_valid when a_valid changes

endmodule