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
// Filename: ipsxe_floating_point_fp_15ops_v1_0.v
// Function: This module instantiates all 15 floating-point operations.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_fp_15ops_v1_0 #( parameter
    TDATA_WIDTH = 0,
    TDATA_OUT_WIDTH = 0,
    OP_SEL = 0,
    WIDTH = 0,
    OUT_WIDTH = 0,
    EXP_WIDTH = 0,
    MAN_WIDTH = 0,
    FRAC_WIDTH = 0,
    ACCUM_MSB = 0,
    ACCUM_LSB = 0,
    ACCUM_INPUT_MSB = 0,
    INPUT_FIXED_INT_BIT = 0,
    INPUT_FIXED_FRAC_BIT = 0,
    RESULT_FIXED_INT_BIT = 0,
    RESULT_FIXED_FRAC_BIT = 0,
    INT_TYPE = 0,
    FLOAT_OUT_EXP = 0,
    FLOAT_OUT_FRAC = 0,
    PIPE_STAGE_NUM = 0,
    RNE = 0,
    RNE1 = 0,
    RNE2 = 0,
    RNE_SQRT = 0,
    RNE_ADDSUB = 6,
    TLAST_BEHAVIOR = 0,
    APM_USAGE = 0,
    PRECISION_INPUT = 0,
    PREC_INPUT = 0,
    LATENCY_CONFIG = 1
) (
    input i_aclk,
    input i_aclken,
    input i_areset_n,

    input [TDATA_WIDTH-1:0] i_axi4s_a_tdata,
    input [TDATA_WIDTH-1:0] i_axi4s_b_tdata,
    input [TDATA_WIDTH-1:0] i_axi4s_c_tdata,
    input [2:0] i_axi4s_operation_tdata,
    input i_axi4s_a_tlast,
    input i_axi4s_b_tlast,
    input i_axi4s_c_tlast,
    input i_axi4s_operation_tlast,
    input i_axi4s_or_abcoperation_tvalid,

    output [TDATA_OUT_WIDTH-1:0] o_axi4s_result_tdata,
    output o_axi4s_result_tlast,
    output o_axi4s_result_tvalid,

    output o_accum_overflow,
    output o_accum_input_overflow,
    output o_divide_by_zero,
    output o_invalid_op,
    output o_underflow,
    output o_overflow
);

wire o_axi4s_result_tlast_accum;
wire i_axi4s_abcoperation_tlast;

ipsxe_floating_point_tlast_v1_0 #(TLAST_BEHAVIOR) u_ipsxe_floating_point_tlast_v1_0 (
    .i_axi4s_a_tlast(i_axi4s_a_tlast),
    .i_axi4s_b_tlast(i_axi4s_b_tlast),
    .i_axi4s_c_tlast(i_axi4s_c_tlast),
    .i_axi4s_operation_tlast(i_axi4s_operation_tlast),
    .o_axi4s_abcoperation_tlast(i_axi4s_abcoperation_tlast)
);

generate
if (OP_SEL == 0) begin
    assign o_axi4s_result_tlast = i_axi4s_a_tlast;
end
else if (OP_SEL == 1) begin
    assign o_axi4s_result_tlast = o_axi4s_result_tlast_accum;
end
else begin
    if (LATENCY_CONFIG == 0) begin
        assign o_axi4s_result_tlast = i_axi4s_abcoperation_tlast;
    end else begin
        wire [PIPE_STAGE_NUM-1:0] i_axi4s_abcoperation_tlast_delay;
        assign o_axi4s_result_tlast = i_axi4s_abcoperation_tlast_delay[PIPE_STAGE_NUM-1];
        if (LATENCY_CONFIG == 1) begin
            ipsxe_floating_point_register_v1_0 #(PIPE_STAGE_NUM) u_reg_i_axi4s_abcoperation_tlast_delay(
                .i_clk(i_aclk),
                .i_aclken(i_aclken),
                .i_rst_n(i_areset_n),
                .i_d(i_axi4s_abcoperation_tlast),
                .o_q(i_axi4s_abcoperation_tlast_delay)
            );
        end
        else begin
            ipsxe_floating_point_register_v1_0 #(PIPE_STAGE_NUM) u_reg_i_axi4s_abcoperation_tlast_delay(
                .i_clk(i_aclk),
                .i_aclken(i_aclken),
                .i_rst_n(i_areset_n),
                .i_d({i_axi4s_abcoperation_tlast_delay[PIPE_STAGE_NUM-2:0], i_axi4s_abcoperation_tlast}),
                .o_q(i_axi4s_abcoperation_tlast_delay)
            );
        end
    end
