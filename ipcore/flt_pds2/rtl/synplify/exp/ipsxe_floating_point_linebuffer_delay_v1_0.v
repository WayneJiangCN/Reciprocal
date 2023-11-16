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
// Filename:ipsxe_floating_point_linebuffer_delay_v1_0.v
// Function:
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_linebuffer_delay_v1_0 #(
    parameter N = 64,
    parameter DELAY_NUM = 1
) 
(
    input i_clk,
    input i_aclken,
    input i_rst_n,
    input [N-1:0] i_d,
    output [N-1:0] o_q
);
reg [N-1:0] linebuffer [DELAY_NUM-1:0];
integer i;
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        for (i = 0; i < DELAY_NUM; i = i+1) begin
            linebuffer[i] <= 0;
        end
    end
    else if (i_aclken) begin
        linebuffer[0] <= i_d;
        for (i = 1; i < DELAY_NUM; i = i+1) begin
            linebuffer[i] <= linebuffer[i-1];
        end
    end
    else begin
        for (i = 0; i < DELAY_NUM; i = i+1) begin
            linebuffer[i] <= linebuffer[i];
        end
    end
end

assign o_q = linebuffer[DELAY_NUM-1];

endmodule
