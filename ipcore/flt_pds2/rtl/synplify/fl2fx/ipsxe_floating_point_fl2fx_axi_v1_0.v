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
// Filename: fl2fx_axi.v
// Function: this module transfers a floating-point number to the fixed-
//           point number
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_fl2fx_axi_v1_0 #(
    parameter FLOAT_EXP_BIT = 8,
    parameter FLOAT_FRAC_BIT = 24, //include the hidden one
    parameter FIXED_INT_BIT = 32, //include sign bit
    parameter FIXED_FRAC_BIT = 0
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
wire all_judge2;
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

reg i_axi4s_or_abcoperation_tvalid_r;
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

always@(posedge i_aclk or negedge i_areset_n)begin:genblk_i_axi4s_or_abcoperation_tvalid_r
    if(!i_areset_n)
        i_axi4s_or_abcoperation_tvalid_r <= 1'b0;
    else if (i_aclken)
        i_axi4s_or_abcoperation_tvalid_r <= i_axi4s_or_abcoperation_tvalid;
end

assign all_judge2 = i_axi4s_or_abcoperation_tvalid_r;

ipsxe_floating_point_register_v1_0 #(1) u_reg_m_axis_result_tvalid(i_aclk, i_aclken, i_areset_n, i_axi4s_or_abcoperation_tvalid_r, o_axi4s_result_tvalid);

////////////////    sign    ////////////////////
always@(posedge i_aclk or negedge i_areset_n) begin:genblk_float_sign
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

////////////    shift_direct and shift_num and M   ////////////////
assign exp_bias = {{1'b0},{(FLOAT_EXP_BIT-1){1'b1}}};
assign exp_max = {(FLOAT_EXP_BIT){1'b1}};

assign float_without_sign = i_axi4s_a_tdata[FLOAT_EXP_BIT+FLOAT_FRAC_BIT-2:0];
assign {float_exp,float_frac} = float_without_sign;

//to see if is zero, infinite or nan
assign zero_judge = float_exp=={(FLOAT_EXP_BIT){1'b0}};//include denormalized floating numbers and zero
assign infinite_judge = (float_exp==exp_max)&&(float_frac=={(FLOAT_FRAC_BIT-1){1'b0}});
assign nan_judge = (float_exp==exp_max)&&(float_frac!={(FLOAT_FRAC_BIT-1){1'b0}});

always@(posedge i_aclk or negedge i_areset_n) begin:genblk_zero_sig
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

always@(posedge i_aclk or negedge i_areset_n) begin:genblk_infinite_sig
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

always@(posedge i_aclk or negedge i_areset_n) begin:genblk_nan_sig
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
//calculate shift_direct, shift_num and M (float_frac with the hidden 1)
assign shift_final = (float_exp>=exp_bias)?(float_exp - exp_bias):(exp_bias - float_exp);
assign M_final = {1'b1,float_frac};
assign shift_direct_w = (float_exp>=exp_bias);

always@(posedge i_aclk or negedge i_areset_n) begin:genblk_shift_constant
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

////////////////  fixed_num   /////////////////
always@(posedge i_aclk or negedge i_areset_n)begin:genblk_nan_infinite_zero
    if(!i_areset_n) begin
        nan <= 1'b0;
        infinite <= 1'b0;
        zero <= 1'b0;
    end
    else if (i_aclken)
    if(all_judge2)begin
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

always@(*)begin:genblk_overflow_r
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

assign underflow_judge1 = ((shift_num-FIXED_FRAC_BIT==1)&&(carry_after[FLOAT_FRAC_BIT]==1'b0));

always@(*)begin:genblk_underflow_r
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
assign minus_max_judge1 = ((shift_num+1==FIXED_INT_BIT)&&(M == {{1'b1},{(FLOAT_FRAC_BIT-1){1'b0}}}))||((shift_num+1==FIXED_INT_BIT-1)&&(carry_after[FLOAT_FRAC_BIT]==1'b1));
assign minus_max_judge2 = (carry_after[FLOAT_FRAC_BIT]==1'b1)&&(FIXED_INT_BIT == 1);

always@(*)begin:genblk_minus_max_r
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

always@(posedge i_aclk or negedge i_areset_n)begin:genblk_overflow
    if(!i_areset_n)begin
        overflow <= 1'b0;
    end
    else if (i_aclken)
    if(all_judge2)begin
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
    if(all_judge2)begin
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
    if(all_judge2)begin
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
    if(all_judge2)begin
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
    else if(zero)begin
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