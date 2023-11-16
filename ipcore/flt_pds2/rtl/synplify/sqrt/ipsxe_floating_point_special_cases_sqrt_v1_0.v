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
// Filename: ipsxe_floating_point_special_cases_sqrt_v1_0.v
// Function: This module judges whether to set the result to 0, inf, NaN
//           or other special values.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_special_cases_sqrt_v1_0 #(parameter SIZE = 64, EXPONENT_SIZE = 11, MANTISSA_SIZE = 52) (
    input i_sign,
    input [EXPONENT_SIZE-1:0] i_exponent,
    input [MANTISSA_SIZE-1:0] i_mantissa,
    output reg [1:0] o_state_special
);

always @ ( * ) begin: blk_o_state_special
    // if a is zero return zero
    if ({i_exponent, i_mantissa} == {(EXPONENT_SIZE+MANTISSA_SIZE){1'b0}}) begin
        o_state_special = 2'd2;
    end
    // if a is negative(-denorm, -norm, -inf, -NaN) or +NaN return NaN
    else if (i_sign == 1'b1 || (i_sign == 1'b0 && i_exponent == {EXPONENT_SIZE{1'b1}} && i_mantissa != {MANTISSA_SIZE{1'b0}})) begin
        o_state_special = 2'd0;
    end
    // if a is +inf return +inf
    else if (i_exponent == {EXPONENT_SIZE{1'b1}}) begin
        o_state_special = 2'd1;
    end
    // Denormalised and normalized Number
    else begin
        o_state_special = 2'd3;
    end
end

endmodule