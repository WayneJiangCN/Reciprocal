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
// Filename: ipsxe_floating_point_fl2fx_half_v1_0
// Function: this module transfers a floating-point number to the fixed-
//           point number
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_fl2fx_half_v1_0 #(
    parameter FLOAT_EXP_BIT = 8,
    parameter FLOAT_FRAC_BIT = 24, //include the hidden one
    parameter FIXED_INT_BIT = 32, //include sign bit
    parameter FIXED_FRAC_BIT = 0,
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

wire all_judge;
wire [FLOAT_EXP_BIT-1:0] exp_bias; //the bias of exp
wire [FLOAT_EXP_BIT-1:0] exp_max; //the maximum of exp
wire [FLOAT_EXP_BIT-1:0]float_exp;
wire [FLOAT_FRAC_BIT-2:0]float_frac;
wire [FLOAT_EXP_BIT+FLOAT_FRAC_BIT-2:0] float_without_sign;//no special meaning
wire zero_judge;
wire infinite_judge;
wire nan_judge;
wire [FLOAT_EXP_BIT-2:0] shift_final;
wire [FLOAT_FRAC_BIT-1:0] M_final;
wire shift_direct_w;
wire common_use_judge1;
wire common_use_judge2;
wire common_use_judge3;
wire [FLOAT_FRAC_BIT-1:0] M_right_final;//to see the final bit of M after shifting right is 0/1 without carrying (floating number <0)
wire [FLOAT_FRAC_BIT-1:0] M_left_final;//to see the final bit of M after shifting left is 0/1 without carrying (floating number >=0)
wire [FLOAT_FRAC_BIT-1:0] pre_add;//the variable for round to even
wire signed [FLOAT_FRAC_BIT-1:0] pre_add_constant1;
wire [FLOAT_FRAC_BIT-1:0] pre_add_constant2;
wire [FLOAT_FRAC_BIT-1:0] pre_add_constant3;
wire [FLOAT_FRAC_BIT:0] carry_after;//the final result before shifting
wire [FIXED_INT_BIT+FIXED_FRAC_BIT-1:0] carry_final;//shifted final result
wire overflow_judge1;//obvious overflow
wire overflow_judge2;//overflow after carrying due to round to even
wire overflow_judge3;//overflow after carrying due to round to even
wire underflow_judge1;//obvious underflow
wire minus_max_judge1;//obvious reaching minimum of fixed num
wire minus_max_judge2;//reaching minimum of fixed num after carrying due to round to evenwire result_judge1;//to see whether floating number is positive or negative
wire result_judge1;
wire result_judge2;//negative infinite and overflow
wire result_judge3;//positive infinite and overflow
wire result_judge4;//nan and negative infinite and overflow
wire tuser_judge1;
wire tuser_judge2;

reg float_sign;
reg zero_sig;
reg infinite_sig;
reg nan_sig;
reg shift_direct; //0 moves towards right(smaller), 1 moves towards left(bigger)
reg [FLOAT_EXP_BIT-2:0]shift_num;//when shift_direct is 0, shift_num>0; when shift_direct is 1, shift_num>=0
reg [FLOAT_FRAC_BIT-1:0]M; //{1.float_fraction}
reg [FIXED_INT_BIT-1:0] fixed_int;
reg zero;        //high active
reg minus_max;   //high active
reg overflow;    //high active
reg infinite;    //high active
reg nan;         //high active
reg underflow;   //high active
reg overflow_r;
reg underflow_r;
reg minus_max_r;
reg tuser_judge1_reg;
reg tuser_judge2_reg;

assign all_judge = i_axi4s_or_abcoperation_tvalid;

ipsxe_floating_point_register_v1_0 #(1) u_reg_m_axis_result_tvalid(i_aclk, i_aclken, i_areset_n, i_axi4s_or_abcoperation_tvalid, o_axi4s_result_tvalid);

////////////////    sign    ////////////////////
generate
if (LATENCY_CONFIG == 1) begin: genblk_sign_latency_config_1
    always@(*) begin:genblk_latency_config_1_float_sign
        float_sign = i_axi4s_a_tdata[FLOAT_EXP_BIT+FLOAT_FRAC_BIT-1];
    end
end
else if(LATENCY_CONFIG == 2) begin: genblk_sign_latency_config_2
    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_2_float_sign
        if(!i_areset_n)begin
            float_sign <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            float_sign <= i_axi4s_a_tdata[FLOAT_EXP_BIT+FLOAT_FRAC_BIT-1];
        end
        else begin
            float_sign <= float_sign;
        end
    end
end
else if(LATENCY_CONFIG == 3) begin: genblk_sign_latency_config_3
    reg float_sign_r1;
    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_3_float_sign_r1
        if(!i_areset_n)begin
            float_sign_r1 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            float_sign_r1 <= i_axi4s_a_tdata[FLOAT_EXP_BIT+FLOAT_FRAC_BIT-1];
        end
        else begin
            float_sign_r1 <= float_sign_r1;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_3_float_sign
        if(!i_areset_n)begin
            float_sign <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            float_sign <= float_sign_r1;
        end
        else begin
            float_sign <= float_sign;
        end
    end
end
else if(LATENCY_CONFIG == 4) begin: genblk_sign_latency_config_4
    reg float_sign_r1;
    reg float_sign_r2;
    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_4_float_sign_r2
        if(!i_areset_n)begin
            float_sign_r2 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            float_sign_r2 <= i_axi4s_a_tdata[FLOAT_EXP_BIT+FLOAT_FRAC_BIT-1];
        end
        else begin
            float_sign_r2 <= float_sign_r2;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_4_float_sign_r1
        if(!i_areset_n)begin
            float_sign_r1 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            float_sign_r1 <= float_sign_r2;
        end
        else begin
            float_sign_r1 <= float_sign_r1;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_4_float_sign
        if(!i_areset_n)begin
            float_sign <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            float_sign <= float_sign_r1;
        end
        else begin
            float_sign <= float_sign;
        end
    end
end
else if(LATENCY_CONFIG == 5) begin: genblk_sign_latency_config_5
    reg float_sign_r1;
    reg float_sign_r2;
    reg float_sign_r3;
    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_5_float_sign_r3
        if(!i_areset_n)begin
            float_sign_r3 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            float_sign_r3 <= i_axi4s_a_tdata[FLOAT_EXP_BIT+FLOAT_FRAC_BIT-1];
        end
        else begin
            float_sign_r3 <= float_sign_r3;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_5_float_sign_r2
        if(!i_areset_n)begin
            float_sign_r2 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            float_sign_r2 <= float_sign_r3;
        end
        else begin
            float_sign_r2 <= float_sign_r2;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_5_float_sign_r1
        if(!i_areset_n)begin
            float_sign_r1 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            float_sign_r1 <= float_sign_r2;
        end
        else begin
            float_sign_r1 <= float_sign_r1;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_5_float_sign
        if(!i_areset_n)begin
            float_sign <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            float_sign <= float_sign_r1;
        end
        else begin
            float_sign <= float_sign;
        end
    end
end
else begin: genblk_sign_latency_config_6
    reg float_sign_r1;
    reg float_sign_r2;
    reg float_sign_r3;
    reg float_sign_r4;
    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_6_float_sign_r4
        if(!i_areset_n)begin
            float_sign_r4 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            float_sign_r4 <= i_axi4s_a_tdata[FLOAT_EXP_BIT+FLOAT_FRAC_BIT-1];
        end
        else begin
            float_sign_r4 <= float_sign_r4;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_6_float_sign_r3
        if(!i_areset_n)begin
            float_sign_r3 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            float_sign_r3 <= float_sign_r4;
        end
        else begin
            float_sign_r3 <= float_sign_r3;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_6_float_sign_r2
        if(!i_areset_n)begin
            float_sign_r2 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            float_sign_r2 <= float_sign_r3;
        end
        else begin
            float_sign_r2 <= float_sign_r2;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_6_float_sign_r1
        if(!i_areset_n)begin
            float_sign_r1 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            float_sign_r1 <= float_sign_r2;
        end
        else begin
            float_sign_r1 <= float_sign_r1;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_6_float_sign
        if(!i_areset_n)begin
            float_sign <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            float_sign <= float_sign_r1;
        end
        else begin
            float_sign <= float_sign;
        end
    end
end

endgenerate


