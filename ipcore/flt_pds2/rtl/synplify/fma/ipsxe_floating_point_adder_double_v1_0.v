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
// Filename: ipsxe_floating_point_adder_v1_0.v
// Function: The module adds a * b and c.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_adder_double_v1_0 #(parameter EXP_WIDTH = 8, MAN_WIDTH = 23, LATENCY_CONFIG = 1, PIPE_STAGE_NUM_MAX = 1, W_USER = 1) (
    input i_clk,
    input i_aclken,
    input i_rst_n,
    input [2*(MAN_WIDTH+1) + (EXP_WIDTH+1):0] i_a_mul_b,
    input i_sign_c,
    input [EXP_WIDTH:0] i_exp_c,
    input [MAN_WIDTH-1:0] i_man_c,
    input i_c_is_0,
    input [W_USER-1:0] i_user,
    output [W_USER-1:0] o_user,
    output [(2*(MAN_WIDTH+1)+1)+(EXP_WIDTH+1):0] o_add_out
);

localparam WIDTH = 1+EXP_WIDTH+MAN_WIDTH; // floating-point data width

wire sign_p;
wire [EXP_WIDTH:0] exp_p;
wire [2*(MAN_WIDTH+1)-1:0] man_p, man_c;
wire bigger;
wire [2*(MAN_WIDTH+1)-1:0] big_man, small_man;
wire [EXP_WIDTH:0] big_exp, small_exp;
wire big_sign, small_sign;
wire [EXP_WIDTH:0] exp_diff;
wire [2*(MAN_WIDTH+1)-1:0] big_man_dly1, big_man_stage2, big_man_stage2_dly1, small_man_dly1;
wire big_sign_dly1, small_sign_dly1;
wire [EXP_WIDTH:0] big_exp_dly1, exp_diff_dly1;
wire [2*(MAN_WIDTH+1)-2:0] small_man_stage2, small_man_stage2_dly1;
wire big_sign_dly2, small_sign_dly2;
wire [EXP_WIDTH:0] big_exp_dly2, big_exp_dly3, big_exp_dly4;
wire [(2*(MAN_WIDTH+1)+1):0] signed_big, signed_small, signed_big_dly1, signed_small_dly1, signed_sum, signed_sum_dly1;
wire sum_sign;
wire [2*(MAN_WIDTH+1):0] abs_sum;
wire [W_USER-1:0] user_dly1, user_dly2, user_dly3;

// take signs of p (= a * b)
assign sign_p = i_a_mul_b[2*(MAN_WIDTH+1) + (EXP_WIDTH+1)];
// take exponents of p
assign exp_p = i_a_mul_b[2*(MAN_WIDTH+1)+:(EXP_WIDTH+1)];
// take mantissas of p
assign man_p = i_a_mul_b[2*(MAN_WIDTH+1)-1:0];
assign man_c = {1'b0, ~i_c_is_0, i_man_c, {MAN_WIDTH{1'b0}}};

// determine which exponent is bigger
assign bigger = (exp_p >= i_exp_c);

// set big_ and small_ mantissas
assign big_man = bigger ? man_p : man_c;
assign small_man = bigger ? man_c : man_p;
// set big_ and small_ exponents
assign big_exp = bigger ? exp_p : i_exp_c;
assign small_exp = bigger ? i_exp_c : exp_p;
// set big_ and small_ signs
assign big_sign = bigger ? sign_p : i_sign_c;
assign small_sign = bigger ? i_sign_c : sign_p;

// determine difference in exponents
assign exp_diff = big_exp - small_exp;

generate
if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (5 / 2)) begin
// pipeline stage 5
ipsxe_floating_point_register_v1_0 #(2*(2*(MAN_WIDTH+1)) + 2*1 + 2*(EXP_WIDTH+1) + W_USER) u_reg_exp_diff(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({big_man     , small_man     , big_sign     , small_sign     , big_exp     , exp_diff     , i_user   }),
    .o_q({big_man_dly1, small_man_dly1, big_sign_dly1, small_sign_dly1, big_exp_dly1, exp_diff_dly1, user_dly1})
);
//ipm_distributed_shiftregister_wrapper_v1_3 #(1, 2*(2*(MAN_WIDTH+1)) + 2*1 + 2*(EXP_WIDTH+1) + W_USER) u_reg_exp_diff(
//    .din({big_man     , small_man     , big_sign     , small_sign     , big_exp     , exp_diff     , i_user   }),
//    .clk(i_clk),      // input
//    .i_aclken(i_aclken),
//    .rst(~i_rst_n),      // input
//    .dout({big_man_dly1, small_man_dly1, big_sign_dly1, small_sign_dly1, big_exp_dly1, exp_diff_dly1, user_dly1})
//);
end
else begin
assign {big_man_dly1, small_man_dly1, big_sign_dly1, small_sign_dly1, big_exp_dly1, exp_diff_dly1, user_dly1} = {big_man     , small_man     , big_sign     , small_sign     , big_exp     , exp_diff     ,i_user};
end
endgenerate

