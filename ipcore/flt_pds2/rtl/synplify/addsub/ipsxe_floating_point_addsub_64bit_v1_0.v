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
// Filename:ipsxe_floating_point_addsub_v1_0.v
// Function: p=a+/-b
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_addsub_64bit_v1_0 #(parameter E = 8, F = 24, APM_USAGE = 0, RNE = 6, LATENCY_CONFIG = 7)(
    i_aclk,
    i_aclken,
    i_rst_n,
    i_axis_aboperation_tvalid,
    i_axis_operation_tdata,
    i_axis_a_tdata,
    i_axis_b_tdata,

    o_axis_result_tdata,
    o_axis_result_tvalid,
    o_invalid_op,
    o_overflow,
    o_underflow
    );

localparam LENTH = E+F;
localparam PIPELINE_STAGE = (LATENCY_CONFIG==12)?8:4;//show the number of inner MUXes for generate group for latency
localparam INNER_LATENCY = (LATENCY_CONFIG==12)?4:0;

input i_aclk;
input i_aclken;
input i_rst_n;
input i_axis_aboperation_tvalid;
input i_axis_operation_tdata;
input [LENTH-1:0] i_axis_a_tdata;
input [LENTH-1:0] i_axis_b_tdata;

output [LENTH-1:0] o_axis_result_tdata;
output o_overflow;
output o_underflow;
output o_invalid_op;
output o_axis_result_tvalid;

//Mantissa bit for input float a\b
wire [F-2:0] sign_a, sign_b;
wire [F-2:0] sign_out;
//Sign bit for input float a\b and output float o
wire s_a, s_b;
reg s_o;
//Exponent bit for input float a\b
wire [E-1:0] exp_a, exp_b;
reg [E:0]  exp_out;
//To check if the highest bit is 1 (carry in) or 0(no carry) in mantissa
wire guard_bit, round_bit, sticky_bit, carry_compensate;

//Declare some special cases, 0\inf\nan
wire a_or_b_nan;//a or b is NAN
wire a_inf, b_inf;//a is inf, b is inf
wire is_input_a_zero, is_input_b_zero;//a is zero, b is zero

//compare values
wire exp_a_g_exp_b;//exp_a is greater than exp_b
wire exp_a_e_exp_b;//exp_a is equal to exp_b
wire sign_a_g_sign_b;//sign_a is greater than or equal to sign_b
wire a_g_b;//a is greater than b

wire [E-1:0]exp_diff;//shift bits according to the difference
reg [F-2+RNE+1:0] sign_exp_smaller,sign_exp_bigger;//record big value or small value based on exponent
wire [F+RNE-2:0] sign_out_before_rounding;//before round

reg [F+RNE:0] sign_temp;//logic temp for sign_out
wire [E-1:0] exp_temp;//logic temp for exp_out

//find the first 1 in mantissa based on different input lenth
wire [LENTH-1:0] find_one, sign_out_before_rounding_temp;
wire find_one_zero;

//declare for latency configuration(regx: blk_ltcyx, which means stage x)
//the space are used to separate the differnt regx group for each individual blk_ltcyx
//generate the register for latency 1, 2, 3
wire s_a_dly1,s_b_dly1, s_a_dly2,s_b_dly2, s_a_dly3,s_b_dly3;
wire [E-1:0] exp_a_dly1, exp_b_dly1, exp_a_dly2, exp_b_dly2;
wire [F-2:0] sign_a_dly1, sign_b_dly1, sign_a_dly2, sign_b_dly2;
wire i_axis_aboperation_tvalid_dly1, i_axis_operation_tdata_dly1, i_axis_aboperation_tvalid_dly2, i_axis_operation_tdata_dly2, i_axis_aboperation_tvalid_dly3, i_axis_operation_tdata_dly3;

wire a_inf_dly2,b_inf_dly2;
wire a_or_b_nan_dly2;
wire is_input_a_zero_dly2,is_input_b_zero_dly2;
wire exp_a_e_exp_b_dly2,exp_a_g_exp_b_dly2,sign_a_g_sign_b_dly2,a_g_b_dly2;

wire is_input_a_zero_dly3,is_input_b_zero_dly3,a_g_b_dly3,a_or_b_nan_dly3;
wire [F-2+RNE+1:0] sign_exp_smaller_dly3,sign_exp_bigger_dly3;
wire a_inf_dly3,b_inf_dly3;
wire [E-1:0] exp_temp_dly3;

