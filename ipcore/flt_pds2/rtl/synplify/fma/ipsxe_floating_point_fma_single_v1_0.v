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
// Filename: ipsxe_floating_point_fma_v1_0.v
// Function: This module implements the fused multiply-add operation (a*b+c),
//           where a*b is not rounded until it is added with c.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_fma_single_v1_0 #(parameter EXP_WIDTH = 8, MAN_WIDTH = 23, APM_USAGE = 0, LATENCY_CONFIG = 1) (
    input i_clk,
    input i_aclken,
    input i_rst_n,
    input i_abc_valid,
    input [(1+EXP_WIDTH+MAN_WIDTH)-1:0] i_a,
    input [(1+EXP_WIDTH+MAN_WIDTH)-1:0] i_b,
    input [(1+EXP_WIDTH+MAN_WIDTH)-1:0] i_c_without_op,
    input i_op,
    output [(1+EXP_WIDTH+MAN_WIDTH)-1:0] o_a_mul_b_plus_c,
    output o_a_mul_b_plus_c_valid,
    output o_invalid_op,
    output o_underflow,
    output o_overflow
);

localparam WIDTH = 1+EXP_WIDTH+MAN_WIDTH; // floating-point data width
localparam LEADING_0_CNT = $clog2(2*(MAN_WIDTH+1)+1); // for the module count_0s
localparam PIPE_STAGE_NUM_MAX = 12+2; // the last pipeline stage of this module

wire [WIDTH-1:0] a_not_denorm, b_not_denorm, c_not_denorm;
wire [2*(MAN_WIDTH+1) + (EXP_WIDTH+1):0] a_mul_b;
wire [(2*(MAN_WIDTH+1)+1)+(EXP_WIDTH+1):0] a_mul_b_plus_c_no_round;
wire [WIDTH-1:0] a_mul_b_plus_c_norm;
wire set_result_0, c_is_0, set_result_c, set_result_nan, set_result_pinf, set_result_ninf;
wire invalid_op, invalid_op_dly5, invalid_op_dly6;
wire [WIDTH-1:0] c;
wire [2*(MAN_WIDTH+1) + (EXP_WIDTH+1):0] a_mul_b_dly1;
wire [(2*(MAN_WIDTH+1)+1)+(EXP_WIDTH+1):0] a_mul_b_plus_c_no_round_dly1;
wire [4:0] set_result, set_result_dly5, set_result_dly6, set_result_dly9;
wire [WIDTH-1:0] c_not_denorm_dly1, c_not_denorm_dly2, c_not_denorm_dly3, c_not_denorm_dly5, c_not_denorm_dly6, c_not_denorm_dly9;
wire abc_valid_dly1, abc_valid_dly2, abc_valid_dly3, abc_valid_dly4, abc_valid_dly5, abc_valid_dly6;
wire sign_c, sign_c_dly1;
wire [EXP_WIDTH-1:0] exp_c_orig, exp_c_orig_dly1;
wire [EXP_WIDTH:0] exp_c, exp_c_dly1;
wire [MAN_WIDTH-1:0] man_c, man_c_dly1;
reg [(1+EXP_WIDTH+MAN_WIDTH)-1:0] no_outreg_o_a_mul_b_plus_c;
wire no_outreg_o_a_mul_b_plus_c_valid;
wire no_outreg_o_invalid_op;
wire no_outreg_o_underflow;
wire no_outreg_o_overflow;

// change the sign of the c input signal if the operator is "minus"
assign c = i_op ? {~i_c_without_op[WIDTH-1], i_c_without_op[WIDTH-2:0]} : i_c_without_op;

// determine whether input signals are denormalized numbers, if so, set them to zero
ipsxe_floating_point_denorm2zero_v1_0 #(EXP_WIDTH, MAN_WIDTH) u_denorm2zero(
    .i_a_norm_or_denorm(i_a),
    .i_b_norm_or_denorm(i_b),
    .i_c_norm_or_denorm(c),
    .o_a(a_not_denorm),
    .o_b(b_not_denorm),
    .o_c(c_not_denorm)
);
// determine whether input signals are special floating point numbers, such as NaN or Inf
// pipeline stages 1 to 4
ipsxe_floating_point_special_cases_v1_0 #(EXP_WIDTH, MAN_WIDTH, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX) u_special_cases(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_a(a_not_denorm),
    .i_b(b_not_denorm),
    .i_c(c_not_denorm),
    .o_set_result_0(set_result_0),
    .o_c_is_0(c_is_0),
    .o_set_result_c(set_result_c),
    .o_set_result_nan(set_result_nan),
    .o_set_result_pinf(set_result_pinf),
    .o_set_result_ninf(set_result_ninf),
    .o_invalid_op(invalid_op)
);
assign set_result = {set_result_0, set_result_c, set_result_nan, set_result_pinf, set_result_ninf};

// multiply the mantissa parts of a and b, but do not round
// pipeline stage 1 to 3
ipsxe_floating_point_multiplier_single_v1_0 #(EXP_WIDTH, MAN_WIDTH, APM_USAGE, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX) u_multiplier(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_a(a_not_denorm),
    .i_b(b_not_denorm),
    .o_a_mul_b(a_mul_b)
);

