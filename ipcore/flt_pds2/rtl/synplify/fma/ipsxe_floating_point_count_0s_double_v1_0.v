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
// Filename: ipsxe_floating_point_count_0s_v1_0.v
// Function: This module implements a selection-width-variable MUX,
//           which counts the number of zeros in the highest bits of i_m
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_count_0s_double_v1_0 #(parameter MAN_WIDTH = 23, LEADING_0_CNT = 6) (
    input i_clk,
    input i_aclken,
    input i_rst_n,

    input [(2*(MAN_WIDTH+1)):0] i_m,
    output  [LEADING_0_CNT-1:0] o_count
);

//integer i;
//always @(*) begin: blk_o_count
//    o_count = 2*(MAN_WIDTH+1)+1;
//    for(i = 0; i <= 2*(MAN_WIDTH+1); i = i + 1) begin
//        if((i_m >> (2*(MAN_WIDTH+1) - i)) == 1)
//            o_count=i;
//    end
//end

// if MAN_WIDTH = 23, the above always block is equal to the following always block:
//always @(*) begin
//         if(i_m[48]) begin o_count =  8'd0; end
//    else if(i_m[47]) begin o_count =  8'd1; end
//    else if(i_m[46]) begin o_count =  8'd2; end
//    ...
//    else if(i_m[ 1]) begin o_count = 8'd47; end
//    else if(i_m[ 0]) begin o_count = 8'd48; end
//    else           begin o_count = 8'd49; end
//end


    wire    [127:0]      m_128;
    wire    [ 6:0]      count;

    wire    [63:0]      m_64;
    wire    [31:0]      m_32;
    wire    [15:0]      m_16;
    wire    [ 7:0]      m_8;
    wire    [ 3:0]      m_4;
    wire    [ 1:0]      m_2;

    
    //the origin logic has the problem of logic level
    //assign m_128 = {{(128-(2*(MAN_WIDTH+1)+1)){1'b0}}, i_m};
    //assign count[6] = |m_128[127:64];
    //assign m_64 = count[6]? m_128[127:64] : m_128[63:0];
    //assign count[5] = |m_64[63:32];
    //assign m_32 = count[5]? m_64[63:32] : m_64[31:0];
    //assign count[4] = |m_32[31:16];
    //assign m_16 = count[4]? m_32[31:16] : m_32[15:0];
    //assign count[3] = |m_16[15:8];
    //assign m_8 = count[3]? m_16[15:8] : m_16[7:0];
    //assign count[2] = |m_8[7:4];
    //assign m_4 = count[2]? m_8[7:4] : m_8[3:0];
    //assign count[1] = |m_4[3:2];
    //assign m_2 = count[1]? m_4[3:2] : m_4[1:0];
    //assign count[0] = m_2[1];

    //assign o_count = 128'd106-count[LEADING_0_CNT-1:0];

    
    
    
    ////////add registers to drop logic level
    //assign m_128 = {{(128-(2*(MAN_WIDTH+1)+1)){1'b0}}, i_m};
    //assign count[6] = |m_128[127:64];
    //assign m_64 = count[6]? m_128[127:64] : m_128[63:0];
    //assign count[5] = |m_64[63:32];
    //assign m_32 = count[5]? m_64[63:32] : m_64[31:0];
    //assign count[4] = |m_32[31:16];
    //
    //
    //wire    [31:0]      m_32_dly1;
    //wire                count4_dly1;
    //wire    [ 6:0]      count_dly0;
    //ipsxe_floating_point_register_v1_0 #(32) u_count_register_m32 (i_clk, i_aclken, i_rst_n, m_32, m_32_dly1);
    //ipsxe_floating_point_register_v1_0 #(1) u_count_register_count4 (i_clk, i_aclken, i_rst_n, count[4], count4_dly1);
    //ipsxe_floating_point_register_v1_0 #(3) u_count_register_count_dly0 (i_clk, i_aclken, i_rst_n, count[6:4], count_dly0[6:4]);
    //assign m_16 = count4_dly1? m_32_dly1[31:16] : m_32_dly1[15:0];
    //assign count_dly0[3] = |m_16[15:8];
    //assign m_8 = count_dly0[3]? m_16[15:8] : m_16[7:0];


    ////assign m_16 = count[4]? m_32[31:16] : m_32[15:0];
    ////assign count[3] = |m_16[15:8];
    ////
    ////wire    [15:0]      m_16_dly1;
    ////wire                count3_dly1;
    ////wire    [ 6:0]      count_dly0;
    ////ipsxe_floating_point_register_v1_0 #(16) u_count_register_m16 (i_clk, i_aclken, i_rst_n, m_16, m_16_dly1);
    ////ipsxe_floating_point_register_v1_0 #(1) u_count_register_count3 (i_clk, i_aclken, i_rst_n, count[3], count3_dly1);
    ////ipsxe_floating_point_register_v1_0 #(3) u_count_register_count_dly0 (i_clk, i_aclken, i_rst_n, count[5:3], count_dly0[5:3]);
    ////assign m_8 = count3_dly1? m_16_dly1[15:8] : m_16_dly1[7:0];


    //assign count_dly0[2] = |m_8[7:4];
    //assign m_4 = count[2]? m_8[7:4] : m_8[3:0];
    //assign count_dly0[1] = |m_4[3:2];
    //assign m_2 = count[1]? m_4[3:2] : m_4[1:0];
    //assign count_dly0[0] = m_2[1];

    //wire     [LEADING_0_CNT-1:0]     count_dly1;
    //ipsxe_floating_point_register_v1_0 #(LEADING_0_CNT) u_count_register_count_dly1 (i_clk, i_aclken, i_rst_n, count_dly0, count_dly1);

    //assign o_count = 7'd106-count_dly1;





    assign m_128 = {{(128-(2*(MAN_WIDTH+1)+1)){1'b0}}, i_m};
    assign count[6] = |m_128[127:64];
    assign m_64 = count[6]? m_128[127:64] : m_128[63:0];
    assign count[5] = |m_64[63:32];
    assign m_32 = count[5]? m_64[63:32] : m_64[31:0];
    assign count[4] = |m_32[31:16];
    wire    [31:0]      m_32_dly1;
    wire                count4_dly1;
    wire    [ 6:0]      count_dly0;
    ipsxe_floating_point_register_v1_0 #(32) u_count_register_m32 (i_clk, i_aclken, i_rst_n, m_32, m_32_dly1);
    ipsxe_floating_point_register_v1_0 #(1) u_count_register_count4 (i_clk, i_aclken, i_rst_n, count[4], count4_dly1);
    ipsxe_floating_point_register_v1_0 #(3) u_count_register_count_dly0 (i_clk, i_aclken, i_rst_n, count[6:4], count_dly0[6:4]);
    assign m_16 = count4_dly1? m_32_dly1[31:16] : m_32_dly1[15:0];
    assign count_dly0[3] = |m_16[15:8];
    assign m_8 = count_dly0[3]? m_16[15:8] : m_16[7:0];
    assign count_dly0[2] = |m_8[7:4];
    assign m_4 = count_dly0[2]? m_8[7:4] : m_8[3:0];
    assign count_dly0[1] = |m_4[3:2];
    assign m_2 = count_dly0[1]? m_4[3:2] : m_4[1:0];
    assign count_dly0[0] = m_2[1];

    wire     [LEADING_0_CNT-1:0]     count_dly1;
    ipsxe_floating_point_register_v1_0 #(LEADING_0_CNT) u_count_register_count_dly1 (i_clk, i_aclken, i_rst_n, count_dly0, count_dly1);

    assign o_count = 7'd106-count_dly1;





endmodule