//generate the register for latency 4
wire s_o_dly4,a_or_b_nan_dly4,s_a_dly4,s_b_dly4,a_inf_dly4,b_inf_dly4,i_axis_operation_tdata_dly4,i_axis_aboperation_tvalid_dly4;
wire [E-1:0] exp_temp_dly4;
wire [F+RNE:0] sign_temp_dly4;

//generate the register for latency 5
wire [F+RNE-2:0] sign_out_before_rounding_dly5;
wire guard_bit_dly5,round_bit_dly5,sticky_bit_dly5,i_axis_aboperation_tvalid_dly5,a_or_b_nan_dly5,a_inf_dly5,b_inf_dly5,s_a_dly5,s_b_dly5,i_axis_operation_tdata_dly5,s_o_dly5,find_one_zero_dly5;
wire [E:0] exp_out_dly5;

//generate the register for latency 6
wire s_o_dly6,i_axis_aboperation_tvalid_dly6,a_or_b_nan_dly6,a_inf_dly6,b_inf_dly6,s_a_dly6,s_b_dly6,i_axis_operation_tdata_dly6;
wire [LENTH-1:0] find_one_dly6;
wire [E-1:0] exp_temp_dly6;
wire [F+RNE:0] sign_temp_dly6;

wire [5:0] fst_one_index;//the first 1's index
wire [5:0] lenth_diff;//difference between the settled lenth and the RNEed mantissa bits

//generate the output signal without output latency
reg temp_o_axis_result_tvalid, temp_o_underflow, temp_o_overflow, temp_o_invalid_op;
reg [LENTH-1:0] temp_o_axis_result_tdata;


//sign bits, exp bits and mantissa bits for a respectively
assign s_a = i_axis_a_tdata[LENTH-1];
assign exp_a = i_axis_a_tdata[E+F-2:F-1];
assign sign_a = i_axis_a_tdata[F-2:0];

//sign bits, exp bits and mantissa bits for b respectively
assign s_b = i_axis_b_tdata[LENTH-1];
assign exp_b = i_axis_b_tdata[E+F-2:F-1];
assign sign_b = i_axis_b_tdata[F-2:0];

//give the initial signal for the rest module
assign {s_a_dly1,exp_a_dly1,sign_a_dly1,s_b_dly1,exp_b_dly1,sign_b_dly1,i_axis_aboperation_tvalid_dly1,i_axis_operation_tdata_dly1} = {s_a,exp_a,sign_a,s_b,exp_b,sign_b,i_axis_aboperation_tvalid,i_axis_operation_tdata};