end
endgenerate

generate

// ABSOLUTE

if (OP_SEL == 0) begin
ipsxe_floating_point_abs_v1_0 #(WIDTH) u_abs (
    .i_axi4s_a_tdata(i_axi4s_a_tdata[WIDTH-1:0]),
    .i_axi4s_a_tvalid(i_axi4s_or_abcoperation_tvalid),
    .o_axi4s_result_tdata(o_axi4s_result_tdata[OUT_WIDTH-1:0]),
    .o_axi4s_result_tvalid(o_axi4s_result_tvalid)
);
assign o_accum_overflow = 1'b0;
assign o_accum_input_overflow = 1'b0;
assign o_divide_by_zero = 1'b0;
assign o_invalid_op = 1'b0;
assign o_underflow = 1'b0;
assign o_overflow = 1'b0;
end

// ACCUMULATOR

else if (OP_SEL == 1) begin
ipsxe_floating_point_accum_v1_0 #(EXP_WIDTH, MAN_WIDTH, ACCUM_MSB, ACCUM_LSB, ACCUM_INPUT_MSB, APM_USAGE) u_accum (
    .i_clk(i_aclk),
    .i_aclken(i_aclken),
    .i_rst_n(i_areset_n),
    .i_axis_a_tdata(i_axi4s_a_tdata[WIDTH-1:0]),
    .i_axis_operation_tdata(i_axi4s_operation_tdata[0]),
    .i_axis_a_tvalid(i_axi4s_or_abcoperation_tvalid),
    .i_axis_a_tlast(i_axi4s_a_tlast),
    .o_axis_result_tdata(o_axi4s_result_tdata[OUT_WIDTH-1:0]),
    .o_axis_result_tvalid(o_axi4s_result_tvalid),
    .o_axis_result_tlast(o_axi4s_result_tlast_accum),
    .o_invalid_op(o_invalid_op),
    .o_accum_input_overflow(o_accum_input_overflow),
    .o_accum_overflow(o_accum_overflow)
);
assign o_divide_by_zero = 1'b0;
assign o_underflow = 1'b0;
assign o_overflow = 1'b0;
end

// ADD SUBTRACT

else if (OP_SEL == 2) begin
ipsxe_floating_point_addsub_v1_0 #(EXP_WIDTH, FRAC_WIDTH, APM_USAGE, RNE_ADDSUB, LATENCY_CONFIG) u_addsub (
    .i_axis_a_tdata(i_axi4s_a_tdata[WIDTH-1:0]),
    .i_axis_b_tdata(i_axi4s_b_tdata[WIDTH-1:0]),
    .i_axis_aboperation_tvalid(i_axi4s_or_abcoperation_tvalid),
    .i_aclk(i_aclk),
    .i_aclken(i_aclken),
    .i_rst_n(i_areset_n),
    .i_axis_operation_tdata(i_axi4s_operation_tdata[0]),
    .o_axis_result_tdata(o_axi4s_result_tdata[OUT_WIDTH-1:0]),
    .o_axis_result_tvalid(o_axi4s_result_tvalid),
    .o_overflow(o_overflow),
    .o_underflow(o_underflow),
    .o_invalid_op(o_invalid_op)
);
assign o_accum_overflow = 1'b0;
assign o_accum_input_overflow = 1'b0;
assign o_divide_by_zero = 1'b0;
end

// COMPARE