generate
if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (1 / 2)) begin
// pipeline stage 1
ipsxe_floating_point_register_v1_0 #(1 + WIDTH) u_reg_stage1(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({i_abc_valid,    c_not_denorm     }),
    .o_q({abc_valid_dly1, c_not_denorm_dly1})
);
end
else begin
assign {abc_valid_dly1, c_not_denorm_dly1} = {i_abc_valid,    c_not_denorm     };
end
endgenerate

generate
if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/2) - (2 / 4)) begin
// pipeline stage 2
ipsxe_floating_point_register_v1_0 #(1 + WIDTH) u_reg_stage2(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({abc_valid_dly1, c_not_denorm_dly1}),
    .o_q({abc_valid_dly2, c_not_denorm_dly2})
);
end
else begin
assign {abc_valid_dly2, c_not_denorm_dly2} = {abc_valid_dly1, c_not_denorm_dly1};
end
endgenerate

generate
if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (3 / 2)) begin
// pipeline stage 3
ipsxe_floating_point_register_v1_0 #(1 + WIDTH) u_reg_stage3(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({abc_valid_dly2, c_not_denorm_dly2}),
    .o_q({abc_valid_dly3, c_not_denorm_dly3})
);
end
else begin
assign {abc_valid_dly3, c_not_denorm_dly3} = {abc_valid_dly2, c_not_denorm_dly2};
end
endgenerate

// take sign of c
assign sign_c = c_not_denorm_dly3[WIDTH-1];
// take exponent of c
assign exp_c_orig = c_not_denorm_dly3[MAN_WIDTH+:EXP_WIDTH];
assign exp_c = c_not_denorm_dly3[MAN_WIDTH+:EXP_WIDTH] + {(EXP_WIDTH-1){1'b1}}; // exp_c - 2*127 = real exp of i_c, whose range is [-126, 127]. range of exp_c is [128, 381]
// take mantissa of c
assign man_c = c_not_denorm_dly3[MAN_WIDTH-1:0];

generate
if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/4) - (4 / 8)) begin
// pipeline stage 4
//ipsxe_floating_point_register_v1_0 #(1 + 1 + EXP_WIDTH+1 + MAN_WIDTH + EXP_WIDTH + 2*(MAN_WIDTH+1)+(EXP_WIDTH+1)+1) u_reg_stage4(
//    .i_clk(i_clk),
//    .i_aclken(i_aclken),
//    .i_rst_n(i_rst_n),
//    .i_d({abc_valid_dly3, sign_c     , exp_c     , man_c     , exp_c_orig     , a_mul_b     }),
//    .o_q({abc_valid_dly4, sign_c_dly1, exp_c_dly1, man_c_dly1, exp_c_orig_dly1, a_mul_b_dly1})
//);
ipm_distributed_shiftregister_wrapper_v1_3 #(1, 1 + 1 + EXP_WIDTH+1 + MAN_WIDTH + EXP_WIDTH + 2*(MAN_WIDTH+1)+(EXP_WIDTH+1)+1) u_reg_stage4(
    .din({abc_valid_dly3, sign_c     , exp_c     , man_c     , exp_c_orig     , a_mul_b     }),
    .clk(i_clk),      // input
    .i_aclken(i_aclken),
    .rst(~i_rst_n),      // input
    .dout({abc_valid_dly4, sign_c_dly1, exp_c_dly1, man_c_dly1, exp_c_orig_dly1, a_mul_b_dly1})
);
end
else begin
assign {abc_valid_dly4, sign_c_dly1, exp_c_dly1, man_c_dly1, exp_c_orig_dly1, a_mul_b_dly1} = {abc_valid_dly3, sign_c     , exp_c     , man_c     , exp_c_orig     , a_mul_b     };
end
endgenerate

// if c is not zero, then add c to the multiplication result of a and b
// pipeline stage 5 to 8
ipsxe_floating_point_adder_single_v1_0 #(EXP_WIDTH, MAN_WIDTH, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 1 + 5+WIDTH+1) u_adder(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_a_mul_b(a_mul_b_dly1),
    .i_sign_c(sign_c_dly1),
    .i_exp_c(exp_c_dly1),
    .i_man_c(man_c_dly1),
    .i_c_is_0(c_is_0),
    .i_user({invalid_op     , set_result     , {sign_c_dly1, exp_c_orig_dly1, man_c_dly1}, abc_valid_dly4}),
    .o_user({invalid_op_dly5, set_result_dly5, c_not_denorm_dly5                         , abc_valid_dly5}),
    .o_add_out(a_mul_b_plus_c_no_round)
);

