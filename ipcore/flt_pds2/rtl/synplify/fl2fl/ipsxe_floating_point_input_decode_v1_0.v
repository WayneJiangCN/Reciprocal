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
// Filename: ipsxe_floating_point_input_decode_v1_0.v
// Function: 
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_input_decode_v1_0 #(
    parameter FLOAT_IN_EXP = 8,
    parameter FLOAT_IN_FRAC = 24, //include the hidden one
    parameter FLOAT_OUT_EXP = 11,
    parameter FLOAT_OUT_FRAC = 53 //include the hidden one
)
(
    input i_aclk,
    input i_aclken,
    input i_areset_n,
    input [FLOAT_IN_EXP+FLOAT_IN_FRAC-1:0] data_in,

    output sign,
    output [FLOAT_IN_EXP-1:0] exp_in,
    output [FLOAT_IN_FRAC-2:0] frac_in,
    output [1:0] case_judge,
    output reg o_overflow,
    output reg o_underflow
);

localparam EXP_BIAS_IN = 2 ** (FLOAT_IN_EXP-1) - 1;
localparam EXP_BIAS_OUT = 2 ** (FLOAT_OUT_EXP-1) - 1;

//////////////////// wire & reg ////////////////////
wire [2:0] special_judge;
wire overflow, underflow;

//////////////////// decode special cases ////////////////////
    assign special_judge[2] = exp_in == 2**(FLOAT_IN_EXP)-1;
    assign special_judge[1] = exp_in == 0;
    assign special_judge[0] = frac_in == 0;

    assign sign = case_judge[1] ? 0 : data_in[FLOAT_IN_EXP+FLOAT_IN_FRAC-1];//nan -> sign=0
    assign {exp_in, frac_in} = data_in[FLOAT_IN_EXP+FLOAT_IN_FRAC-2 : 0];

//////////////////// judge underflow and overflow ////////////////////
generate
    if(FLOAT_IN_EXP > FLOAT_OUT_EXP) begin
        assign overflow = exp_in > (EXP_BIAS_IN+EXP_BIAS_OUT+1);
        assign underflow = exp_in < (EXP_BIAS_IN-EXP_BIAS_OUT);

        assign case_judge[1] = special_judge[2] & !special_judge[0]; //frac = 1000
        assign case_judge[0] = underflow | overflow; //exp = 0 | 1111, frac = 0
    end
    else begin
        assign overflow = 1'b0;
        assign underflow = 1'b0;

        assign case_judge[1] = special_judge[2] & !special_judge[0]; //frac = 1000
        assign case_judge[0] = special_judge[2] | special_judge[1]; //exp = 0 | 1111, frac = 0
    end
endgenerate

    always @(posedge i_aclk) begin
        if(!i_areset_n) begin
            o_overflow <= 0;
            o_underflow <= 0;
        end
        else if(i_aclken) begin
            o_overflow <= overflow & !special_judge[2];
            o_underflow <= underflow & !special_judge[1];
        end
    end


endmodule