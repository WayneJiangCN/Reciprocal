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
// Filename:float_mul.v
// Function: c=a*b
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns
(*use_dsp="no"*)
module ipsxe_floating_point_mul_v1_0 #(parameter EXPONENT_LENTH = 8, SIGNIFICANT_LENTH = 23, APM_USAGE = 0, LATENCY_CONFIG = 7)(
    i_clk,
    i_aclken,
    i_areset_n,
    i_axis_or_ab_tvalid,
    i_axis_a_tdata,
    i_axis_b_tdata,

    o_axis_result_tdata,
    o_axis_result_tvalid_when_tready,
    o_invalid_op,
    o_overflow,
    o_underflow
    );

localparam LENTH = 1+EXPONENT_LENTH+SIGNIFICANT_LENTH;
localparam PIPELINE_STAGE = 5;

input i_clk;
input i_aclken;
input i_areset_n;
input i_axis_or_ab_tvalid;
input signed [LENTH-1:0] i_axis_a_tdata;
input signed [LENTH-1:0] i_axis_b_tdata;

output signed [LENTH-1:0] o_axis_result_tdata;
output o_overflow;
output o_underflow;
output o_invalid_op;
output o_axis_result_tvalid_when_tready;

//significand bit for input float a\b and output float o
wire [SIGNIFICANT_LENTH-1:0] sign_a, sign_b, sign_o;
reg [SIGNIFICANT_LENTH-1:0] sign_o_temp;
//sign bit for input float a\b and output float o
wire s_a, s_b, s_o;
//exponent bit for input float a\b and output float o
wire [EXPONENT_LENTH-1:0] exp_a, exp_b, exp_o;

//insert pipeline declare------------------begin-----------------------
wire s_a_reg1, s_b_reg1, s_a_reg2, s_b_reg2, s_a_reg3, s_b_reg3, s_a_reg4, s_b_reg4;
wire [EXPONENT_LENTH-1:0] exp_a_reg1, exp_b_reg1, exp_a_reg2, exp_b_reg2, exp_a_reg3, exp_b_reg3, exp_a_reg4, exp_b_reg4, exp_a_reg5, exp_b_reg5;
wire [SIGNIFICANT_LENTH-1:0] sign_a_reg1, sign_b_reg1, sign_a_reg2, sign_b_reg2, sign_a_reg3, sign_b_reg3, sign_a_reg4, sign_b_reg4, sign_a_reg5, sign_b_reg5;
wire [SIGNIFICANT_LENTH-1:0] sign_o_reg1, sign_o_reg2;
wire s_o_reg1;
wire carry_reg;
wire [EXPONENT_LENTH-1:0] exp_o_reg1;
wire [EXPONENT_LENTH:0] flow_reg1;
wire zero_a_reg1, zero_b_reg1, zero_a_reg2, zero_b_reg2;
wire i_axis_or_ab_tvalid_reg1, i_axis_or_ab_tvalid_reg2, i_axis_or_ab_tvalid_reg3, i_axis_or_ab_tvalid_reg4, i_axis_or_ab_tvalid_reg5;
wire reg1_is_nan_nan,reg1_is_nan_inf,reg1_is_inf_input, reg2_is_nan_nan,reg2_is_nan_inf,reg2_is_inf_input, reg3_is_nan_nan,reg3_is_nan_inf,reg3_is_inf_input, reg4_is_nan_nan,reg4_is_nan_inf,reg4_is_inf_input;
//insert pipeline declare------------------end-----------------------

//the principle of the multiply process
//math: 1.m*1.n = 1 + 0.m*0.n + (0.m+0.n)
//meanning: a * b = inte + mul + add
wire [1:0] inte, inte_reg;//integer
wire [2*SIGNIFICANT_LENTH-1:0] mul, mul_reg1, mul_reg2;//multiply part
wire [SIGNIFICANT_LENTH:0] add, add_reg;//addition part
wire [SIGNIFICANT_LENTH:0] dec_reg;//register decimal part
wire [SIGNIFICANT_LENTH:0] dec;//actual decimal part
wire guard_bit,round_bit,sticky_bit;//rounding bits
wire carry_compensate;//compensate the carry forward bit in the next stage
wire carry;//carry forward in flow
wire zero_a,zero_b;//check if each input is 0
wire [EXPONENT_LENTH:0] flow;//get the answer exponent
wire [EXPONENT_LENTH-1:0] adj_flow;//parameter based on input bits
wire [EXPONENT_LENTH:0] flow_hi;
 