else if (OP_SEL == 3) begin
ipsxe_floating_point_comp_v1_0 #(EXP_WIDTH, MAN_WIDTH, LATENCY_CONFIG) u_comp (
    .i_clk(i_aclk),
    .i_aclken(i_aclken),
    .i_areset_n(i_areset_n),
    .i_axis_or_ab_tvalid(i_axi4s_or_abcoperation_tvalid),
    .i_axis_a_tdata(i_axi4s_a_tdata[WIDTH-1:0]),
    .i_axis_b_tdata(i_axi4s_b_tdata[WIDTH-1:0]),
    .i_axis_operation_tdata(i_axi4s_operation_tdata),
    .o_axis_result_tvalid_when_tready(o_axi4s_result_tvalid),
    .o_axis_result_tdata(o_axi4s_result_tdata[8-1:0])
);
assign o_accum_overflow = 1'b0;
assign o_accum_input_overflow = 1'b0;
assign o_divide_by_zero = 1'b0;
assign o_invalid_op = 1'b0;
assign o_underflow = 1'b0;
assign o_overflow = 1'b0;
end

// DIVIDE

else if (OP_SEL == 4) begin
ipsxe_floating_point_div_inv_v1_0 #(WIDTH, WIDTH, WIDTH, EXP_WIDTH, MAN_WIDTH, LATENCY_CONFIG) u_div (
    .i_clk(i_aclk),
    .i_aclken(i_aclken),
    .i_areset_n(i_areset_n),
    .i_opa_in(i_axi4s_a_tdata[WIDTH-1:0]),
    .i_opb_in(i_axi4s_b_tdata[WIDTH-1:0]),
    .i_a_tvalid(i_axi4s_or_abcoperation_tvalid),
    .o_resul(o_axi4s_result_tdata[OUT_WIDTH-1:0]),
    .o_overflow(o_overflow),
    .o_underflow(o_underflow),
    .o_divide_by_zero(o_divide_by_zero),
    .o_invalid_op(o_invalid_op),
    .o_q_valid(o_axi4s_result_tvalid)
);
assign o_accum_overflow = 1'b0;
assign o_accum_input_overflow = 1'b0;
end

// EXPONENTIAL

else if (OP_SEL == 5) begin
ipsxe_floating_point_exp_axi_top_v1_0 #(
    EXP_WIDTH,
    FRAC_WIDTH,
    FRAC_WIDTH,
    FRAC_WIDTH,
    PIPE_STAGE_NUM,
    PRECISION_INPUT,
    LATENCY_CONFIG
) u_exp_axi (
    .i_clk(i_aclk),
    .i_aclken(i_aclken),
    .i_rst_n(i_areset_n),
    .i_data_float(i_axi4s_a_tdata[WIDTH-1:0]),
    .i_valid(i_axi4s_or_abcoperation_tvalid),
    .o_exp_float(o_axi4s_result_tdata[OUT_WIDTH-1:0]),
    .o_overflow(o_overflow),
    .o_underflow(o_underflow),
    .o_valid(o_axi4s_result_tvalid)
);
assign o_accum_overflow = 1'b0;
assign o_accum_input_overflow = 1'b0;
assign o_divide_by_zero = 1'b0;
assign o_invalid_op = 1'b0;
end

// FIXED TO FLOAT

else if (OP_SEL == 6) begin
ipsxe_floating_point_fx2fl_top_v1_0 #(
    .FIXED_INT_BIT(INPUT_FIXED_INT_BIT), //with sign bit
    .FIXED_FRAC_BIT(INPUT_FIXED_FRAC_BIT),
    .FLOAT_EXP_BIT(FLOAT_OUT_EXP),
    .FLOAT_FRAC_BIT(FLOAT_OUT_FRAC),
    .INT_TYPE(INT_TYPE),
    .LATENCY_CONFIG(LATENCY_CONFIG)
) u_fx2fl_top (
    .i_aclk(i_aclk),
    .i_aclken(i_aclken),
    .i_areset_n(i_areset_n),
    .i_axi4s_a_tdata(i_axi4s_a_tdata[WIDTH-1:0]),
    .i_axi4s_or_abcoperation_tvalid(i_axi4s_or_abcoperation_tvalid),
    .o_axi4s_result_tdata(o_axi4s_result_tdata[OUT_WIDTH-1:0]),
    .o_axi4s_result_tvalid(o_axi4s_result_tvalid)
);
assign o_accum_overflow = 1'b0;
assign o_accum_input_overflow = 1'b0;
assign o_divide_by_zero = 1'b0;
assign o_invalid_op = 1'b0;
assign o_underflow = 1'b0;
assign o_overflow = 1'b0;
end

// FLOAT TO FIXED

