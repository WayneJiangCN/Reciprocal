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
// Filename: ipsxe_floating_point_rne_v1_0.v
// Function: This module rounds a binary number to the nearest even.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_rne_v1_0 #(parameter W=23, RNE=5) (
    input [W+RNE-1:0] i_before_rne,
    output reg [W-1:0] o_after_rne
);

// round to nearest even: round off the lowest RNE bits
always @(*) begin: blk_o_after_rne
    if(~i_before_rne[RNE-1]) // if the highest bit of the lowest RNE bits is 0
        o_after_rne = i_before_rne[W+RNE-1:RNE]; // then there is no 1-bit carry
    // why this else-if branch is deleted?
    // because it prevents invsqrt from achieving rne and 0.5ulp precision
    // else if(i_before_rne[RNE-1:0] == {1'b1, {(RNE-1){1'b0}}}) // if the lowest RNE bits are 10000...0
    //     if(i_before_rne[RNE]) // let o_after_rne to be an even number
    //         o_after_rne = i_before_rne[W+RNE-1:RNE] + 1;
    //     else
    //         o_after_rne = i_before_rne[W+RNE-1:RNE];
    else // carry bit = 1
        o_after_rne = i_before_rne[W+RNE-1:RNE] + 1'b1;
end

endmodule