//---------------------nan and inf cases begin---------------------
//nan: exp = all 1 and mantissa != 0
//inf: exp = all 1 and mantissa == 0
assign a_or_b_nan = (((exp_a_dly1=={E{1'b1}})&(|sign_a_dly1)) | ((exp_b_dly1=={E{1'b1}})&(|sign_b_dly1)));
assign a_inf = (exp_a_dly1=={E{1'b1}})&(~(|sign_a_dly1));
assign b_inf = (exp_b_dly1=={E{1'b1}})&(~(|sign_b_dly1));
//---------------------nan and inf cases end---------------------
//check if a and b are zero or not
assign is_input_a_zero = ~(|exp_a_dly1);
assign is_input_b_zero = ~(|exp_b_dly1);

//compare the specific values
assign exp_a_e_exp_b = exp_a_dly1==exp_b_dly1;//a's exponent == b's exponent
assign exp_a_g_exp_b = exp_a_dly1 > exp_b_dly1;//a's exponent > b's exponent
assign sign_a_g_sign_b = sign_a_dly1 > sign_b_dly1;//a's mantissa > b's mantissa
assign a_g_b = (exp_a_g_exp_b|(exp_a_e_exp_b&sign_a_g_sign_b));//a is greater than b

//generate for latency
generate
if (LATENCY_CONFIG>=2)begin
ipsxe_floating_point_register_v1_0#(2*LENTH+1+1+9) blk_ltcy2(
        .i_clk(i_aclk),
        .i_aclken(i_aclken),
        .i_rst_n(i_rst_n),
        .i_d({s_a_dly1,exp_a_dly1,sign_a_dly1,s_b_dly1,exp_b_dly1,sign_b_dly1,i_axis_aboperation_tvalid_dly1,i_axis_operation_tdata_dly1,a_or_b_nan,a_inf,b_inf,is_input_a_zero,is_input_b_zero,exp_a_e_exp_b,exp_a_g_exp_b,sign_a_g_sign_b,a_g_b}),
        .o_q({s_a_dly2,exp_a_dly2,sign_a_dly2,s_b_dly2,exp_b_dly2,sign_b_dly2,i_axis_aboperation_tvalid_dly2,i_axis_operation_tdata_dly2,a_or_b_nan_dly2,a_inf_dly2,b_inf_dly2,is_input_a_zero_dly2,is_input_b_zero_dly2,exp_a_e_exp_b_dly2,exp_a_g_exp_b_dly2,sign_a_g_sign_b_dly2,a_g_b_dly2})
    );
end
else begin
assign {s_a_dly2,exp_a_dly2,sign_a_dly2,s_b_dly2,exp_b_dly2,sign_b_dly2,i_axis_aboperation_tvalid_dly2,i_axis_operation_tdata_dly2,a_or_b_nan_dly2,a_inf_dly2,b_inf_dly2,is_input_a_zero_dly2,is_input_b_zero_dly2,exp_a_e_exp_b_dly2,exp_a_g_exp_b_dly2,sign_a_g_sign_b_dly2,a_g_b_dly2} = {s_a_dly1,exp_a_dly1,sign_a_dly1,s_b_dly1,exp_b_dly1,sign_b_dly1,i_axis_aboperation_tvalid_dly1,i_axis_operation_tdata_dly1,a_or_b_nan,a_inf,b_inf,is_input_a_zero,is_input_b_zero,exp_a_e_exp_b,exp_a_g_exp_b,sign_a_g_sign_b,a_g_b};
end
endgenerate
//principle of the operation
//highest 1 bit is needed to check carry-in  [F-2+RNE+2], 2nd highest bit is needed to represent the decimal
//1.xxxxxxxxxxxxxxxxx * 2^(n)
//+ -
//1.xxxxxxxxxxxxxxxxx * 2^(m)
//the first 1(integer) is also considered as the mantissa for easier calculation

//get the difference between a's exponent and b's
assign exp_diff = exp_a_g_exp_b_dly2?exp_a_dly2-exp_b_dly2:exp_b_dly2-exp_a_dly2;
//The mantissa bits are fixed to a or b whose exponent bits are bigger than the others'
//The other mantissa has to do the shift operation
//RNE is added to ensure the accuracy
always@(*)begin
    if (exp_a_g_exp_b_dly2)begin//a's exp > b's exp
        sign_exp_bigger = {1'b1,sign_a_dly2,{RNE{1'b0}}};
        sign_exp_smaller = {1'b1,sign_b_dly2,{RNE{1'b0}}}>>exp_diff;
    end
    else if (exp_a_e_exp_b_dly2)begin//a's exp == b's exp
        sign_exp_bigger = sign_a_g_sign_b_dly2?{1'b1,sign_a_dly2,{RNE{1'b0}}}:{1'b1,sign_b_dly2,{RNE{1'b0}}};
        sign_exp_smaller = sign_a_g_sign_b_dly2?{1'b1,sign_b_dly2,{RNE{1'b0}}}>>exp_diff:{1'b1,sign_a_dly2,{RNE{1'b0}}}>>exp_diff;
    end
    else begin//a's exp < b's exp
        sign_exp_bigger = {1'b1,sign_b_dly2,{RNE{1'b0}}};
        sign_exp_smaller = {1'b1,sign_a_dly2,{RNE{1'b0}}}>>exp_diff;
    end
end

//deal with the significant bits or the mantissa bits, which means find the bigger one and use it as the temporary fixed exponent bits
assign exp_temp = exp_a_g_exp_b_dly2?exp_a_dly2:exp_b_dly2;
//generate for latency
generate
if (LATENCY_CONFIG>=1)begin
ipsxe_floating_point_register_v1_0#(E+3+1+2*(F+RNE)+2+4) blk_ltcy3(
        .i_clk(i_aclk),
        .i_aclken(i_aclken),
        .i_rst_n(i_rst_n),
        .i_d({exp_temp,a_g_b_dly2,a_inf_dly2,b_inf_dly2,a_or_b_nan_dly2,i_axis_aboperation_tvalid_dly2,i_axis_operation_tdata_dly2,sign_exp_bigger,sign_exp_smaller,s_a_dly2,s_b_dly2,is_input_a_zero_dly2,is_input_b_zero_dly2}),
        .o_q({exp_temp_dly3,a_g_b_dly3,a_inf_dly3,b_inf_dly3,a_or_b_nan_dly3,i_axis_aboperation_tvalid_dly3,i_axis_operation_tdata_dly3,sign_exp_bigger_dly3,sign_exp_smaller_dly3,s_a_dly3,s_b_dly3,is_input_a_zero_dly3,is_input_b_zero_dly3})
    );
