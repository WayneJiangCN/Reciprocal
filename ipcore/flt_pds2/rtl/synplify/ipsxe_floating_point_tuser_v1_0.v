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
// Filename: ipsxe_floating_point_tuser_v1_0.v
// Function: This module handles the input tuser signals to produce the
//           output tuser signals.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_tuser_v1_0 #(
    parameter OP_SEL = 0,
    parameter ABCOP_TUSER = 0,
    parameter TUSER_IN_ABCOPERATION_WIDTH = 1,
    parameter PIPE_STAGE_NUM = 1,
    parameter TUSER_RESULT_WIDTH = 1,
    parameter LATENCY_CONFIG = 1
) (
    input i_aclk,
    input i_aclken,
    input i_areset_n,
    input [1+TUSER_RESULT_WIDTH-1:0] i_axi4s_dummy_abcoperation_tuser_overunderinvalid,
    output [TUSER_RESULT_WIDTH-1:0] o_axi4s_result_tuser
);

generate
if (OP_SEL != 0) begin

if (ABCOP_TUSER) begin

if (LATENCY_CONFIG == 0) begin
if (TUSER_RESULT_WIDTH-1 >= TUSER_IN_ABCOPERATION_WIDTH) begin
assign o_axi4s_result_tuser = i_axi4s_dummy_abcoperation_tuser_overunderinvalid[TUSER_RESULT_WIDTH-1:0];
end
else begin
assign o_axi4s_result_tuser = i_axi4s_dummy_abcoperation_tuser_overunderinvalid[TUSER_RESULT_WIDTH-1-:TUSER_IN_ABCOPERATION_WIDTH];
end
end
else begin
wire [TUSER_IN_ABCOPERATION_WIDTH-1:0] i_axi4s_abcoperation_tuser_delay;

ipm_distributed_shiftregister_wrapper_v1_3 #(LATENCY_CONFIG, TUSER_IN_ABCOPERATION_WIDTH) u_shift_reg_i_axi4s_abcoperation_tuser_delay (
    .din(i_axi4s_dummy_abcoperation_tuser_overunderinvalid[TUSER_RESULT_WIDTH-1-:TUSER_IN_ABCOPERATION_WIDTH]),      // input
    .clk(i_aclk),      // input
    .i_aclken(i_aclken),
    .rst(~i_areset_n),      // input
    .dout(i_axi4s_abcoperation_tuser_delay)     // output
);

if (TUSER_RESULT_WIDTH-1 >= TUSER_IN_ABCOPERATION_WIDTH) begin
assign o_axi4s_result_tuser = {i_axi4s_abcoperation_tuser_delay, i_axi4s_dummy_abcoperation_tuser_overunderinvalid[TUSER_RESULT_WIDTH-1-TUSER_IN_ABCOPERATION_WIDTH:0]};
end
else begin
assign o_axi4s_result_tuser = i_axi4s_abcoperation_tuser_delay;
end
end

end

else begin // !ABCOP_TUSER
assign o_axi4s_result_tuser = {
i_axi4s_dummy_abcoperation_tuser_overunderinvalid[TUSER_RESULT_WIDTH-1-TUSER_IN_ABCOPERATION_WIDTH:0]
};
end

end

else begin // OP_SEL == 0
assign o_axi4s_result_tuser = i_axi4s_dummy_abcoperation_tuser_overunderinvalid[TUSER_RESULT_WIDTH-1-:TUSER_IN_ABCOPERATION_WIDTH];
end
endgenerate

endmodule