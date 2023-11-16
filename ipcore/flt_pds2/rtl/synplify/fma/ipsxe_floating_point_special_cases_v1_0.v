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
// Filename: ipsxe_floating_point_special_cases_v1_0.v
// Function: This module judges whether to set the result to 0, inf, NaN
//           or other special values.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_special_cases_v1_0 #(parameter EXP_WIDTH = 8, MAN_WIDTH = 23, LATENCY_CONFIG = 1, PIPE_STAGE_NUM_MAX = 1) (
    input i_clk,
    input i_aclken,
    input i_rst_n,
    input [(1+EXP_WIDTH+MAN_WIDTH)-1:0] i_a,
    input [(1+EXP_WIDTH+MAN_WIDTH)-1:0] i_b,
    input [(1+EXP_WIDTH+MAN_WIDTH)-1:0] i_c,
    output o_set_result_0,
    output o_c_is_0,
    output o_set_result_c,
    output o_set_result_nan,
    output o_set_result_pinf,
    output o_set_result_ninf,
    output o_invalid_op
);

localparam WIDTH = 1+EXP_WIDTH+MAN_WIDTH; // floating-point data width

wire a_is_0, b_is_0, c_is_0;
wire a_nan, b_nan, c_nan;
wire a_is_pinf, b_is_pinf, c_is_pinf, a_is_ninf, b_is_ninf, c_is_ninf;
wire a_is_p, b_is_p, c_is_p, a_is_n, b_is_n, c_is_n;
wire a_mul_b_is_pinf, a_mul_b_is_ninf, pinf_plus_ninf, inf_mul_0;
wire a_is_0_dly1, b_is_0_dly1, c_is_0_dly1, a_nan_dly1, b_nan_dly1, c_nan_dly1, a_is_pinf_dly1, b_is_pinf_dly1, c_is_pinf_dly1, a_is_ninf_dly1, b_is_ninf_dly1, c_is_ninf_dly1, a_is_p_dly1, b_is_p_dly1, c_is_p_dly1, a_is_n_dly1, b_is_n_dly1, c_is_n_dly1;
wire a_nan_dly2, b_nan_dly2, a_is_0_dly2, b_is_0_dly2, c_is_0_dly2, c_nan_dly2, c_is_pinf_dly2, c_is_ninf_dly2, a_is_p_dly2, b_is_p_dly2, c_is_p_dly2, a_is_n_dly2, b_is_n_dly2, c_is_n_dly2, a_mul_b_is_pinf_dly1, a_mul_b_is_ninf_dly1, inf_mul_0_dly1;
wire a_nan_dly3, b_nan_dly3, a_is_0_dly3, b_is_0_dly3, c_is_0_dly3, c_nan_dly3, c_is_pinf_dly3, c_is_ninf_dly3, a_is_p_dly3, b_is_p_dly3, c_is_p_dly3, a_is_n_dly3, b_is_n_dly3, c_is_n_dly3, a_mul_b_is_pinf_dly2, a_mul_b_is_ninf_dly2, inf_mul_0_dly2, pinf_plus_ninf_dly1;
wire set_result_nan  , invalid_op;
wire a_is_0_dly4, b_is_0_dly4, c_is_0_dly4, c_nan_dly4, c_is_pinf_dly4, c_is_ninf_dly4, a_is_p_dly4, b_is_p_dly4, c_is_p_dly4, a_is_n_dly4, b_is_n_dly4, c_is_n_dly4, a_mul_b_is_pinf_dly3, a_mul_b_is_ninf_dly3;

// judge whether a, b or c are 0
assign a_is_0 = (i_a[WIDTH-2:WIDTH-EXP_WIDTH-1] == 0);
assign b_is_0 = (i_b[WIDTH-2:WIDTH-EXP_WIDTH-1] == 0);
assign c_is_0 = (i_c[WIDTH-2:WIDTH-EXP_WIDTH-1] == 0);

