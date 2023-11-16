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
// Filename: ipsxe_floating_point_exp_sqrt_v1_0.v
// Function: This module calculates the square-root of the exponent.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_exp_sqrt_v1_0 #(parameter EXPONENT_SIZE = 11) (
    input [EXPONENT_SIZE - 1:0] i_exponent,
    output [EXPONENT_SIZE - 1:0] o_out
);

wire signed [EXPONENT_SIZE - 1:0] exp_minus_bias, exp_minus_bias_rsh1;
wire signed [EXPONENT_SIZE - 1:0] bias;

// 1. minus bias to get the real exponent value
assign exp_minus_bias = i_exponent - {(EXPONENT_SIZE-1){1'b1}};
// 2. right shift 1 bit to get exponent/2
assign exp_minus_bias_rsh1 = (exp_minus_bias >>> 1'b1);
// 3. add bias to get the exponent in ieee-754 format
assign bias = {1'b0, {(EXPONENT_SIZE-1){1'b1}}};
assign o_out = exp_minus_bias_rsh1 + bias;

endmodule