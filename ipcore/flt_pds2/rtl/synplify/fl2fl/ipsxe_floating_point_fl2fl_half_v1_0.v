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
// Filename: ipsxe_floating_point_fl2fl_half_v1_0.v
// Function: this module transfers a floating-point number to another
//           floating precision
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns
module ipsxe_floating_point_fl2fl_half_v1_0 #(
    parameter FLOAT_IN_EXP = 8,
    parameter FLOAT_IN_FRAC = 24,//include the hidden one
    parameter FLOAT_OUT_EXP = 11,
    parameter FLOAT_OUT_FRAC = 53,//include the hidden one
    parameter LATENCY_CONFIG = 1
)(
    input i_aclk,
    input i_aclken,
    input i_areset_n,
    input [FLOAT_IN_EXP+FLOAT_IN_FRAC-1:0]i_axi4s_a_tdata,
    input i_axi4s_or_abcoperation_tvalid,
    output [FLOAT_OUT_EXP+FLOAT_OUT_FRAC-1:0] o_axi4s_result_tdata,
    output o_axi4s_result_tvalid,
    output reg o_overflow,
    output reg o_underflow
);

wire all_judge;
wire [FLOAT_IN_EXP-1:0] float_in_exp_max;//maximum of the input float exp
wire [FLOAT_OUT_EXP-1:0] float_out_exp_max;//maximum of the output float exp
wire [FLOAT_IN_EXP-1:0] float_in_exp_num_max;//bias of the input float exp
wire [FLOAT_OUT_EXP-1:0] float_out_exp_num_max;//bias of the output float exp
wire signed [FLOAT_IN_FRAC-2:0] float_in_frac_signed;//for float_in_frac_final_signed

reg sign;
reg [FLOAT_OUT_EXP-1:0] float_out_exp;//the output float exp
reg [FLOAT_OUT_FRAC-2:0] float_out_frac;//the output float frac
reg [FLOAT_IN_FRAC-2:0] float_in_frac_shift_back;//for round to even

assign all_judge = i_axi4s_or_abcoperation_tvalid;

ipsxe_floating_point_register_v1_0 #(1) u_reg_m_axis_result_tvalid(i_aclk, i_aclken, i_areset_n, i_axi4s_or_abcoperation_tvalid, o_axi4s_result_tvalid);

