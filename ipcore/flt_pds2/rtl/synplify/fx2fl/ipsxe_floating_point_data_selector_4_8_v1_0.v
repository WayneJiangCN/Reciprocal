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
// Filename: ipsxe_floating_point_data_selector_4_8_v1_0.v
// Function: 
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_data_selector_4_8_v1_0
(
    input wire [3:0] sel,              
    input wire [2:0] data0,
    input wire [2:0] data1,
    input wire [2:0] data2,
    input wire [2:0] data3,     
    output reg [4:0] o_data         
);

always @(*) begin
    casex(sel)
        4'b1xxx: o_data = data3 + 24;
        4'b01xx: o_data = data2 + 16;
        4'b001x: o_data = data1 + 8;
        default: o_data = data0 ;
    endcase
end

endmodule
