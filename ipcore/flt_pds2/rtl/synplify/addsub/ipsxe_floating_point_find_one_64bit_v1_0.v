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
// Filename:ipsxe_floating_point_find_one_v1_0.v
// Function: find the leftest 1 in the input

//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_find_one_64bit_v1_0#(parameter LATENCY = 0)(
input i_clk,
input i_rst_n,
input i_clken,
input [63:0] i_din,
output [5:0] o_index
);

//replace_valuex means replace the original value with the calculated value
reg [31:0] replace_value4;
reg [15:0] replace_value3;
reg [7:0] replace_value0;
reg [3:0] replace_value1;
reg [1:0] replace_value2;
reg [5:0] index;
//Dichotomy is used in order to find the index of the first 1

//Check if the fisrt half of the replace_value4 has any 1. If so, give index[4] 1 and pass the fii_rst_n half to replace_value3. Other wise, give index[4] 0 and pass the left half to replace_value3.
//At the same time, index[5] is cached into register to ensure the correct o_index in the final stage.
reg l5_index_dly2, l4_index_dly2;

//Check if the fisrt half of the replace_value3 has any 1. If so, give index[3] 1 and pass the fii_rst_n half to replace_value0. Other wise, give index[3] 0 and pass the left half to replace_value0.
//At the same time, index[4] is cached into register to ensure the correct o_index in the final stage.
reg l5_index_dly3, l4_index_dly3, l3_index_dly3;

//Check if the fisrt half of the replace_value0 has any 1. If so, give index[2] 1 and pass the fii_rst_n half to replace_value1. Other wise, give index[2] 0 and pass the left half to replace_value1.
//At the same time, index[3] and other registers are cached into register to ensure the correct o_index in the final stage.
reg l5_index_dly4, l4_index_dly4, l3_index_dly4, l2_index_dly4;

//Check if the fisrt half of the replace_value1 has any 1. If so, give index[1] 1 and pass the fii_rst_n half to replace_value2. Other wise, give index[1] 0 and pass the left half to replace_value2.
//At the same time, index[2] and other registers are cached into register to ensure the correct o_index in the final stage.
reg l5_index_dly5, l4_index_dly5, l3_index_dly5, l2_index_dly5, l1_index_dly5;

//Firstly, check if the fisrt half of the input has any 1. If so, give index[5] 1 and pass the fii_rst_n half to replace_value4. Other wise, give index[5] 0 and pass the left half to replace_value4.
always@(*)begin
index[5] <= (|i_din[63:32]);
replace_value4 <= index[5] ? i_din[63:32] : i_din[31:0];
end

always@(*)begin index[4] <= (|replace_value4[31:16]); end
//generate for latency
generate
if (LATENCY>=1)begin
always@(posedge i_clk or negedge i_rst_n)begin
if (!i_rst_n)begin
    l5_index_dly2 <= 0;
    replace_value3 <= 0;
    l4_index_dly2 <= 0;
end
else if (i_clken) begin
    l5_index_dly2 <= index[5];
    l4_index_dly2 <= index[4];
    replace_value3 <= index[4] ? replace_value4[31:16] : replace_value4[15:0]; 
end
else begin
    l5_index_dly2 <= l5_index_dly2;
    replace_value3 <= replace_value3;
    l4_index_dly2 <= l4_index_dly2;
end
end
end
else begin
always@(*)begin 
l5_index_dly2 <= index[5];
l4_index_dly2 <= index[4];
replace_value3 <= index[4] ? replace_value4[31:16] : replace_value4[15:0];
end
end
endgenerate

always@(*)begin  index[3] <= (|replace_value3[15:8]); end
//generate for latency
generate
if (LATENCY>=2)begin
always@(posedge i_clk or negedge i_rst_n)begin
if (!i_rst_n)begin
    l5_index_dly3 <= 0;
    l4_index_dly3 <= 0;
    l3_index_dly3 <= 0;
    replace_value0 <= 0;