// shift according to difference in exponents
assign big_man_stage2 = big_man_dly1;
assign small_man_stage2 = (exp_diff_dly1 == 0) ? small_man_dly1[2*(MAN_WIDTH+1)-1-1:0] : (small_man_dly1[2*(MAN_WIDTH+1)-1:1] >> (exp_diff_dly1-1)); // {2'b0, small_man_dly1} >> exp_diff_dly1;

generate
if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/2) - (6 / 4)) begin
// pipeline stage 6
ipsxe_floating_point_register_v1_0 #(2*(MAN_WIDTH+1) + 2*(MAN_WIDTH+1)-1 + 2*1 + (EXP_WIDTH+1) + W_USER) u_reg_signed_big_small(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({big_man_stage2     , small_man_stage2     , big_sign_dly1, small_sign_dly1, big_exp_dly1, user_dly1}),
    .o_q({big_man_stage2_dly1, small_man_stage2_dly1, big_sign_dly2, small_sign_dly2, big_exp_dly2, user_dly2})
);
//ipm_distributed_shiftregister_wrapper_v1_3 #(1, 2*(MAN_WIDTH+1) + 2*(MAN_WIDTH+1)-1 + 2*1 + (EXP_WIDTH+1) + W_USER) u_reg_signed_big_small(
//    .din({big_man_stage2     , small_man_stage2     , big_sign_dly1, small_sign_dly1, big_exp_dly1, user_dly1}),
//    .clk(i_clk),      // input
//    .i_aclken(i_aclken),
//    .rst(~i_rst_n),      // input
//    .dout({big_man_stage2_dly1, small_man_stage2_dly1, big_sign_dly2, small_sign_dly2, big_exp_dly2, user_dly2})
//);
end
else begin
assign {big_man_stage2_dly1, small_man_stage2_dly1, big_sign_dly2, small_sign_dly2, big_exp_dly2, user_dly2} = {big_man_stage2     , small_man_stage2     , big_sign_dly1, small_sign_dly1, big_exp_dly1, user_dly1};
end
endgenerate


