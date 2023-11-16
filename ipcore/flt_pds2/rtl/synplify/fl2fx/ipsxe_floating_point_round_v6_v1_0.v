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
// Filename: ipsxe_floating_point_round_v6_v1_0.v
// Function: this module is the round to the nearest even module for the
//           floating-point number to fixed-point number conversion
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_round_v6_v1_0 #(
    parameter FLOAT_FRAC_BIT = 24 //include the hidden one
)
(
    input [FLOAT_FRAC_BIT-1:0] data_in,
    output carry,
    output carry_mid
);

    assign carry = (data_in>{{1'b1},{(FLOAT_FRAC_BIT-1){1'b0}}});
    assign carry_mid = (data_in=={{1'b1},{(FLOAT_FRAC_BIT-1){1'b0}}});

endmodule