/////////////  exp and frac  /////////////
    assign float_in_exp_max = {(FLOAT_IN_EXP){1'b1}};
    assign float_out_exp_max = {(FLOAT_OUT_EXP){1'b1}};

    assign float_in_exp_num_max = {(FLOAT_IN_EXP-1){1'b1}};
    assign float_out_exp_num_max = {(FLOAT_OUT_EXP-1){1'b1}};
generate
if (LATENCY_CONFIG == 1) begin: genblk_exp_and_frac_latency_config_1
    wire [FLOAT_IN_EXP-1:0] float_in_exp;//the input float exp
    wire [FLOAT_IN_FRAC-2:0] float_in_frac; //the input float exp
    wire [FLOAT_IN_FRAC-2:0] float_in_frac_remain;//for round to even
    wire common_pre_judge_1;
    wire common_pre_judge_2;
    wire common_pre_judge_3;
    wire zero;
    wire denormalized;
    wire infinite;
    wire nan;
    wire common_judge_1;
    wire common_judge_2;
    wire common_judge_3;
    wire common_judge_4_1;
    wire common_judge_4_2;
    wire common_judge_4;
    wire common_judge_5;
    wire common_judge_6;
    wire common_judge_7;
    wire common_judge_8;
    wire common_judge_9;
    wire common_judge_10;
    wire common_judge_11;
    wire common_judge_12;
    wire [FLOAT_OUT_EXP-1:0] common_num_1;
    wire [FLOAT_OUT_EXP-1:0] common_num_2;
    wire [FLOAT_OUT_EXP-1:0] common_num_3;
    wire [FLOAT_OUT_FRAC-2:0] common_num_4;
    wire [FLOAT_OUT_EXP-1:0] float_out_exp_origin;
    wire [FLOAT_OUT_EXP-1:0] float_out_exp_add;
    wire [FLOAT_OUT_FRAC-2:0] float_out_frac_origin;
    wire [FLOAT_OUT_FRAC-2:0] float_out_frac_add;
    wire [FLOAT_OUT_EXP-1:0] float_out_exp_r;//the output float exp
    wire [FLOAT_OUT_FRAC-2:0] float_out_frac_r;//the output float frac
    wire o_overflow_r;
    wire o_underflow_r;

    reg [FLOAT_IN_FRAC-2:0] float_in_frac_shift;//to see the bit after the last needed bit    
    reg signed [FLOAT_IN_FRAC-2:0] float_in_frac_final_signed;//to see exp needs to carry or not when frac carries
    reg [FLOAT_IN_FRAC-2:0] float_in_frac_final;//the result before carries
    reg [FLOAT_OUT_FRAC-2:0] float_in_frac_final2;//the result before carries

    assign float_in_exp = i_axi4s_a_tdata[FLOAT_IN_EXP+FLOAT_IN_FRAC-2:FLOAT_IN_FRAC-1];
    assign float_in_frac = i_axi4s_a_tdata[FLOAT_IN_FRAC-2:0];

    //these are for carrying and round to even
    assign float_in_frac_signed = float_in_frac;

    always@(*)begin:genblk_float_constant_r
        if(FLOAT_IN_FRAC>FLOAT_OUT_FRAC)begin
            float_in_frac_shift = float_in_frac >> (FLOAT_IN_FRAC-FLOAT_OUT_FRAC-1);
            float_in_frac_final_signed = float_in_frac_signed >>> (FLOAT_IN_FRAC-FLOAT_OUT_FRAC);
            float_in_frac_final = float_in_frac >> (FLOAT_IN_FRAC-FLOAT_OUT_FRAC);
            float_in_frac_shift_back = float_in_frac_shift<<(FLOAT_IN_FRAC-FLOAT_OUT_FRAC-1);
            float_in_frac_final2 = {(FLOAT_OUT_FRAC-1){1'b0}};
        end
        else begin //FLOAT_IN_FRAC<=FLOAT_OUT_FRAC
            float_in_frac_shift = {(FLOAT_IN_FRAC-1){1'b0}};
            float_in_frac_final_signed = {(FLOAT_IN_FRAC-1){1'b0}};
            float_in_frac_final = {(FLOAT_IN_FRAC-1){1'b0}};
            float_in_frac_shift_back = {(FLOAT_IN_FRAC-1){1'b0}};
            float_in_frac_final2 = float_in_frac << (FLOAT_OUT_FRAC-FLOAT_IN_FRAC);
        end
    end

    assign float_in_frac_remain = float_in_frac - float_in_frac_shift_back;

    //calculate exp and frac

    assign common_pre_judge_1 = (float_in_exp == {(FLOAT_IN_EXP){1'b0}});
    assign common_pre_judge_2 = (float_in_frac == {(FLOAT_IN_FRAC-1){1'b0}});
    assign common_pre_judge_3 = (float_in_exp == float_in_exp_max);

    assign zero = (common_pre_judge_1) && (common_pre_judge_2);
    assign denormalized = (common_pre_judge_1) && (!common_pre_judge_2);
    assign infinite = (common_pre_judge_3) && (common_pre_judge_2);
    assign nan = (common_pre_judge_3) && (!common_pre_judge_2);

    assign common_judge_1 = (float_in_exp>=float_in_exp_num_max);
    assign common_judge_2 = (common_judge_1)?((float_in_exp-float_in_exp_num_max)>float_out_exp_num_max):((float_in_exp_num_max-float_in_exp)>float_out_exp_num_max);
    assign common_judge_3 = (common_judge_1)?((float_in_exp-float_in_exp_num_max)==float_out_exp_num_max):((float_in_exp_num_max-float_in_exp)==float_out_exp_num_max);
    assign common_judge_4_1 = (float_in_frac_shift[0] == 1'b1);
    assign common_judge_4_2 = (float_in_frac_final_signed == {(FLOAT_IN_FRAC-1){1'b1}});
    assign common_judge_4 = (common_judge_4_1)&&(common_judge_4_2);
    assign common_judge_5 = (common_judge_3)&&(common_judge_4);
    assign common_judge_6 = float_in_frac_remain != {(FLOAT_IN_FRAC-1){1'b0}};
    assign common_judge_7 = float_in_frac_final[0] == 1'b1;
    assign common_judge_8 = (common_judge_6)?(1'b1):((common_judge_7)?(1'b1):(1'b0));
    assign common_judge_9 = FLOAT_IN_FRAC>FLOAT_OUT_FRAC;
    assign common_judge_10 = common_judge_4_1;
    assign common_num_1 = (common_judge_1)?(float_out_exp_max):({(FLOAT_OUT_EXP){1'b0}});
    assign common_num_2 = (float_in_exp-float_in_exp_num_max+float_out_exp_num_max);
    assign common_num_3 = (common_judge_6)?({{(FLOAT_OUT_EXP-1){1'b0}},{1'b1}}):((common_judge_7)?({{(FLOAT_OUT_EXP-1){1'b0}},{1'b1}}):({(FLOAT_OUT_EXP){1'b0}}));
    assign common_num_4 = (common_judge_6)?({{(FLOAT_OUT_FRAC-2){1'b0}},{1'b1}}):((common_judge_7)?({{(FLOAT_OUT_FRAC-2){1'b0}},{1'b1}}):({(FLOAT_OUT_FRAC-1){1'b0}}));

    assign float_out_exp_origin = (common_judge_2)?(common_num_1):(common_num_2);
    assign float_out_exp_add = (common_judge_4)?(common_num_3):({(FLOAT_OUT_EXP){1'b0}});
    assign float_out_frac_origin = (common_judge_9)?((common_judge_2)?({(FLOAT_OUT_FRAC-1){1'b0}}):(float_in_frac_final)):(float_in_frac_final2);
    assign float_out_frac_add = (common_judge_10)?(common_num_4):({(FLOAT_OUT_FRAC-1){1'b0}});

    assign o_overflow_r = ((common_judge_1)?((common_judge_2)?(1'b1):((common_judge_5)?(common_judge_8):(1'b0))):(1'b0))&&(!infinite)&&(!nan);
    assign o_underflow_r = ((denormalized)?(1'b1):((common_judge_1)?(1'b0):((common_judge_2)?(1'b1):((common_judge_3)?((common_judge_4)?(!common_judge_8):(1'b1)):(1'b0)))))&&(!zero);

    assign common_judge_11 = zero||o_underflow_r;
    assign common_judge_12 = infinite||o_overflow_r;

    assign float_out_exp_r = (common_judge_11)?({(FLOAT_OUT_EXP){1'b0}}):((common_judge_12||nan)?(float_out_exp_max):(float_out_exp_origin + float_out_exp_add));
    assign float_out_frac_r = (common_judge_11||common_judge_12)?({(FLOAT_OUT_FRAC-1){1'b0}}):((nan)?({{1'b1},{(FLOAT_OUT_FRAC-2){1'b0}}}):(float_out_frac_origin + float_out_frac_add));

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_float_out_underflow_r_overflow_r
        if(!i_areset_n)begin
            float_out_exp <= {(FLOAT_OUT_EXP){1'b0}};
            float_out_frac <= {(FLOAT_OUT_FRAC-1){1'b0}};
            o_underflow <= 1'b0;
            o_overflow <= 1'b0;
        end
        else if (i_aclken)begin
            if(all_judge)begin
                float_out_exp <= float_out_exp_r;
                float_out_frac <= float_out_frac_r;
                o_underflow <= o_underflow_r;
                o_overflow <= o_overflow_r;
            end
            else begin
                float_out_exp <= float_out_exp;
                float_out_frac <= float_out_frac;
                o_underflow <= o_underflow;
                o_overflow <= o_overflow;
            end
        end
    end
    //////////////// sign /////////////////////
    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_sign
        if(!i_areset_n)begin
            sign <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            if((float_in_exp == float_in_exp_max) && (float_in_frac != 0))begin //nan
                sign <= 1'b0;
            end
            else begin
                sign <= i_axi4s_a_tdata[FLOAT_IN_EXP+FLOAT_IN_FRAC-1];
            end
        end
        else begin
            sign <= sign;
        end
    end
end
else if (LATENCY_CONFIG == 2) begin:genblk_exp_and_frac_latency_config_2
    wire [FLOAT_IN_EXP-1:0] float_in_exp_r;//the input float exp
    wire [FLOAT_IN_FRAC-2:0] float_in_frac_r; //the input float exp
    wire [FLOAT_IN_FRAC-2:0] float_in_frac_remain_r;//for round to even
    wire common_pre_judge_1;
    wire common_pre_judge_2;
    wire common_pre_judge_3;
    wire zero;
    wire denormalized;
    wire infinite;
    wire nan;
    wire common_judge_1;
    wire common_judge_2;
    wire common_judge_3;
    wire common_judge_4_1;
    wire common_judge_4_2;
    wire common_judge_4;
    wire common_judge_5;
    wire common_judge_6;
    wire common_judge_7;
    wire common_judge_8;
    wire common_judge_9;
    wire common_judge_10;
    wire common_judge_11;
    wire common_judge_12;
    wire [FLOAT_OUT_EXP-1:0] common_num_1;
    wire [FLOAT_OUT_EXP-1:0] common_num_2;
    wire [FLOAT_OUT_EXP-1:0] common_num_3;
    wire [FLOAT_OUT_FRAC-2:0] common_num_4;
    wire [FLOAT_OUT_EXP-1:0] float_out_exp_origin;
    wire [FLOAT_OUT_EXP-1:0] float_out_exp_add;
    wire [FLOAT_OUT_FRAC-2:0] float_out_frac_origin;
    wire [FLOAT_OUT_FRAC-2:0] float_out_frac_add;
    wire [FLOAT_OUT_EXP-1:0] float_out_exp_r;//the output float exp
    wire [FLOAT_OUT_FRAC-2:0] float_out_frac_r;//the output float frac
    wire o_overflow_r;
    wire o_underflow_r;

    reg [FLOAT_IN_FRAC-2:0] float_in_frac_shift_r;//to see the bit after the last needed bit    
    reg signed [FLOAT_IN_FRAC-2:0] float_in_frac_final_signed_r;//to see exp needs to carry or not when frac carries
    reg [FLOAT_IN_FRAC-2:0] float_in_frac_final_r;//the result before carries
    reg [FLOAT_OUT_FRAC-2:0] float_in_frac_final2_r;//the result before carries
    reg [FLOAT_IN_EXP-1:0] float_in_exp;//the input float exp
    reg [FLOAT_IN_FRAC-2:0] float_in_frac; //the input float exp
    reg [FLOAT_IN_FRAC-2:0] float_in_frac_shift;//to see the bit after the last needed bit    
    reg signed [FLOAT_IN_FRAC-2:0] float_in_frac_final_signed;//to see exp needs to carry or not when frac carries
    reg [FLOAT_IN_FRAC-2:0] float_in_frac_final;//the result before carries
    reg [FLOAT_OUT_FRAC-2:0] float_in_frac_final2;//the result before carries
    reg [FLOAT_IN_FRAC-2:0] float_in_frac_remain;//for round to even    
    reg sign_r;

    assign float_in_exp_r = i_axi4s_a_tdata[FLOAT_IN_EXP+FLOAT_IN_FRAC-2:FLOAT_IN_FRAC-1];
    assign float_in_frac_r = i_axi4s_a_tdata[FLOAT_IN_FRAC-2:0];

    //these are for carrying and round to even
    assign float_in_frac_signed = float_in_frac_r;

    always@(*)begin:genblk_float_constant_r
        if(FLOAT_IN_FRAC>FLOAT_OUT_FRAC)begin
            float_in_frac_shift_r = float_in_frac_r >> (FLOAT_IN_FRAC-FLOAT_OUT_FRAC-1);
            float_in_frac_final_signed_r = float_in_frac_signed >>> (FLOAT_IN_FRAC-FLOAT_OUT_FRAC);
            float_in_frac_final_r = float_in_frac_r >> (FLOAT_IN_FRAC-FLOAT_OUT_FRAC);
            float_in_frac_shift_back = float_in_frac_shift_r<<(FLOAT_IN_FRAC-FLOAT_OUT_FRAC-1);
            float_in_frac_final2_r = {(FLOAT_OUT_FRAC-1){1'b0}};
        end
        else begin //FLOAT_IN_FRAC<=FLOAT_OUT_FRAC
            float_in_frac_shift_r = {(FLOAT_IN_FRAC-1){1'b0}};
            float_in_frac_final_signed_r = {(FLOAT_IN_FRAC-1){1'b0}};
            float_in_frac_final_r = {(FLOAT_IN_FRAC-1){1'b0}};
            float_in_frac_shift_back = {(FLOAT_IN_FRAC-1){1'b0}};
            float_in_frac_final2_r = float_in_frac_r << (FLOAT_OUT_FRAC-FLOAT_IN_FRAC);
        end
    end

    assign float_in_frac_remain_r = float_in_frac_r - float_in_frac_shift_back;

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_float_constant
        if(!i_areset_n)begin
            float_in_exp <= {(FLOAT_IN_EXP){1'b0}};
            float_in_frac <= {(FLOAT_OUT_FRAC-1){1'b0}};
            float_in_frac_shift <= {(FLOAT_IN_FRAC-1){1'b0}};
            float_in_frac_final_signed <= {(FLOAT_IN_FRAC-1){1'b0}};
            float_in_frac_final <= {(FLOAT_IN_FRAC-1){1'b0}};
            float_in_frac_final2 <= {(FLOAT_OUT_FRAC-1){1'b0}};
            float_in_frac_remain <= {(FLOAT_IN_FRAC-1){1'b0}};
        end
        else if (i_aclken)begin
            if(all_judge)begin
                float_in_exp <= float_in_exp_r;
                float_in_frac <= float_in_frac_r;
                float_in_frac_shift <= float_in_frac_shift_r;
                float_in_frac_final_signed <= float_in_frac_final_signed_r;
                float_in_frac_final <= float_in_frac_final_r;
                float_in_frac_final2 <= float_in_frac_final2_r;
                float_in_frac_remain <= float_in_frac_remain_r;
            end
            else begin
                float_in_exp <= float_in_exp;
                float_in_frac <= float_in_frac;
                float_in_frac_shift <= float_in_frac_shift;
                float_in_frac_final_signed <= float_in_frac_final_signed;
                float_in_frac_final <= float_in_frac_final;
                float_in_frac_final2 <= float_in_frac_final2;
                float_in_frac_remain <= float_in_frac_remain;
            end
        end
    end

    //calculate exp and frac

    assign common_pre_judge_1 = (float_in_exp == {(FLOAT_IN_EXP){1'b0}});
    assign common_pre_judge_2 = (float_in_frac == {(FLOAT_IN_FRAC-1){1'b0}});
    assign common_pre_judge_3 = (float_in_exp == float_in_exp_max);

    assign zero = (common_pre_judge_1) && (common_pre_judge_2);
    assign denormalized = (common_pre_judge_1) && (!common_pre_judge_2);
    assign infinite = (common_pre_judge_3) && (common_pre_judge_2);
    assign nan = (common_pre_judge_3) && (!common_pre_judge_2);

    assign common_judge_1 = (float_in_exp>=float_in_exp_num_max);
    assign common_judge_2 = (common_judge_1)?((float_in_exp-float_in_exp_num_max)>float_out_exp_num_max):((float_in_exp_num_max-float_in_exp)>float_out_exp_num_max);
    assign common_judge_3 = (common_judge_1)?((float_in_exp-float_in_exp_num_max)==float_out_exp_num_max):((float_in_exp_num_max-float_in_exp)==float_out_exp_num_max);
    assign common_judge_4_1 = (float_in_frac_shift[0] == 1'b1);
    assign common_judge_4_2 = (float_in_frac_final_signed == {(FLOAT_IN_FRAC-1){1'b1}});
    assign common_judge_4 = (common_judge_4_1)&&(common_judge_4_2);
    assign common_judge_5 = (common_judge_3)&&(common_judge_4);
    assign common_judge_6 = float_in_frac_remain != {(FLOAT_IN_FRAC-1){1'b0}};
    assign common_judge_7 = float_in_frac_final[0] == 1'b1;
    assign common_judge_8 = (common_judge_6)?(1'b1):((common_judge_7)?(1'b1):(1'b0));
    assign common_judge_9 = FLOAT_IN_FRAC>FLOAT_OUT_FRAC;
    assign common_judge_10 = common_judge_4_1;
    assign common_num_1 = (common_judge_1)?(float_out_exp_max):({(FLOAT_OUT_EXP){1'b0}});
    assign common_num_2 = (float_in_exp-float_in_exp_num_max+float_out_exp_num_max);
    assign common_num_3 = (common_judge_6)?({{(FLOAT_OUT_EXP-1){1'b0}},{1'b1}}):((common_judge_7)?({{(FLOAT_OUT_EXP-1){1'b0}},{1'b1}}):({(FLOAT_OUT_EXP){1'b0}}));
    assign common_num_4 = (common_judge_6)?({{(FLOAT_OUT_FRAC-2){1'b0}},{1'b1}}):((common_judge_7)?({{(FLOAT_OUT_FRAC-2){1'b0}},{1'b1}}):({(FLOAT_OUT_FRAC-1){1'b0}}));

    assign float_out_exp_origin = (common_judge_2)?(common_num_1):(common_num_2);
    assign float_out_exp_add = (common_judge_4)?(common_num_3):({(FLOAT_OUT_EXP){1'b0}});
    assign float_out_frac_origin = (common_judge_9)?((common_judge_2)?({(FLOAT_OUT_FRAC-1){1'b0}}):(float_in_frac_final)):(float_in_frac_final2);
    assign float_out_frac_add = (common_judge_10)?(common_num_4):({(FLOAT_OUT_FRAC-1){1'b0}});

    assign o_overflow_r = ((common_judge_1)?((common_judge_2)?(1'b1):((common_judge_5)?(common_judge_8):(1'b0))):(1'b0))&&(!infinite)&&(!nan);
    assign o_underflow_r = ((denormalized)?(1'b1):((common_judge_1)?(1'b0):((common_judge_2)?(1'b1):((common_judge_3)?((common_judge_4)?(!common_judge_8):(1'b1)):(1'b0)))))&&(!zero);

    assign common_judge_11 = zero||o_underflow_r;
    assign common_judge_12 = infinite||o_overflow_r;

    assign float_out_exp_r = (common_judge_11)?({(FLOAT_OUT_EXP){1'b0}}):((common_judge_12||nan)?(float_out_exp_max):(float_out_exp_origin + float_out_exp_add));
    assign float_out_frac_r = (common_judge_11||common_judge_12)?({(FLOAT_OUT_FRAC-1){1'b0}}):((nan)?({{1'b1},{(FLOAT_OUT_FRAC-2){1'b0}}}):(float_out_frac_origin + float_out_frac_add));

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_float_out_underflow_r_overflow_r
        if(!i_areset_n)begin
            float_out_exp <= {(FLOAT_OUT_EXP){1'b0}};
            float_out_frac <= {(FLOAT_OUT_FRAC-1){1'b0}};
            o_underflow <= 1'b0;
            o_overflow <= 1'b0;
        end
        else if (i_aclken)begin
            if(all_judge)begin
                float_out_exp <= float_out_exp_r;
                float_out_frac <= float_out_frac_r;
                o_underflow <= o_underflow_r;
                o_overflow <= o_overflow_r;
            end
            else begin
                float_out_exp <= float_out_exp;
                float_out_frac <= float_out_frac;
                o_underflow <= o_underflow;
                o_overflow <= o_overflow;
            end
        end
    end
    //////////////// sign /////////////////////

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_sign_r
        if(!i_areset_n)begin
            sign_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            if((float_in_exp_r == float_in_exp_max) && (float_in_frac_r != 0))begin //nan
                sign_r <= 1'b0;
            end
            else begin
                sign_r <= i_axi4s_a_tdata[FLOAT_IN_EXP+FLOAT_IN_FRAC-1];
            end
        end
        else begin
            sign_r <= sign_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_sign
        if(!i_areset_n)begin
            sign <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            sign <= sign_r;
        end
        else begin
            sign <= sign;
        end
    end
end
else begin:genblk_exp_and_frac_latency_config_3
    wire [FLOAT_IN_EXP-1:0] float_in_exp_r;//the input float exp
    wire [FLOAT_IN_FRAC-2:0] float_in_frac_r; //the input float exp
    wire [FLOAT_IN_FRAC-2:0] float_in_frac_remain_r;//for round to even
    wire common_pre_judge_1;
    wire common_pre_judge_2;
    wire common_pre_judge_3;
    wire zero_r;
    wire denormalized_r;
    wire infinite_r;
    wire nan_r;
    wire common_judge_1_r;
    wire common_judge_2_r;
    wire common_judge_3_r;
    wire common_judge_4_1;
    wire common_judge_4_2;
    wire common_judge_4_r;
    wire common_judge_5_r;
    wire common_judge_6;
    wire common_judge_7;
    wire common_judge_8_r;
    wire common_judge_9_r;
    wire common_judge_10_r;
    wire common_judge_11;
    wire common_judge_12;
    wire [FLOAT_OUT_EXP-1:0] common_num_1_r;
    wire [FLOAT_OUT_EXP-1:0] common_num_2_r;
    wire [FLOAT_OUT_EXP-1:0] common_num_3_r;
    wire [FLOAT_OUT_FRAC-2:0] common_num_4_r;
    wire [FLOAT_OUT_EXP-1:0] float_out_exp_origin;
    wire [FLOAT_OUT_EXP-1:0] float_out_exp_add;
    wire [FLOAT_OUT_FRAC-2:0] float_out_frac_origin;
    wire [FLOAT_OUT_FRAC-2:0] float_out_frac_add;
    wire [FLOAT_OUT_EXP-1:0] float_out_exp_r;//the output float exp
    wire [FLOAT_OUT_FRAC-2:0] float_out_frac_r;//the output float frac
    wire o_overflow_r;
    wire o_underflow_r;

    reg [FLOAT_IN_FRAC-2:0] float_in_frac_shift_r;//to see the bit after the last needed bit    
    reg signed [FLOAT_IN_FRAC-2:0] float_in_frac_final_signed_r;//to see exp needs to carry or not when frac carries
    reg [FLOAT_IN_FRAC-2:0] float_in_frac_final_r2;//the result before carries
    reg [FLOAT_OUT_FRAC-2:0] float_in_frac_final2_r2;//the result before carries
    reg [FLOAT_IN_FRAC-2:0] float_in_frac_final_r;//the result before carries
    reg [FLOAT_OUT_FRAC-2:0] float_in_frac_final2_r;//the result before carries
    reg [FLOAT_IN_EXP-1:0] float_in_exp;//the input float exp
    reg [FLOAT_IN_FRAC-2:0] float_in_frac; //the input float exp
    reg [FLOAT_IN_FRAC-2:0] float_in_frac_shift;//to see the bit after the last needed bit    
    reg signed [FLOAT_IN_FRAC-2:0] float_in_frac_final_signed;//to see exp needs to carry or not when frac carries
    reg [FLOAT_IN_FRAC-2:0] float_in_frac_final;//the result before carries
    reg [FLOAT_OUT_FRAC-2:0] float_in_frac_final2;//the result before carries
    reg [FLOAT_IN_FRAC-2:0] float_in_frac_remain;//for round to even
    reg zero;
    reg denormalized;
    reg infinite;
    reg nan;
    reg common_judge_1;
    reg common_judge_2;
    reg common_judge_3;
    reg common_judge_4;
    reg common_judge_5;
    reg common_judge_8;
    reg common_judge_9;
    reg common_judge_10;
    reg [FLOAT_OUT_EXP-1:0] common_num_1;
    reg [FLOAT_OUT_EXP-1:0] common_num_2;
    reg [FLOAT_OUT_EXP-1:0] common_num_3;
    reg [FLOAT_OUT_FRAC-2:0] common_num_4;
    reg sign_r;
    reg sign_r2;

    assign float_in_exp_r = i_axi4s_a_tdata[FLOAT_IN_EXP+FLOAT_IN_FRAC-2:FLOAT_IN_FRAC-1];
    assign float_in_frac_r = i_axi4s_a_tdata[FLOAT_IN_FRAC-2:0];

    //these are for carrying and round to even
    assign float_in_frac_signed = float_in_frac_r;

    always@(*)begin:genblk_float_constant_r
        if(FLOAT_IN_FRAC>FLOAT_OUT_FRAC)begin
            float_in_frac_shift_r = float_in_frac_r >> (FLOAT_IN_FRAC-FLOAT_OUT_FRAC-1);
            float_in_frac_final_signed_r = float_in_frac_signed >>> (FLOAT_IN_FRAC-FLOAT_OUT_FRAC);
            float_in_frac_final_r2 = float_in_frac_r >> (FLOAT_IN_FRAC-FLOAT_OUT_FRAC);
            float_in_frac_shift_back = float_in_frac_shift_r<<(FLOAT_IN_FRAC-FLOAT_OUT_FRAC-1);
            float_in_frac_final2_r2 = {(FLOAT_OUT_FRAC-1){1'b0}};
        end
        else begin //FLOAT_IN_FRAC<=FLOAT_OUT_FRAC
            float_in_frac_shift_r = {(FLOAT_IN_FRAC-1){1'b0}};
            float_in_frac_final_signed_r = {(FLOAT_IN_FRAC-1){1'b0}};
            float_in_frac_final_r2 = {(FLOAT_IN_FRAC-1){1'b0}};
            float_in_frac_shift_back = {(FLOAT_IN_FRAC-1){1'b0}};
            float_in_frac_final2_r2 = float_in_frac_r << (FLOAT_OUT_FRAC-FLOAT_IN_FRAC);
        end
    end

    assign float_in_frac_remain_r = float_in_frac_r - float_in_frac_shift_back;

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_float_constant
        if(!i_areset_n)begin
            float_in_exp <= {(FLOAT_IN_EXP){1'b0}};
            float_in_frac <= {(FLOAT_OUT_FRAC-1){1'b0}};
            float_in_frac_shift <= {(FLOAT_IN_FRAC-1){1'b0}};
            float_in_frac_final_signed <= {(FLOAT_IN_FRAC-1){1'b0}};
            float_in_frac_final_r <= {(FLOAT_IN_FRAC-1){1'b0}};
            float_in_frac_final2_r <= {(FLOAT_OUT_FRAC-1){1'b0}};
            float_in_frac_remain <= {(FLOAT_IN_FRAC-1){1'b0}};
        end
        else if (i_aclken)begin
            if(all_judge)begin
                float_in_exp <= float_in_exp_r;
                float_in_frac <= float_in_frac_r;
                float_in_frac_shift <= float_in_frac_shift_r;
                float_in_frac_final_signed <= float_in_frac_final_signed_r;
                float_in_frac_final_r <= float_in_frac_final_r2;
                float_in_frac_final2_r <= float_in_frac_final2_r2;
                float_in_frac_remain <= float_in_frac_remain_r;
            end
            else begin
                float_in_exp <= float_in_exp;
                float_in_frac <= float_in_frac;
                float_in_frac_shift <= float_in_frac_shift;
                float_in_frac_final_signed <= float_in_frac_final_signed;
                float_in_frac_final_r <= float_in_frac_final_r;
                float_in_frac_final2_r <= float_in_frac_final2_r;
                float_in_frac_remain <= float_in_frac_remain;
            end
        end
    end

    //calculate exp and frac

    assign common_pre_judge_1 = (float_in_exp == {(FLOAT_IN_EXP){1'b0}});
    assign common_pre_judge_2 = (float_in_frac == {(FLOAT_IN_FRAC-1){1'b0}});
    assign common_pre_judge_3 = (float_in_exp == float_in_exp_max);

    assign zero_r = (common_pre_judge_1) && (common_pre_judge_2);
    assign denormalized_r = (common_pre_judge_1) && (!common_pre_judge_2);
    assign infinite_r = (common_pre_judge_3) && (common_pre_judge_2);
    assign nan_r = (common_pre_judge_3) && (!common_pre_judge_2);

    assign common_judge_1_r = (float_in_exp>=float_in_exp_num_max);
    assign common_judge_2_r = (common_judge_1_r)?((float_in_exp-float_in_exp_num_max)>float_out_exp_num_max):((float_in_exp_num_max-float_in_exp)>float_out_exp_num_max);
    assign common_judge_3_r = (common_judge_1_r)?((float_in_exp-float_in_exp_num_max)==float_out_exp_num_max):((float_in_exp_num_max-float_in_exp)==float_out_exp_num_max);
    assign common_judge_4_1 = (float_in_frac_shift[0] == 1'b1);
    assign common_judge_4_2 = (float_in_frac_final_signed == {(FLOAT_IN_FRAC-1){1'b1}});
    assign common_judge_4_r = (common_judge_4_1)&&(common_judge_4_2);
    assign common_judge_5_r = (common_judge_3_r)&&(common_judge_4_r);
    assign common_judge_6 = float_in_frac_remain != {(FLOAT_IN_FRAC-1){1'b0}};
    assign common_judge_7 = float_in_frac_final_r[0] == 1'b1;
    assign common_judge_8_r = (common_judge_6)?(1'b1):((common_judge_7)?(1'b1):(1'b0));
    assign common_judge_9_r = FLOAT_IN_FRAC>FLOAT_OUT_FRAC;
    assign common_judge_10_r = common_judge_4_1;
    assign common_num_1_r = (common_judge_1_r)?(float_out_exp_max):({(FLOAT_OUT_EXP){1'b0}});
    assign common_num_2_r = (float_in_exp-float_in_exp_num_max+float_out_exp_num_max);
    assign common_num_3_r = (common_judge_6)?({{(FLOAT_OUT_EXP-1){1'b0}},{1'b1}}):((common_judge_7)?({{(FLOAT_OUT_EXP-1){1'b0}},{1'b1}}):({(FLOAT_OUT_EXP){1'b0}}));
    assign common_num_4_r = (common_judge_6)?({{(FLOAT_OUT_FRAC-2){1'b0}},{1'b1}}):((common_judge_7)?({{(FLOAT_OUT_FRAC-2){1'b0}},{1'b1}}):({(FLOAT_OUT_FRAC-1){1'b0}}));

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_special_cases
        if(!i_areset_n)begin
            zero <= 1'b0;
            denormalized <= 1'b0;
            infinite <= 1'b0;
            nan <= 1'b0;
        end
        else if (i_aclken)begin
            if(all_judge)begin
                zero <= zero_r;
                denormalized <= denormalized_r;
                infinite <= infinite_r;
                nan <= nan_r;
            end
            else begin
                zero <= zero;
                denormalized <= denormalized;
                infinite <= infinite;
                nan <= nan;
            end
        end
    end
    
    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_common_judge
        if(!i_areset_n)begin
            common_judge_1 <= 1'b0;
            common_judge_2 <= 1'b0;
            common_judge_3 <= 1'b0;
            common_judge_4 <= 1'b0;
            common_judge_5 <= 1'b0;
            common_judge_8 <= 1'b0;
            common_judge_9 <= 1'b0;
            common_judge_10 <= 1'b0;
        end
        else if (i_aclken)begin
            if(all_judge)begin
                common_judge_1 <= common_judge_1_r;
                common_judge_2 <= common_judge_2_r;
                common_judge_3 <= common_judge_3_r;
                common_judge_4 <= common_judge_4_r;
                common_judge_5 <= common_judge_5_r;
                common_judge_8 <= common_judge_8_r;
                common_judge_9 <= common_judge_9_r;
                common_judge_10 <= common_judge_10_r;
            end
            else begin
                common_judge_1 <= common_judge_1;
                common_judge_2 <= common_judge_2;
                common_judge_3 <= common_judge_3;
                common_judge_4 <= common_judge_4;
                common_judge_5 <= common_judge_5;
                common_judge_8 <= common_judge_8;
                common_judge_9 <= common_judge_9;
                common_judge_10 <= common_judge_10;
            end
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_common_float_frac_final
        if(!i_areset_n)begin
            float_in_frac_final <= {(FLOAT_IN_FRAC-1){1'b0}};
            float_in_frac_final2 <= {(FLOAT_OUT_FRAC-1){1'b0}};
        end
        else if (i_aclken)begin
            if(all_judge)begin
                float_in_frac_final <= float_in_frac_final_r;
                float_in_frac_final2 <= float_in_frac_final2_r;
            end
            else begin
                float_in_frac_final <= float_in_frac_final;
                float_in_frac_final2 <= float_in_frac_final2;
            end
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_common_num
        if(!i_areset_n)begin
            common_num_1 <= {(FLOAT_OUT_EXP){1'b0}};
            common_num_2 <= {(FLOAT_OUT_EXP){1'b0}};
            common_num_3 <= {(FLOAT_OUT_FRAC-1){1'b0}};
            common_num_4 <= {(FLOAT_OUT_FRAC-1){1'b0}};
        end
        else if (i_aclken)begin
            if(all_judge)begin
                common_num_1 <= common_num_1_r;
                common_num_2 <= common_num_2_r;
                common_num_3 <= common_num_3_r;
                common_num_4 <= common_num_4_r;
            end
            else begin
                common_num_1 <= common_num_1;
                common_num_2 <= common_num_2;
                common_num_3 <= common_num_3;
                common_num_4 <= common_num_4;
            end
        end
    end

    assign float_out_exp_origin = (common_judge_2)?(common_num_1):(common_num_2);
    assign float_out_exp_add = (common_judge_4)?(common_num_3):({(FLOAT_OUT_EXP){1'b0}});
    assign float_out_frac_origin = (common_judge_9)?((common_judge_2)?({(FLOAT_OUT_FRAC-1){1'b0}}):(float_in_frac_final)):(float_in_frac_final2);
    assign float_out_frac_add = (common_judge_10)?(common_num_4):({(FLOAT_OUT_FRAC-1){1'b0}});

    assign o_overflow_r = ((common_judge_1)?((common_judge_2)?(1'b1):((common_judge_5)?(common_judge_8):(1'b0))):(1'b0))&&(!infinite)&&(!nan);
    assign o_underflow_r = ((denormalized)?(1'b1):((common_judge_1)?(1'b0):((common_judge_2)?(1'b1):((common_judge_3)?((common_judge_4)?(!common_judge_8):(1'b1)):(1'b0)))))&&(!zero);

    assign common_judge_11 = zero||o_underflow_r;
    assign common_judge_12 = infinite||o_overflow_r;

    assign float_out_exp_r = (common_judge_11)?({(FLOAT_OUT_EXP){1'b0}}):((common_judge_12||nan)?(float_out_exp_max):(float_out_exp_origin + float_out_exp_add));
    assign float_out_frac_r = (common_judge_11||common_judge_12)?({(FLOAT_OUT_FRAC-1){1'b0}}):((nan)?({{1'b1},{(FLOAT_OUT_FRAC-2){1'b0}}}):(float_out_frac_origin + float_out_frac_add));

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_float_out_underflow_r_overflow_r
        if(!i_areset_n)begin
            float_out_exp <= {(FLOAT_OUT_EXP){1'b0}};
            float_out_frac <= {(FLOAT_OUT_FRAC-1){1'b0}};
            o_underflow <= 1'b0;
            o_overflow <= 1'b0;
        end
        else if (i_aclken)begin
            if(all_judge)begin
                float_out_exp <= float_out_exp_r;
                float_out_frac <= float_out_frac_r;
                o_underflow <= o_underflow_r;
                o_overflow <= o_overflow_r;
            end
            else begin
                float_out_exp <= float_out_exp;
                float_out_frac <= float_out_frac;
                o_underflow <= o_underflow;
                o_overflow <= o_overflow;
            end
        end
    end
    //////////////// sign /////////////////////

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_sign_r2
        if(!i_areset_n)begin
            sign_r2 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            if((float_in_exp_r == float_in_exp_max) && (float_in_frac_r != 0))begin //nan
                sign_r2 <= 1'b0;
            end
            else begin
                sign_r2 <= i_axi4s_a_tdata[FLOAT_IN_EXP+FLOAT_IN_FRAC-1];
            end
        end
        else begin
            sign_r2 <= sign_r2;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_sign_r
        if(!i_areset_n)begin
            sign_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            sign_r <= sign_r2;
        end
        else begin
            sign_r <= sign_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_sign
        if(!i_areset_n)begin
            sign <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            sign <= sign_r;
        end
        else begin
            sign <= sign;
        end
    end
end
endgenerate
///////////////  combination ////////////////////
assign o_axi4s_result_tdata = {sign,float_out_exp,float_out_frac};

endmodule