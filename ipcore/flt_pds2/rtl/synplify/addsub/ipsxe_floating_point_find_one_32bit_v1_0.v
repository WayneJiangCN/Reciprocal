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

module ipsxe_floating_point_find_one_32bit_v1_0#(parameter LATENCY = 3)(
input i_clk,
input i_rst_n,
input i_clken,
input [31:0] i_din,
output [4:0] o_index
);

reg    [15:0]  replace_value3;
reg    [7:0]   replace_value0;
reg    [3:0]   replace_value1;
reg    [1:0]   replace_value2;

//store the temporary index for output
reg [4:0] index;

//method of bisection
always@(*)begin index[4] = (|i_din[31:16]);end
generate
if (LATENCY>=4)begin
always@(posedge i_clk or negedge i_rst_n)begin
	if (!i_rst_n)replace_value3 <= 0;
	else if (i_clken) replace_value3 <= index[4] ? i_din[31:16] : i_din[15:0];
	else replace_value3 <= replace_value3;
end
end
else begin
always@(*)begin
replace_value3 = index[4] ? i_din[31:16] : i_din[15:0];
end
end
endgenerate

reg index3_dly1, index4_dly1;
always@(*)begin index[3] = (|replace_value3[15:8]);end
generate
if (LATENCY>=1)begin
always@(posedge i_clk or negedge i_rst_n)begin
	if (!i_rst_n)begin
		index3_dly1 <= 0;
		index4_dly1 <= 0;
		replace_value0 <= 0;
	end
	else if(i_clken) begin
		index3_dly1 <= index[3];
		index4_dly1 <= index[4];
		replace_value0 <= index[3]?replace_value3[15:8]:replace_value3[7:0];
	end
	else begin
		index3_dly1 <= index3_dly1;
		index4_dly1 <= index4_dly1;
		replace_value0 <= replace_value0;
	end
end
end
else begin
always@(*)begin
		index3_dly1 <= index[3];
		index4_dly1 <= index[4];
		replace_value0 <= index[3]?replace_value3[15:8]:replace_value3[7:0];
end
end
endgenerate

reg index2_dly2, index3_dly2, index4_dly2;
always@(*)begin index[2] = (|replace_value0[7:4]);end
generate
if (LATENCY>=2)begin
always@(posedge i_clk or negedge i_rst_n)begin
	if (!i_rst_n)begin
		index3_dly2 <= 0;
		index4_dly2 <= 0;
		index2_dly2 <= 0;
		replace_value1 <= 0;
	end
	else if(i_clken) begin
		index3_dly2 <= index3_dly1;
		index4_dly2 <= index4_dly1;
		index2_dly2 <= index[2]; 
		replace_value1 <= index[2] ? replace_value0[7:4] : replace_value0[3:0];
	end
	else begin
		index3_dly2 <= index3_dly2;
		index4_dly2 <= index4_dly2;
		index2_dly2 <= index2_dly2;
		replace_value1 <= replace_value1;
	end
end
end
else begin
always@(*)begin
		index3_dly2 <= index3_dly1;
		index4_dly2 <= index4_dly1;
		index2_dly2 <= index[2];
		replace_value1 <= index[2] ? replace_value0[7:4] : replace_value0[3:0];
end
end
endgenerate

reg index1_dly3, index2_dly3, index3_dly3, index4_dly3;
always@(*)begin index[1] = (|replace_value1[3:2]);end
generate
if (LATENCY>=3)begin
always@(posedge i_clk or negedge i_rst_n)begin
	if (!i_rst_n)begin
		index3_dly3 <= 0;
		index4_dly3 <= 0;
		index2_dly3 <= 0;
		index1_dly3 <= 0;
		replace_value2 <= 0;
	end
	else if(i_clken) begin
		index3_dly3 <= index3_dly2;
		index4_dly3 <= index4_dly2;
		index2_dly3 <= index2_dly2;
		index1_dly3 <= index[1];
		replace_value2 <= index[1] ? replace_value1[3:2] : replace_value1[1:0];
	end
	else begin
		index3_dly3 <= index3_dly3;
		index4_dly3 <= index4_dly3;
		index2_dly3 <= index2_dly3;
		index1_dly3 <= index1_dly3;
		replace_value2 <= replace_value2;
	end
end
end
else begin
always@(*)begin
		index3_dly3 <= index3_dly2;
		index4_dly3 <= index4_dly2;
		index2_dly3 <= index2_dly2;
		index1_dly3 <= index[1];
		replace_value2 <= index[1] ? replace_value1[3:2] : replace_value1[1:0];
end
end
endgenerate

always@(*)begin index[0] = replace_value2[1];end

assign o_index = {index4_dly3,index3_dly3,index2_dly3,index1_dly3,index[0]};

endmodule