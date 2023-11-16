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
// Filename: ipsxe_floating_point_round_v1_0.v
// Function: This module rounds a*b+c.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_round_single_v1_0 #(parameter EXP_WIDTH = 8, MAN_WIDTH = 23, LEADING_0_CNT = 6, LATENCY_CONFIG = 1, PIPE_STAGE_NUM_MAX = 1, W_USER = 1) (
    input i_clk,
    input i_aclken,
    input i_rst_n,
    input [(2*(MAN_WIDTH+1)+1)+(EXP_WIDTH+1):0] i_add_out,
    input [W_USER-1:0] i_user,
    output [W_USER-1:0] o_user,
    output [(1+EXP_WIDTH+MAN_WIDTH)-1:0] o_rounded_float,
    output o_underflow,
    output o_overflow
);

wire [LEADING_0_CNT-1:0] add_out_leading_0s;
wire [(2*(MAN_WIDTH+1)+1)+(EXP_WIDTH+1):0] add_out_dly1;
wire [LEADING_0_CNT-1:0] add_out_leading_0s_dly1;
wire [(2*(MAN_WIDTH+1)):0] add_out_man_lsh, add_out_man_lsh_dly1;
wire [EXP_WIDTH:0] add_out_exp_lsh, add_out_exp_lsh_dly1;
wire [EXP_WIDTH-1:0] add_out_exp_lsh_round_minus_127;
wire i_add_out_is_0, i_add_out_is_0_dly1, i_add_out_is_0_dly2;
wire add_out_dly1_msb, add_out_dly1_msb_dly1, add_out_dly1_msb_dly2;
wire [W_USER-1:0] user_dly1, user_dly2;

// count the number of the leading zero-bits of i_add_out[(2*(MAN_WIDTH+1)):0], which is the mantissa part of i_add_out
ipsxe_floating_point_count_0s_single_v1_0 #(MAN_WIDTH, LEADING_0_CNT) u_count_0s(i_clk, i_aclken, i_rst_n, i_add_out[(2*(MAN_WIDTH+1)):0], add_out_leading_0s);

//generate
//if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/2) - (10 / 4)) begin
//// pipeline stage 10
//ipsxe_floating_point_register_v1_0 #((2*(MAN_WIDTH+1)+1)+(EXP_WIDTH+1)+1 + LEADING_0_CNT + W_USER) u_reg_count_0s(
//    .i_clk(i_clk),
//    .i_aclken(i_aclken),
//    .i_rst_n(i_rst_n),
//    .i_d({i_add_out   , add_out_leading_0s     , i_user}),
//    .o_q({add_out_dly1, add_out_leading_0s_dly1, user_dly1}));
//end
//else begin
//assign {add_out_dly1, add_out_leading_0s_dly1, user_dly1} = {i_add_out   , add_out_leading_0s     , i_user};
//end
//endgenerate



////+++++++add 2 registers to meet with the timing of add_out_leading_0s_dly1.
wire [(2*(MAN_WIDTH+1)+1)+(EXP_WIDTH+1):0] add_out_dly1_temp1;
wire [(2*(MAN_WIDTH+1)+1)+(EXP_WIDTH+1):0] add_out_dly1_temp2;
wire [W_USER-1:0]                           i_user_temp1;
wire [W_USER-1:0]                           i_user_temp2;

ipsxe_floating_point_register_v1_0 #(W_USER) u_reg_i_user0 (i_clk, i_aclken, i_rst_n, i_user      , i_user_temp1);
ipsxe_floating_point_register_v1_0 #(W_USER) u_reg_i_user1 (i_clk, i_aclken, i_rst_n, i_user_temp1, i_user_temp2);
generate
if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/2) - (10 / 4)) begin
// pipeline stage 10
//ipsxe_floating_point_register_v1_0 #((2*(MAN_WIDTH+1)+1)+(EXP_WIDTH+1)+1 + LEADING_0_CNT + W_USER) u_reg_count_0s(
//    .i_clk(i_clk),
//    .i_aclken(i_aclken),
//    .i_rst_n(i_rst_n),
//    .i_d({i_add_out   , add_out_leading_0s     , i_user_temp2}),
//    .o_q({add_out_dly1_temp1, add_out_leading_0s_dly1, user_dly1}));
ipm_distributed_shiftregister_wrapper_v1_3 #(1, (2*(MAN_WIDTH+1)+1)+(EXP_WIDTH+1)+1 + LEADING_0_CNT + W_USER) u_reg_count_0s(
    .din({i_add_out   , add_out_leading_0s     , i_user_temp2}),
    .clk(i_clk),      // input
    .i_aclken(i_aclken),
    .rst(~i_rst_n),      // input
    .dout({add_out_dly1_temp1, add_out_leading_0s_dly1, user_dly1})
);
end
else begin
assign {add_out_dly1_temp1, add_out_leading_0s_dly1, user_dly1} = {i_add_out   , add_out_leading_0s     , i_user_temp2};
end
endgenerate
ipsxe_floating_point_register_v1_0 #((2*(MAN_WIDTH+1)+1)+(EXP_WIDTH+1)+1) u_reg_add_out_dly1_temp1 (i_clk, i_aclken, i_rst_n, add_out_dly1_temp1, add_out_dly1_temp2);
ipsxe_floating_point_register_v1_0 #((2*(MAN_WIDTH+1)+1)+(EXP_WIDTH+1)+1) u_reg_add_out_dly1_temp2 (i_clk, i_aclken, i_rst_n, add_out_dly1_temp2, add_out_dly1);
////++++