// judge whether a, b or c are NaN
assign a_nan = (i_a[WIDTH-2:WIDTH-EXP_WIDTH-1]=={EXP_WIDTH{1'b1}}) & (|i_a[MAN_WIDTH-1:0]);
assign b_nan = (i_b[WIDTH-2:WIDTH-EXP_WIDTH-1]=={EXP_WIDTH{1'b1}}) & (|i_b[MAN_WIDTH-1:0]);
assign c_nan = (i_c[WIDTH-2:WIDTH-EXP_WIDTH-1]=={EXP_WIDTH{1'b1}}) & (|i_c[MAN_WIDTH-1:0]);

// judge whether a, b or c are infinite numbers
assign a_is_pinf = (i_a[WIDTH-2:WIDTH-EXP_WIDTH-1]=={EXP_WIDTH{1'b1}}) & (~|i_a[MAN_WIDTH-1:0]) & ~i_a[WIDTH-1];
assign b_is_pinf = (i_b[WIDTH-2:WIDTH-EXP_WIDTH-1]=={EXP_WIDTH{1'b1}}) & (~|i_b[MAN_WIDTH-1:0]) & ~i_b[WIDTH-1];
assign c_is_pinf = (i_c[WIDTH-2:WIDTH-EXP_WIDTH-1]=={EXP_WIDTH{1'b1}}) & (~|i_c[MAN_WIDTH-1:0]) & ~i_c[WIDTH-1];
assign a_is_ninf = (i_a[WIDTH-2:WIDTH-EXP_WIDTH-1]=={EXP_WIDTH{1'b1}}) & (~|i_a[MAN_WIDTH-1:0]) & i_a[WIDTH-1];
assign b_is_ninf = (i_b[WIDTH-2:WIDTH-EXP_WIDTH-1]=={EXP_WIDTH{1'b1}}) & (~|i_b[MAN_WIDTH-1:0]) & i_b[WIDTH-1];
assign c_is_ninf = (i_c[WIDTH-2:WIDTH-EXP_WIDTH-1]=={EXP_WIDTH{1'b1}}) & (~|i_c[MAN_WIDTH-1:0]) & i_c[WIDTH-1];

// judge whether a, b or c are normalized positive or negative numbers
assign a_is_p = (i_a[WIDTH-1] == 0) & (i_a[WIDTH-2:WIDTH-EXP_WIDTH-1]!=0 & i_a[WIDTH-2:WIDTH-EXP_WIDTH-1]!={EXP_WIDTH{1'b1}});
assign a_is_n = (i_a[WIDTH-1] == 1) & (i_a[WIDTH-2:WIDTH-EXP_WIDTH-1]!=0 & i_a[WIDTH-2:WIDTH-EXP_WIDTH-1]!={EXP_WIDTH{1'b1}});
assign b_is_p = (i_b[WIDTH-1] == 0) & (i_b[WIDTH-2:WIDTH-EXP_WIDTH-1]!=0 & i_b[WIDTH-2:WIDTH-EXP_WIDTH-1]!={EXP_WIDTH{1'b1}});
assign b_is_n = (i_b[WIDTH-1] == 1) & (i_b[WIDTH-2:WIDTH-EXP_WIDTH-1]!=0 & i_b[WIDTH-2:WIDTH-EXP_WIDTH-1]!={EXP_WIDTH{1'b1}});
assign c_is_p = (i_c[WIDTH-1] == 0) & (i_c[WIDTH-2:WIDTH-EXP_WIDTH-1]!=0 & i_c[WIDTH-2:WIDTH-EXP_WIDTH-1]!={EXP_WIDTH{1'b1}});
assign c_is_n = (i_c[WIDTH-1] == 1) & (i_c[WIDTH-2:WIDTH-EXP_WIDTH-1]!=0 & i_c[WIDTH-2:WIDTH-EXP_WIDTH-1]!={EXP_WIDTH{1'b1}});

generate
if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (1 / 2)) begin
// pipeline stage 1
ipsxe_floating_point_register_v1_0 #(18) u_reg_stage1(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({a_is_0,      b_is_0,      c_is_0     , a_nan     , b_nan     , c_nan     , a_is_pinf     , b_is_pinf     , c_is_pinf     , a_is_ninf     , b_is_ninf     , c_is_ninf     , a_is_p     , b_is_p     , c_is_p     , a_is_n     , b_is_n     , c_is_n     }),
    .o_q({a_is_0_dly1, b_is_0_dly1, c_is_0_dly1, a_nan_dly1, b_nan_dly1, c_nan_dly1, a_is_pinf_dly1, b_is_pinf_dly1, c_is_pinf_dly1, a_is_ninf_dly1, b_is_ninf_dly1, c_is_ninf_dly1, a_is_p_dly1, b_is_p_dly1, c_is_p_dly1, a_is_n_dly1, b_is_n_dly1, c_is_n_dly1})
);
end
else begin
assign {a_is_0_dly1, b_is_0_dly1, c_is_0_dly1, a_nan_dly1, b_nan_dly1, c_nan_dly1, a_is_pinf_dly1, b_is_pinf_dly1, c_is_pinf_dly1, a_is_ninf_dly1, b_is_ninf_dly1, c_is_ninf_dly1, a_is_p_dly1, b_is_p_dly1, c_is_p_dly1, a_is_n_dly1, b_is_n_dly1, c_is_n_dly1} = {a_is_0,      b_is_0,      c_is_0     , a_nan     , b_nan     , c_nan     , a_is_pinf     , b_is_pinf     , c_is_pinf     , a_is_ninf     , b_is_ninf     , c_is_ninf     , a_is_p     , b_is_p     , c_is_p     , a_is_n     , b_is_n     , c_is_n     };
end
endgenerate

// judge whether a * b is a positive infinite number
assign a_mul_b_is_pinf = (a_is_pinf_dly1 & b_is_pinf_dly1) | (a_is_ninf_dly1 & b_is_ninf_dly1) | (a_is_pinf_dly1 & b_is_p_dly1) | (b_is_pinf_dly1 & a_is_p_dly1) | (a_is_ninf_dly1 & b_is_n_dly1) | (b_is_ninf_dly1 & a_is_n_dly1);
// judge whether a * b is a negative infinite number
assign a_mul_b_is_ninf = (a_is_pinf_dly1 & b_is_ninf_dly1) | (a_is_ninf_dly1 & b_is_pinf_dly1) | (a_is_ninf_dly1 & b_is_p_dly1) | (a_is_pinf_dly1 & b_is_n_dly1) | (b_is_ninf_dly1 & a_is_p_dly1) | (b_is_pinf_dly1 & a_is_n_dly1);
// judge whether a is infinite and b is 0, or vice versa
assign inf_mul_0 = ((a_is_pinf_dly1 | a_is_ninf_dly1) & b_is_0_dly1) | ((b_is_pinf_dly1 | b_is_ninf_dly1) & a_is_0_dly1); // +inf * 0 or -inf * 0

generate
if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/2) - (2 / 4)) begin
// pipeline stage 2
ipsxe_floating_point_register_v1_0 #(17) u_reg_stage1(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({a_nan_dly1, b_nan_dly1, a_is_0_dly1, b_is_0_dly1, c_is_0_dly1, c_nan_dly1, c_is_pinf_dly1, c_is_ninf_dly1, a_is_p_dly1, b_is_p_dly1, c_is_p_dly1, a_is_n_dly1, b_is_n_dly1, c_is_n_dly1, a_mul_b_is_pinf,      a_mul_b_is_ninf,      inf_mul_0     }),
    .o_q({a_nan_dly2, b_nan_dly2, a_is_0_dly2, b_is_0_dly2, c_is_0_dly2, c_nan_dly2, c_is_pinf_dly2, c_is_ninf_dly2, a_is_p_dly2, b_is_p_dly2, c_is_p_dly2, a_is_n_dly2, b_is_n_dly2, c_is_n_dly2, a_mul_b_is_pinf_dly1, a_mul_b_is_ninf_dly1, inf_mul_0_dly1})
);
end
else begin
assign {a_nan_dly2, b_nan_dly2, a_is_0_dly2, b_is_0_dly2, c_is_0_dly2, c_nan_dly2, c_is_pinf_dly2, c_is_ninf_dly2, a_is_p_dly2, b_is_p_dly2, c_is_p_dly2, a_is_n_dly2, b_is_n_dly2, c_is_n_dly2, a_mul_b_is_pinf_dly1, a_mul_b_is_ninf_dly1, inf_mul_0_dly1} = {a_nan_dly1, b_nan_dly1, a_is_0_dly1, b_is_0_dly1, c_is_0_dly1, c_nan_dly1, c_is_pinf_dly1, c_is_ninf_dly1, a_is_p_dly1, b_is_p_dly1, c_is_p_dly1, a_is_n_dly1, b_is_n_dly1, c_is_n_dly1, a_mul_b_is_pinf,      a_mul_b_is_ninf,      inf_mul_0     };
end
endgenerate

// judge whether a * b is a positive infinite number and c is a negative infinite number, or vice versa
assign pinf_plus_ninf = (a_mul_b_is_pinf_dly1 & c_is_ninf_dly2) | (a_mul_b_is_ninf_dly1 & c_is_pinf_dly2);

generate
if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (3 / 2)) begin
// pipeline stage 3
ipsxe_floating_point_register_v1_0 #(18) u_reg_stage1(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({a_nan_dly2, b_nan_dly2, a_is_0_dly2, b_is_0_dly2, c_is_0_dly2, c_nan_dly2, c_is_pinf_dly2, c_is_ninf_dly2, a_is_p_dly2, b_is_p_dly2, c_is_p_dly2, a_is_n_dly2, b_is_n_dly2, c_is_n_dly2, a_mul_b_is_pinf_dly1, a_mul_b_is_ninf_dly1, inf_mul_0_dly1, pinf_plus_ninf     }),
    .o_q({a_nan_dly3, b_nan_dly3, a_is_0_dly3, b_is_0_dly3, c_is_0_dly3, c_nan_dly3, c_is_pinf_dly3, c_is_ninf_dly3, a_is_p_dly3, b_is_p_dly3, c_is_p_dly3, a_is_n_dly3, b_is_n_dly3, c_is_n_dly3, a_mul_b_is_pinf_dly2, a_mul_b_is_ninf_dly2, inf_mul_0_dly2, pinf_plus_ninf_dly1})
);
end
else begin
assign {a_nan_dly3, b_nan_dly3, a_is_0_dly3, b_is_0_dly3, c_is_0_dly3, c_nan_dly3, c_is_pinf_dly3, c_is_ninf_dly3, a_is_p_dly3, b_is_p_dly3, c_is_p_dly3, a_is_n_dly3, b_is_n_dly3, c_is_n_dly3, a_mul_b_is_pinf_dly2, a_mul_b_is_ninf_dly2, inf_mul_0_dly2, pinf_plus_ninf_dly1} = {a_nan_dly2, b_nan_dly2, a_is_0_dly2, b_is_0_dly2, c_is_0_dly2, c_nan_dly2, c_is_pinf_dly2, c_is_ninf_dly2, a_is_p_dly2, b_is_p_dly2, c_is_p_dly2, a_is_n_dly2, b_is_n_dly2, c_is_n_dly2, a_mul_b_is_pinf_dly1, a_mul_b_is_ninf_dly1, inf_mul_0_dly1, pinf_plus_ninf     };
end
endgenerate

// if the following cases accur, then invalid_op = 1
assign invalid_op = pinf_plus_ninf_dly1 | inf_mul_0_dly2;
// if the following cases accur, then set the result to NaN
assign set_result_nan = a_nan_dly3 | b_nan_dly3 | c_nan_dly3 | invalid_op;

generate
if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/4) - (4 / 8)) begin
// pipeline stage 4
ipsxe_floating_point_register_v1_0 #(16) u_reg_stage1(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({a_is_0_dly3, b_is_0_dly3, c_is_0_dly3, c_nan_dly3, c_is_pinf_dly3, c_is_ninf_dly3, a_is_p_dly3, b_is_p_dly3, c_is_p_dly3, a_is_n_dly3, b_is_n_dly3, c_is_n_dly3, a_mul_b_is_pinf_dly2, a_mul_b_is_ninf_dly2, set_result_nan  , invalid_op  }),
    .o_q({a_is_0_dly4, b_is_0_dly4, c_is_0_dly4, c_nan_dly4, c_is_pinf_dly4, c_is_ninf_dly4, a_is_p_dly4, b_is_p_dly4, c_is_p_dly4, a_is_n_dly4, b_is_n_dly4, c_is_n_dly4, a_mul_b_is_pinf_dly3, a_mul_b_is_ninf_dly3, o_set_result_nan, o_invalid_op})
);
end
else begin
assign {a_is_0_dly4, b_is_0_dly4, c_is_0_dly4, c_nan_dly4, c_is_pinf_dly4, c_is_ninf_dly4, a_is_p_dly4, b_is_p_dly4, c_is_p_dly4, a_is_n_dly4, b_is_n_dly4, c_is_n_dly4, a_mul_b_is_pinf_dly3, a_mul_b_is_ninf_dly3, o_set_result_nan, o_invalid_op} = {a_is_0_dly3, b_is_0_dly3, c_is_0_dly3, c_nan_dly3, c_is_pinf_dly3, c_is_ninf_dly3, a_is_p_dly3, b_is_p_dly3, c_is_p_dly3, a_is_n_dly3, b_is_n_dly3, c_is_n_dly3, a_mul_b_is_pinf_dly2, a_mul_b_is_ninf_dly2, set_result_nan  , invalid_op  };
end
endgenerate

// if a or b is 0, and c is 0, then the result is 0
assign o_set_result_0 = !o_set_result_nan & (a_is_0_dly4 | b_is_0_dly4) & c_is_0_dly4;
// if a or b are normalized numbers and c is 0, then the result is a * b
assign o_c_is_0 = c_is_0_dly4;
// if a or b is 0, and c is a normalized number, then the result is c
assign o_set_result_c = !o_set_result_nan & (a_is_0_dly4 | b_is_0_dly4) & (c_is_p_dly4 | c_is_n_dly4);
// if the following cases accur, then set the result to positive infinite or negative infinite
assign o_set_result_pinf = (a_mul_b_is_pinf_dly3 & ~c_is_ninf_dly4 & ~c_nan_dly4) | (c_is_pinf_dly4 & ~a_mul_b_is_ninf_dly3 & ~o_set_result_nan);
assign o_set_result_ninf = (a_mul_b_is_ninf_dly3 & ~c_is_pinf_dly4 & ~c_nan_dly4) | (c_is_ninf_dly4 & ~a_mul_b_is_pinf_dly3 & ~o_set_result_nan);

endmodule