//NAN detect
wire is_nan_nan;
wire is_nan_inf;
wire [LENTH-1:0] nan_out;
//inf detect
wire is_inf_input;
wire [EXPONENT_LENTH-1:0] inf_exp;
wire [SIGNIFICANT_LENTH-1:0] inf_sig;
wire [LENTH-1:0] zero_out_final;

//signals without output latency 
wire no_outreg_o_overflow, no_outreg_o_underflow, no_outreg_o_invalid_op, no_outreg_o_axis_result_tvalid_when_tready;
wire [LENTH-1:0] no_outreg_o_axis_result_tdata;

//The floating point multiplier first intercepts the corresponding parts of the two input floating point numbers into sign bits, exponent bits and tail bits respectively.
assign s_a = i_axis_a_tdata[LENTH-1];
assign exp_a = i_axis_a_tdata[LENTH-2:LENTH-EXPONENT_LENTH-1];
assign sign_a = i_axis_a_tdata[SIGNIFICANT_LENTH-1:0];

assign s_b = i_axis_b_tdata[LENTH-1];
assign exp_b = i_axis_b_tdata[LENTH-2:LENTH-EXPONENT_LENTH-1];
assign sign_b = i_axis_b_tdata[SIGNIFICANT_LENTH-1:0];

generate
if (APM_USAGE == 0) begin
wire [2*SIGNIFICANT_LENTH-1:0] mul_temp /*synthesis syn_dspstyle = "logic" */;
assign mul_temp = sign_a * sign_b;
if (LATENCY_CONFIG>=5)begin
    ipsxe_floating_point_register_v1_0#((2*SIGNIFICANT_LENTH)+2*LENTH) reg_pipeline_begin(
        .i_clk(i_clk),
        .i_aclken(i_aclken),
        .i_rst_n(i_areset_n),
        .i_d({mul_temp,s_a,exp_a,sign_a,s_b,exp_b,sign_b}),
        .o_q({mul,s_a_reg1,exp_a_reg1,sign_a_reg1,s_b_reg1,exp_b_reg1,sign_b_reg1})
    );
end
else begin
assign {mul,s_a_reg1,exp_a_reg1,sign_a_reg1,s_b_reg1,exp_b_reg1,sign_b_reg1} = {mul_temp,s_a,exp_a,sign_a,s_b,exp_b,sign_b};
end
end
else if (APM_USAGE == 1) begin
wire [2*SIGNIFICANT_LENTH-1:0] mul_hi, mul_hi_reg1 /*synthesis syn_dspstyle = "block_mult" */;
wire [2*SIGNIFICANT_LENTH-1:0] mul_mi, mul_mi_reg1 /*synthesis syn_dspstyle = "logic" */;
wire [2*SIGNIFICANT_LENTH-1:0] mul_lo, mul_lo_reg1 /*synthesis syn_dspstyle = "logic" */;
assign mul_hi = sign_a * sign_b[SIGNIFICANT_LENTH-1:((SIGNIFICANT_LENTH*2)/3)];
assign mul_mi = sign_a * sign_b[((SIGNIFICANT_LENTH*2)/3)-1:(SIGNIFICANT_LENTH/3)];
assign mul_lo = sign_a * sign_b[(SIGNIFICANT_LENTH/3)-1:0]; 
if (LATENCY_CONFIG>=5)begin
    ipsxe_floating_point_register_v1_0#(3*(2*SIGNIFICANT_LENTH)+2*LENTH) reg_pipeline_begin(
        .i_clk(i_clk),
        .i_aclken(i_aclken),
        .i_rst_n(i_areset_n),
        .i_d({mul_hi,mul_mi,mul_lo,s_a,exp_a,sign_a,s_b,exp_b,sign_b}),
        .o_q({mul_hi_reg1,mul_mi_reg1,mul_lo_reg1,s_a_reg1,exp_a_reg1,sign_a_reg1,s_b_reg1,exp_b_reg1,sign_b_reg1})
    );
