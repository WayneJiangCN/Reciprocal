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
// Filename: ipsxe_floating_point_find_one_loc_v1_0.v
// Function: 
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_find_one_loc_v1_0 #(
    parameter WIDTH = 64,
    parameter LOC_BITS = 6
    )
(
    input i_clk,
    input i_aclken,
    input i_rst_n,
    input [ WIDTH -1:0] i_data,
    output wire [LOC_BITS - 1 : 0] one_location,
    output wire zero_judge
);

generate
    if(WIDTH>32)begin
        wire [3:0] sel;
        wire [3:0] data0;
        wire [3:0] data1;
        wire [3:0] data2;
        wire [3:0] data3;


        ipsxe_floating_point_one_loc_sub16_v1_0 #(
            .WIDTH(16)
        ) u1_ipsxe_floating_point_one_loc_sub16_v1_0
        (
            .i_clk(i_clk),
            .i_aclken(i_aclken),
            .i_rst_n(i_rst_n),
            .i_data(i_data[15:0]),
            .one_location(data0),
            .zero_judge(sel[0])
        );

        ipsxe_floating_point_one_loc_sub16_v1_0 #(
            .WIDTH(16)
        ) u2_ipsxe_floating_point_one_loc_sub16_v1_0
        (
            .i_clk(i_clk),
            .i_aclken(i_aclken),
            .i_rst_n(i_rst_n),
            .i_data(i_data[31:16]),
            .one_location(data1),
            .zero_judge(sel[1])
        );

        ipsxe_floating_point_one_loc_sub16_v1_0 #(
            .WIDTH(16)
        ) u3_ipsxe_floating_point_one_loc_sub16_v1_0
        (
            .i_clk(i_clk),
            .i_aclken(i_aclken),
            .i_rst_n(i_rst_n),
            .i_data(i_data[47:32]),
            .one_location(data2),
            .zero_judge(sel[2])
        );

        ipsxe_floating_point_one_loc_sub16_v1_0 #(
            .WIDTH(16)
        ) u4_ipsxe_floating_point_one_loc_sub16_v1_0
        (
            .i_clk(i_clk),
            .i_aclken(i_aclken),
            .i_rst_n(i_rst_n),
            .i_data(i_data[63:48]),
            .one_location(data3),
            .zero_judge(sel[3])
        );

    ipsxe_floating_point_data_selector_4_16_v1_0 selector
    (
        .sel(~sel),
        .data0(data0),
        .data1(data1),
        .data2(data2),
        .data3(data3),
        .o_data(one_location)
    );
    assign zero_judge = sel ==4'hf;

    end
    else begin

    wire [3:0] sel;
    wire [2:0] data0;
    wire [2:0] data1;
    wire [2:0] data2;
    wire [2:0] data3;

    ipsxe_floating_point_one_loc_sub8_v1_0 #(
        .WIDTH(8)
    ) u0 (
        .i_clk(i_clk),
        .i_aclken(i_aclken),
        .i_rst_n(i_rst_n),
        .i_data(i_data[7:0]),
        .one_location(data0),
        .zero_judge(sel[0])
    );

    ipsxe_floating_point_one_loc_sub8_v1_0 #(
        .WIDTH(8)
    ) u1 (
        .i_clk(i_clk),
        .i_aclken(i_aclken),
        .i_rst_n(i_rst_n),
        .i_data( i_data[15:8] ),
        .one_location(data1),
        .zero_judge(sel[1])
    );

    ipsxe_floating_point_one_loc_sub8_v1_0 #(
        .WIDTH(8)
    ) u2 (
        .i_clk(i_clk),
        .i_aclken(i_aclken),
        .i_rst_n(i_rst_n),
        .i_data( i_data[23:16] ),
        .one_location(data2),
        .zero_judge(sel[2])
    );

    ipsxe_floating_point_one_loc_sub8_v1_0 #(
        .WIDTH(8)
    ) u3 (
        .i_clk(i_clk),
        .i_aclken(i_aclken),
        .i_rst_n(i_rst_n),
        .i_data( i_data[31:24] ),
        .one_location(data3),
        .zero_judge(sel[3])
    );

    ipsxe_floating_point_data_selector_4_8_v1_0 selector(
        .sel(~sel),
        .data0(data0),
        .data1(data1),
        .data2(data2),
        .data3(data3),
        .o_data(one_location)
    );
    assign zero_judge = sel ==4'hf;

    end
endgenerate


endmodule