////////////    shift_direct and shift_num and M   ////////////////
assign exp_bias = {{1'b0},{(FLOAT_EXP_BIT-1){1'b1}}};
assign exp_max = {(FLOAT_EXP_BIT){1'b1}};

assign float_without_sign = i_axi4s_a_tdata[FLOAT_EXP_BIT+FLOAT_FRAC_BIT-2:0];
assign {float_exp,float_frac} = float_without_sign;

//to see if is zero, infinite or nan
assign zero_judge = float_exp=={(FLOAT_EXP_BIT){1'b0}};//include denormalized floating numbers and zero
assign infinite_judge = (float_exp==exp_max)&&(float_frac=={(FLOAT_FRAC_BIT-1){1'b0}});
assign nan_judge = (float_exp==exp_max)&&(float_frac!={(FLOAT_FRAC_BIT-1){1'b0}});
generate
if (LATENCY_CONFIG == 1) begin: genblk_sig_latency_config_1
    always@(*) begin:genblk_latency_config_1_zero_sig
        if(zero_judge)begin
            zero_sig = 1'b1;
        end
        else begin
            zero_sig = 1'b0;
        end
    end

    always@(*) begin:genblk_latency_config_1_infinite_sig
        if(infinite_judge)begin
            infinite_sig = 1'b1;
        end
        else begin
            infinite_sig = 1'b0;
        end
    end

    always@(*) begin:genblk_latency_config_1_nan_sig
        if(nan_judge)begin
            nan_sig = 1'b1;
        end
        else begin
            nan_sig = 1'b0;
        end
    end   
end
else if (LATENCY_CONFIG == 2) begin: genblk_sig_latency_config_2
    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_2_zero_sig
        if(!i_areset_n) begin
            zero_sig <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            if(zero_judge)begin
                zero_sig <= 1'b1;
            end
            else begin
                zero_sig <= 1'b0;
            end
        end
        else begin
            zero_sig <= zero_sig;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_2_infinite_sig
        if(!i_areset_n) begin
            infinite_sig <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            if(infinite_judge)begin
                infinite_sig <= 1'b1;
            end
            else begin
                infinite_sig <= 1'b0;
            end
        end
        else begin
            infinite_sig <= infinite_sig;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_2_nan_sig
        if(!i_areset_n) begin
            nan_sig <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            if(nan_judge)begin
                nan_sig <= 1'b1;
            end
            else begin
                nan_sig <= 1'b0;
            end
        end
        else begin
            nan_sig <= nan_sig;
        end
    end
end
else if (LATENCY_CONFIG == 3) begin: genblk_sig_latency_config_3
reg zero_sig_r1;
reg infinite_sig_r1;
reg nan_sig_r1;
    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_3_zero_sig_r1
        if(!i_areset_n) begin
            zero_sig_r1 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            if(zero_judge)begin
                zero_sig_r1 <= 1'b1;
            end
            else begin
                zero_sig_r1 <= 1'b0;
            end
        end
        else begin
            zero_sig_r1 <= zero_sig_r1;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_3_infinite_sig_r1
        if(!i_areset_n) begin
            infinite_sig_r1 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            if(infinite_judge)begin
                infinite_sig_r1 <= 1'b1;
            end
            else begin
                infinite_sig_r1 <= 1'b0;
            end
        end
        else begin
            infinite_sig_r1 <= infinite_sig_r1;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_3_nan_sig_r1
        if(!i_areset_n) begin
            nan_sig_r1 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            if(nan_judge)begin
                nan_sig_r1 <= 1'b1;
            end
            else begin
                nan_sig_r1 <= 1'b0;
            end
        end
        else begin
            nan_sig_r1 <= nan_sig_r1;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_3_zero_sig
        if(!i_areset_n) begin
            zero_sig <= 1'b0;
        end
        else if (i_aclken) begin 
            zero_sig <= zero_sig_r1;
        end
        else begin
            zero_sig <= zero_sig;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_3_infinite_sig
        if(!i_areset_n) begin
            infinite_sig <= 1'b0;
        end
        else if (i_aclken) begin
            infinite_sig <= infinite_sig_r1;
        end
        else begin
            infinite_sig <= infinite_sig;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_3_nan_sig
        if(!i_areset_n) begin
            nan_sig <= 1'b0;
        end
        else if (i_aclken)begin
            nan_sig <= nan_sig_r1;
        end
        else begin
            nan_sig <= nan_sig;
        end
    end
end
else if (LATENCY_CONFIG == 4) begin: genblk_sig_latency_config_4
reg zero_sig_r1;
reg infinite_sig_r1;
reg nan_sig_r1;
reg zero_sig_r2;
reg infinite_sig_r2;
reg nan_sig_r2;
    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_4_zero_sig_r2
        if(!i_areset_n) begin
            zero_sig_r2 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            if(zero_judge)begin
                zero_sig_r2 <= 1'b1;
            end
            else begin
                zero_sig_r2 <= 1'b0;
            end
        end
        else begin
            zero_sig_r2 <= zero_sig_r2;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_4_infinite_sig_r2
        if(!i_areset_n) begin
            infinite_sig_r2 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            if(infinite_judge)begin
                infinite_sig_r2 <= 1'b1;
            end
            else begin
                infinite_sig_r2 <= 1'b0;
            end
        end
        else begin
            infinite_sig_r2 <= infinite_sig_r2;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_4_nan_sig_r2
        if(!i_areset_n) begin
            nan_sig_r2 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            if(nan_judge)begin
                nan_sig_r2 <= 1'b1;
            end
            else begin
                nan_sig_r2 <= 1'b0;
            end
        end
        else begin
            nan_sig_r2 <= nan_sig_r2;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_4_zero_sig_r1
        if(!i_areset_n) begin
            zero_sig_r1 <= 1'b0;
        end
        else if (i_aclken) begin 
            zero_sig_r1 <= zero_sig_r2;
        end
        else begin
            zero_sig_r1 <= zero_sig_r1;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_4_infinite_sig_r1
        if(!i_areset_n) begin
            infinite_sig_r1 <= 1'b0;
        end
        else if (i_aclken) begin
            infinite_sig_r1 <= infinite_sig_r2;
        end
        else begin
            infinite_sig_r1 <= infinite_sig_r1;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_4_nan_sig_r1
        if(!i_areset_n) begin
            nan_sig_r1 <= 1'b0;
        end
        else if (i_aclken)begin
            nan_sig_r1 <= nan_sig_r2;
        end
        else begin
            nan_sig_r1 <= nan_sig_r1;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_4_zero_sig
        if(!i_areset_n) begin
            zero_sig <= 1'b0;
        end
        else if (i_aclken) begin 
            zero_sig <= zero_sig_r1;
        end
        else begin
            zero_sig <= zero_sig;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_4_infinite_sig
        if(!i_areset_n) begin
            infinite_sig <= 1'b0;
        end
        else if (i_aclken) begin
            infinite_sig <= infinite_sig_r1;
        end
        else begin
            infinite_sig <= infinite_sig;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_4_nan_sig
        if(!i_areset_n) begin
            nan_sig <= 1'b0;
        end
        else if (i_aclken)begin
            nan_sig <= nan_sig_r1;
        end
        else begin
            nan_sig <= nan_sig;
        end
    end
end
else if (LATENCY_CONFIG == 5) begin: genblk_sig_latency_config_5
reg zero_sig_r1;
reg infinite_sig_r1;
reg nan_sig_r1;
reg zero_sig_r2;
reg infinite_sig_r2;
reg nan_sig_r2;
reg zero_sig_r3;
reg infinite_sig_r3;
reg nan_sig_r3;
    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_5_zero_sig_r3
        if(!i_areset_n) begin
            zero_sig_r3 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            if(zero_judge)begin
                zero_sig_r3 <= 1'b1;
            end
            else begin
                zero_sig_r3 <= 1'b0;
            end
        end
        else begin
            zero_sig_r3 <= zero_sig_r3;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_5_infinite_sig_r3
        if(!i_areset_n) begin
            infinite_sig_r3 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            if(infinite_judge)begin
                infinite_sig_r3 <= 1'b1;
            end
            else begin
                infinite_sig_r3 <= 1'b0;
            end
        end
        else begin
            infinite_sig_r3 <= infinite_sig_r3;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_5_nan_sig_r3
        if(!i_areset_n) begin
            nan_sig_r3 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            if(nan_judge)begin
                nan_sig_r3 <= 1'b1;
            end
            else begin
                nan_sig_r3 <= 1'b0;
            end
        end
        else begin
            nan_sig_r3 <= nan_sig_r3;
        end
    end
    
    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_5_zero_sig_r2
        if(!i_areset_n) begin
            zero_sig_r2 <= 1'b0;
        end
        else if (i_aclken) begin 
            zero_sig_r2 <= zero_sig_r3;
        end
        else begin
            zero_sig_r2 <= zero_sig_r2;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_5_infinite_sig_r2
        if(!i_areset_n) begin
            infinite_sig_r2 <= 1'b0;
        end
        else if (i_aclken) begin
            infinite_sig_r2 <= infinite_sig_r3;
        end
        else begin
            infinite_sig_r2 <= infinite_sig_r2;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_5_nan_sig_r2
        if(!i_areset_n) begin
            nan_sig_r2 <= 1'b0;
        end
        else if (i_aclken)begin
            nan_sig_r2 <= nan_sig_r3;
        end
        else begin
            nan_sig_r2 <= nan_sig_r2;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_5_zero_sig_r1
        if(!i_areset_n) begin
            zero_sig_r1 <= 1'b0;
        end
        else if (i_aclken) begin 
            zero_sig_r1 <= zero_sig_r2;
        end
        else begin
            zero_sig_r1 <= zero_sig_r1;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_5_infinite_sig_r1
        if(!i_areset_n) begin
            infinite_sig_r1 <= 1'b0;
        end
        else if (i_aclken) begin
            infinite_sig_r1 <= infinite_sig_r2;
        end
        else begin
            infinite_sig_r1 <= infinite_sig_r1;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_5_nan_sig_r1
        if(!i_areset_n) begin
            nan_sig_r1 <= 1'b0;
        end
        else if (i_aclken)begin
            nan_sig_r1 <= nan_sig_r2;
        end
        else begin
            nan_sig_r1 <= nan_sig_r1;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_5_zero_sig
        if(!i_areset_n) begin
            zero_sig <= 1'b0;
        end
        else if (i_aclken) begin 
            zero_sig <= zero_sig_r1;
        end
        else begin
            zero_sig <= zero_sig;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_5_infinite_sig
        if(!i_areset_n) begin
            infinite_sig <= 1'b0;
        end
        else if (i_aclken) begin
            infinite_sig <= infinite_sig_r1;
        end
        else begin
            infinite_sig <= infinite_sig;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_5_nan_sig
        if(!i_areset_n) begin
            nan_sig <= 1'b0;
        end
        else if (i_aclken)begin
            nan_sig <= nan_sig_r1;
        end
        else begin
            nan_sig <= nan_sig;
        end
    end
end
else begin: genblk_sig_latency_config_6
reg zero_sig_r1;
reg infinite_sig_r1;
reg nan_sig_r1;
reg zero_sig_r2;
reg infinite_sig_r2;
reg nan_sig_r2;
reg zero_sig_r3;
reg infinite_sig_r3;
reg nan_sig_r3;
reg zero_sig_r4;
reg infinite_sig_r4;
reg nan_sig_r4;
    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_6_zero_sig_r4
        if(!i_areset_n) begin
            zero_sig_r4 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            if(zero_judge)begin
                zero_sig_r4 <= 1'b1;
            end
            else begin
                zero_sig_r4 <= 1'b0;
            end
        end
        else begin
            zero_sig_r4 <= zero_sig_r4;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_6_infinite_sig_r4
        if(!i_areset_n) begin
            infinite_sig_r4 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            if(infinite_judge)begin
                infinite_sig_r4 <= 1'b1;
            end
            else begin
                infinite_sig_r4 <= 1'b0;
            end
        end
        else begin
            infinite_sig_r4 <= infinite_sig_r4;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_6_nan_sig_r4
        if(!i_areset_n) begin
            nan_sig_r4 <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            if(nan_judge)begin
                nan_sig_r4 <= 1'b1;
            end
            else begin
                nan_sig_r4 <= 1'b0;
            end
        end
        else begin
            nan_sig_r4 <= nan_sig_r4;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_6_zero_sig_r3
        if(!i_areset_n) begin
            zero_sig_r3 <= 1'b0;
        end
        else if (i_aclken) begin 
            zero_sig_r3 <= zero_sig_r4;
        end
        else begin
            zero_sig_r3 <= zero_sig_r3;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_6_infinite_sig_r3
        if(!i_areset_n) begin
            infinite_sig_r3 <= 1'b0;
        end
        else if (i_aclken) begin
            infinite_sig_r3 <= infinite_sig_r4;
        end
        else begin
            infinite_sig_r3 <= infinite_sig_r3;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_6_nan_sig_r3
        if(!i_areset_n) begin
            nan_sig_r3 <= 1'b0;
        end
        else if (i_aclken)begin
            nan_sig_r3 <= nan_sig_r4;
        end
        else begin
            nan_sig_r3 <= nan_sig_r3;
        end
    end
    
    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_6_zero_sig_r2
        if(!i_areset_n) begin
            zero_sig_r2 <= 1'b0;
        end
        else if (i_aclken) begin 
            zero_sig_r2 <= zero_sig_r3;
        end
        else begin
            zero_sig_r2 <= zero_sig_r2;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_6_infinite_sig_r2
        if(!i_areset_n) begin
            infinite_sig_r2 <= 1'b0;
        end
        else if (i_aclken) begin
            infinite_sig_r2 <= infinite_sig_r3;
        end
        else begin
            infinite_sig_r2 <= infinite_sig_r2;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_6_nan_sig_r2
        if(!i_areset_n) begin
            nan_sig_r2 <= 1'b0;
        end
        else if (i_aclken)begin
            nan_sig_r2 <= nan_sig_r3;
        end
        else begin
            nan_sig_r2 <= nan_sig_r2;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_6_zero_sig_r1
        if(!i_areset_n) begin
            zero_sig_r1 <= 1'b0;
        end
        else if (i_aclken) begin 
            zero_sig_r1 <= zero_sig_r2;
        end
        else begin
            zero_sig_r1 <= zero_sig_r1;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_6_infinite_sig_r1
        if(!i_areset_n) begin
            infinite_sig_r1 <= 1'b0;
        end
        else if (i_aclken) begin
            infinite_sig_r1 <= infinite_sig_r2;
        end
        else begin
            infinite_sig_r1 <= infinite_sig_r1;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_6_nan_sig_r1
        if(!i_areset_n) begin
            nan_sig_r1 <= 1'b0;
        end
        else if (i_aclken)begin
            nan_sig_r1 <= nan_sig_r2;
        end
        else begin
            nan_sig_r1 <= nan_sig_r1;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_6_zero_sig
        if(!i_areset_n) begin
            zero_sig <= 1'b0;
        end
        else if (i_aclken) begin 
            zero_sig <= zero_sig_r1;
        end
        else begin
            zero_sig <= zero_sig;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_6_infinite_sig
        if(!i_areset_n) begin
            infinite_sig <= 1'b0;
        end
        else if (i_aclken) begin
            infinite_sig <= infinite_sig_r1;
        end
        else begin
            infinite_sig <= infinite_sig;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_latency_config_6_nan_sig
        if(!i_areset_n) begin
            nan_sig <= 1'b0;
        end
        else if (i_aclken)begin
            nan_sig <= nan_sig_r1;
        end
        else begin
            nan_sig <= nan_sig;
        end
    end
end
endgenerate

//calculate shift_direct, shift_num and M (float_frac with the hidden 1)
assign shift_final = (float_exp>=exp_bias)?(float_exp - exp_bias):(exp_bias - float_exp);
assign M_final = {1'b1,float_frac};
assign shift_direct_w = (float_exp>=exp_bias);
////////////////  fixed_num   /////////////////
always@(posedge i_aclk or negedge i_areset_n)begin:genblk_nan_infinite_zero
    if(!i_areset_n) begin
        nan <= 1'b0;
        infinite <= 1'b0;
        zero <= 1'b0;
    end
    else if (i_aclken)
    if(all_judge)begin
        nan <= nan_sig;
        infinite <= infinite_sig;
        zero <= zero_sig;
    end
    else begin
        nan <= nan;
        infinite <= infinite;
        zero <= zero;
    end
end

//calculate fixed num
generate
if (LATENCY_CONFIG == 1) begin: genblk_vital_value_latency_config_1
    always@(*) begin:genblk_shift_constant
        shift_direct = shift_direct_w;
        shift_num = shift_final;
        M = M_final;
    end
    //these are for round to even
    assign common_use_judge1 = FIXED_FRAC_BIT+1>=FLOAT_FRAC_BIT+shift_num;//represents no carrying when shift_direct is 0 (right)
    assign common_use_judge2 = FIXED_FRAC_BIT+1+shift_num>=FLOAT_FRAC_BIT;//represents no carrying when shift_direct is 1 (left)
    assign common_use_judge3 = shift_direct==1'b1; //left

    assign M_right_final = (common_use_judge1)?({(FLOAT_FRAC_BIT){1'b0}}):(M >> (FLOAT_FRAC_BIT+shift_num-1-FIXED_FRAC_BIT));
    assign M_left_final = (common_use_judge2)?({(FLOAT_FRAC_BIT){1'b0}}):(M >> (FLOAT_FRAC_BIT-shift_num-1-FIXED_FRAC_BIT));
    
    assign pre_add_constant1 = {{1'b1},{(FLOAT_FRAC_BIT-1){1'b0}}};
    assign pre_add_constant2 = pre_add_constant1>>>(FIXED_FRAC_BIT+1-shift_num);
    assign pre_add_constant3 = pre_add_constant1>>>(FIXED_FRAC_BIT+1+shift_num);
    assign pre_add = (common_use_judge3)?((common_use_judge2)?({(FLOAT_FRAC_BIT){1'b0}}):((M_left_final[0])?({{(FLOAT_FRAC_BIT-1){1'b0}},{1'b1}}<<(FLOAT_FRAC_BIT-shift_num-2-FIXED_FRAC_BIT)):(~pre_add_constant3))):((FIXED_FRAC_BIT+1>=FLOAT_FRAC_BIT+shift_num)?({(FLOAT_FRAC_BIT){1'b0}}):((M_right_final[0]==1'b0)?(~pre_add_constant2):({{(FLOAT_FRAC_BIT-1){1'b0}},{1'b1}}<<(FLOAT_FRAC_BIT+shift_num-2-FIXED_FRAC_BIT))));

    assign carry_after = pre_add + M;
    assign carry_final = (common_use_judge3)?((common_use_judge2)?(carry_after<<(FIXED_FRAC_BIT-FLOAT_FRAC_BIT+shift_num+1)):(carry_after>>(FLOAT_FRAC_BIT-shift_num-1-FIXED_FRAC_BIT))):((FIXED_FRAC_BIT+1>=FLOAT_FRAC_BIT+shift_num)?(carry_after<<(FIXED_FRAC_BIT-FLOAT_FRAC_BIT-shift_num+1)):(carry_after>>(FLOAT_FRAC_BIT+shift_num-1-FIXED_FRAC_BIT)));
    //these are special conditions
    assign overflow_judge1 = (shift_num+1==FIXED_INT_BIT)&&(M != {{1'b1},{(FLOAT_FRAC_BIT-1){1'b0}}});
    assign overflow_judge2 = (carry_after[FLOAT_FRAC_BIT]==1'b1)&&(FIXED_INT_BIT == shift_num+2);
    assign overflow_judge3 = (carry_after[FLOAT_FRAC_BIT]==1'b1)&&(FIXED_INT_BIT == 1);
    assign underflow_judge1 = ((shift_num-FIXED_FRAC_BIT==1)&&(carry_after[FLOAT_FRAC_BIT]==1'b0));
    assign minus_max_judge1 = ((shift_num+1==FIXED_INT_BIT)&&(M == {{1'b1},{(FLOAT_FRAC_BIT-1){1'b0}}}))||((shift_num+1==FIXED_INT_BIT-1)&&(carry_after[FLOAT_FRAC_BIT]==1'b1));
    assign minus_max_judge2 = (carry_after[FLOAT_FRAC_BIT]==1'b1)&&(FIXED_INT_BIT == 1);

    always@(*)begin:genblk_overflow_r_latency_config_2
        if(float_sign == 1'b1)begin
            if(common_use_judge3)begin
                if(shift_num+1>FIXED_INT_BIT)begin
                    overflow_r = 1'b1;
                end
                else begin//shift_num+1<=FIXED_INT_BIT
                    overflow_r = overflow_judge1;
                end
            end
            else begin//shift_direct==1'b0
                overflow_r = 1'b0;
            end
        end
        else begin//float_sign == 1'b0
            if(common_use_judge3)begin
                if(shift_num+2>FIXED_INT_BIT)begin
                    overflow_r = 1'b1;
                end
                else begin//shift_num+1<=FIXED_INT_BIT-1
                    overflow_r = overflow_judge2;
                end
            end
            else begin//shift_direct==1'b0
                overflow_r = overflow_judge3;
            end
        end
    end

    always@(*)begin:genblk_underflow_r_latency_config_2
        if(common_use_judge3)begin
            underflow_r = 1'b0;
        end
        else begin//shift_direct==1'b0
            if(zero_sig==1'b0)begin
                if(shift_num>1+FIXED_FRAC_BIT)begin
                    underflow_r = 1'b1;
                end
                else begin//shift_num-FIXED_FRAC_BIT<=1
                    underflow_r = underflow_judge1;
                end
            end
            else begin//zero_sig==1'b1
                underflow_r = 1'b0;
            end
        end
    end

    always@(*)begin:genblk_minus_max_r_latency_config_2
        if(float_sign==1'b1)begin
            if(common_use_judge3)begin
                minus_max_r = minus_max_judge1;
            end
            else begin
                minus_max_r = minus_max_judge2;
            end
        end
        else begin//float_sign==1'b1
            minus_max_r = 1'b0;
        end
    end

end
else if (LATENCY_CONFIG == 2) begin: genblk_vital_value_latency_config_2//Since shift_constant changes, there is no difference between genblk_vital_value_latency_config_1 and genblk_vital_value_latency_config_2
    
    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_shift_constant_latency_config_2
        if(!i_areset_n) begin
            shift_direct <= 1'b0;
            shift_num <= {(FLOAT_EXP_BIT-1){1'b0}};
            M <= {(FLOAT_EXP_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge) begin
            shift_direct <= shift_direct_w;
            shift_num <= shift_final;
            M <= M_final;
        end
        else begin
            shift_direct <= shift_direct;
            shift_num <= shift_num;
            M <= M;
        end
    end
    
    //these are for round to even
    assign common_use_judge1 = FIXED_FRAC_BIT+1>=FLOAT_FRAC_BIT+shift_num;//represents no carrying when shift_direct is 0 (right)
    assign common_use_judge2 = FIXED_FRAC_BIT+1+shift_num>=FLOAT_FRAC_BIT;//represents no carrying when shift_direct is 1 (left)
    assign common_use_judge3 = shift_direct==1'b1; //left

    assign M_right_final = (common_use_judge1)?({(FLOAT_FRAC_BIT){1'b0}}):(M >> (FLOAT_FRAC_BIT+shift_num-1-FIXED_FRAC_BIT));
    assign M_left_final = (common_use_judge2)?({(FLOAT_FRAC_BIT){1'b0}}):(M >> (FLOAT_FRAC_BIT-shift_num-1-FIXED_FRAC_BIT));
    
    assign pre_add_constant1 = {{1'b1},{(FLOAT_FRAC_BIT-1){1'b0}}};
    assign pre_add_constant2 = pre_add_constant1>>>(FIXED_FRAC_BIT+1-shift_num);
    assign pre_add_constant3 = pre_add_constant1>>>(FIXED_FRAC_BIT+1+shift_num);
    assign pre_add = (common_use_judge3)?((common_use_judge2)?({(FLOAT_FRAC_BIT){1'b0}}):((M_left_final[0])?({{(FLOAT_FRAC_BIT-1){1'b0}},{1'b1}}<<(FLOAT_FRAC_BIT-shift_num-2-FIXED_FRAC_BIT)):(~pre_add_constant3))):((FIXED_FRAC_BIT+1>=FLOAT_FRAC_BIT+shift_num)?({(FLOAT_FRAC_BIT){1'b0}}):((M_right_final[0]==1'b0)?(~pre_add_constant2):({{(FLOAT_FRAC_BIT-1){1'b0}},{1'b1}}<<(FLOAT_FRAC_BIT+shift_num-2-FIXED_FRAC_BIT))));

    assign carry_after = pre_add + M;
    assign carry_final = (common_use_judge3)?((common_use_judge2)?(carry_after<<(FIXED_FRAC_BIT-FLOAT_FRAC_BIT+shift_num+1)):(carry_after>>(FLOAT_FRAC_BIT-shift_num-1-FIXED_FRAC_BIT))):((FIXED_FRAC_BIT+1>=FLOAT_FRAC_BIT+shift_num)?(carry_after<<(FIXED_FRAC_BIT-FLOAT_FRAC_BIT-shift_num+1)):(carry_after>>(FLOAT_FRAC_BIT+shift_num-1-FIXED_FRAC_BIT)));
    //these are special conditions
    assign overflow_judge1 = (shift_num+1==FIXED_INT_BIT)&&(M != {{1'b1},{(FLOAT_FRAC_BIT-1){1'b0}}});
    assign overflow_judge2 = (carry_after[FLOAT_FRAC_BIT]==1'b1)&&(FIXED_INT_BIT == shift_num+2);
    assign overflow_judge3 = (carry_after[FLOAT_FRAC_BIT]==1'b1)&&(FIXED_INT_BIT == 1);
    assign underflow_judge1 = ((shift_num-FIXED_FRAC_BIT==1)&&(carry_after[FLOAT_FRAC_BIT]==1'b0));
    assign minus_max_judge1 = ((shift_num+1==FIXED_INT_BIT)&&(M == {{1'b1},{(FLOAT_FRAC_BIT-1){1'b0}}}))||((shift_num+1==FIXED_INT_BIT-1)&&(carry_after[FLOAT_FRAC_BIT]==1'b1));
    assign minus_max_judge2 = (carry_after[FLOAT_FRAC_BIT]==1'b1)&&(FIXED_INT_BIT == 1);

    always@(*)begin:genblk_overflow_r_latency_config_2
        if(float_sign == 1'b1)begin
            if(common_use_judge3)begin
                if(shift_num+1>FIXED_INT_BIT)begin
                    overflow_r = 1'b1;
                end
                else begin//shift_num+1<=FIXED_INT_BIT
                    overflow_r = overflow_judge1;
                end
            end
            else begin//shift_direct==1'b0
                overflow_r = 1'b0;
            end
        end
        else begin//float_sign == 1'b0
            if(common_use_judge3)begin
                if(shift_num+2>FIXED_INT_BIT)begin
                    overflow_r = 1'b1;
                end
                else begin//shift_num+1<=FIXED_INT_BIT-1
                    overflow_r = overflow_judge2;
                end
            end
            else begin//shift_direct==1'b0
                overflow_r = overflow_judge3;
            end
        end
    end

    always@(*)begin:genblk_underflow_r_latency_config_2
        if(common_use_judge3)begin
            underflow_r = 1'b0;
        end
        else begin//shift_direct==1'b0
            if(zero_sig==1'b0)begin
                if(shift_num>1+FIXED_FRAC_BIT)begin
                    underflow_r = 1'b1;
                end
                else begin//shift_num-FIXED_FRAC_BIT<=1
                    underflow_r = underflow_judge1;
                end
            end
            else begin//zero_sig==1'b1
                underflow_r = 1'b0;
            end
        end
    end

    always@(*)begin:genblk_minus_max_r_latency_config_2
        if(float_sign==1'b1)begin
            if(common_use_judge3)begin
                minus_max_r = minus_max_judge1;
            end
            else begin
                minus_max_r = minus_max_judge2;
            end
        end
        else begin//float_sign==1'b1
            minus_max_r = 1'b0;
        end
    end

end
else if (LATENCY_CONFIG == 3) begin: genblk_vital_value_latency_config_3
reg shift_direct_r1;
reg [FLOAT_EXP_BIT-2:0]shift_num_r1;
reg [FLOAT_FRAC_BIT-1:0]M_r1;
reg overflow_judge1_r;
reg overflow_judge2_r;
reg overflow_judge3_r;
reg underflow_judge1_r;
reg minus_max_judge1_r;
reg minus_max_judge2_r;
wire [FIXED_INT_BIT+FIXED_FRAC_BIT-1:0] carry_final_w;
reg [FIXED_INT_BIT+FIXED_FRAC_BIT-1:0] carry_final_r;

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_shift_constant_r1_latency_config_3
        if(!i_areset_n) begin
            shift_direct_r1 <= 1'b0;
            shift_num_r1 <= {(FLOAT_EXP_BIT-1){1'b0}};
            M_r1 <= {(FLOAT_EXP_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge) begin
            shift_direct_r1 <= shift_direct_w;
            shift_num_r1 <= shift_final;
            M_r1 <= M_final;
        end
        else begin
            shift_direct_r1 <= shift_direct_r1;
            shift_num_r1 <= shift_num_r1;
            M_r1 <= M_r1;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_shift_constant_latency_config_3
        if(!i_areset_n) begin
            shift_direct <= 1'b0;
            shift_num <= {(FLOAT_EXP_BIT-1){1'b0}};
            M <= {(FLOAT_EXP_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge) begin
            shift_direct <= shift_direct_r1;
            shift_num <= shift_num_r1;
            M <= M_r1;
        end
        else begin
            shift_direct <= shift_direct;
            shift_num <= shift_num;
            M <= M;
        end
    end
    //these are for round to even
    assign common_use_judge1 = FIXED_FRAC_BIT+1>=FLOAT_FRAC_BIT+shift_num_r1;//represents no carrying when shift_direct is 0 (right)
    assign common_use_judge2 = FIXED_FRAC_BIT+1+shift_num_r1>=FLOAT_FRAC_BIT;//represents no carrying when shift_direct is 1 (left)
    assign common_use_judge3 = shift_direct_r1==1'b1; //left

    assign M_right_final = (common_use_judge1)?({(FLOAT_FRAC_BIT){1'b0}}):(M_r1 >> (FLOAT_FRAC_BIT+shift_num_r1-1-FIXED_FRAC_BIT));
    assign M_left_final = (common_use_judge2)?({(FLOAT_FRAC_BIT){1'b0}}):(M_r1 >> (FLOAT_FRAC_BIT-shift_num_r1-1-FIXED_FRAC_BIT));
    
    assign pre_add_constant1 = {{1'b1},{(FLOAT_FRAC_BIT-1){1'b0}}};
    assign pre_add_constant2 = pre_add_constant1>>>(FIXED_FRAC_BIT+1-shift_num_r1);
    assign pre_add_constant3 = pre_add_constant1>>>(FIXED_FRAC_BIT+1+shift_num_r1);
    assign pre_add = (shift_direct_r1==1'b1)?((FIXED_FRAC_BIT+1+shift_num_r1>=FLOAT_FRAC_BIT)?({(FLOAT_FRAC_BIT){1'b0}}):((M_left_final[0])?({{(FLOAT_FRAC_BIT-1){1'b0}},{1'b1}}<<(FLOAT_FRAC_BIT-shift_num_r1-2-FIXED_FRAC_BIT)):(~pre_add_constant3))):((FIXED_FRAC_BIT+1>=FLOAT_FRAC_BIT+shift_num_r1)?({(FLOAT_FRAC_BIT){1'b0}}):((M_right_final[0]==1'b0)?(~pre_add_constant2):({{(FLOAT_FRAC_BIT-1){1'b0}},{1'b1}}<<(FLOAT_FRAC_BIT+shift_num_r1-2-FIXED_FRAC_BIT))));

    assign carry_after = pre_add + M_r1;

    assign carry_final_w = (shift_direct_r1==1'b1)?((FIXED_FRAC_BIT+1+shift_num_r1>=FLOAT_FRAC_BIT)?(carry_after<<(FIXED_FRAC_BIT-FLOAT_FRAC_BIT+shift_num_r1+1)):(carry_after>>(FLOAT_FRAC_BIT-shift_num_r1-1-FIXED_FRAC_BIT))):((FIXED_FRAC_BIT+1>=FLOAT_FRAC_BIT+shift_num_r1)?(carry_after<<(FIXED_FRAC_BIT-FLOAT_FRAC_BIT-shift_num_r1+1)):(carry_after>>(FLOAT_FRAC_BIT+shift_num_r1-1-FIXED_FRAC_BIT)));
    
    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_3_carry_final_r
        if(!i_areset_n)begin
            carry_final_r <= {(FIXED_INT_BIT+FIXED_FRAC_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge)begin
            carry_final_r <= carry_final_w;
        end
        else begin
            carry_final_r <= carry_final_r;
        end
    end

    assign carry_final = carry_final_r;

    //these are special conditions
    assign overflow_judge1 = (shift_num_r1+1==FIXED_INT_BIT)&&(M_r1 != {{1'b1},{(FLOAT_FRAC_BIT-1){1'b0}}});
    assign overflow_judge2 = (carry_after[FLOAT_FRAC_BIT]==1'b1)&&(FIXED_INT_BIT == shift_num_r1+2);
    assign overflow_judge3 = (carry_after[FLOAT_FRAC_BIT]==1'b1)&&(FIXED_INT_BIT == 1);
    assign underflow_judge1 = ((shift_num_r1-FIXED_FRAC_BIT==1)&&(carry_after[FLOAT_FRAC_BIT]==1'b0));
    assign minus_max_judge1 = ((shift_num_r1+1==FIXED_INT_BIT)&&(M_r1 == {{1'b1},{(FLOAT_FRAC_BIT-1){1'b0}}}))||((shift_num_r1+1==FIXED_INT_BIT-1)&&(carry_after[FLOAT_FRAC_BIT]==1'b1));
    assign minus_max_judge2 = (carry_after[FLOAT_FRAC_BIT]==1'b1)&&(FIXED_INT_BIT == 1);

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_3_overflow_judge1_r
        if(!i_areset_n)begin
            overflow_judge1_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            overflow_judge1_r <= overflow_judge1;
        end
        else begin
            overflow_judge1_r <= overflow_judge1_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_3_overflow_judge2_r
        if(!i_areset_n)begin
            overflow_judge2_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            overflow_judge2_r <= overflow_judge2;
        end
        else begin
            overflow_judge2_r <= overflow_judge2_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_3_overflow_judge3_r
        if(!i_areset_n)begin
            overflow_judge3_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            overflow_judge3_r <= overflow_judge3;
        end
        else begin
            overflow_judge3_r <= overflow_judge3_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_3_underflow_judge1_r
        if(!i_areset_n)begin
            underflow_judge1_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            underflow_judge1_r <= underflow_judge1;
        end
        else begin
            underflow_judge1_r <= underflow_judge1_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_3_minus_max_judge1_r
        if(!i_areset_n)begin
            minus_max_judge1_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            minus_max_judge1_r <= minus_max_judge1;
        end
        else begin
            minus_max_judge1_r <= minus_max_judge1_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_3_minus_max_judge2_r
        if(!i_areset_n)begin
            minus_max_judge2_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            minus_max_judge2_r <= minus_max_judge2;
        end
        else begin
            minus_max_judge2_r <= minus_max_judge2_r;
        end
    end

    always@(*)begin:genblk_latency_config_3_overflow_r
        if(float_sign == 1'b1)begin
            if(shift_direct==1'b1)begin
                if(shift_num+1>FIXED_INT_BIT)begin
                    overflow_r = 1'b1;
                end
                else begin//shift_num+1<=FIXED_INT_BIT
                    overflow_r = overflow_judge1_r;
                end
            end
            else begin//shift_direct==1'b0
                overflow_r = 1'b0;
            end
        end
        else begin//float_sign == 1'b0
            if(shift_direct==1'b1)begin
                if(shift_num+2>FIXED_INT_BIT)begin
                    overflow_r = 1'b1;
                end
                else begin//shift_num+1<=FIXED_INT_BIT-1
                    overflow_r = overflow_judge2_r;
                end
            end
            else begin//shift_direct==1'b0
                overflow_r = overflow_judge3_r;
            end
        end
    end

    always@(*)begin:genblk_latency_config_3_underflow_r
        if(shift_direct==1'b1)begin
            underflow_r = 1'b0;
        end
        else begin//shift_direct==1'b0
            if(zero_sig==1'b0)begin
                if(shift_num>1+FIXED_FRAC_BIT)begin
                    underflow_r = 1'b1;
                end
                else begin//shift_num-FIXED_FRAC_BIT<=1
                    underflow_r = underflow_judge1_r;
                end
            end
            else begin//zero_sig==1'b1
                underflow_r = 1'b0;
            end
        end
    end

    always@(*)begin:genblk_latency_config_3_minus_max_r
        if(float_sign==1'b1)begin
            if(shift_direct==1'b1)begin
                minus_max_r = minus_max_judge1_r;
            end
            else begin
                minus_max_r = minus_max_judge2_r;
            end
        end
        else begin//float_sign==1'b1
            minus_max_r = 1'b0;
        end
    end

end
else if (LATENCY_CONFIG == 4) begin: genblk_vital_value_latency_config_4
reg [FLOAT_FRAC_BIT-1:0] pre_add_r;
reg overflow_judge1_r;
reg overflow_judge2_r;
reg overflow_judge3_r;
reg underflow_judge1_r;
reg minus_max_judge1_r;
reg minus_max_judge2_r;
wire [FIXED_INT_BIT+FIXED_FRAC_BIT-1:0] carry_final_w;
reg [FIXED_INT_BIT+FIXED_FRAC_BIT-1:0] carry_final_r;
reg shift_direct_r1;
reg [FLOAT_EXP_BIT-2:0]shift_num_r1;
reg [FLOAT_FRAC_BIT-1:0]M_r1;
reg shift_direct_r2;
reg [FLOAT_EXP_BIT-2:0]shift_num_r2;
reg [FLOAT_FRAC_BIT-1:0]M_r2;

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_shift_constant_r2_latency_config_4
        if(!i_areset_n) begin
            shift_direct_r2 <= 1'b0;
            shift_num_r2 <= {(FLOAT_EXP_BIT-1){1'b0}};
            M_r2 <= {(FLOAT_EXP_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge) begin
            shift_direct_r2 <= shift_direct_w;
            shift_num_r2 <= shift_final;
            M_r2 <= M_final;
        end
        else begin
            shift_direct_r2 <= shift_direct_r2;
            shift_num_r2 <= shift_num_r2;
            M_r2 <= M_r2;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_shift_constant_r1_latency_config_4
        if(!i_areset_n) begin
            shift_direct_r1 <= 1'b0;
            shift_num_r1 <= {(FLOAT_EXP_BIT-1){1'b0}};
            M_r1 <= {(FLOAT_EXP_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge) begin
            shift_direct_r1 <= shift_direct_r2;
            shift_num_r1 <= shift_num_r2;
            M_r1 <= M_r2;
        end
        else begin
            shift_direct_r1 <= shift_direct_r1;
            shift_num_r1 <= shift_num_r1;
            M_r1 <= M_r1;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_shift_constant_latency_config_4
        if(!i_areset_n) begin
            shift_direct <= 1'b0;
            shift_num <= {(FLOAT_EXP_BIT-1){1'b0}};
            M <= {(FLOAT_EXP_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge) begin
            shift_direct <= shift_direct_r1;
            shift_num <= shift_num_r1;
            M <= M_r1;
        end
        else begin
            shift_direct <= shift_direct;
            shift_num <= shift_num;
            M <= M;
        end
    end

    //these are for round to even
    assign common_use_judge1 = FIXED_FRAC_BIT+1>=FLOAT_FRAC_BIT+shift_num_r2;//represents no carrying when shift_direct is 0 (right)
    assign common_use_judge2 = FIXED_FRAC_BIT+1+shift_num_r2>=FLOAT_FRAC_BIT;//represents no carrying when shift_direct is 1 (left)
    assign common_use_judge3 = shift_direct_r2==1'b1; //left

    assign M_right_final = (common_use_judge1)?({(FLOAT_FRAC_BIT){1'b0}}):(M_r2 >> (FLOAT_FRAC_BIT+shift_num_r2-1-FIXED_FRAC_BIT));
    assign M_left_final = (common_use_judge2)?({(FLOAT_FRAC_BIT){1'b0}}):(M_r2 >> (FLOAT_FRAC_BIT-shift_num_r2-1-FIXED_FRAC_BIT));
    
    assign pre_add_constant1 = {{1'b1},{(FLOAT_FRAC_BIT-1){1'b0}}};
    assign pre_add_constant2 = pre_add_constant1>>>(FIXED_FRAC_BIT+1-shift_num_r2);
    assign pre_add_constant3 = pre_add_constant1>>>(FIXED_FRAC_BIT+1+shift_num_r2);
    assign pre_add = (shift_direct_r2==1'b1)?((FIXED_FRAC_BIT+1+shift_num_r2>=FLOAT_FRAC_BIT)?({(FLOAT_FRAC_BIT){1'b0}}):((M_left_final[0])?({{(FLOAT_FRAC_BIT-1){1'b0}},{1'b1}}<<(FLOAT_FRAC_BIT-shift_num_r2-2-FIXED_FRAC_BIT)):(~pre_add_constant3))):((FIXED_FRAC_BIT+1>=FLOAT_FRAC_BIT+shift_num_r2)?({(FLOAT_FRAC_BIT){1'b0}}):((M_right_final[0]==1'b0)?(~pre_add_constant2):({{(FLOAT_FRAC_BIT-1){1'b0}},{1'b1}}<<(FLOAT_FRAC_BIT+shift_num_r2-2-FIXED_FRAC_BIT))));

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_4_pre_add_r
        if(!i_areset_n)begin
            pre_add_r <= {(FLOAT_FRAC_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge)begin
            pre_add_r <= pre_add;
        end
        else begin
            pre_add_r <= pre_add_r;
        end
    end

    assign carry_after = pre_add_r + M_r1;

    assign carry_final_w = (shift_direct_r1==1'b1)?((FIXED_FRAC_BIT+1+shift_num_r1>=FLOAT_FRAC_BIT)?(carry_after<<(FIXED_FRAC_BIT-FLOAT_FRAC_BIT+shift_num_r1+1)):(carry_after>>(FLOAT_FRAC_BIT-shift_num_r1-1-FIXED_FRAC_BIT))):((FIXED_FRAC_BIT+1>=FLOAT_FRAC_BIT+shift_num_r1)?(carry_after<<(FIXED_FRAC_BIT-FLOAT_FRAC_BIT-shift_num_r1+1)):(carry_after>>(FLOAT_FRAC_BIT+shift_num_r1-1-FIXED_FRAC_BIT)));
    
    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_4_carry_final_r
        if(!i_areset_n)begin
            carry_final_r <= {(FIXED_INT_BIT+FIXED_FRAC_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge)begin
            carry_final_r <= carry_final_w;
        end
        else begin
            carry_final_r <= carry_final_r;
        end
    end

    assign carry_final = carry_final_r;
    //these are special conditions
    assign overflow_judge1 = (shift_num_r1+1==FIXED_INT_BIT)&&(M_r1 != {{1'b1},{(FLOAT_FRAC_BIT-1){1'b0}}});
    assign overflow_judge2 = (carry_after[FLOAT_FRAC_BIT]==1'b1)&&(FIXED_INT_BIT == shift_num_r1+2);
    assign overflow_judge3 = (carry_after[FLOAT_FRAC_BIT]==1'b1)&&(FIXED_INT_BIT == 1);
    assign underflow_judge1 = ((shift_num_r1-FIXED_FRAC_BIT==1)&&(carry_after[FLOAT_FRAC_BIT]==1'b0));
    assign minus_max_judge1 = ((shift_num_r1+1==FIXED_INT_BIT)&&(M_r1 == {{1'b1},{(FLOAT_FRAC_BIT-1){1'b0}}}))||((shift_num_r1+1==FIXED_INT_BIT-1)&&(carry_after[FLOAT_FRAC_BIT]==1'b1));
    assign minus_max_judge2 = (carry_after[FLOAT_FRAC_BIT]==1'b1)&&(FIXED_INT_BIT == 1);

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_4_overflow_judge1_r
        if(!i_areset_n)begin
            overflow_judge1_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            overflow_judge1_r <= overflow_judge1;
        end
        else begin
            overflow_judge1_r <= overflow_judge1_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_4_overflow_judge2_r
        if(!i_areset_n)begin
            overflow_judge2_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            overflow_judge2_r <= overflow_judge2;
        end
        else begin
            overflow_judge2_r <= overflow_judge2_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_4_overflow_judge3_r
        if(!i_areset_n)begin
            overflow_judge3_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            overflow_judge3_r <= overflow_judge3;
        end
        else begin
            overflow_judge3_r <= overflow_judge3_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_4_underflow_judge1_r
        if(!i_areset_n)begin
            underflow_judge1_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            underflow_judge1_r <= underflow_judge1;
        end
        else begin
            underflow_judge1_r <= underflow_judge1_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_4_minus_max_judge1_r
        if(!i_areset_n)begin
            minus_max_judge1_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            minus_max_judge1_r <= minus_max_judge1;
        end
        else begin
            minus_max_judge1_r <= minus_max_judge1_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_4_minus_max_judge2_r
        if(!i_areset_n)begin
            minus_max_judge2_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            minus_max_judge2_r <= minus_max_judge2;
        end
        else begin
            minus_max_judge2_r <= minus_max_judge2_r;
        end
    end

    always@(*)begin:genblk_latency_config_4_overflow_r
        if(float_sign == 1'b1)begin
            if(shift_direct==1'b1)begin
                if(shift_num+1>FIXED_INT_BIT)begin
                    overflow_r = 1'b1;
                end
                else begin//shift_num+1<=FIXED_INT_BIT
                    overflow_r = overflow_judge1_r;
                end
            end
            else begin//shift_direct==1'b0
                overflow_r = 1'b0;
            end
        end
        else begin//float_sign == 1'b0
            if(shift_direct==1'b1)begin
                if(shift_num+2>FIXED_INT_BIT)begin
                    overflow_r = 1'b1;
                end
                else begin//shift_num+1<=FIXED_INT_BIT-1
                    overflow_r = overflow_judge2_r;
                end
            end
            else begin//shift_direct==1'b0
                overflow_r = overflow_judge3_r;
            end
        end
    end

    always@(*)begin:genblk_latency_config_4_underflow_r
        if(shift_direct==1'b1)begin
            underflow_r = 1'b0;
        end
        else begin//shift_direct==1'b0
            if(zero_sig==1'b0)begin
                if(shift_num>1+FIXED_FRAC_BIT)begin
                    underflow_r = 1'b1;
                end
                else begin//shift_num-FIXED_FRAC_BIT<=1
                    underflow_r = underflow_judge1_r;
                end
            end
            else begin//zero_sig==1'b1
                underflow_r = 1'b0;
            end
        end
    end

    always@(*)begin:genblk_latency_config_4_minus_max_r
        if(float_sign==1'b1)begin
            if(shift_direct==1'b1)begin
                minus_max_r = minus_max_judge1_r;
            end
            else begin
                minus_max_r = minus_max_judge2_r;
            end
        end
        else begin//float_sign==1'b1
            minus_max_r = 1'b0;
        end
    end
end
else if (LATENCY_CONFIG == 5) begin: genblk_vital_value_latency_config_5
reg [FLOAT_FRAC_BIT-1:0] pre_add_r;
reg [FLOAT_FRAC_BIT-1:0] pre_add_constant2_r;
reg [FLOAT_FRAC_BIT-1:0] pre_add_constant3_r;
reg [FLOAT_FRAC_BIT-1:0] M_right_final_r;
reg [FLOAT_FRAC_BIT-1:0] M_left_final_r;
reg overflow_judge1_r;
reg overflow_judge2_r;
reg overflow_judge3_r;
reg underflow_judge1_r;
reg minus_max_judge1_r;
reg minus_max_judge2_r;
wire [FIXED_INT_BIT+FIXED_FRAC_BIT-1:0] carry_final_w;
reg [FIXED_INT_BIT+FIXED_FRAC_BIT-1:0] carry_final_r;
reg shift_direct_r1;
reg [FLOAT_EXP_BIT-2:0]shift_num_r1;
reg [FLOAT_FRAC_BIT-1:0]M_r1;
reg shift_direct_r2;
reg [FLOAT_EXP_BIT-2:0]shift_num_r2;
reg [FLOAT_FRAC_BIT-1:0]M_r2;
reg shift_direct_r3;
reg [FLOAT_EXP_BIT-2:0]shift_num_r3;
reg [FLOAT_FRAC_BIT-1:0]M_r3;

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_shift_constant_r3_latency_config_5
        if(!i_areset_n) begin
            shift_direct_r3 <= 1'b0;
            shift_num_r3 <= {(FLOAT_EXP_BIT-1){1'b0}};
            M_r3 <= {(FLOAT_EXP_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge) begin
            shift_direct_r3 <= shift_direct_w;
            shift_num_r3 <= shift_final;
            M_r3 <= M_final;
        end
        else begin
            shift_direct_r3 <= shift_direct_r3;
            shift_num_r3 <= shift_num_r3;
            M_r3 <= M_r3;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_shift_constant_r2_latency_config_5
        if(!i_areset_n) begin
            shift_direct_r2 <= 1'b0;
            shift_num_r2 <= {(FLOAT_EXP_BIT-1){1'b0}};
            M_r2 <= {(FLOAT_EXP_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge) begin
            shift_direct_r2 <= shift_direct_r3;
            shift_num_r2 <= shift_num_r3;
            M_r2 <= M_r3;
        end
        else begin
            shift_direct_r2 <= shift_direct_r2;
            shift_num_r2 <= shift_num_r2;
            M_r2 <= M_r2;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_shift_constant_r1_latency_config_5
        if(!i_areset_n) begin
            shift_direct_r1 <= 1'b0;
            shift_num_r1 <= {(FLOAT_EXP_BIT-1){1'b0}};
            M_r1 <= {(FLOAT_EXP_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge) begin
            shift_direct_r1 <= shift_direct_r2;
            shift_num_r1 <= shift_num_r2;
            M_r1 <= M_r2;
        end
        else begin
            shift_direct_r1 <= shift_direct_r1;
            shift_num_r1 <= shift_num_r1;
            M_r1 <= M_r1;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_shift_constant_latency_config_5
        if(!i_areset_n) begin
            shift_direct <= 1'b0;
            shift_num <= {(FLOAT_EXP_BIT-1){1'b0}};
            M <= {(FLOAT_EXP_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge) begin
            shift_direct <= shift_direct_r1;
            shift_num <= shift_num_r1;
            M <= M_r1;
        end
        else begin
            shift_direct <= shift_direct;
            shift_num <= shift_num;
            M <= M;
        end
    end

    //these are for round to even
    assign common_use_judge1 = FIXED_FRAC_BIT+1>=FLOAT_FRAC_BIT+shift_num_r3;//represents no carrying when shift_direct is 0 (right)
    assign common_use_judge2 = FIXED_FRAC_BIT+1+shift_num_r3>=FLOAT_FRAC_BIT;//represents no carrying when shift_direct is 1 (left)
    assign common_use_judge3 = shift_direct_r3==1'b1; //left

    assign M_right_final = (common_use_judge1)?({(FLOAT_FRAC_BIT){1'b0}}):(M_r3 >> (FLOAT_FRAC_BIT+shift_num_r3-1-FIXED_FRAC_BIT));
    assign M_left_final = (common_use_judge2)?({(FLOAT_FRAC_BIT){1'b0}}):(M_r3 >> (FLOAT_FRAC_BIT-shift_num_r3-1-FIXED_FRAC_BIT));

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_5_M_right_final_r
        if(!i_areset_n)begin
            M_right_final_r <= {(FLOAT_FRAC_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge)begin
            M_right_final_r <= M_right_final;
        end
        else begin
            M_right_final_r <= M_right_final_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_5_M_left_final_r
        if(!i_areset_n)begin
            M_left_final_r <= {(FLOAT_FRAC_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge)begin
            M_left_final_r <= M_left_final;
        end
        else begin
            M_left_final_r <= M_left_final_r;
        end
    end
    
    assign pre_add_constant1 = {{1'b1},{(FLOAT_FRAC_BIT-1){1'b0}}};
    assign pre_add_constant2 = pre_add_constant1>>>(FIXED_FRAC_BIT+1-shift_num_r3);
    assign pre_add_constant3 = pre_add_constant1>>>(FIXED_FRAC_BIT+1+shift_num_r3);

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_5_pre_add_constant2_r
        if(!i_areset_n)begin
            pre_add_constant2_r <= {(FLOAT_FRAC_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge)begin
            pre_add_constant2_r <= pre_add_constant2;
        end
        else begin
            pre_add_constant2_r <= pre_add_constant2_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_5_pre_add_constant3_r
        if(!i_areset_n)begin
            pre_add_constant3_r <= {(FLOAT_FRAC_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge)begin
            pre_add_constant3_r <= pre_add_constant3;
        end
        else begin
            pre_add_constant3_r <= pre_add_constant3_r;
        end
    end

    assign pre_add = (shift_direct_r2==1'b1)?((FIXED_FRAC_BIT+1+shift_num_r2>=FLOAT_FRAC_BIT)?({(FLOAT_FRAC_BIT){1'b0}}):((M_left_final_r[0])?({{(FLOAT_FRAC_BIT-1){1'b0}},{1'b1}}<<(FLOAT_FRAC_BIT-shift_num_r2-2-FIXED_FRAC_BIT)):(~pre_add_constant3_r))):((FIXED_FRAC_BIT+1>=FLOAT_FRAC_BIT+shift_num_r2)?({(FLOAT_FRAC_BIT){1'b0}}):((M_right_final_r[0]==1'b0)?(~pre_add_constant2_r):({{(FLOAT_FRAC_BIT-1){1'b0}},{1'b1}}<<(FLOAT_FRAC_BIT+shift_num_r2-2-FIXED_FRAC_BIT))));

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_5_pre_add_r
        if(!i_areset_n)begin
            pre_add_r <= {(FLOAT_FRAC_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge)begin
            pre_add_r <= pre_add;
        end
        else begin
            pre_add_r <= pre_add_r;
        end
    end

    assign carry_after = pre_add_r + M_r1;

    assign carry_final_w = (shift_direct_r1==1'b1)?((FIXED_FRAC_BIT+1+shift_num_r1>=FLOAT_FRAC_BIT)?(carry_after<<(FIXED_FRAC_BIT-FLOAT_FRAC_BIT+shift_num_r1+1)):(carry_after>>(FLOAT_FRAC_BIT-shift_num_r1-1-FIXED_FRAC_BIT))):((FIXED_FRAC_BIT+1>=FLOAT_FRAC_BIT+shift_num_r1)?(carry_after<<(FIXED_FRAC_BIT-FLOAT_FRAC_BIT-shift_num_r1+1)):(carry_after>>(FLOAT_FRAC_BIT+shift_num_r1-1-FIXED_FRAC_BIT)));
    
    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_5_carry_final_r
        if(!i_areset_n)begin
            carry_final_r <= {(FIXED_INT_BIT+FIXED_FRAC_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge)begin
            carry_final_r <= carry_final_w;
        end
        else begin
            carry_final_r <= carry_final_r;
        end
    end

    assign carry_final = carry_final_r;

    //these are special conditions
    assign overflow_judge1 = (shift_num_r1+1==FIXED_INT_BIT)&&(M_r1 != {{1'b1},{(FLOAT_FRAC_BIT-1){1'b0}}});
    assign overflow_judge2 = (carry_after[FLOAT_FRAC_BIT]==1'b1)&&(FIXED_INT_BIT == shift_num_r1+2);
    assign overflow_judge3 = (carry_after[FLOAT_FRAC_BIT]==1'b1)&&(FIXED_INT_BIT == 1);
    assign underflow_judge1 = ((shift_num_r1-FIXED_FRAC_BIT==1)&&(carry_after[FLOAT_FRAC_BIT]==1'b0));
    assign minus_max_judge1 = ((shift_num_r1+1==FIXED_INT_BIT)&&(M_r1 == {{1'b1},{(FLOAT_FRAC_BIT-1){1'b0}}}))||((shift_num_r1+1==FIXED_INT_BIT-1)&&(carry_after[FLOAT_FRAC_BIT]==1'b1));
    assign minus_max_judge2 = (carry_after[FLOAT_FRAC_BIT]==1'b1)&&(FIXED_INT_BIT == 1);

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_5_overflow_judge1_r
        if(!i_areset_n)begin
            overflow_judge1_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            overflow_judge1_r <= overflow_judge1;
        end
        else begin
            overflow_judge1_r <= overflow_judge1_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_5_overflow_judge2_r
        if(!i_areset_n)begin
            overflow_judge2_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            overflow_judge2_r <= overflow_judge2;
        end
        else begin
            overflow_judge2_r <= overflow_judge2_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_5_overflow_judge3_r
        if(!i_areset_n)begin
            overflow_judge3_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            overflow_judge3_r <= overflow_judge3;
        end
        else begin
            overflow_judge3_r <= overflow_judge3_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_5_underflow_judge1_r
        if(!i_areset_n)begin
            underflow_judge1_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            underflow_judge1_r <= underflow_judge1;
        end
        else begin
            underflow_judge1_r <= underflow_judge1_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_5_minus_max_judge1_r
        if(!i_areset_n)begin
            minus_max_judge1_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            minus_max_judge1_r <= minus_max_judge1;
        end
        else begin
            minus_max_judge1_r <= minus_max_judge1_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_5_minus_max_judge2_r
        if(!i_areset_n)begin
            minus_max_judge2_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            minus_max_judge2_r <= minus_max_judge2;
        end
        else begin
            minus_max_judge2_r <= minus_max_judge2_r;
        end
    end

    always@(*)begin:genblk_latency_config_5_overflow_r
        if(float_sign == 1'b1)begin
            if(shift_direct==1'b1)begin
                if(shift_num+1>FIXED_INT_BIT)begin
                    overflow_r = 1'b1;
                end
                else begin//shift_num+1<=FIXED_INT_BIT
                    overflow_r = overflow_judge1_r;
                end
            end
            else begin//shift_direct==1'b0
                overflow_r = 1'b0;
            end
        end
        else begin//float_sign == 1'b0
            if(shift_direct==1'b1)begin
                if(shift_num+2>FIXED_INT_BIT)begin
                    overflow_r = 1'b1;
                end
                else begin//shift_num+1<=FIXED_INT_BIT-1
                    overflow_r = overflow_judge2_r;
                end
            end
            else begin//shift_direct==1'b0
                overflow_r = overflow_judge3_r;
            end
        end
    end

    always@(*)begin:genblk_latency_config_5_underflow_r
        if(shift_direct==1'b1)begin
            underflow_r = 1'b0;
        end
        else begin//shift_direct==1'b0
            if(zero_sig==1'b0)begin
                if(shift_num>1+FIXED_FRAC_BIT)begin
                    underflow_r = 1'b1;
                end
                else begin//shift_num-FIXED_FRAC_BIT<=1
                    underflow_r = underflow_judge1_r;
                end
            end
            else begin//zero_sig==1'b1
                underflow_r = 1'b0;
            end
        end
    end

    always@(*)begin:genblk_latency_config_5_minus_max_r
        if(float_sign==1'b1)begin
            if(shift_direct==1'b1)begin
                minus_max_r = minus_max_judge1_r;
            end
            else begin
                minus_max_r = minus_max_judge2_r;
            end
        end
        else begin//float_sign==1'b1
            minus_max_r = 1'b0;
        end
    end
end
else begin: genblk_vital_value_latency_config_6
reg [FLOAT_FRAC_BIT-1:0] pre_add_r;
reg [FLOAT_FRAC_BIT-1:0] pre_add_constant2_r;
reg [FLOAT_FRAC_BIT-1:0] pre_add_constant3_r;
reg [FLOAT_FRAC_BIT:0] carry_after_r;
reg [FLOAT_FRAC_BIT-1:0] M_right_final_r;
reg [FLOAT_FRAC_BIT-1:0] M_left_final_r;
reg overflow_judge1_r;
reg overflow_judge2_r;
reg overflow_judge3_r;
reg underflow_judge1_r;
reg minus_max_judge1_r;
reg minus_max_judge2_r;
wire [FIXED_INT_BIT+FIXED_FRAC_BIT-1:0] carry_final_w;
reg [FIXED_INT_BIT+FIXED_FRAC_BIT-1:0] carry_final_r;
reg shift_direct_r1;
reg [FLOAT_EXP_BIT-2:0]shift_num_r1;
reg [FLOAT_FRAC_BIT-1:0]M_r1;
reg shift_direct_r2;
reg [FLOAT_EXP_BIT-2:0]shift_num_r2;
reg [FLOAT_FRAC_BIT-1:0]M_r2;
reg shift_direct_r3;
reg [FLOAT_EXP_BIT-2:0]shift_num_r3;
reg [FLOAT_FRAC_BIT-1:0]M_r3;
reg shift_direct_r4;
reg [FLOAT_EXP_BIT-2:0]shift_num_r4;
reg [FLOAT_FRAC_BIT-1:0]M_r4;

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_shift_constant_r4_latency_config_6
        if(!i_areset_n) begin
            shift_direct_r4 <= 1'b0;
            shift_num_r4 <= {(FLOAT_EXP_BIT-1){1'b0}};
            M_r4 <= {(FLOAT_EXP_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge) begin
            shift_direct_r4 <= shift_direct_w;
            shift_num_r4 <= shift_final;
            M_r4 <= M_final;
        end
        else begin
            shift_direct_r4 <= shift_direct_r4;
            shift_num_r4 <= shift_num_r4;
            M_r4 <= M_r4;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_shift_constant_r3_latency_config_6
        if(!i_areset_n) begin
            shift_direct_r3 <= 1'b0;
            shift_num_r3 <= {(FLOAT_EXP_BIT-1){1'b0}};
            M_r3 <= {(FLOAT_EXP_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge) begin
            shift_direct_r3 <= shift_direct_r4;
            shift_num_r3 <= shift_num_r4;
            M_r3 <= M_r4;
        end
        else begin
            shift_direct_r3 <= shift_direct_r3;
            shift_num_r3 <= shift_num_r3;
            M_r3 <= M_r3;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_shift_constant_r2_latency_config_6
        if(!i_areset_n) begin
            shift_direct_r2 <= 1'b0;
            shift_num_r2 <= {(FLOAT_EXP_BIT-1){1'b0}};
            M_r2 <= {(FLOAT_EXP_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge) begin
            shift_direct_r2 <= shift_direct_r3;
            shift_num_r2 <= shift_num_r3;
            M_r2 <= M_r3;
        end
        else begin
            shift_direct_r2 <= shift_direct_r2;
            shift_num_r2 <= shift_num_r2;
            M_r2 <= M_r2;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_shift_constant_r1_latency_config_6
        if(!i_areset_n) begin
            shift_direct_r1 <= 1'b0;
            shift_num_r1 <= {(FLOAT_EXP_BIT-1){1'b0}};
            M_r1 <= {(FLOAT_EXP_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge) begin
            shift_direct_r1 <= shift_direct_r2;
            shift_num_r1 <= shift_num_r2;
            M_r1 <= M_r2;
        end
        else begin
            shift_direct_r1 <= shift_direct_r1;
            shift_num_r1 <= shift_num_r1;
            M_r1 <= M_r1;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n) begin:genblk_shift_constant_latency_config_6
        if(!i_areset_n) begin
            shift_direct <= 1'b0;
            shift_num <= {(FLOAT_EXP_BIT-1){1'b0}};
            M <= {(FLOAT_EXP_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge) begin
            shift_direct <= shift_direct_r1;
            shift_num <= shift_num_r1;
            M <= M_r1;
        end
        else begin
            shift_direct <= shift_direct;
            shift_num <= shift_num;
            M <= M;
        end
    end

    //these are for round to even
    assign common_use_judge1 = FIXED_FRAC_BIT+1>=FLOAT_FRAC_BIT+shift_num_r4;//represents no carrying when shift_direct is 0 (right)
    assign common_use_judge2 = FIXED_FRAC_BIT+1+shift_num_r4>=FLOAT_FRAC_BIT;//represents no carrying when shift_direct is 1 (left)
    assign common_use_judge3 = shift_direct_r4==1'b1; //left

    assign M_right_final = (common_use_judge1)?({(FLOAT_FRAC_BIT){1'b0}}):(M_r4 >> (FLOAT_FRAC_BIT+shift_num_r4-1-FIXED_FRAC_BIT));
    assign M_left_final = (common_use_judge2)?({(FLOAT_FRAC_BIT){1'b0}}):(M_r4 >> (FLOAT_FRAC_BIT-shift_num_r4-1-FIXED_FRAC_BIT));

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_6_M_right_final_r
        if(!i_areset_n)begin
            M_right_final_r <= {(FLOAT_FRAC_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge)begin
            M_right_final_r <= M_right_final;
        end
        else begin
            M_right_final_r <= M_right_final_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_6_M_left_final_r
        if(!i_areset_n)begin
            M_left_final_r <= {(FLOAT_FRAC_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge)begin
            M_left_final_r <= M_left_final;
        end
        else begin
            M_left_final_r <= M_left_final_r;
        end
    end
    
    assign pre_add_constant1 = {{1'b1},{(FLOAT_FRAC_BIT-1){1'b0}}};
    assign pre_add_constant2 = pre_add_constant1>>>(FIXED_FRAC_BIT+1-shift_num_r4);
    assign pre_add_constant3 = pre_add_constant1>>>(FIXED_FRAC_BIT+1+shift_num_r4);

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_6_pre_add_constant2_r
        if(!i_areset_n)begin
            pre_add_constant2_r <= {(FLOAT_FRAC_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge)begin
            pre_add_constant2_r <= pre_add_constant2;
        end
        else begin
            pre_add_constant2_r <= pre_add_constant2_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_6_pre_add_constant3_r
        if(!i_areset_n)begin
            pre_add_constant3_r <= {(FLOAT_FRAC_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge)begin
            pre_add_constant3_r <= pre_add_constant3;
        end
        else begin
            pre_add_constant3_r <= pre_add_constant3_r;
        end
    end

    assign pre_add = (shift_direct_r3==1'b1)?((FIXED_FRAC_BIT+1+shift_num_r3>=FLOAT_FRAC_BIT)?({(FLOAT_FRAC_BIT){1'b0}}):((M_left_final_r[0])?({{(FLOAT_FRAC_BIT-1){1'b0}},{1'b1}}<<(FLOAT_FRAC_BIT-shift_num_r3-2-FIXED_FRAC_BIT)):(~pre_add_constant3_r))):((FIXED_FRAC_BIT+1>=FLOAT_FRAC_BIT+shift_num_r3)?({(FLOAT_FRAC_BIT){1'b0}}):((M_right_final_r[0]==1'b0)?(~pre_add_constant2_r):({{(FLOAT_FRAC_BIT-1){1'b0}},{1'b1}}<<(FLOAT_FRAC_BIT+shift_num_r3-2-FIXED_FRAC_BIT))));

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_6_pre_add_r
        if(!i_areset_n)begin
            pre_add_r <= {(FLOAT_FRAC_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge)begin
            pre_add_r <= pre_add;
        end
        else begin
            pre_add_r <= pre_add_r;
        end
    end

    assign carry_after = pre_add_r + M_r2;

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_6_carry_after_r
        if(!i_areset_n)begin
            carry_after_r <= {(FLOAT_FRAC_BIT+1){1'b0}};
        end
        else if (i_aclken)
        if(all_judge)begin
            carry_after_r <= carry_after;
        end
        else begin
            carry_after_r <= carry_after_r;
        end
    end

    assign carry_final_w = (shift_direct_r1)?((FIXED_FRAC_BIT+1+shift_num_r1>=FLOAT_FRAC_BIT)?(carry_after_r<<(FIXED_FRAC_BIT-FLOAT_FRAC_BIT+shift_num_r1+1)):(carry_after_r>>(FLOAT_FRAC_BIT-shift_num_r1-1-FIXED_FRAC_BIT))):((FIXED_FRAC_BIT+1>=FLOAT_FRAC_BIT+shift_num_r1)?(carry_after_r<<(FIXED_FRAC_BIT-FLOAT_FRAC_BIT-shift_num_r1+1)):(carry_after_r>>(FLOAT_FRAC_BIT+shift_num_r1-1-FIXED_FRAC_BIT)));
    
    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_6_carry_final_r
        if(!i_areset_n)begin
            carry_final_r <= {(FIXED_INT_BIT+FIXED_FRAC_BIT){1'b0}};
        end
        else if (i_aclken)
        if(all_judge)begin
            carry_final_r <= carry_final_w;
        end
        else begin
            carry_final_r <= carry_final_r;
        end
    end

    assign carry_final = carry_final_r;

    //these are special conditions
    assign overflow_judge1 = (shift_num_r1+1==FIXED_INT_BIT)&&(M_r1 != {{1'b1},{(FLOAT_FRAC_BIT-1){1'b0}}});
    assign overflow_judge2 = (carry_after_r[FLOAT_FRAC_BIT]==1'b1)&&(FIXED_INT_BIT == shift_num_r1+2);
    assign overflow_judge3 = (carry_after_r[FLOAT_FRAC_BIT]==1'b1)&&(FIXED_INT_BIT == 1);
    assign underflow_judge1 = ((shift_num_r1-FIXED_FRAC_BIT==1)&&(carry_after_r[FLOAT_FRAC_BIT]==1'b0));
    assign minus_max_judge1 = ((shift_num_r1+1==FIXED_INT_BIT)&&(M_r1 == {{1'b1},{(FLOAT_FRAC_BIT-1){1'b0}}}))||((shift_num_r1+1==FIXED_INT_BIT-1)&&(carry_after_r[FLOAT_FRAC_BIT]==1'b1));
    assign minus_max_judge2 = (carry_after_r[FLOAT_FRAC_BIT]==1'b1)&&(FIXED_INT_BIT == 1);

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_6_overflow_judge1_r
        if(!i_areset_n)begin
            overflow_judge1_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            overflow_judge1_r <= overflow_judge1;
        end
        else begin
            overflow_judge1_r <= overflow_judge1_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_6_overflow_judge2_r
        if(!i_areset_n)begin
            overflow_judge2_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            overflow_judge2_r <= overflow_judge2;
        end
        else begin
            overflow_judge2_r <= overflow_judge2_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_6_overflow_judge3_r
        if(!i_areset_n)begin
            overflow_judge3_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            overflow_judge3_r <= overflow_judge3;
        end
        else begin
            overflow_judge3_r <= overflow_judge3_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_6_underflow_judge1_r
        if(!i_areset_n)begin
            underflow_judge1_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            underflow_judge1_r <= underflow_judge1;
        end
        else begin
            underflow_judge1_r <= underflow_judge1_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_6_minus_max_judge1_r
        if(!i_areset_n)begin
            minus_max_judge1_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            minus_max_judge1_r <= minus_max_judge1;
        end
        else begin
            minus_max_judge1_r <= minus_max_judge1_r;
        end
    end

    always@(posedge i_aclk or negedge i_areset_n)begin:genblk_latency_config_6_minus_max_judge2_r
        if(!i_areset_n)begin
            minus_max_judge2_r <= 1'b0;
        end
        else if (i_aclken)
        if(all_judge)begin
            minus_max_judge2_r <= minus_max_judge2;
        end
        else begin
            minus_max_judge2_r <= minus_max_judge2_r;
        end
    end

    always@(*)begin:genblk_latency_config_6_overflow_r
        if(float_sign == 1'b1)begin
            if(shift_direct==1'b1)begin
                if(shift_num+1>FIXED_INT_BIT)begin
                    overflow_r = 1'b1;
                end
                else begin//shift_num+1<=FIXED_INT_BIT
                    overflow_r = overflow_judge1_r;
                end
            end
            else begin//shift_direct==1'b0
                overflow_r = 1'b0;
            end
        end
        else begin//float_sign == 1'b0
            if(shift_direct==1'b1)begin
                if(shift_num+2>FIXED_INT_BIT)begin
                    overflow_r = 1'b1;
                end
                else begin//shift_num+1<=FIXED_INT_BIT-1
                    overflow_r = overflow_judge2_r;
                end
            end
            else begin//shift_direct==1'b0
                overflow_r = overflow_judge3_r;
            end
        end
    end

    always@(*)begin:genblk_latency_config_6_underflow_r
        if(shift_direct==1'b1)begin
            underflow_r = 1'b0;
        end
        else begin//shift_direct==1'b0
            if(zero_sig==1'b0)begin
                if(shift_num>1+FIXED_FRAC_BIT)begin
                    underflow_r = 1'b1;
                end
                else begin//shift_num-FIXED_FRAC_BIT<=1
                    underflow_r = underflow_judge1_r;
                end
            end
            else begin//zero_sig==1'b1
                underflow_r = 1'b0;
            end
        end
    end

    always@(*)begin:genblk_latency_config_6_minus_max_r
        if(float_sign==1'b1)begin
            if(shift_direct==1'b1)begin
                minus_max_r = minus_max_judge1_r;
            end
            else begin
                minus_max_r = minus_max_judge2_r;
            end
        end
        else begin//float_sign==1'b1
            minus_max_r = 1'b0;
        end
    end
end
endgenerate

always@(posedge i_aclk or negedge i_areset_n)begin:genblk_overflow
    if(!i_areset_n)begin
        overflow <= 1'b0;
    end
    else if (i_aclken)
    if(all_judge)begin
        overflow <= overflow_r;
    end
    else begin
        overflow <= overflow;
    end
end

always@(posedge i_aclk or negedge i_areset_n)begin:genblk_underflow
    if(!i_areset_n)begin
        underflow <= 1'b0;
    end
    else if (i_aclken)
    if(all_judge)begin
        underflow <= underflow_r;
    end
    else begin
        underflow <= underflow;
    end
end

always@(posedge i_aclk or negedge i_areset_n)begin:genblk_minus_max
    if(!i_areset_n)begin
        minus_max <= 1'b0;
    end
    else if (i_aclken)
    if(all_judge)begin
        minus_max <= minus_max_r;
    end
    else begin
        minus_max <= minus_max;
    end
end
//////////////// outcome ///////////////
assign result_judge1 = fixed_int[FIXED_INT_BIT-1]==1'b1;
assign result_judge2 = result_judge1&&(overflow||infinite);
assign result_judge3 = (!result_judge1)&&(overflow||infinite);
assign result_judge4 = nan||result_judge2;

generate
if(FIXED_FRAC_BIT != 0) begin: genblk_o_axi4s_result_tdata_frac
reg [FIXED_FRAC_BIT-1:0] fixed_frac;
always@(posedge i_aclk or negedge i_areset_n)begin:genblk_fixed_int_fixed_frac
    if(!i_areset_n)begin
        fixed_int <= {(FIXED_INT_BIT){1'b0}};
        fixed_frac <= {(FIXED_FRAC_BIT){1'b0}};
    end
    else if (i_aclken)
    if(all_judge)begin
        {fixed_int,fixed_frac} <= {float_sign, carry_final[(FIXED_INT_BIT+FIXED_FRAC_BIT-2):0]};
    end
    else begin
        fixed_int <= fixed_int;
        fixed_frac <= fixed_frac;
    end
end
always@(*)begin:genblk_o_axi4s_result_tdata_with_frac
    if(result_judge4)begin
        o_axi4s_result_tdata = {{1'b1},{(FIXED_INT_BIT+FIXED_FRAC_BIT-1){1'b0}}};
    end
    else if(zero||underflow)begin
        o_axi4s_result_tdata = {(FIXED_INT_BIT+FIXED_FRAC_BIT){1'b0}};
    end
    else if(result_judge3)begin
        o_axi4s_result_tdata = {{1'b0},{(FIXED_INT_BIT+FIXED_FRAC_BIT-1){1'b1}}};
    end
    else if(minus_max == 1'b1)begin
        o_axi4s_result_tdata = {{1'b1},{(FIXED_INT_BIT+FIXED_FRAC_BIT-1){1'b0}}};
    end
    else begin
        if(result_judge1)begin
            if(FIXED_INT_BIT == 1)begin
                o_axi4s_result_tdata = {{1'b1},{(~fixed_frac)+1}};
            end
            else begin
                o_axi4s_result_tdata = {{1'b1},{(~{fixed_int[FIXED_INT_BIT-2:0],fixed_frac})+1}};
            end            
        end
        else begin
            o_axi4s_result_tdata = {fixed_int,fixed_frac};
        end
    end
end
end else begin: genblk_o_axi4s_result_tdata_int
always@(posedge i_aclk or negedge i_areset_n)begin:genblk_fixed_frac
    if(!i_areset_n)begin
        fixed_int <= {(FIXED_INT_BIT){1'b0}};
    end
    else if (i_aclken)
    if(all_judge)begin
        fixed_int <= {float_sign, carry_final[(FIXED_INT_BIT+FIXED_FRAC_BIT-2):0]};
    end
    else begin
        fixed_int <= fixed_int;
    end
end
always@(*)begin:genblk_o_axi4s_result_tdata_without_frac
    if(result_judge4)begin
        o_axi4s_result_tdata = {{1'b1},{(FIXED_INT_BIT+FIXED_FRAC_BIT-1){1'b0}}};
    end
    else if(zero||underflow)begin
        o_axi4s_result_tdata = {(FIXED_INT_BIT+FIXED_FRAC_BIT){1'b0}};
    end
    else if(result_judge3)begin
        o_axi4s_result_tdata = {{1'b0},{(FIXED_INT_BIT+FIXED_FRAC_BIT-1){1'b1}}};
    end
    else if(minus_max == 1'b1)begin
        o_axi4s_result_tdata = {{1'b1},{(FIXED_INT_BIT+FIXED_FRAC_BIT-1){1'b0}}};
    end
    else begin
        if(result_judge1)begin
            o_axi4s_result_tdata = {{1'b1},{(~fixed_int[FIXED_INT_BIT-2:0])+1}};
        end
        else begin
            o_axi4s_result_tdata = fixed_int;
        end
    end
end
end
endgenerate

// tuser
assign tuser_judge1 = nan_sig||infinite_sig;
assign tuser_judge2 = overflow_r||infinite_sig;

assign o_overflow = tuser_judge2_reg;
assign o_invalid_op = tuser_judge1_reg;

always@(posedge i_aclk or negedge i_areset_n)begin:genblk_tuser
    if(!i_areset_n) begin
        tuser_judge1_reg <= 1'b0;
        tuser_judge2_reg <= 1'b0;
    end
    else if (i_aclken) begin
        tuser_judge1_reg <= tuser_judge1;
        tuser_judge2_reg <= tuser_judge2;
    end
end
    
endmodule