end
else begin
assign exp_temp_dly3 = exp_temp;
assign {a_inf_dly3,b_inf_dly3,a_or_b_nan_dly3} = {a_inf_dly2,b_inf_dly2,a_or_b_nan_dly2};//3
assign {i_axis_aboperation_tvalid_dly3,i_axis_operation_tdata_dly3} = {i_axis_aboperation_tvalid_dly2,i_axis_operation_tdata_dly2};//2
assign {sign_exp_bigger_dly3,sign_exp_smaller_dly3} = {sign_exp_bigger,sign_exp_smaller};//2*(F+RNE)
assign {s_a_dly3,s_b_dly3} = {s_a_dly2,s_b_dly2};//2
assign {a_g_b_dly3,is_input_a_zero_dly3,is_input_b_zero_dly3} = {a_g_b_dly2,is_input_a_zero_dly2,is_input_b_zero_dly2};//4
end
endgenerate

//to get the mantissa and sign bits based on the input operator
//--------------------significant bits operation in add:
//a>=0, b>=0  --->sum
//a>=0, b<0  --->sub
//a<=0, b<=0  --->sum
//a<=0, b>0  --->sub 
//--------------------significant bits operation in sub:
//a>=0, b>=0  --->sub
//a>=0, b<0  --->sum
//a<=0, b<=0  --->sub
//a<=0, b>0  --->sum
always@(*)begin
    if (is_input_a_zero_dly3 & is_input_b_zero_dly3)begin//if a and b is zero
    sign_temp = 0;
    s_o = 0;
    end
    else if (is_input_a_zero_dly3)begin//if a is zero
    sign_temp = sign_exp_bigger_dly3;
    s_o = s_b_dly3^i_axis_operation_tdata_dly3;
    end
    else if (is_input_b_zero_dly3)begin//if b is zero
    s_o = s_a_dly3;
    sign_temp = sign_exp_bigger_dly3;
    end
    else begin//null zero
    if (~((s_a_dly3)^(s_b_dly3^i_axis_operation_tdata_dly3)))begin//add 
    s_o = s_a_dly3;
    sign_temp = sign_exp_bigger_dly3+sign_exp_smaller_dly3;
    end
    else begin//sub
    s_o = a_g_b_dly3?s_a_dly3:s_b_dly3^i_axis_operation_tdata_dly3;
    sign_temp = sign_exp_bigger_dly3-sign_exp_smaller_dly3;
    end
    end
end

//generate for latency
generate
if (LATENCY_CONFIG>=3)begin
ipsxe_floating_point_register_v1_0#((F+RNE+1)+1+E+6+1) blk_ltcy4(
        .i_clk(i_aclk),
        .i_aclken(i_aclken),
        .i_rst_n(i_rst_n),
        .i_d({sign_temp,s_o,exp_temp_dly3,a_or_b_nan_dly3,s_a_dly3,s_b_dly3,a_inf_dly3,b_inf_dly3,i_axis_operation_tdata_dly3,i_axis_aboperation_tvalid_dly3}),
        .o_q({sign_temp_dly4,s_o_dly4,exp_temp_dly4,a_or_b_nan_dly4,s_a_dly4,s_b_dly4,a_inf_dly4,b_inf_dly4,i_axis_operation_tdata_dly4,i_axis_aboperation_tvalid_dly4})
);
end
else begin
assign {sign_temp_dly4,s_o_dly4,exp_temp_dly4,a_or_b_nan_dly4,s_a_dly4,s_b_dly4,a_inf_dly4,b_inf_dly4,i_axis_operation_tdata_dly4,i_axis_aboperation_tvalid_dly4} = {sign_temp,s_o,exp_temp_dly3,a_or_b_nan_dly3,s_a_dly3,s_b_dly3,a_inf_dly3,b_inf_dly3,i_axis_operation_tdata_dly3,i_axis_aboperation_tvalid_dly3};
end
endgenerate