end
else begin
assign {mul_hi_reg1,mul_mi_reg1,mul_lo_reg1,s_a_reg1,exp_a_reg1,sign_a_reg1,s_b_reg1,exp_b_reg1,sign_b_reg1} = {mul_hi,mul_mi,mul_lo,s_a,exp_a,sign_a,s_b,exp_b,sign_b};
end
assign mul = {mul_hi_reg1, {((SIGNIFICANT_LENTH*2)/3){1'b0}}} + {mul_mi_reg1, {(SIGNIFICANT_LENTH/3){1'b0}}} + mul_lo_reg1;
end
else if (APM_USAGE == 2) begin
wire [2*SIGNIFICANT_LENTH-1:0] mul_hi, mul_hi_reg1 /*synthesis syn_dspstyle = "block_mult" */;
wire [2*SIGNIFICANT_LENTH-1:0] mul_mi, mul_mi_reg1 /*synthesis syn_dspstyle = "block_mult" */;
wire [2*SIGNIFICANT_LENTH-1:0] mul_lo, mul_lo_reg1 /*synthesis syn_dspstyle = "logic" */;
assign mul_hi = sign_a * sign_b[SIGNIFICANT_LENTH-1:((SIGNIFICANT_LENTH*2)/3)];
assign mul_mi = sign_a * sign_b[((SIGNIFICANT_LENTH*2)/3)-1:(SIGNIFICANT_LENTH/3)];
assign mul_lo = sign_a * sign_b[(SIGNIFICANT_LENTH/3)-1:0]; 
if (LATENCY_CONFIG>=5)begin
    ipsxe_floating_point_register_v1_0#(3*(2*SIGNIFICANT_LENTH)+2*LENTH) reg_pipeline_begin(
        .i_clk(i_clk),
        .i_aclken(i_aclken),
        .i_rst_n(i_areset_n),
        .i_d({mul_hi,mul_mi,mul_lo,s_a,exp_a,sign_a,s_b,exp_b,sign_b}),
        .o_q({mul_hi_reg1,mul_mi_reg1,mul_lo_reg1,s_a_reg1,exp_a_reg1,sign_a_reg1,s_b_reg1,exp_b_reg1,sign_b_reg1})
    );

end
else begin
assign {mul_hi_reg1,mul_mi_reg1,mul_lo_reg1,s_a_reg1,exp_a_reg1,sign_a_reg1,s_b_reg1,exp_b_reg1,sign_b_reg1} = {mul_hi,mul_mi,mul_lo,s_a,exp_a,sign_a,s_b,exp_b,sign_b};
end
assign mul = {mul_hi_reg1, {((SIGNIFICANT_LENTH*2)/3){1'b0}}} + {mul_mi_reg1, {(SIGNIFICANT_LENTH/3){1'b0}}} + mul_lo_reg1;
end
else begin // APM_USAGE == 3
wire [2*SIGNIFICANT_LENTH-1:0] mul_hi, mul_hi_reg1 /*synthesis syn_dspstyle = "block_mult" */;
wire [2*SIGNIFICANT_LENTH-1:0] mul_mi, mul_mi_reg1 /*synthesis syn_dspstyle = "block_mult" */;
wire [2*SIGNIFICANT_LENTH-1:0] mul_lo, mul_lo_reg1 /*synthesis syn_dspstyle = "block_mult" */;
assign mul_hi = sign_a * sign_b[SIGNIFICANT_LENTH-1:((SIGNIFICANT_LENTH*2)/3)];
assign mul_mi = sign_a * sign_b[((SIGNIFICANT_LENTH*2)/3)-1:(SIGNIFICANT_LENTH/3)];
assign mul_lo = sign_a * sign_b[(SIGNIFICANT_LENTH/3)-1:0]; 
if (LATENCY_CONFIG>=5)begin
    ipsxe_floating_point_register_v1_0#(3*(2*SIGNIFICANT_LENTH)+2*LENTH) reg_pipeline_begin(
        .i_clk(i_clk),
        .i_aclken(i_aclken),
        .i_rst_n(i_areset_n),
        .i_d({mul_hi,mul_mi,mul_lo,s_a,exp_a,sign_a,s_b,exp_b,sign_b}),
        .o_q({mul_hi_reg1,mul_mi_reg1,mul_lo_reg1,s_a_reg1,exp_a_reg1,sign_a_reg1,s_b_reg1,exp_b_reg1,sign_b_reg1})
    );