end
else if (i_clken) begin
    l5_index_dly3 <= l5_index_dly2;
    l4_index_dly3 <= l4_index_dly2;
    l3_index_dly3 <= index[3];
    replace_value0 <= index[3] ? replace_value3[15:8] : replace_value3[7:0];
end
else begin
    l5_index_dly3 <= l5_index_dly3;
    l4_index_dly3 <= l4_index_dly3;
    l3_index_dly3 <= l3_index_dly3;
    replace_value0 <= replace_value0;
end
    end
end
else begin
always@(*)begin
    l5_index_dly3 <= l5_index_dly2;
    l4_index_dly3 <= l4_index_dly2;
    l3_index_dly3 <= index[3];
    replace_value0 <= index[3] ? replace_value3[15:8] : replace_value3[7:0];
end
end
endgenerate

always@(*)begin index[2] <= (|replace_value0[7:4]); end
generate
if (LATENCY>=3)begin
always@(posedge i_clk or negedge i_rst_n)begin
if (!i_rst_n)begin
    l5_index_dly4 <= 0;
    l4_index_dly4 <= 0;
    l3_index_dly4 <= 0;
    l2_index_dly4 <= 0;
    replace_value1 <= 0;
end
else if (i_clken) begin
    l5_index_dly4 <= l5_index_dly3;
    l4_index_dly4 <= l4_index_dly3;
    l3_index_dly4 <= l3_index_dly3;
    l2_index_dly4 <= index[2];
    replace_value1 <= index[2] ? replace_value0[7:4] : replace_value0[3:0];//decide which part contains 1
end
else begin
    l5_index_dly4 <= l5_index_dly4;
    l4_index_dly4 <= l4_index_dly4;
    l3_index_dly4 <= l3_index_dly4;
    l2_index_dly4 <= l2_index_dly4;
    replace_value1 <= replace_value1;
end
end
end
else begin
always@(*)begin
    l5_index_dly4 <= l5_index_dly3;
    l4_index_dly4 <= l4_index_dly3;
    l3_index_dly4 <= l3_index_dly3;
    l2_index_dly4 <= index[2];
    replace_value1 <= index[2] ? replace_value0[7:4] : replace_value0[3:0];//decide which part contains 1
end
end
endgenerate

always@(*)begin index[1] <= (|replace_value1[3:2]); end
//generate for latency
generate
if (LATENCY>=4)begin
always@(posedge i_clk or negedge i_rst_n)begin
if (!i_rst_n)begin
    l5_index_dly5 <= 0;
    l4_index_dly5 <= 0;
    l3_index_dly5 <= 0;
    l2_index_dly5 <= 0;
    replace_value2 <= 0;
    l1_index_dly5 <= 0;
end
else if (i_clken) begin
    l5_index_dly5 <= l5_index_dly4;
    l4_index_dly5 <= l4_index_dly4;
    l3_index_dly5 <= l3_index_dly4;
    l2_index_dly5 <= l2_index_dly4;
    replace_value2 <= index[1] ? replace_value1[3:2] : replace_value1[1:0];
    l1_index_dly5 <= index[1];
end
else begin
    l5_index_dly5 <= l5_index_dly5;
    l4_index_dly5 <= l4_index_dly5;
    l3_index_dly5 <= l3_index_dly5;
    l2_index_dly5 <= l2_index_dly5;
    l1_index_dly5 <= l1_index_dly5;
    replace_value2 <= replace_value2;
end
end
end
else begin
always@(*)begin 
    l5_index_dly5 <= l5_index_dly4;
    l4_index_dly5 <= l4_index_dly4;
    l3_index_dly5 <= l3_index_dly4;
    l2_index_dly5 <= l2_index_dly4;
    replace_value2 <= index[1] ? replace_value1[3:2] : replace_value1[1:0];
    l1_index_dly5 <= index[1];
end
end
endgenerate

always@(*)begin
index[0] <= replace_value2[1];
end

//Fianlly, assign the contacted and cached signals to output o_index
assign o_index = {l5_index_dly5,l4_index_dly5,l3_index_dly5,l2_index_dly5,l1_index_dly5,index[0]};
endmodule