generate
if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (9 / 2)) begin
// pipeline stage 9
//ipsxe_floating_point_register_v1_0 #((2*(MAN_WIDTH+1)+1)+(EXP_WIDTH+1)+1 + 1 + 5+WIDTH+1) u_reg_a_mul_b_plus_c_no_round(
//    .i_clk(i_clk),
//    .i_aclken(i_aclken),
//    .i_rst_n(i_rst_n),
//    .i_d({a_mul_b_plus_c_no_round     , invalid_op_dly5, set_result_dly5, c_not_denorm_dly5, abc_valid_dly5}),
//    .o_q({a_mul_b_plus_c_no_round_dly1, invalid_op_dly6, set_result_dly6, c_not_denorm_dly6, abc_valid_dly6})
//);
ipm_distributed_shiftregister_wrapper_v1_3 #(1, (2*(MAN_WIDTH+1)+1)+(EXP_WIDTH+1)+1 + 1 + 5+WIDTH+1) u_reg_a_mul_b_plus_c_no_round(
    .din({a_mul_b_plus_c_no_round     , invalid_op_dly5, set_result_dly5, c_not_denorm_dly5, abc_valid_dly5}),
    .clk(i_clk),      // input
    .i_aclken(i_aclken),
    .rst(~i_rst_n),      // input
    .dout({a_mul_b_plus_c_no_round_dly1, invalid_op_dly6, set_result_dly6, c_not_denorm_dly6, abc_valid_dly6})
);
end
else begin
assign {a_mul_b_plus_c_no_round_dly1, invalid_op_dly6, set_result_dly6, c_not_denorm_dly6, abc_valid_dly6} = {a_mul_b_plus_c_no_round     , invalid_op_dly5, set_result_dly5, c_not_denorm_dly5, abc_valid_dly5};
end
endgenerate

// round the addtion of c and a * b
// pipeline stage 10 to 12
ipsxe_floating_point_round_single_v1_0 #(EXP_WIDTH, MAN_WIDTH, LEADING_0_CNT, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX, 1 + 5+WIDTH+1) u_round(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_add_out(a_mul_b_plus_c_no_round_dly1),
    .i_user({invalid_op_dly6       , set_result_dly6, c_not_denorm_dly6, abc_valid_dly6                  }),
    .o_user({no_outreg_o_invalid_op, set_result_dly9, c_not_denorm_dly9, no_outreg_o_a_mul_b_plus_c_valid}),
    .o_rounded_float(a_mul_b_plus_c_norm),
    .o_underflow(no_outreg_o_underflow),
    .o_overflow(no_outreg_o_overflow)
);

// set the result to special numbers in special cases
always @ (*) begin: blk_o_a_mul_b_plus_c
    case(set_result_dly9)
        5'b10000: no_outreg_o_a_mul_b_plus_c = 0; // if set_result_0 == 1, set the result to zero
        5'b01000: no_outreg_o_a_mul_b_plus_c = c_not_denorm_dly9; // if set_result_c == 1, set the result to c
        5'b00100: no_outreg_o_a_mul_b_plus_c = {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // if set_result_nan == 1, set the result to NaN
        5'b00010: no_outreg_o_a_mul_b_plus_c = {1'b0, {EXP_WIDTH{1'b1}}, {MAN_WIDTH{1'b0}}}; // if set_result_pinf == 1, set the result to +inf
        5'b00001: no_outreg_o_a_mul_b_plus_c = {1'b1, {EXP_WIDTH{1'b1}}, {MAN_WIDTH{1'b0}}}; // if set_result_ninf == 1, set the result to -inf
        default: // if non of the above conditions are true
            if(no_outreg_o_overflow) // set it to +inf or -inf, according to the sign of a * b + c
                no_outreg_o_a_mul_b_plus_c = {a_mul_b_plus_c_norm[WIDTH-1], {EXP_WIDTH{1'b1}}, {MAN_WIDTH{1'b0}}};
            else if(no_outreg_o_underflow) // set it to 0
                no_outreg_o_a_mul_b_plus_c = 0;
            else // set it to the output of the u_round module
                no_outreg_o_a_mul_b_plus_c = a_mul_b_plus_c_norm;
    endcase
end


generate
if (LATENCY_CONFIG < PIPE_STAGE_NUM_MAX + 1) begin
assign {o_a_mul_b_plus_c, o_a_mul_b_plus_c_valid, o_invalid_op, o_underflow, o_overflow} = {no_outreg_o_a_mul_b_plus_c, no_outreg_o_a_mul_b_plus_c_valid, no_outreg_o_invalid_op, no_outreg_o_underflow, no_outreg_o_overflow};
end

else begin // LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX + 1
wire [(4*1 + WIDTH)-1:0] out_delay;
// pipeline stage PIPE_STAGE_NUM_MAX + 1 to ...
ipm_distributed_shiftregister_wrapper_v1_3 #((LATENCY_CONFIG - PIPE_STAGE_NUM_MAX), 4*1 + WIDTH) u_shift_register (
    .din({no_outreg_o_a_mul_b_plus_c, no_outreg_o_a_mul_b_plus_c_valid, no_outreg_o_invalid_op, no_outreg_o_underflow, no_outreg_o_overflow}),      // input [12:0]
    .clk(i_clk),      // input
    .i_aclken(i_aclken),
    .rst(~i_rst_n),      // input
    .dout(out_delay)     // output [12:0]
);
assign {o_a_mul_b_plus_c, o_a_mul_b_plus_c_valid, o_invalid_op, o_underflow, o_overflow} = out_delay;
end
endgenerate

endmodule