///////+++++++++++++++++++++++++all shift register
////process for small_man_stage2 and exp_diff_dly1
//generate
//if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (5 / 2)) begin
//ipsxe_floating_point_register_v1_0 #(2*(MAN_WIDTH+1)-1 +  (EXP_WIDTH + 1)) u_reg_small_man_exp_diff(
//    .i_clk(i_clk),
//    .i_aclken(i_aclken),
//    .i_rst_n(i_rst_n),
//    .i_d({small_man     , exp_diff     }),
//    .o_q({small_man_dly1, exp_diff_dly1})
//);
////ipm_distributed_shiftregister_wrapper_v1_3 #(1, 2*(MAN_WIDTH+1)-1 +  (EXP_WIDTH + 1)) u_reg_small_man_exp_diff(
////    .din({small_man     , exp_diff     }),
////    .clk(i_clk),      // input
////    .i_aclken(i_aclken),
////    .rst(~i_rst_n),      // input
////    .dout({small_man_dly1, exp_diff_dly1})
////);
//end
//else begin
//assign {small_man_dly1,exp_diff_dly1} = {small_man, exp_diff};
//end
//endgenerate
//assign small_man_stage2 = (exp_diff_dly1 == 0) ? small_man_dly1[2*(MAN_WIDTH+1)-1-1:0] : (small_man_dly1[2*(MAN_WIDTH+1)-1:1] >> (exp_diff_dly1-1)); // {2'b0, small_man_dly1} >> exp_diff_dly1;
//generate
//if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/2) - (6 / 4)) begin
//// pipeline stage 6
//ipsxe_floating_point_register_v1_0 #(2*(MAN_WIDTH+1)-1) u_reg_small_man_stage2(
//    .i_clk(i_clk),
//    .i_aclken(i_aclken),
//    .i_rst_n(i_rst_n),
//    .i_d(small_man_stage2     ),
//    .o_q(small_man_stage2_dly1)
//);
////ipm_distributed_shiftregister_wrapper_v1_3 #(1, 2*(MAN_WIDTH+1)-1) u_reg_small_man_stage2(
////    .din(small_man_stage2),
////    .clk(i_clk),      // input
////    .i_aclken(i_aclken),
////    .rst(~i_rst_n),      // input
////    .dout(small_man_stage2_dly1)
////);
//end
//else begin
//assign small_man_stage2_dly1 = small_man_stage2;
//end
//endgenerate
////
////
//////process for other signals
////generate
////if ((LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (5 / 2)) & (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/2) - (6 / 4))) begin
////ipm_distributed_shiftregister_wrapper_v1_3 #(2, 2*(MAN_WIDTH+1) + 2*1 + (EXP_WIDTH+1) + W_USER) u_sr_2dly_sr_man_sign_big_user(
////    .din({big_man, big_sign, small_sign, big_exp, i_user}),
////    .clk(i_clk),      // input
////    .i_aclken(i_aclken),
////    .rst(~i_rst_n),      // input
////    .dout({big_man_stage2_dly1, big_sign_dly2, small_sign_dly2, big_exp_dly2, user_dly2})
////);
////end
////else if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/2) - (6 / 4)) begin
////ipm_distributed_shiftregister_wrapper_v1_3 #(1, 2*(MAN_WIDTH+1) + 2*1 + (EXP_WIDTH+1) + W_USER) u_sr_1dly_0_sr_man_sign_big_user(
////    .din({big_man, big_sign, small_sign, big_exp, i_user}),
////    .clk(i_clk),      // input
////    .i_aclken(i_aclken),
////    .rst(~i_rst_n),      // input
////    .dout({big_man_stage2_dly1, big_sign_dly2, small_sign_dly2, big_exp_dly2, user_dly2})
////);
////end
////else if ((LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (5 / 2))) begin
////ipm_distributed_shiftregister_wrapper_v1_3 #(1, 2*(MAN_WIDTH+1) + 2*1 + (EXP_WIDTH+1) + W_USER) u_sr_1dly_1_sr_man_sign_big_user(
////    .din({big_man, big_sign, small_sign, big_exp, i_user}),
////    .clk(i_clk),      // input
////    .i_aclken(i_aclken),
////    .rst(~i_rst_n),      // input
////    .dout({big_man_stage2_dly1, big_sign_dly2, small_sign_dly2, big_exp_dly2, user_dly2})
////);
////end
////else begin
////assign {big_man_stage2_dly1, big_sign_dly2, small_sign_dly2, big_exp_dly2, user_dly2} = {big_man, big_sign, small_sign, big_exp, i_user};
////end
////endgenerate
//
//ipm_distributed_shiftregister_wrapper_v1_3 #(2, 2*(MAN_WIDTH+1) + 2*1 + (EXP_WIDTH+1) + W_USER) u_sr_2dly_sr_man_sign_big_user(
//    .din({big_man, big_sign, small_sign, big_exp, i_user}),
//    .clk(i_clk),      // input
//    .i_aclken(i_aclken),
//    .rst(~i_rst_n),      // input
//    .dout({big_man_stage2_dly1, big_sign_dly2, small_sign_dly2, big_exp_dly2, user_dly2})
//);

////////-----------------------------











//// before the addition, transfer big_man and small_man into 2's complement, because the signs may be negative
//assign signed_big = ({2'b0, big_man_stage2_dly1}^{(2*(MAN_WIDTH+1)+1+1){big_sign_dly2}}) + big_sign_dly2;
//assign signed_small = ({3'b0, small_man_stage2_dly1}^{(2*(MAN_WIDTH+1)+1+1){small_sign_dly2}}) + small_sign_dly2;
//
//generate
//if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (7 / 2)) begin
//// pipeline stage 7
//ipsxe_floating_point_register_v1_0 #((2*(MAN_WIDTH+1)+1)+1 + (2*(MAN_WIDTH+1)+1)+1 + (EXP_WIDTH+1) + W_USER) u_reg_signed_sum(
//    .i_clk(i_clk),
//    .i_aclken(i_aclken),
//    .i_rst_n(i_rst_n),
//    .i_d({signed_big     , signed_small     , big_exp_dly2, user_dly2}),
//    .o_q({signed_big_dly1, signed_small_dly1, big_exp_dly3, user_dly3})
//);
//end
//else begin
//assign {signed_big_dly1, signed_small_dly1, big_exp_dly3, user_dly3} = {signed_big     , signed_small     , big_exp_dly2, user_dly2};
//end
//endgenerate
//
//// add big to small
//assign signed_sum = signed_big_dly1 + signed_small_dly1;

///////------------------------
wire    [(2*(MAN_WIDTH+1)+1):0]     signed_big_addend;
wire    [(2*(MAN_WIDTH+1)+1):0]     signed_small_addend;

wire    [(2*(MAN_WIDTH+1)+1):0]     signed_sum_s;
wire    [(2*(MAN_WIDTH+1)+1):0]     signed_sum_c;
wire     [(2*(MAN_WIDTH+1)+1):0]     signed_sum_s_dly1;
wire     [(2*(MAN_WIDTH+1)+1):0]     signed_sum_c_dly1;
wire                                 small_sign_dly3;

