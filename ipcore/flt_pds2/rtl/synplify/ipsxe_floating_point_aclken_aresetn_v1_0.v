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
// Filename: ipsxe_floating_point_aclken_aresetn_v1_0.v
// Function: This module handles the clock enable and reset signals.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_aclken_aresetn_v1_0 (
    input i_aclken,
    input i_areset_n,
    input i_result_tready,
    output o_aclken,
    output o_areset_n,
    output o_dummy_tuser
);

assign o_aclken = i_aclken & i_result_tready;
assign o_areset_n = i_areset_n;

assign o_dummy_tuser = 1'b0;

endmodule