end
else begin
assign {mul_hi_reg1,mul_mi_reg1,mul_lo_reg1,s_a_reg1,exp_a_reg1,sign_a_reg1,s_b_reg1,exp_b_reg1,sign_b_reg1} = {mul_hi,mul_mi,mul_lo,s_a,exp_a,sign_a,s_b,exp_b,sign_b};
end
assign mul = {mul_hi_reg1, {((SIGNIFICANT_LENTH*2)/3){1'b0}}} + {mul_mi_reg1, {(SIGNIFICANT_LENTH/3){1'b0}}} + mul_lo_reg1;
end
endgenerate

//general process for mul  ------------------begin---------------------
//Perform parallel operations and operations on these three parts simultaneously using the same clock. The operation of the mantissa is the most important among multipliers.
//This design uses a multiplication and addition strategy to operate on the number of digits and record whether they are carried. The specific algorithm is shown in the following equation.
//1.m * 1.n = (1+0.m) * (1+0.n) = 1 + 0.m * 0.n + (0.m + 0.n)
//From the formula, it can be seen that multiplication such as this can be divided into three parts using the multiplication allocation law, namely the initial integer part is 1, the multiplication part is the multiplication of the two mantissas themselves, and the addition part is the addition of the two mantissas themselves.
//Therefore, the algorithm has been made concise and clear, where the decimal part (the last two parts in the formula) added directly after the decimal point can be considered as the output mantissa, while the possible carry after the decimal part (the last two parts in the formula) added will be taken into account whether the index is carried or not.

assign is_nan_nan = (exp_a_reg1==inf_exp&&sign_a_reg1!=0)||(exp_b_reg1==inf_exp&&sign_b_reg1!=0);
assign is_nan_inf = ((exp_b_reg1==0)&&(exp_a_reg1==inf_exp&&sign_a_reg1==0))||((exp_a_reg1==0)&&(exp_b_reg1==inf_exp&&sign_b_reg1==0));
assign is_inf_input = (exp_a_reg1==inf_exp&&sign_a_reg1==0)||(exp_b_reg1==inf_exp&&sign_b_reg1==0);

assign add = sign_a_reg1 + sign_b_reg1;

generate
if (LATENCY_CONFIG>=5)begin
    ipsxe_floating_point_register_v1_0#(1) reg_input_valid(
        .i_clk(i_clk),
        .i_aclken(i_aclken),
        .i_rst_n(i_areset_n),
        .i_d(i_axis_or_ab_tvalid),
        .o_q(i_axis_or_ab_tvalid_reg1)
    );
end
else begin
assign i_axis_or_ab_tvalid_reg1 = i_axis_or_ab_tvalid;
end
endgenerate

//If latency is more than 1, add the 1st pipeline to cater for the latency.
generate
if (LATENCY_CONFIG>=1)begin
    ipsxe_floating_point_register_v1_0#(2*SIGNIFICANT_LENTH+(SIGNIFICANT_LENTH+1)+2*LENTH+1+3) reg_add_mul(
        .i_clk(i_clk),
        .i_aclken(i_aclken),
        .i_rst_n(i_areset_n),
        .i_d({mul,add,s_a_reg1,exp_a_reg1,sign_a_reg1,s_b_reg1,exp_b_reg1,sign_b_reg1,i_axis_or_ab_tvalid_reg1,is_nan_nan,is_nan_inf,is_inf_input}),
        .o_q({mul_reg1,add_reg,s_a_reg2,exp_a_reg2,sign_a_reg2,s_b_reg2,exp_b_reg2,sign_b_reg2,i_axis_or_ab_tvalid_reg2,reg1_is_nan_nan,reg1_is_nan_inf,reg1_is_inf_input})
    );
