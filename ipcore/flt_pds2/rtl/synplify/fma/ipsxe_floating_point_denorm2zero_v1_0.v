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
// Filename: ipsxe_floating_point_denorm2zero_v1_0.v
// Function: This module set denomalized input numbers to zeros.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_denorm2zero_v1_0 #(parameter EXP_WIDTH = 8, SIG_WIDTH = 23) (
    input [(1+EXP_WIDTH+SIG_WIDTH)-1:0] i_a_norm_or_denorm,
    input [(1+EXP_WIDTH+SIG_WIDTH)-1:0] i_b_norm_or_denorm,
    input [(1+EXP_WIDTH+SIG_WIDTH)-1:0] i_c_norm_or_denorm,
    output [(1+EXP_WIDTH+SIG_WIDTH)-1:0] o_a,
    output [(1+EXP_WIDTH+SIG_WIDTH)-1:0] o_b,
    output [(1+EXP_WIDTH+SIG_WIDTH)-1:0] o_c
);

localparam WIDTH = 1+EXP_WIDTH+SIG_WIDTH; // floating-point data width

wire a_is_denorm, b_is_denorm, c_is_denorm;

// if the exponent is zero and the mantissa is not zero, then this is a denormalized floating-point number
assign a_is_denorm = (i_a_norm_or_denorm[WIDTH-2:WIDTH-EXP_WIDTH-1]==0) & (i_a_norm_or_denorm[SIG_WIDTH-1:0]!=0);
assign b_is_denorm = (i_b_norm_or_denorm[WIDTH-2:WIDTH-EXP_WIDTH-1]==0) & (i_b_norm_or_denorm[SIG_WIDTH-1:0]!=0);
assign c_is_denorm = (i_c_norm_or_denorm[WIDTH-2:WIDTH-EXP_WIDTH-1]==0) & (i_c_norm_or_denorm[SIG_WIDTH-1:0]!=0);

// set denormalized numbers to zeros
assign o_a = a_is_denorm ? 0 : i_a_norm_or_denorm;
assign o_b = b_is_denorm ? 0 : i_b_norm_or_denorm;
assign o_c = c_is_denorm ? 0 : i_c_norm_or_denorm;

endmodule