assign signed_big_addend = ({2'b0, big_man_stage2_dly1}^{(2*(MAN_WIDTH+1)+1+1){big_sign_dly2}});
assign signed_small_addend = ({3'b0, small_man_stage2_dly1}^{(2*(MAN_WIDTH+1)+1+1){small_sign_dly2}});

genvar i;
generate
	for(i=0;i<(2*(MAN_WIDTH+1)+1)+1;i=i+1)
    begin:signed_big_dly1_plus_signed_small_dly1
        if(i==0) begin
            ipsxe_floating_point_fa_1bit_v1_0 u_ipsxe_floating_point_fa_1bit_v1_0(signed_big_addend[0], signed_small_addend[0], big_sign_dly2, signed_sum_c[0], signed_sum_s[0]);
        end
        else begin
            ipsxe_floating_point_ha_1bit_v1_0 u_ipsxe_floating_point_ha_1bit_v1_0(signed_big_addend[i], signed_small_addend[i], signed_sum_c[i], signed_sum_s[i]);
        end
    end
endgenerate
generate
if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (7 / 2)) begin
    ipsxe_floating_point_register_v1_0 #((2*(MAN_WIDTH+1)+1)+1 + (2*(MAN_WIDTH+1)+1)+1 + (EXP_WIDTH+1) + W_USER + 1) u_reg_signed_big_dly1_plus_signed_small_dly1(
        .i_clk(i_clk),
        .i_aclken(i_aclken),
        .i_rst_n(i_rst_n),
        .i_d({signed_sum_c, signed_sum_s, big_exp_dly2, user_dly2, small_sign_dly2}),
        .o_q({signed_sum_c_dly1, signed_sum_s_dly1, big_exp_dly3, user_dly3, small_sign_dly3})
    );
//    ipm_distributed_shiftregister_wrapper_v1_3 #(1, (2*(MAN_WIDTH+1)+1)+1 + (2*(MAN_WIDTH+1)+1)+1 + (EXP_WIDTH+1) + W_USER + 1) u_reg_signed_big_dly1_plus_signed_small_dly1(
//        .din({signed_sum_c, signed_sum_s, big_exp_dly2, user_dly2, small_sign_dly2}),      // input [12:0]
//        .clk(i_clk),      // input
//        .i_aclken(i_aclken),
//        .rst(~i_rst_n),      // input
//        .dout({signed_sum_c_dly1, signed_sum_s_dly1, big_exp_dly3, user_dly3, small_sign_dly3})     // output [12:0]
//    );
end
else begin
    assign {signed_sum_c_dly1, signed_sum_s_dly1, big_exp_dly3, user_dly3, small_sign_dly3} = {signed_sum_c, signed_sum_s, big_exp_dly2, user_dly2, small_sign_dly2};
end
endgenerate

assign signed_sum = {signed_sum_c_dly1, small_sign_dly3} + signed_sum_s_dly1;

///////------------------------



generate
if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/8) - (8 / 16)) begin
// pipeline stage 8
ipsxe_floating_point_register_v1_0 #((2*(MAN_WIDTH+1)+1)+1 + (EXP_WIDTH+1) + W_USER) u_reg_signed_sum(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({signed_sum     , big_exp_dly3, user_dly3}),
    .o_q({signed_sum_dly1, big_exp_dly4, o_user   })
);
//    ipm_distributed_shiftregister_wrapper_v1_3 #(1, (2*(MAN_WIDTH+1)+1)+1 + (2*(MAN_WIDTH+1)+1)+1 + (EXP_WIDTH+1) + W_USER + 1) u_reg_signed_big_dly1_plus_signed_small_dly1(
//        .din({signed_sum     , big_exp_dly3, user_dly3}),      // input [12:0]
//        .clk(i_clk),      // input
//        .i_aclken(i_aclken),
//        .rst(~i_rst_n),      // input
//        .dout({signed_sum_dly1, big_exp_dly4, o_user   })     // output [12:0]
//    );

end
else begin
assign {signed_sum_dly1, big_exp_dly4, o_user   } = {signed_sum     , big_exp_dly3, user_dly3};
end
endgenerate

// the sign of the addition is the highest bit of signed_sum
assign sum_sign = signed_sum_dly1[(2*(MAN_WIDTH+1)+1)];
// find absolute value of product
assign abs_sum = (signed_sum_dly1[(2*(MAN_WIDTH+1)+1)-1:0]^{(2*(MAN_WIDTH+1)+1){sum_sign}}) + sum_sign;

// construct output
assign o_add_out[(2*(MAN_WIDTH+1)+1)+(EXP_WIDTH+1)] = sum_sign;
assign o_add_out[(2*(MAN_WIDTH+1)+1)+:(EXP_WIDTH+1)] = big_exp_dly4; // big_exp - 2*127 = real exp of o_add_out
assign o_add_out[(2*(MAN_WIDTH+1)):0] = abs_sum; // the binary point is between [46] and [45], for single precision






endmodule