end
else begin
assign {mul_reg1,add_reg,s_a_reg2,exp_a_reg2,sign_a_reg2,s_b_reg2,exp_b_reg2,sign_b_reg2,i_axis_or_ab_tvalid_reg2,reg1_is_nan_nan,reg1_is_nan_inf,reg1_is_inf_input} = {mul,add,s_a_reg1,exp_a_reg1,sign_a_reg1,s_b_reg1,exp_b_reg1,sign_b_reg1,i_axis_or_ab_tvalid_reg1,is_nan_nan,is_nan_inf,is_inf_input};
end
endgenerate

assign dec = mul_reg1[2*SIGNIFICANT_LENTH-1:SIGNIFICANT_LENTH] + add_reg[SIGNIFICANT_LENTH-1:0];
assign inte = 1'b1 +add_reg[SIGNIFICANT_LENTH] + dec[SIGNIFICANT_LENTH];

//If latency is more than 2, add the 2st pipeline to cater for the latency.
generate
if (LATENCY_CONFIG>=2)begin
    ipsxe_floating_point_register_v1_0#((SIGNIFICANT_LENTH+1)+2+(2*SIGNIFICANT_LENTH)+2*LENTH+1+3) reg_dec_inte(
        .i_clk(i_clk),
        .i_aclken(i_aclken),
        .i_rst_n(i_areset_n),
        .i_d({dec,inte,mul_reg1,s_a_reg2,exp_a_reg2,sign_a_reg2,s_b_reg2,exp_b_reg2,sign_b_reg2,i_axis_or_ab_tvalid_reg2,reg1_is_nan_nan,reg1_is_nan_inf,reg1_is_inf_input}),
        .o_q({dec_reg,inte_reg,mul_reg2,s_a_reg3,exp_a_reg3,sign_a_reg3,s_b_reg3,exp_b_reg3,sign_b_reg3,i_axis_or_ab_tvalid_reg3,reg2_is_nan_nan,reg2_is_nan_inf,reg2_is_inf_input})
    );
end
else begin
assign {dec_reg,inte_reg,mul_reg2} = {dec,inte,mul_reg1};
assign {s_a_reg3,exp_a_reg3,sign_a_reg3,s_b_reg3,exp_b_reg3,sign_b_reg3, i_axis_or_ab_tvalid_reg3} = {s_a_reg2,exp_a_reg2,sign_a_reg2,s_b_reg2,exp_b_reg2,sign_b_reg2,i_axis_or_ab_tvalid_reg2};
assign {reg2_is_nan_nan,reg2_is_nan_inf,reg2_is_inf_input} = {reg1_is_nan_nan,reg1_is_nan_inf,reg1_is_inf_input};
end
endgenerate

assign carry = ((sign_a_reg3==0)||(sign_b_reg3==0))?0:(inte_reg[1]?1:0);
assign zero_a=(exp_a_reg3==0)?1'b1:1'b0;
assign zero_b=(exp_b_reg3==0)?1'b1:1'b0;

assign guard_bit = inte_reg[1]?dec_reg[1]:dec_reg[0];//LSB of the result
assign round_bit = inte_reg[1]?dec_reg[0]:mul_reg2[SIGNIFICANT_LENTH-1];//1st removed bit 
assign sticky_bit = inte_reg[1]?(|mul_reg2[SIGNIFICANT_LENTH-1:0]):(|mul_reg2[SIGNIFICANT_LENTH-2:0]);//OR for the remained bits
assign carry_compensate = (sticky_bit&&round_bit)||(guard_bit&&round_bit&&(!sticky_bit));

