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
// Filename: ipsxe_floating_point_frac_round_v1_0.v
// Function: 
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_frac_round_v1_0 #(
    parameter FLOAT_IN_FRAC = 53,
    parameter FLOAT_OUT_FRAC = 24
)
(
    input [FLOAT_IN_FRAC-2:0] frac_in,
    output [FLOAT_OUT_FRAC-1:0] frac_mid
);

    localparam FRAC_ROUND_BITS = FLOAT_IN_FRAC - FLOAT_OUT_FRAC;

    wire carry, carry_mid, frac_carry;

    //round_v6 #( //round to even
    //    .FLOAT_FRAC_BIT(FLOAT_IN_FRAC-FLOAT_OUT_FRAC)
    //) u_round (
    //    .data_in(frac_in[FLOAT_IN_FRAC-FLOAT_OUT_FRAC-1:0]),
    //    .carry(carry),
    //    .carry_mid(carry_mid)
    //);

    assign carry = frac_in[FRAC_ROUND_BITS-1:0] > {{1'b1},{(FRAC_ROUND_BITS-1){1'b0}}};
    assign carry_mid = frac_in[FRAC_ROUND_BITS-1:0] == {{1'b1},{(FRAC_ROUND_BITS-1){1'b0}}};

    assign frac_carry = carry | (carry_mid & frac_in[FRAC_ROUND_BITS]);
    assign frac_mid = frac_in[FLOAT_IN_FRAC-2 -: FLOAT_OUT_FRAC-1] + frac_carry;

endmodule