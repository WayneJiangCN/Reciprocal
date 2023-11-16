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
// Filename: ipsxe_floating_point_fl2fx_nothalf_v1_0
// Function: this module transfers a floating-point number to the fixed-
//           point number
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_fl2fx_nothalf_v1_0 #(
    parameter FLOAT_EXP_BIT = 8,
    parameter FLOAT_FRAC_BIT = 24, //include the hidden one
    parameter FIXED_INT_BIT = 31, //include sign bit
    parameter FIXED_FRAC_BIT = 1,
    parameter LATENCY_CONFIG = 1
)
(
    input i_aclk,
    input i_aclken,
    input i_areset_n,
    input [FLOAT_EXP_BIT+FLOAT_FRAC_BIT-1:0] i_axi4s_a_tdata,
    input i_axi4s_or_abcoperation_tvalid,
    output reg [FIXED_INT_BIT+FIXED_FRAC_BIT-1:0] o_axi4s_result_tdata, //with 1 sign bit
    output o_axi4s_result_tvalid,
    output o_invalid_op,
    output o_overflow
);

localparam FIXED_DATA_WIDTH = FIXED_INT_BIT + FIXED_FRAC_BIT;
localparam EXP_BIAS = 2 ** (FLOAT_EXP_BIT-1) - 1 + (FIXED_INT_BIT-1);
localparam EXP_MAX = 2 ** FLOAT_EXP_BIT - 1;

//////////////////// wire & reg ////////////////////
// wire float_sign, zero, infinite, nan, overflow, underflow;
wire float_sign, infinite, nan, overflow, underflow;
wire minus_max;

wire [FLOAT_EXP_BIT-1:0] float_exp;
wire [FLOAT_FRAC_BIT-2:0] float_frac;

wire signed [FLOAT_EXP_BIT-1:0] shift_num;
wire shift_direct;
wire [FIXED_DATA_WIDTH-1:0] fixed_data_pre;
reg [FIXED_DATA_WIDTH+FLOAT_FRAC_BIT-1:0] shift_data;

reg [FIXED_DATA_WIDTH-1:0] fixed_data;
wire fixed_carry;
wire carry, carry_mid;
wire w_overflow;
wire w_invalid;

//////////////////// judge sign, zero, infinite, and NaN ////////////////////
    assign float_sign = i_axi4s_a_tdata[FLOAT_EXP_BIT+FLOAT_FRAC_BIT-1];
    assign {float_exp,float_frac} = i_axi4s_a_tdata[FLOAT_EXP_BIT+FLOAT_FRAC_BIT-2:0];

    // assign zero = float_exp=={(FLOAT_EXP_BIT){1'b0}};//include denormalized floating numbers and zero
    assign infinite = (float_exp==EXP_MAX)&&(float_frac=={(FLOAT_FRAC_BIT-1){1'b0}});
    assign nan = (float_exp==EXP_MAX)&&(float_frac!={(FLOAT_FRAC_BIT-1){1'b0}});

    assign shift_num = EXP_BIAS - float_exp;
    assign shift_direct = i_axi4s_a_tdata[FLOAT_EXP_BIT+FLOAT_FRAC_BIT-2];

//////////////////// decode float to fixed data ////////////////////
    always @(*) begin
        if(!shift_num[FLOAT_EXP_BIT-1])
            shift_data = { {1'b1}, float_frac, {(FIXED_DATA_WIDTH){1'b0}} } >> shift_num[FLOAT_EXP_BIT-2:0];
        else
            shift_data = 0;
    end

    ipsxe_floating_point_round_v6_v1_0 #( //round to even
        .FLOAT_FRAC_BIT(FLOAT_FRAC_BIT)
    ) u_round (
        .data_in(shift_data[FLOAT_FRAC_BIT-1:0]),
        .carry(carry),
        .carry_mid(carry_mid)
    );

    assign fixed_carry = carry | (carry_mid & shift_data[FLOAT_FRAC_BIT]);
    assign fixed_data_pre = shift_data[FIXED_DATA_WIDTH+FLOAT_FRAC_BIT-1 -: FIXED_DATA_WIDTH] + fixed_carry;

    always @(*) begin
        //fixed_data = shift_data[FIXED_DATA_WIDTH+FLOAT_FRAC_BIT-1 -: FIXED_DATA_WIDTH] + fixed_carry;
        if(float_sign)
            fixed_data = ~(fixed_data_pre) + 1;
        else
            fixed_data = fixed_data_pre;
    end

//////////////////// encode output data ////////////////////
    assign minus_max = float_sign && fixed_data == {{1'b1},{(FIXED_DATA_WIDTH-1){1'b0}}};    // can try to change shift_direct?

    assign overflow = (fixed_data_pre[FIXED_DATA_WIDTH-1] | (shift_direct & shift_num[FLOAT_EXP_BIT-1]) | (!fixed_data_pre[FIXED_DATA_WIDTH-1] & shift_data[FIXED_DATA_WIDTH+FLOAT_FRAC_BIT-1]));
    assign underflow = (~shift_direct & (shift_num[FLOAT_EXP_BIT-1]|shift_num>=FIXED_DATA_WIDTH)) & fixed_data_pre[0] != 1;

    always @(posedge i_aclk or negedge i_areset_n) begin
        if(!i_areset_n) begin
            o_axi4s_result_tdata <= 0;
        end
        else if(i_aclken) begin
            if((float_sign & (overflow | infinite)) | nan) begin
                o_axi4s_result_tdata <= {{1'b1},{(FIXED_DATA_WIDTH-1){1'b0}}};
            end
            else if(~float_sign & (overflow | infinite)) begin
                o_axi4s_result_tdata <= {{1'b0},{(FIXED_DATA_WIDTH-1){1'b1}}};
            end
            else if(underflow) begin
                o_axi4s_result_tdata <= 0; //{(FIXED_INT_BIT+FIXED_FRAC_BIT){1'b0}};
            end
            else begin
                o_axi4s_result_tdata <= {float_sign, fixed_data[FIXED_DATA_WIDTH-2:0]};
                //if(float_sign)
                //    o_axi4s_result_tdata <= {{1'b1}, {~fixed_data[FIXED_DATA_WIDTH-2:0]+1}};
                //else
                //    o_axi4s_result_tdata <= {{1'b0}, fixed_data[FIXED_DATA_WIDTH-2:0]};
            end
        end
    end

    ipsxe_floating_point_register_v1_0 #(1) u_reg_m_axis_result_tvalid(
        i_aclk,
        i_aclken,
        i_areset_n,
        i_axi4s_or_abcoperation_tvalid,
        o_axi4s_result_tvalid
    );

    assign o_overflow = !minus_max & (overflow | infinite) & !nan;
    assign o_invalid_op = nan | infinite;

    // assign w_overflow = !minus_max & (overflow | infinite) & !nan;
    // assign w_invalid = nan | infinite;

    // always @(posedge i_aclk or negedge i_areset_n) begin
    //     if(!i_areset_n) begin
    //         o_overflow <= 0;
    //         o_invalid_op <= 0;
    //     end
    //     else if(i_aclken)begin
    //         o_overflow <= w_overflow;
    //         o_invalid_op <= w_invalid;
    //     end
    //     else begin
    //         o_overflow <= o_overflow;
    //         o_invalid_op <= o_invalid_op;
    //     end
    // end



endmodule