always@(*)begin
case (inte_reg)
    2'b11:begin
    sign_o_temp =  dec_reg[SIGNIFICANT_LENTH:1];
    end 
    2'b10:begin
    sign_o_temp =  {1'b0,dec_reg[SIGNIFICANT_LENTH-1:1]};
    end
    default begin
    sign_o_temp =  dec_reg[SIGNIFICANT_LENTH-1:0];
    end
endcase
end

assign sign_o = sign_o_temp + carry_compensate;

//If latency is more than 3, add the 3rd pipeline to cater for the latency.
generate
if (LATENCY_CONFIG>=3)begin
    ipsxe_floating_point_register_v1_0#(2*LENTH+2+SIGNIFICANT_LENTH+2+3) reg_dec_inte(
        .i_clk(i_clk),
        .i_aclken(i_aclken),
        .i_rst_n(i_areset_n),
        .i_d({carry,s_a_reg3,exp_a_reg3,sign_a_reg3,s_b_reg3,exp_b_reg3,sign_b_reg3,i_axis_or_ab_tvalid_reg3,sign_o, zero_a, zero_b, reg2_is_nan_nan,reg2_is_nan_inf,reg2_is_inf_input}),
        .o_q({carry_reg,s_a_reg4,exp_a_reg4,sign_a_reg4,s_b_reg4,exp_b_reg4,sign_b_reg4,i_axis_or_ab_tvalid_reg4,sign_o_reg1, zero_a_reg1, zero_b_reg1, reg3_is_nan_nan,reg3_is_nan_inf,reg3_is_inf_input})
    );
end
else begin
assign {carry_reg,sign_o_reg1} = {carry,sign_o};
assign {zero_a_reg1,zero_b_reg1} = {zero_a, zero_b};
assign {s_a_reg4,exp_a_reg4,sign_a_reg4,s_b_reg4,exp_b_reg4,sign_b_reg4,i_axis_or_ab_tvalid_reg4} = {s_a_reg3,exp_a_reg3,sign_a_reg3,s_b_reg3,exp_b_reg3,sign_b_reg3,i_axis_or_ab_tvalid_reg3};
assign {reg3_is_nan_nan,reg3_is_nan_inf,reg3_is_inf_input} = {reg2_is_nan_nan,reg2_is_nan_inf,reg2_is_inf_input};
end
endgenerate

//For exponential bits, the sum of the corresponding exponents of two floating point numbers plus carry or not minus 127 can get the output index.
//The output symbol can be simply obtained by XOR of the sign bits of two input floating point numbers.
assign adj_flow = {1'b1,{(EXPONENT_LENTH-1){1'b0}}}-1'd1;
assign flow_hi = carry_reg?(exp_b_reg4+exp_a_reg4+1):exp_b_reg4+exp_a_reg4;
assign flow = flow_hi-adj_flow;

assign s_o = s_a_reg4^s_b_reg4;
assign exp_o = flow[EXPONENT_LENTH-1:0];

//If latency is more than 4, add the 4th pipeline to cater for the latency.
generate 
if (LATENCY_CONFIG>=4)begin
    ipsxe_floating_point_register_v1_0#(LENTH+2*EXPONENT_LENTH+(EXPONENT_LENTH+1)+1+1+1+3) reg4_inst(
        .i_clk(i_clk),
        .i_aclken(i_aclken),
        .i_rst_n(i_areset_n),
        .i_d({s_o,exp_o,sign_o_reg1, exp_a_reg4,exp_b_reg4, flow, i_axis_or_ab_tvalid_reg4, zero_a_reg1, zero_b_reg1, reg3_is_nan_nan,reg3_is_nan_inf,reg3_is_inf_input}),
        .o_q({s_o_reg1,exp_o_reg1,sign_o_reg2, exp_a_reg5,exp_b_reg5, flow_reg1, i_axis_or_ab_tvalid_reg5, zero_a_reg2, zero_b_reg2, reg4_is_nan_nan,reg4_is_nan_inf,reg4_is_inf_input})
    );
end
else begin
assign {s_o_reg1,exp_o_reg1,sign_o_reg2} = {s_o,exp_o,sign_o_reg1};
assign {exp_a_reg5,exp_b_reg5} = {exp_a_reg4,exp_b_reg4};
assign {i_axis_or_ab_tvalid_reg5,flow_reg1} = {i_axis_or_ab_tvalid_reg4,flow};
assign {zero_a_reg2,zero_b_reg2} = {zero_a_reg1,zero_b_reg1};
assign {reg4_is_nan_nan,reg4_is_nan_inf,reg4_is_inf_input} = {reg3_is_nan_nan,reg3_is_nan_inf,reg3_is_inf_input};
end
endgenerate 
//general process for mul  ------------------end---------------------

