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
// Filename: ipsxe_floating_point_sram_dualports_v1_0.v
// Function: The module is an SRAM verilog model for axi streams.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_sram_dualports_v1_0
#(
    parameter MEM_WIDTH        = 32,
    parameter MEM_DEPTH        = 2,
    parameter ADDR_WIDTH       = 8
)
(
    input                               i_aclk,

    //Input Stream
    input      [MEM_WIDTH-1:0]          i_d, //input data
    input      [ADDR_WIDTH-1:0]         i_wa, //write address
    input                               i_we, //write enable
    input      [ADDR_WIDTH-1:0]         i_ra, //read address
    input                               i_re, //read enable

    //Output Stream
    output reg [MEM_WIDTH-1:0]          o_q //output data
);

reg [MEM_WIDTH-1:0] mem [MEM_DEPTH-1:0];
reg [ADDR_WIDTH-1:0] rd_addr=0;

always @(posedge i_aclk) begin: blk_mem
    if(i_we) begin
        mem[i_wa] <= i_d;
    end
end

always @(posedge i_aclk) begin: blk_rd_addr
    if(i_re) begin
        rd_addr <= i_ra;
    end
end

always @(*) begin: blk_o_q
    if(i_re) begin
        o_q = mem[i_ra];
    end
    else
        o_q = mem[rd_addr];
end

endmodule