// remove the leading zeros and the first bit "1", to normalize
// add_out_man_lsh = add_out_dly1 << (add_out_leading_0s_dly1 + 1)
assign add_out_man_lsh[(2*(MAN_WIDTH+1)):1] = add_out_dly1[(2*(MAN_WIDTH+1))-1:0] << add_out_leading_0s_dly1;
assign add_out_man_lsh[0] = 0;
// exponential changes according to the shifting bits of the mantissa
// for single precision, previously the binary point is between [46] and [45], 2-bit away from the highest [47] bit
// but now the binary point moves to the left of the [47] bit, so there is a "+ 2" in the following expression
assign add_out_exp_lsh = add_out_dly1[(2*(MAN_WIDTH+1)+1)+:(EXP_WIDTH+1)] + (2 - add_out_leading_0s_dly1);

assign i_add_out_is_0 = (add_out_leading_0s_dly1 == 2*(MAN_WIDTH+1)+1);
assign add_out_dly1_msb = add_out_dly1[(2*(MAN_WIDTH+1)+1)+(EXP_WIDTH+1)];

generate
if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (11 / 2)) begin
// pipeline stage 11
//ipsxe_floating_point_register_v1_0 #(1 + 1 + (2*(MAN_WIDTH+1)) + EXP_WIDTH+1 + W_USER) u_reg_add_out_1bit_dly1_lsh(
//    .i_clk(i_clk),
//    .i_aclken(i_aclken),
//    .i_rst_n(i_rst_n),
//    .i_d({i_add_out_is_0     , add_out_dly1_msb     , add_out_man_lsh[(2*(MAN_WIDTH+1)):1]     , add_out_exp_lsh     , user_dly1}),
//    .o_q({i_add_out_is_0_dly1, add_out_dly1_msb_dly1, add_out_man_lsh_dly1[(2*(MAN_WIDTH+1)):1], add_out_exp_lsh_dly1, user_dly2}));
ipm_distributed_shiftregister_wrapper_v1_3 #(1, (2*(MAN_WIDTH+1)+1)+(EXP_WIDTH+1)+1 + LEADING_0_CNT + W_USER) u_reg_add_out_1bit_dly1_lsh(
    .din({i_add_out_is_0     , add_out_dly1_msb     , add_out_man_lsh[(2*(MAN_WIDTH+1)):1]     , add_out_exp_lsh     , user_dly1}),
    .clk(i_clk),      // input
    .i_aclken(i_aclken),
    .rst(~i_rst_n),      // input
    .dout({i_add_out_is_0_dly1, add_out_dly1_msb_dly1, add_out_man_lsh_dly1[(2*(MAN_WIDTH+1)):1], add_out_exp_lsh_dly1, user_dly2})
);
end
else begin
assign {i_add_out_is_0_dly1, add_out_dly1_msb_dly1, add_out_man_lsh_dly1[(2*(MAN_WIDTH+1)):1], add_out_exp_lsh_dly1, user_dly2} = {i_add_out_is_0     , add_out_dly1_msb     , add_out_man_lsh[(2*(MAN_WIDTH+1)):1]     , add_out_exp_lsh     , user_dly1};
end
endgenerate
assign add_out_man_lsh_dly1[0] = 0;