//special cases: NAN and inf
assign inf_exp = {1'b1,adj_flow[EXPONENT_LENTH-2:0]};
assign inf_sig = 0;
assign zero_out_final = {s_o_reg1,{(LENTH-1){1'b0}}};
assign nan_out = {1'b0,inf_exp,{1'b1,inf_sig[SIGNIFICANT_LENTH-2:0]}};

//output signals
assign no_outreg_o_invalid_op = ((|exp_a_reg5) | (|exp_b_reg5))?0:1;//if 1 exists, valid; else invalid->o_invalid_op
assign no_outreg_o_underflow = (flow_reg1[EXPONENT_LENTH]&&flow_reg1[EXPONENT_LENTH-1])?1'b1:1'b0;
assign no_outreg_o_overflow = ((flow_reg1[EXPONENT_LENTH] == 1'b1)&&(!flow_reg1[EXPONENT_LENTH-1]))||((flow_reg1[EXPONENT_LENTH] == 1'b0)&&(&flow_reg1[EXPONENT_LENTH-1:0]))?1:0;
assign no_outreg_o_axis_result_tdata = (reg4_is_nan_nan||reg4_is_nan_inf)?nan_out:(reg4_is_inf_input||no_outreg_o_overflow)?{s_o_reg1,inf_exp,inf_sig}:(zero_a_reg2||zero_b_reg2||(exp_o_reg1==0))?{zero_out_final}:(flow_reg1[EXPONENT_LENTH])?((flow_reg1[EXPONENT_LENTH-1])?{zero_out_final}:{s_o_reg1,inf_exp,inf_sig}):{s_o_reg1, exp_o_reg1, sign_o_reg2};
assign no_outreg_o_axis_result_tvalid_when_tready = i_axis_or_ab_tvalid_reg5;

//Output pipelines for catering the latency requirement.
generate
if (LATENCY_CONFIG < PIPELINE_STAGE+1)begin
    assign {o_invalid_op,o_underflow,o_overflow,o_axis_result_tvalid_when_tready,o_axis_result_tdata} = {no_outreg_o_invalid_op,no_outreg_o_underflow,no_outreg_o_overflow,no_outreg_o_axis_result_tvalid_when_tready,no_outreg_o_axis_result_tdata};
end 
else if (LATENCY_CONFIG == PIPELINE_STAGE+1)begin
    wire [(4*1+LENTH)-1:0] out_delay;
    ipsxe_floating_point_register_v1_0 #(4*1+LENTH) outreg_inst(
        .i_clk(i_clk),
        .i_aclken(i_aclken),
        .i_rst_n(i_areset_n),
        .i_d({no_outreg_o_axis_result_tvalid_when_tready,no_outreg_o_invalid_op,no_outreg_o_underflow,no_outreg_o_overflow,no_outreg_o_axis_result_tdata}),
        .o_q(out_delay)
    );
    assign {o_axis_result_tvalid_when_tready,o_invalid_op,o_underflow,o_overflow,o_axis_result_tdata} = out_delay;
end
else begin
    wire [(4*1+LENTH)*(LATENCY_CONFIG-PIPELINE_STAGE)-1:0] out_delay;
    ipsxe_floating_point_register_v1_0 #((4*1+LENTH)*(LATENCY_CONFIG-PIPELINE_STAGE)) outreg_further_inst(
        .i_clk(i_clk),
        .i_aclken(i_aclken),
        .i_rst_n(i_areset_n),
        .i_d({out_delay[(4*1+LENTH)*(LATENCY_CONFIG-PIPELINE_STAGE)-1-(4*1+LENTH):0],no_outreg_o_axis_result_tvalid_when_tready,no_outreg_o_invalid_op,no_outreg_o_underflow,no_outreg_o_overflow,no_outreg_o_axis_result_tdata}),
        .o_q(out_delay)
    );
    assign {o_axis_result_tvalid_when_tready,o_invalid_op,o_underflow,o_overflow,o_axis_result_tdata} = out_delay[(4*1+LENTH)*(LATENCY_CONFIG-PIPELINE_STAGE)-1:(4*1+LENTH)*(LATENCY_CONFIG-PIPELINE_STAGE-1)];
end
endgenerate
endmodule