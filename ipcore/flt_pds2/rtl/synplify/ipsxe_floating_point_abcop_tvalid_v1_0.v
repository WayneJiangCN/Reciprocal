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
// Filename: ipsxe_floating_point_abcop_tvalid_v1_0.v
// Function: This module ORs tvalid signals of all input channels.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_abcop_tvalid_v1_0 (
    input i_axi4s_a_tvalid,
    input i_axi4s_b_tvalid,
    input i_axi4s_c_tvalid,
    input i_axi4s_operation_tvalid,
    output o_axi4s_and_abcoperation_tvalid
);

assign o_axi4s_and_abcoperation_tvalid = i_axi4s_a_tvalid && i_axi4s_b_tvalid && i_axi4s_c_tvalid && i_axi4s_operation_tvalid;

endmodule