// add_out_man_lsh_dly1 round to nearest even: round off the lowest MAN_WIDTH + 3 bits
reg [MAN_WIDTH-1:0] add_out_man_lsh_round;
wire [MAN_WIDTH-1:0] add_out_man_lsh_round_dly1;
reg [EXP_WIDTH:0] add_out_exp_lsh_round;
wire [EXP_WIDTH:0] add_out_exp_lsh_round_dly1;
always @(*) begin: blk_add_out_lsh_round
    if(~add_out_man_lsh_dly1[(2*(MAN_WIDTH+1))-MAN_WIDTH] ||
        (add_out_man_lsh_dly1[(2*(MAN_WIDTH+1))-MAN_WIDTH] &&
            ~(|add_out_man_lsh_dly1[(2*(MAN_WIDTH+1))-MAN_WIDTH-1:0]) &&
            ~add_out_man_lsh_dly1[(2*(MAN_WIDTH+1))-MAN_WIDTH+1])) begin // no 1-bit carry
        add_out_man_lsh_round = add_out_man_lsh_dly1[(2*(MAN_WIDTH+1))-:MAN_WIDTH];
        add_out_exp_lsh_round = add_out_exp_lsh_dly1;
    end else begin // carry bit = 1. in case that add_out_man_lsh_dly1 overflows,
        // we concatinate add_out_exp_lsh_dly1 and add_out_man_lsh_dly1[2*MAN_WIDTH-:MAN_WIDTH], to make the overflow bit added to add_out_exp_lsh_dly1
        {add_out_exp_lsh_round, add_out_man_lsh_round} = {add_out_exp_lsh_dly1, add_out_man_lsh_dly1[(2*(MAN_WIDTH+1))-:MAN_WIDTH]} + 1;
    end
end

generate
if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/4) - (12 / 8)) begin
// pipeline stage 12
//ipsxe_floating_point_register_v1_0 #(1 + 1 + MAN_WIDTH + EXP_WIDTH+1 + W_USER) u_reg_add_out_1bit_dly2(
//    .i_clk(i_clk),
//    .i_aclken(i_aclken),
//    .i_rst_n(i_rst_n),
//    .i_d({i_add_out_is_0_dly1, add_out_dly1_msb_dly1, add_out_man_lsh_round     , add_out_exp_lsh_round     , user_dly2}),
//    .o_q({i_add_out_is_0_dly2, add_out_dly1_msb_dly2, add_out_man_lsh_round_dly1, add_out_exp_lsh_round_dly1, o_user   }));
ipm_distributed_shiftregister_wrapper_v1_3 #(1, 1 + 1 + MAN_WIDTH + EXP_WIDTH+1 + W_USER) u_reg_add_out_1bit_dly2(
    .din({i_add_out_is_0_dly1, add_out_dly1_msb_dly1, add_out_man_lsh_round     , add_out_exp_lsh_round     , user_dly2}),
    .clk(i_clk),      // input
    .i_aclken(i_aclken),
    .rst(~i_rst_n),      // input
    .dout({i_add_out_is_0_dly2, add_out_dly1_msb_dly2, add_out_man_lsh_round_dly1, add_out_exp_lsh_round_dly1, o_user   })
);
end
else begin
assign {i_add_out_is_0_dly2, add_out_dly1_msb_dly2, add_out_man_lsh_round_dly1, add_out_exp_lsh_round_dly1, o_user   } = {i_add_out_is_0_dly1, add_out_dly1_msb_dly1, add_out_man_lsh_round     , add_out_exp_lsh_round     , user_dly2};
end
endgenerate

// for example, for single precision, if add_out_exp_lsh_round - 127 < 1, then the result underflows
assign o_underflow = add_out_exp_lsh_round_dly1 < (2*{(EXP_WIDTH-1){1'b1}} - ({(EXP_WIDTH-1){1'b1}} - 1));
// for example, for single precision, if add_out_exp_lsh_round - 127 > 254, then the result overflows
assign o_overflow = add_out_exp_lsh_round_dly1 > (2*{(EXP_WIDTH-1){1'b1}} + {(EXP_WIDTH-1){1'b1}});

assign add_out_exp_lsh_round_minus_127 = add_out_exp_lsh_round_dly1 - {(EXP_WIDTH-1){1'b1}};

// if i_add_out is zero, then the rounded result is also zero
// otherwize it is the concatination of the above calculated values
assign o_rounded_float = i_add_out_is_0_dly2 ? 0 : {add_out_dly1_msb_dly2, add_out_exp_lsh_round_minus_127, add_out_man_lsh_round_dly1};

endmodule
