
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
// Filename: flt_pds2_onboard.v
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module flt_pds2_onboard
(
    i_aclk,

    i_areset_n,
    o_axi4s_result_tdata,
    i_axi4s_a_tdata_delay_output,

    o_axi4s_result_tvalid
);


localparam EXP_WIDTH = 8;
localparam MAN_WIDTH = 23;

localparam INPUT_FIXED_INT_BIT = 32;
localparam INPUT_FIXED_FRAC_BIT = 0;

localparam RESULT_FIXED_INT_BIT = 32; // unused
localparam RESULT_FIXED_FRAC_BIT = 0; // unused

localparam FLOAT_OUT_EXP = 5;
localparam FLOAT_OUT_FRAC = 11;

localparam WIDTH = 1 + EXP_WIDTH + MAN_WIDTH;

localparam FRAC_WIDTH = 1 + MAN_WIDTH;

localparam TDATA_WIDTH = (WIDTH[2:0] == 0) ? WIDTH : (((WIDTH >> 3) + 1) << 3);

localparam OUT_WIDTH = 1 + EXP_WIDTH + MAN_WIDTH;

localparam TDATA_OUT_WIDTH = (OUT_WIDTH[2:0] == 0) ? OUT_WIDTH : (((OUT_WIDTH >> 3) + 1) << 3);

localparam LATENCY_CONFIG = 0;

localparam PIPE_STAGE_NUM = LATENCY_CONFIG; // MAN_WIDTH + 3 + 2;

localparam RNE_SQRT = 1;

localparam OP_SEL = 12;


input i_aclk;

input i_areset_n;
output [TDATA_OUT_WIDTH-1:0] o_axi4s_result_tdata;// synthesis PAP_MARK_DEBUG="1"
output [TDATA_WIDTH-1:0] i_axi4s_a_tdata_delay_output;

output o_axi4s_result_tvalid;// synthesis PAP_MARK_DEBUG="1"

wire [3:0] rd_addr;
wire i_axi4s_abcoperation_tvalid;
wire [TDATA_WIDTH-1:0] i_axi4s_a_tdata, i_axi4s_b_tdata, i_axi4s_c_tdata;
wire [7:0] i_axi4s_operation_tdata;

floating_point_rom_addr_counter u_floating_point_rom_addr_counter (
    i_aclk,
    i_areset_n,
    i_axi4s_abcoperation_tvalid,
    rd_addr
);

floating_point_rom_a #(EXP_WIDTH, MAN_WIDTH, OP_SEL) u_floating_point_rom_a (
    i_aclk,
    rd_addr,
    i_axi4s_a_tdata
);

floating_point_rom_b #(EXP_WIDTH, MAN_WIDTH) u_floating_point_rom_b (
    i_aclk,
    rd_addr,
    i_axi4s_b_tdata
);

floating_point_rom_c #(EXP_WIDTH, MAN_WIDTH) u_floating_point_rom_c (
    i_aclk,
    rd_addr,
    i_axi4s_c_tdata
);

floating_point_rom_operation u_floating_point_rom_operation (
    i_aclk,
    rd_addr,
    i_axi4s_operation_tdata
);

wire i_axi4s_a_tlast;
generate
if (OP_SEL == 1) begin
floating_point_rom_accum_tlast u_floating_point_rom_accum_tlast (
    i_aclk,
    rd_addr,
    i_axi4s_a_tlast
);
end
endgenerate

flt_pds2 u_flt_pds2
(

    i_aclk,

    i_axi4s_a_tdata,

    i_axi4s_abcoperation_tvalid,

    o_axi4s_result_tdata,

    o_axi4s_result_tvalid
);



wire [TDATA_WIDTH-1:0] i_axi4s_a_tdata_delay_output = i_axi4s_a_tdata;


endmodule

