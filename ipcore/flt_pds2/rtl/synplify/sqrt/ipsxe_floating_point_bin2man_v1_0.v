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
// Filename: ipsxe_floating_point_bin2man_v1_0.v
// Function: This module rounds a binary number to the nearest even.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_bin2man_v1_0 #(parameter MANTISSA_SIZE = 52, BINARY_SIZE = 106, RNE = 5) (
    input [BINARY_SIZE/2-1:0] i_bin,
    output reg [MANTISSA_SIZE-1:0] o_man
);

// round to nearest even
always @(*) begin: blk_o_man
    if(~i_bin[RNE-1])
        o_man = i_bin[BINARY_SIZE/2-2:RNE];
    // why this else-if branch is deleted?
    // because it prevents sqrt from achieving rne and 0.5ulp precision
    // else if(i_bin[RNE-1:0] == {1'b1, {(RNE-1){1'b0}}})
    //     if(i_bin[RNE]) // if odd
    //         o_man = i_bin[BINARY_SIZE/2-2:RNE] + 1;
    //     else // if even
    //         o_man = i_bin[BINARY_SIZE/2-2:RNE];
    else // i_bin[RNE-1:0] > {1'b1, {(RNE-1){1'b0}}}
        o_man = i_bin[BINARY_SIZE/2-2:RNE] + 1'b1;
end

endmodule