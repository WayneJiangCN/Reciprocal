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
// Filename:ipsxe_floating_point_find_one_v1_0.v
// Function: find the leftest 1 in the input

//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_find_one_16bit_v1_0(
        input       [15:0]  i_din,
        output      [3:0]   o_index
    );
//replace_valuex means replace the original value with the calculated value
wire    [7:0]   replace_value0;
wire    [3:0]   replace_value1;
wire    [1:0]   replace_value2;

//method of bisection
assign o_index[3] = (|i_din[15:8]);                     //find 1 in the first half of the rest
assign replace_value0 = o_index[3] ? i_din[15:8] : i_din[7:0];    //decide which part contains 1

assign o_index[2] = (|replace_value0[7:4]);                     //find 1 in the first half of the rest
assign replace_value1 = o_index[2] ? replace_value0[7:4] : replace_value0[3:0];    //decide which part contains 1

assign o_index[1] = (|replace_value1[3:2]);                     //find 1 in the first half of the rest
assign replace_value2 = o_index[1] ? replace_value1[3:2] : replace_value1[1:0];    //decide which part contains 1

assign o_index[0] = replace_value2[1];

endmodule