else if (OP_SEL == 7) begin
ipsxe_floating_point_fl2fx_top_v1_0 #(
    .FLOAT_EXP_BIT(EXP_WIDTH),
    .FLOAT_FRAC_BIT(FRAC_WIDTH),
    .FIXED_INT_BIT(RESULT_FIXED_INT_BIT),
    .FIXED_FRAC_BIT(RESULT_FIXED_FRAC_BIT),
    .PRECISION_INPUT(PRECISION_INPUT),
    .LATENCY_CONFIG(LATENCY_CONFIG)
) u_fl2fx_top (
    .i_aclk(i_aclk),
    .i_aclken(i_aclken),
    .i_areset_n(i_areset_n),
    .i_axi4s_a_tdata(i_axi4s_a_tdata[WIDTH-1:0]),
    .i_axi4s_or_abcoperation_tvalid(i_axi4s_or_abcoperation_tvalid),
    .o_axi4s_result_tdata(o_axi4s_result_tdata[OUT_WIDTH-1:0]),
    .o_axi4s_result_tvalid(o_axi4s_result_tvalid),
    .o_invalid_op(o_invalid_op),
    .o_overflow(o_overflow)
);
assign o_accum_overflow = 1'b0;
assign o_accum_input_overflow = 1'b0;
assign o_divide_by_zero = 1'b0;
assign o_underflow = 1'b0;
end

// FLOAT TO FLOAT

else if (OP_SEL == 8) begin
ipsxe_floating_point_fl2fl_top_v1_0 #(
    .FLOAT_IN_EXP(EXP_WIDTH),
    .FLOAT_IN_FRAC(FRAC_WIDTH),
    .FLOAT_OUT_EXP(FLOAT_OUT_EXP),
    .FLOAT_OUT_FRAC(FLOAT_OUT_FRAC),
    .PRECISION_INPUT(PRECISION_INPUT),
    .LATENCY_CONFIG(LATENCY_CONFIG)
) u_fl2fl_top (
    .i_aclk(i_aclk),
    .i_aclken(i_aclken),
    .i_areset_n(i_areset_n),
    .i_axi4s_a_tdata(i_axi4s_a_tdata[WIDTH-1:0]),
    .i_axi4s_or_abcoperation_tvalid(i_axi4s_or_abcoperation_tvalid),
    .o_axi4s_result_tdata(o_axi4s_result_tdata[OUT_WIDTH-1:0]),
    .o_axi4s_result_tvalid(o_axi4s_result_tvalid),
    .o_overflow(o_overflow),
    .o_underflow(o_underflow)
);
assign o_accum_overflow = 1'b0;
assign o_accum_input_overflow = 1'b0;
assign o_divide_by_zero = 1'b0;
assign o_invalid_op = 1'b0;
end

// FUSED MULTIPLY ADD

else if (OP_SEL == 9) begin
ipsxe_floating_point_fma_v1_0 #(PRECISION_INPUT, EXP_WIDTH, MAN_WIDTH, APM_USAGE, LATENCY_CONFIG) u_fma (
    .i_clk(i_aclk),
    .i_aclken(i_aclken),
    .i_rst_n(i_areset_n),
    .i_abc_valid(i_axi4s_or_abcoperation_tvalid),
    .i_a(i_axi4s_a_tdata[WIDTH-1:0]),
    .i_b(i_axi4s_b_tdata[WIDTH-1:0]),
    .i_c_without_op(i_axi4s_c_tdata[WIDTH-1:0]),
    .i_op(i_axi4s_operation_tdata[0]),
    .o_a_mul_b_plus_c(o_axi4s_result_tdata[OUT_WIDTH-1:0]),
    .o_a_mul_b_plus_c_valid(o_axi4s_result_tvalid),
    .o_invalid_op(o_invalid_op),
    .o_underflow(o_underflow),
    .o_overflow(o_overflow)
);
assign o_accum_overflow = 1'b0;
assign o_accum_input_overflow = 1'b0;
assign o_divide_by_zero = 1'b0;
end

// LOGARITHM