//to find the first one in each mantissa, which means the first one is the integer and the rest are the mantissa itself
//1.xxxxxxxxxxxxxxxxx * 2^(n)            ---->           0.1xxxxxxxxxxxxxx * 2^(n+1)
//+ -
//1.xxxxxxxxxxxxxxxxx * 2^(m)            ---->           0.1xxxxxxxxxxxxxx * 2^(n+1)
assign find_one = i_axis_aboperation_tvalid_dly4?{{(E-RNE-1){1'b0}},sign_temp_dly4}:0;
ipsxe_floating_point_find_one_64bit_v1_0#(INNER_LATENCY) u_find1_64(i_aclk,i_rst_n,i_aclken,find_one,fst_one_index);//the find 1 module for 64bits input can adjust its inner latency for logic levels
assign lenth_diff = E+F - (fst_one_index);
    if (INNER_LATENCY==4)begin//the inner latency if set to achieve the requirement of logic levels in the max latency configration
    ipm_distributed_shiftregister_wrapper_v1_3 #(INNER_LATENCY,LENTH+E+(F+RNE+1)+1+7) inner1_inst(
        .clk(i_aclk),
        .i_aclken(i_aclken),
        .rst(!i_rst_n),
        .din({find_one,exp_temp_dly4,sign_temp_dly4,s_o_dly4,i_axis_aboperation_tvalid_dly4,a_or_b_nan_dly4,a_inf_dly4,b_inf_dly4,s_a_dly4,s_b_dly4,i_axis_operation_tdata_dly4}),
        .dout({find_one_dly6,exp_temp_dly6,sign_temp_dly6,s_o_dly6,i_axis_aboperation_tvalid_dly6,a_or_b_nan_dly6,a_inf_dly6,b_inf_dly6,s_a_dly6,s_b_dly6,i_axis_operation_tdata_dly6})
    );
    end
    else begin
    assign {find_one_dly6,exp_temp_dly6,sign_temp_dly6,s_o_dly6,i_axis_aboperation_tvalid_dly6,a_or_b_nan_dly6,a_inf_dly6,b_inf_dly6,s_a_dly6,s_b_dly6,i_axis_operation_tdata_dly6} = {find_one,exp_temp_dly4,sign_temp_dly4,s_o_dly4,i_axis_aboperation_tvalid_dly4,a_or_b_nan_dly4,a_inf_dly4,b_inf_dly4,s_a_dly4,s_b_dly4,i_axis_operation_tdata_dly4};
    end
assign find_one_zero = (fst_one_index==0);
assign sign_out_before_rounding_temp = find_one_dly6<<lenth_diff;//shift the difference between the settled lenth and the RNEed mantissa bits
assign sign_out_before_rounding = sign_out_before_rounding_temp[LENTH-1:E+1-RNE];//get the before-rounding mantissa
always@(*)begin//get the exponent for temporary output
if (find_one_zero) exp_out = exp_temp_dly6;
else if (fst_one_index<F+RNE-1) exp_out = exp_temp_dly6-(F+RNE-1-fst_one_index);
else exp_out = sign_temp_dly6[F+RNE]?exp_temp_dly6+1'b1:exp_temp_dly6;
end

//round to nearest even
assign guard_bit = sign_out_before_rounding[RNE];//LSB of the result
assign round_bit = sign_out_before_rounding[RNE-1];//1st removed bit 
assign sticky_bit = |sign_out_before_rounding[RNE-2:4];//OR for the remained bits

//latency configuration
generate
if (LATENCY_CONFIG>=4)begin
ipsxe_floating_point_register_v1_0#(1+1+(F+RNE-1)+3+1+(E+1)+6) blk_ltcy5(
        .i_clk(i_aclk),
        .i_aclken(i_aclken),
        .i_rst_n(i_rst_n),
        .i_d({find_one_zero,s_o_dly6,sign_out_before_rounding,guard_bit,round_bit,sticky_bit,i_axis_aboperation_tvalid_dly6,exp_out,a_or_b_nan_dly6,a_inf_dly6,b_inf_dly6,s_a_dly6,s_b_dly6,i_axis_operation_tdata_dly6}),
        .o_q({find_one_zero_dly5,s_o_dly5,sign_out_before_rounding_dly5,guard_bit_dly5,round_bit_dly5,sticky_bit_dly5,i_axis_aboperation_tvalid_dly5,exp_out_dly5,a_or_b_nan_dly5,a_inf_dly5,b_inf_dly5,s_a_dly5,s_b_dly5,i_axis_operation_tdata_dly5})
);
end
else begin
assign {find_one_zero_dly5,s_o_dly5,sign_out_before_rounding_dly5,guard_bit_dly5,round_bit_dly5,sticky_bit_dly5,i_axis_aboperation_tvalid_dly5,exp_out_dly5,a_or_b_nan_dly5,a_inf_dly5,b_inf_dly5,s_a_dly5,s_b_dly5,i_axis_operation_tdata_dly5} = {find_one_zero,s_o_dly6,sign_out_before_rounding,guard_bit,round_bit,sticky_bit,i_axis_aboperation_tvalid_dly6,exp_out,a_or_b_nan_dly6,a_inf_dly6,b_inf_dly6,s_a_dly6,s_b_dly6,i_axis_operation_tdata_dly6};
end
endgenerate 
assign carry_compensate = (sticky_bit_dly5&round_bit_dly5)|(guard_bit_dly5&round_bit_dly5&(~sticky_bit_dly5));//carry bit
assign sign_out = find_one_zero_dly5?sign_out_before_rounding_dly5[LENTH-1-RNE:E+1-RNE]:(carry_compensate?sign_out_before_rounding_dly5[F+RNE-2:RNE]+1'b1:sign_out_before_rounding_dly5[F+RNE-2:RNE]);//mantissa output

//temp output without latency
always@(*)begin
    temp_o_axis_result_tvalid = i_axis_aboperation_tvalid_dly5;
    temp_o_underflow = exp_out_dly5==0;
    temp_o_overflow = ((exp_out_dly5[E]&(~exp_out_dly5[E-1]))|((~exp_out_dly5[E])&(&exp_out_dly5[E-1:0])));
    temp_o_invalid_op = (a_or_b_nan_dly5|b_inf_dly5|a_inf_dly5);
    if(a_or_b_nan_dly5)begin//a or b is nan
    temp_o_axis_result_tdata = {1'b0,{E{1'b1}},{(F-1){1'b1}}};
    end
    else if (a_inf_dly5&(~b_inf_dly5))begin//only a is infinity
    temp_o_axis_result_tdata = {s_a_dly5,{E{1'b1}},{(F-1){1'b0}}};
    end
    else if ((~a_inf_dly5)&(b_inf_dly5))begin//only b is infinity
    temp_o_axis_result_tdata = {s_b_dly5^i_axis_operation_tdata_dly5,{E{1'b1}},{(F-1){1'b0}}};
    end
    else if((a_inf_dly5)&(b_inf_dly5))begin//a and b are infinity
    temp_o_axis_result_tdata = (~((s_a_dly5)^(s_b_dly5^i_axis_operation_tdata_dly5)))?{s_a_dly5,{E{1'b1}},{(F-1){1'b0}}}:{1'b0,{E{1'b1}},{(F-1){1'b1}}};
    end
    else begin//normal cases
    temp_o_axis_result_tdata = {s_o_dly5,exp_out_dly5[E-1:0],sign_out};
    end
end

//output pipelines for catering the latency requirement
generate
if (LATENCY_CONFIG < PIPELINE_STAGE+1)begin
    assign {o_invalid_op,o_underflow,o_overflow,o_axis_result_tvalid,o_axis_result_tdata} = {temp_o_invalid_op,temp_o_underflow,temp_o_overflow,temp_o_axis_result_tvalid,temp_o_axis_result_tdata};
end 
else if (LATENCY_CONFIG == PIPELINE_STAGE+1)begin
    wire [(4*1+LENTH)-1:0] out_delay;
    ipsxe_floating_point_register_v1_0 #(4*1+LENTH) outreg_inst(
        .i_clk(i_aclk),
        .i_aclken(i_aclken),
        .i_rst_n(i_rst_n),
        .i_d({temp_o_axis_result_tvalid,temp_o_invalid_op,temp_o_underflow,temp_o_overflow,temp_o_axis_result_tdata}),
        .o_q(out_delay)
    );
    assign {o_axis_result_tvalid,o_invalid_op,o_underflow,o_overflow,o_axis_result_tdata} = out_delay;
end
else begin
    ipm_distributed_shiftregister_wrapper_v1_3 #((LATENCY_CONFIG-PIPELINE_STAGE),(4*1+LENTH)) outreg_further_inst(
        .clk(i_aclk),
        .i_aclken(i_aclken),
        .rst(!i_rst_n),
        .din({temp_o_axis_result_tvalid,temp_o_invalid_op,temp_o_underflow,temp_o_overflow,temp_o_axis_result_tdata}),
        .dout({o_axis_result_tvalid,o_invalid_op,o_underflow,o_overflow,o_axis_result_tdata})
    );
end
endgenerate

endmodule