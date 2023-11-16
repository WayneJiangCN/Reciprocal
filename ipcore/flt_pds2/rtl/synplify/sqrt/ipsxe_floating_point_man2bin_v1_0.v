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
// Filename: ipsxe_floating_point_man2bin_v1_0.v
// Function: This module left shift the mantissa to get more significand
//           bits after binary sqrt.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_man2bin_v1_0 #(parameter MANTISSA_SIZE = 52, BINARY_SIZE = 106) (
    input i_is_exp_odd,
    input [MANTISSA_SIZE-1:0] i_man,
    output [BINARY_SIZE-1:0] o_bin
);

// left shift the mantissa to get more significand bits after binary sqrt
// why fill 2+MANTISSA_SIZE zeros in the lowest bits? because we want to keep even bits after the binary point of 1.xxx
// which means the "xxx000" part of 1.xxx000 should be even bits
// since the "xxx" part is MANTISSA_SIZE bits, and we want the square root to have MANTISSA_SIZE+1 bit after the binary point,
// we fill 2+MANTISSA_SIZE zeros to make (MANTISSA_SIZE + 2+MANTISSA_SIZE) bits after the binary point
assign o_bin[BINARY_SIZE-1-(2+MANTISSA_SIZE):0] = {(BINARY_SIZE-(2+MANTISSA_SIZE)){1'b0}};
// double mantissa or not according to i_is_exp_odd, see the module ipsxe_floating_point_exp_sqrt_v1_0
assign o_bin[BINARY_SIZE-1-:(2+MANTISSA_SIZE)] = i_is_exp_odd ? {1'b0, 1'b1, i_man} : {1'b1, i_man, 1'b0};

endmodule