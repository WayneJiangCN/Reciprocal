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
// Filename: ipsxe_floating_point_sqrt_v1_0.v
// Function: This module calculates the square-root of a floating-point number.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_sqrt_v1_0 #(parameter EXPONENT_SIZE = 8, MANTISSA_SIZE = 23, RNE = 5, LATENCY_CONFIG = 1) (
    input i_clk,
    input i_aclken,
    input i_rst_n,
    input i_valid,
    input [(1+EXPONENT_SIZE+MANTISSA_SIZE)-1:0] i_fp,
    output [(1+EXPONENT_SIZE+MANTISSA_SIZE)-1:0] o_result,
    output o_valid,
    output o_invalid_op
);

localparam WIDTH = 1+EXPONENT_SIZE+MANTISSA_SIZE;
localparam BINARY_SIZE = (1 + MANTISSA_SIZE + RNE) * 2; // why "1 +"? because 1.mantissa; why "+ RNE"? in order to round to nearest even and reach 0.5ulp.
localparam PIPE_STAGE_NUM_MAX = (BINARY_SIZE/2) + 3; // the last pipeline stage of the ipsxe_floating_point_sqrt_v1_0 module
localparam LATENCY_CONFIG_SHIFT_REG = (LATENCY_CONFIG >= (BINARY_SIZE/2) + 2) ? (BINARY_SIZE/2) + 2 : LATENCY_CONFIG;

wire sign, sign_dly, sign_dly_dly;
wire [EXPONENT_SIZE-1:0] exponent, exponent_dly, sqrt_exp, sqrt_exp_dly;
wire [MANTISSA_SIZE-1:0] mantissa, mantissa_dly, sqrt_man;
wire [BINARY_SIZE-1:0] bin_man, bin_man_dly;
wire [1:0] state_special, state_special_dly;
wire is_input_stable_dly, is_input_stable_dly_dly;
wire [WIDTH-1:0] in;
wire in_is_neg, in_is_neg_dly, in_is_neg_dly_dly;
reg [(1+EXPONENT_SIZE+MANTISSA_SIZE)-1:0] no_outreg_o_result;

// determine whether i_fp is a denormalized number, if so, set it to zero
assign in[WIDTH-1:MANTISSA_SIZE] = i_fp[WIDTH-1:MANTISSA_SIZE];
assign in[MANTISSA_SIZE-1:0] = (i_fp[WIDTH-2-:EXPONENT_SIZE] == {EXPONENT_SIZE{1'b0}}) ? {MANTISSA_SIZE{1'b0}} : i_fp[MANTISSA_SIZE-1:0];

// determine whether i_fp is a negative number
assign in_is_neg = i_fp[WIDTH-1] && (i_fp[WIDTH-2-:EXPONENT_SIZE] != {EXPONENT_SIZE{1'b1}});

// split input data into sign, exp and man
assign sign = i_valid ? in[WIDTH-1] : 1'b1; // sign
assign exponent = i_valid ? in[MANTISSA_SIZE+:EXPONENT_SIZE] : {EXPONENT_SIZE{1'b0}}; // exp
assign mantissa = i_valid ? in[MANTISSA_SIZE-1:0] : {MANTISSA_SIZE{1'b0}}; // man

generate
// if (1 % 2 != 0) // already satisfied
if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (1 / 2)) begin
// pipeline stage 1
ipsxe_floating_point_register_v1_0 #(2*1+WIDTH) u_reg_split(
    .i_clk(i_clk), // input clock
    .i_aclken(i_aclken), // input clock enable
    .i_rst_n(i_rst_n), // input reset
    .i_d({in_is_neg    , i_valid            , sign    , exponent    , mantissa    }), // input data
    .o_q({in_is_neg_dly, is_input_stable_dly, sign_dly, exponent_dly, mantissa_dly}) // output data
);
end else begin
assign {in_is_neg_dly, is_input_stable_dly, sign_dly, exponent_dly, mantissa_dly} = {in_is_neg    , i_valid            , sign    , exponent    , mantissa    };
end
endgenerate

// determine whether i_fp is a special floating point number, such as NaN or Inf
ipsxe_floating_point_special_cases_sqrt_v1_0 #(WIDTH, EXPONENT_SIZE, MANTISSA_SIZE) u_special_cases(
    .i_sign(sign_dly),
    .i_exponent(exponent_dly),
    .i_mantissa(mantissa_dly),
    .o_state_special(state_special)
);

// calculate the square-root of exp
ipsxe_floating_point_exp_sqrt_v1_0 #(EXPONENT_SIZE) u_exp_sqrt(
    .i_exponent(exponent_dly),
    .o_out(sqrt_exp)
);

// left shift mantissa
ipsxe_floating_point_man2bin_v1_0 #(MANTISSA_SIZE, BINARY_SIZE) u_man2bin (
    .i_is_exp_odd(exponent_dly[0]),
    .i_man(mantissa_dly),
    .o_bin(bin_man)
);

generate
// if (2 % 2 != 0) // not satisfied
// else if (2 % 4 != 0) // satisfied
if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/2)     - (2 / 4)) begin
// pipeline stage 2
ipsxe_floating_point_register_v1_0 #(2+MANTISSA_SIZE) u_reg_bin_man(
    .i_clk(i_clk), // input clock
    .i_aclken(i_aclken), // input clock enable
    .i_rst_n(i_rst_n), // input reset
    .i_d(bin_man[BINARY_SIZE-1-:(2+MANTISSA_SIZE)]), // input data
    .o_q(bin_man_dly[BINARY_SIZE-1-:(2+MANTISSA_SIZE)]) // output data
);
end else begin
assign bin_man_dly[BINARY_SIZE-1-:(2+MANTISSA_SIZE)] = bin_man[BINARY_SIZE-1-:(2+MANTISSA_SIZE)];
end
endgenerate

