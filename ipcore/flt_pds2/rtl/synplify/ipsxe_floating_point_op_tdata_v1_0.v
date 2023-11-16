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
// Filename: ipsxe_floating_point_op_tdata_v1_0.v
// Function: This module determines operation_data values according to the
//           user configuration.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_op_tdata_v1_0 #(
    parameter OP_SEL = 0,
    parameter OP_PLUS_MINUS = 0,
    parameter OP_COMPARE = 0
) (
    input [8-1:0] i_axi4s_operation_tdata,
    output [2:0] o_operation_tdata
);

generate
if (OP_SEL != 3) begin
if (OP_PLUS_MINUS == 0) begin
assign o_operation_tdata = i_axi4s_operation_tdata[2:0];
end
else if (OP_PLUS_MINUS == 1) begin
assign o_operation_tdata = 3'b0;
end
else begin // OP_PLUS_MINUS == 2
assign o_operation_tdata = 3'b1;
end
end

else begin
if (OP_COMPARE == 0) begin
assign o_operation_tdata = i_axi4s_operation_tdata[5:3];
end
else if (OP_COMPARE == 1) begin
assign o_operation_tdata = 3'b000;
end
else if (OP_COMPARE == 2) begin
assign o_operation_tdata = 3'b001;
end
else if (OP_COMPARE == 3) begin
assign o_operation_tdata = 3'b010;
end
else if (OP_COMPARE == 4) begin
assign o_operation_tdata = 3'b011;
end
else if (OP_COMPARE == 5) begin
assign o_operation_tdata = 3'b100;
end
else if (OP_COMPARE == 6) begin
assign o_operation_tdata = 3'b101;
end
else if (OP_COMPARE == 7) begin
assign o_operation_tdata = 3'b110;
end
else begin // OP_COMPARE == 8
assign o_operation_tdata = 3'b111;
end
end
endgenerate

endmodule