else if (OP_SEL == 10) begin
ipsxe_floating_point_log_axi_top_v1_0 #(
    EXP_WIDTH,
    FRAC_WIDTH,
    PIPE_STAGE_NUM,
    PRECISION_INPUT
) u_log_axi (
    .i_clk(i_aclk),
    .i_aclken(i_aclken),
    .i_rst_n(i_areset_n),
    .i_data(i_axi4s_a_tdata[WIDTH-1:0]),
    .i_valid(i_axi4s_or_abcoperation_tvalid),
    .o_ln_float(o_axi4s_result_tdata[OUT_WIDTH-1:0]),
    .o_invalid_op(o_invalid_op),
    .o_overflow(o_overflow),
    .o_underflow(o_underflow),
    .o_valid(o_axi4s_result_tvalid)
);
assign o_accum_overflow = 1'b0;
assign o_accum_input_overflow = 1'b0;
assign o_divide_by_zero = 1'b0;
end

// MULTIPLY

else if (OP_SEL == 11) begin
ipsxe_floating_point_mul_v1_0 #(EXP_WIDTH, MAN_WIDTH, APM_USAGE, LATENCY_CONFIG) u_mul (
    .i_clk(i_aclk),
    .i_aclken(i_aclken),
    .i_areset_n(i_areset_n),
    .i_axis_or_ab_tvalid(i_axi4s_or_abcoperation_tvalid),
    .i_axis_a_tdata(i_axi4s_a_tdata[WIDTH-1:0]),
    .i_axis_b_tdata(i_axi4s_b_tdata[WIDTH-1:0]),
    .o_axis_result_tdata(o_axi4s_result_tdata[OUT_WIDTH-1:0]),
    .o_axis_result_tvalid_when_tready(o_axi4s_result_tvalid),
    .o_invalid_op(o_invalid_op),
    .o_overflow(o_overflow),
    .o_underflow(o_underflow)
);
assign o_accum_overflow = 1'b0;
assign o_accum_input_overflow = 1'b0;
assign o_divide_by_zero = 1'b0;
end

// RECIPROCAL

else if (OP_SEL == 12) begin
ipsxe_floating_point_div_inv_v1_0 #(WIDTH, WIDTH, WIDTH, EXP_WIDTH, MAN_WIDTH, LATENCY_CONFIG) u_inv (
    .i_clk(i_aclk),
    .i_aclken(i_aclken),
    .i_areset_n(i_areset_n),
  //  .i_op_in({2'b0, {(EXP_WIDTH-1){1'b1}}, {MAN_WIDTH{1'b0}}}), // 1
    .i_op_in(i_axi4s_a_tdata[WIDTH-1:0]),
    .i_tvalid(i_axi4s_or_abcoperation_tvalid),
    .o_resul(o_axi4s_result_tdata[OUT_WIDTH-1:0]),
  //  .o_overflow(o_overflow),
  //  .o_underflow(o_underflow),
    .o_divide_by_zero(o_divide_by_zero),
  //  .o_invalid_op(o_invalid_op),
    .o_q_valid(o_axi4s_result_tvalid)
);
assign o_accum_overflow = 1'b0;
assign o_accum_input_overflow = 1'b0;
end

// RECIPROCAL SQUARE ROOT

else if (OP_SEL == 13) begin
ipsxe_floating_point_invsqrt_v1_0 #(EXP_WIDTH, MAN_WIDTH, RNE, RNE1, RNE2, APM_USAGE, PRECISION_INPUT, LATENCY_CONFIG) u_invsqrt (
    .i_clk(i_aclk),
    .i_aclken(i_aclken),
    .i_rst_n(i_areset_n),
    .i_valid(i_axi4s_or_abcoperation_tvalid),
    .i_x_norm_or_denorm(i_axi4s_a_tdata[WIDTH-1:0]),
    .o_valid(o_axi4s_result_tvalid),
    .o_invsqrt_x(o_axi4s_result_tdata[OUT_WIDTH-1:0]),
    .o_invalid_op(o_invalid_op),
    .o_divide_by_zero(o_divide_by_zero)
);
assign o_accum_overflow = 1'b0;
assign o_accum_input_overflow = 1'b0;
assign o_underflow = 1'b0;
assign o_overflow = 1'b0;
end

// SQUARE ROOT