assign bin_man_dly[BINARY_SIZE-1-(2+MANTISSA_SIZE):0] = {(BINARY_SIZE-(2+MANTISSA_SIZE)){1'b0}};

// calculate the square-root of mantissa
// pipeline stage 3 to (BINARY_SIZE/2) + 2
ipsxe_floating_point_sqrt_man_v1_0 #(BINARY_SIZE, MANTISSA_SIZE, RNE, LATENCY_CONFIG, PIPE_STAGE_NUM_MAX) u_sqrt_man(
    .i_clk(i_clk), // input clock
    .i_aclken(i_aclken), // input clock enable
    .i_rst_n(i_rst_n), // input reset
    .i_man(bin_man_dly),
    .o_sqrt_man(sqrt_man)
);

// pipeline stage 2 to (BINARY_SIZE/2) + 3
ipm_distributed_shiftregister_wrapper_v1_3 #(LATENCY_CONFIG_SHIFT_REG, EXPONENT_SIZE+2+3*1) u_shift_register (
    .din({state_special, sqrt_exp, sign_dly, is_input_stable_dly, in_is_neg_dly}),      // input [12:0]
    .clk(i_clk),      // input
    .i_aclken(i_aclken),
    .rst(~i_rst_n),      // input
    .dout({state_special_dly, sqrt_exp_dly, sign_dly_dly, is_input_stable_dly_dly, in_is_neg_dly_dly})     // output [12:0]
);

// set the result to special numbers in special cases
always @(*) begin: blk_o_result
    // if a is NaN or negative return NaN
    if (state_special_dly == 2'd0) begin
        no_outreg_o_result[WIDTH-1] = 1'b0; // sign
        no_outreg_o_result[MANTISSA_SIZE+:EXPONENT_SIZE] = {EXPONENT_SIZE{1'b1}}; // exponent
        no_outreg_o_result[MANTISSA_SIZE-1] = 1'b1; // mantissa
        no_outreg_o_result[MANTISSA_SIZE-2:0] = {(MANTISSA_SIZE-1){1'b0}}; // mantissa
    end
    // if a is inf return inf
    else if (state_special_dly == 2'd1) begin
        no_outreg_o_result[WIDTH-1] = sign_dly_dly; // sign
        no_outreg_o_result[MANTISSA_SIZE+:EXPONENT_SIZE] = {EXPONENT_SIZE{1'b1}}; // exponent
        no_outreg_o_result[MANTISSA_SIZE-1:0] = {MANTISSA_SIZE{1'b0}}; // mantissa
    end
    // if a is zero return zero
    else if (state_special_dly == 2'd2) begin
        no_outreg_o_result[WIDTH-1] = sign_dly_dly; // sign
        no_outreg_o_result[MANTISSA_SIZE+:EXPONENT_SIZE] = {EXPONENT_SIZE{1'b0}}; // exponent
        no_outreg_o_result[MANTISSA_SIZE-1:0] = {MANTISSA_SIZE{1'b0}}; // mantissa
    end
    // denormalised and normalized Number
    else begin
        no_outreg_o_result = {sign_dly_dly, sqrt_exp_dly, sqrt_man};
    end
end

assign {o_valid, o_invalid_op, o_result} = {is_input_stable_dly_dly, in_is_neg_dly_dly, no_outreg_o_result};

endmodule