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
// Filename: ipsxe_floating_point_one_loc_sub16_v1_0.v
// Function: 
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_one_loc_sub16_v1_0 #(
    parameter WIDTH = 16
)
(
    input i_clk,
    input i_aclken,
    input i_rst_n,
    input [WIDTH -1:0] i_data,
    output reg [3:0] one_location,
    output reg zero_judge
);

wire [3:0] one_location_in;

wire [1:0] find_one1;
wire [3:0] find_one2;
wire [7:0] find_one3;
// wire [15:0] find_one4;

wire one_location_temp;
    assign one_location_temp = (|i_data[15:8]);
    assign find_one3 = one_location_temp ? i_data[15:8] : i_data[7:0];

wire [7:0] find_one3_reg;

// ipsxe_floating_point_register_v1_0 #(1) u_one_location4_reg(i_clk, i_aclken, i_rst_n, one_location_temp , one_location_in[4]);

//ipsxe_floating_point_register_v1_0 #(16) u_find_one4_reg(i_clk, i_aclken, i_rst_n, find_one4     , find_one4_reg);

// ipm_distributed_shiftregister_wrapper_v1_3 #(1,16) u_find_one4_reg (
//     .din(find_one4),
//     .clk(i_clk),
//     .i_aclken(i_aclken),
//     .rst(~i_rst_n),
//     .dout(find_one4_reg)
// );
    ipsxe_floating_point_register_v1_0 #(1) u_reg_one_loc(
        i_clk,
        i_aclken,
        i_rst_n,
        one_location_temp,
        one_location_in[3]
    );
    
    ipsxe_floating_point_register_v1_0 #(8) u_reg_find_one3(
        i_clk,
        i_aclken,
        i_rst_n,
        find_one3,
        find_one3_reg
    );

    // assign one_location_in[3] = (i_data[15:8]!=0?1'b1:1'b0);
    // assign find_one3 = one_location_in[3] ? i_data[15:8] : i_data[7:0];

    assign one_location_in[2] = (|find_one3_reg[7:4]);
    assign find_one2 = one_location_in[2] ? find_one3_reg[7:4] : find_one3_reg[3:0];

    assign one_location_in[1] = (|find_one2[3:2]);
    assign find_one1 = one_location_in[1] ? find_one2[3:2] : find_one2[1:0];

    assign one_location_in[0] = find_one1[1];


    always @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) 
        zero_judge <= 0; 
    else if (i_aclken)
        zero_judge = (one_location_in == 1'b0) && (find_one1[0] == 1'b0) ? 1'b1 : 1'b0; 
    else
        zero_judge <= zero_judge;
    end

    always @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) 
        one_location <= 0;
    else if (i_aclken)
        one_location <= one_location_in;
    else
        one_location <= one_location;
    end

    // always @(*) begin
    //     zero_judge = (one_location_in == 1'b0) && (find_one1[0] == 1'b0) ? 1'b1 : 1'b0; 
    // end

    // always @(*) begin
    //     one_location = one_location_in;
    // end

endmodule
