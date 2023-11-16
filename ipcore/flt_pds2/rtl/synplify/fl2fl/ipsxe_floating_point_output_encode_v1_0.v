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
// Filename: ipsxe_floating_point_output_encode_v1_0.v
// Function: 
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_output_encode_v1_0 #(
    parameter FRAC_MID_WIDTH = 24,
    parameter FLOAT_IN_EXP = 8,
    parameter FLOAT_IN_FRAC = 24, //include the hidden one
    parameter FLOAT_OUT_EXP = 11,
    parameter FLOAT_OUT_FRAC = 53 //include the hidden one
)
(
    input i_aclk,
    input i_aclken,
    input i_areset_n,
    input sign,
    input [FRAC_MID_WIDTH-1:0] frac_mid,
    input [FLOAT_IN_EXP-1:0] exp_in,
    input [1:0] case_judge,

    output reg [FLOAT_OUT_EXP+FLOAT_OUT_FRAC-1:0] data_out
);

localparam EXP_BIAS_IN = 2 ** (FLOAT_IN_EXP-1) - 1;
localparam EXP_BIAS_OUT = 2 ** (FLOAT_OUT_EXP-1) - 1;
localparam signed EXP_BIAS = EXP_BIAS_OUT - EXP_BIAS_IN;

generate
    if(FLOAT_IN_FRAC > FLOAT_OUT_FRAC) begin
        wire [FLOAT_OUT_FRAC-2:0] frac_out;
        wire [FLOAT_OUT_EXP-1:0] exp_out;

        assign frac_out[FLOAT_OUT_FRAC-2] = case_judge[0] ? case_judge[1] : frac_mid[FRAC_MID_WIDTH-2];
        assign frac_out[FLOAT_OUT_FRAC-3:0] = case_judge[0] ? 0 : frac_mid[FRAC_MID_WIDTH-3:0];

        assign exp_out = case_judge[0] ? {(FLOAT_OUT_EXP){exp_in[FLOAT_IN_EXP-1]}} : exp_in+EXP_BIAS+frac_mid[FRAC_MID_WIDTH-1];

        always @(posedge i_aclk) begin
            if(!i_areset_n) begin
                data_out <= 0;
            end
            else if(i_aclken) begin
                data_out <= {sign, exp_out, frac_out};
            end
        end
    end
    else begin
        wire [FRAC_MID_WIDTH-1:0] frac_out;
        wire [FLOAT_OUT_EXP-1:0] exp_out;

        assign frac_out[FRAC_MID_WIDTH-1] = case_judge[0] ? case_judge[1] : frac_mid[FRAC_MID_WIDTH-1];
        assign frac_out[FRAC_MID_WIDTH-2:0] = case_judge[0] ? 0 : frac_mid[FRAC_MID_WIDTH-2:0];

        assign exp_out = case_judge[0] ? {(FLOAT_OUT_EXP){exp_in[0]}} : exp_in + EXP_BIAS;

        always @(posedge i_aclk) begin
            if(!i_areset_n) begin
                data_out <= 0;
            end
            else if(i_aclken) begin
                data_out <= {sign, exp_out, frac_out, {(FLOAT_OUT_FRAC-FLOAT_IN_FRAC){1'b0}}};
            end
        end
    end
endgenerate


endmodule