else if (OP_SEL == 14) begin
ipsxe_floating_point_sqrt_v1_0 #(EXP_WIDTH, MAN_WIDTH, RNE_SQRT, LATENCY_CONFIG) u_sqrt (
    .i_clk(i_aclk),
    .i_aclken(i_aclken),
    .i_rst_n(i_areset_n),
    .i_valid(i_axi4s_or_abcoperation_tvalid),
    .i_fp(i_axi4s_a_tdata[WIDTH-1:0]),
    .o_result(o_axi4s_result_tdata[OUT_WIDTH-1:0]),
    .o_valid(o_axi4s_result_tvalid),
    .o_invalid_op(o_invalid_op)
);
assign o_accum_overflow = 1'b0;
assign o_accum_input_overflow = 1'b0;
assign o_divide_by_zero = 1'b0;
assign o_underflow = 1'b0;
assign o_overflow = 1'b0;
end

// UNFUSED MULTIPLY ADD

else if (OP_SEL == 15) begin
ipsxe_floating_point_umadd_v1_0 #(WIDTH, FRAC_WIDTH, EXP_WIDTH, EXP_WIDTH, FRAC_WIDTH, 0) u_umadd (
    .i_aclk(i_aclk),
    .i_aclken(i_aclken),
    .i_areset_n(i_areset_n),
    .i_axi4s_tvalid(i_axi4s_or_abcoperation_tvalid),
    .i_axi4s_a_tdata(i_axi4s_a_tdata[WIDTH-1:0]),
    .i_axi4s_b_tdata(i_axi4s_b_tdata[WIDTH-1:0]),
    .i_axi4s_c_tdata(i_axi4s_c_tdata[WIDTH-1:0]),
    .i_axi4s_d_tdata({2'b0, {(EXP_WIDTH-1){1'b1}}, {MAN_WIDTH{1'b0}}}), // 1
    .o_axi4s_result_tdata(o_axi4s_result_tdata[OUT_WIDTH-1:0]),
    .o_axi4s_result_tvalid(o_axi4s_result_tvalid)
);
assign o_accum_overflow = 1'b0;
assign o_accum_input_overflow = 1'b0;
assign o_divide_by_zero = 1'b0;
assign o_invalid_op = 1'b0;
assign o_underflow = 1'b0;
assign o_overflow = 1'b0;
end

// UNFUSED MULTIPLY ACCUM

else if (OP_SEL == 16) begin
ipsxe_floating_point_umacc_v1_0 #(WIDTH, FRAC_WIDTH, EXP_WIDTH, EXP_WIDTH, FRAC_WIDTH, 0) u_umacc (
    .i_aclk(i_aclk),
    .i_aclken(i_aclken),
    .i_areset_n(i_areset_n),
    .i_axi4s_tvalid(i_axi4s_or_abcoperation_tvalid),
    .i_axi4s_a_tdata(i_axi4s_a_tdata[WIDTH-1:0]),
    .i_axi4s_b_tdata(i_axi4s_b_tdata[WIDTH-1:0]),
    .o_axi4s_result_tdata(o_axi4s_result_tdata[OUT_WIDTH-1:0]),
    .o_axi4s_result_tvalid(o_axi4s_result_tvalid)
);
assign o_accum_overflow = 1'b0;
assign o_accum_input_overflow = 1'b0;
assign o_divide_by_zero = 1'b0;
assign o_invalid_op = 1'b0;
assign o_underflow = 1'b0;
assign o_overflow = 1'b0;
end

// ACCUM PRIMITIVE

else if (OP_SEL == 17) begin
ipsxe_floating_point_accprim_v1_0 #(WIDTH, FRAC_WIDTH, EXP_WIDTH, EXP_WIDTH, FRAC_WIDTH, 0) u_accprim (
    .i_aclk(i_aclk),
    .i_aclken(i_aclken),
    .i_areset_n(i_areset_n),
    .i_axi4s_tvalid(i_axi4s_or_abcoperation_tvalid),
    .i_axi4s_a_tdata(i_axi4s_a_tdata[WIDTH-1:0]),
    .o_axi4s_result_tdata(o_axi4s_result_tdata[OUT_WIDTH-1:0]),
    .o_axi4s_result_tvalid(o_axi4s_result_tvalid)
);
assign o_accum_overflow = 1'b0;
assign o_accum_input_overflow = 1'b0;
assign o_divide_by_zero = 1'b0;
assign o_invalid_op = 1'b0;
assign o_underflow = 1'b0;
assign o_overflow = 1'b0;
end


endgenerate

endmodule
