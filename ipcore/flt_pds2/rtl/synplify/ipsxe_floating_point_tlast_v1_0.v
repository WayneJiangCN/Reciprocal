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
// Filename: ipsxe_floating_point_tlast_v1_0.v
// Function: This module selects the tlast behavior according to user
//           configuration.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_tlast_v1_0 #(
    parameter TLAST_BEHAVIOR = 0
)(
    input i_axi4s_a_tlast,
    input i_axi4s_b_tlast,
    input i_axi4s_c_tlast,
    input i_axi4s_operation_tlast,

    output o_axi4s_abcoperation_tlast
);

generate
if (TLAST_BEHAVIOR == 0) begin // Pass A TLAST
    assign o_axi4s_abcoperation_tlast = i_axi4s_a_tlast;
end
else if (TLAST_BEHAVIOR == 1) begin // Pass B TLAST
    assign o_axi4s_abcoperation_tlast = i_axi4s_b_tlast;
end
else if (TLAST_BEHAVIOR == 2) begin // Pass C TLAST
    assign o_axi4s_abcoperation_tlast = i_axi4s_c_tlast;
end
else if (TLAST_BEHAVIOR == 3) begin // Pass OPERATION TLAST
    assign o_axi4s_abcoperation_tlast = i_axi4s_operation_tlast;
end
else if (TLAST_BEHAVIOR == 4) begin // OR all TLASTs
    assign o_axi4s_abcoperation_tlast = i_axi4s_a_tlast | i_axi4s_b_tlast | i_axi4s_c_tlast | i_axi4s_operation_tlast;
end
else begin // TLAST_BEHAVIOR == 5: AND all TLASTs
    assign o_axi4s_abcoperation_tlast = i_axi4s_a_tlast & i_axi4s_b_tlast & i_axi4s_c_tlast & i_axi4s_operation_tlast;
end
endgenerate

endmodule