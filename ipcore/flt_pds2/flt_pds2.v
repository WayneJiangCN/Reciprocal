
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
// Filename: flt_pds2.v
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module flt_pds2
(

    i_aclk,

    i_axi4s_a_tdata,

    i_axi4s_a_tvalid,

    o_axi4s_result_tdata,

    o_axi4s_result_tvalid
);


localparam TUSER_IN_A_WIDTH = 0;

localparam TUSER_IN_B_WIDTH = 0;

localparam TUSER_IN_C_WIDTH = 0;

localparam TUSER_IN_OPERATION_WIDTH = 0;

localparam INVALID_OP_WIDTH = 0;

localparam UNDERFLOW_WIDTH = 0;

localparam OVERFLOW_WIDTH = 0;

localparam DIVIDE_BY_ZERO_WIDTH = 0;

localparam ACCUM_OVERFLOW_WIDTH = 0;

localparam ACCUM_INPUT_OVERFLOW_WIDTH = 0;


localparam TUSER_RESULT_WIDTH = TUSER_IN_A_WIDTH + TUSER_IN_B_WIDTH + TUSER_IN_C_WIDTH + TUSER_IN_OPERATION_WIDTH + INVALID_OP_WIDTH + UNDERFLOW_WIDTH + OVERFLOW_WIDTH + DIVIDE_BY_ZERO_WIDTH + ACCUM_OVERFLOW_WIDTH + ACCUM_INPUT_OVERFLOW_WIDTH;
localparam TUSER_IN_ABCOPERATION_WIDTH = TUSER_IN_A_WIDTH + TUSER_IN_B_WIDTH + TUSER_IN_C_WIDTH + TUSER_IN_OPERATION_WIDTH;


localparam PRECISION_INPUT = 1;

localparam EXP_WIDTH = 8;
localparam MAN_WIDTH = 23;
localparam RNE = 2;
localparam RNE1 = 20;
localparam RNE2 = 21;
localparam RNE_ADDSUB = 6;

localparam INPUT_FIXED_INT_BIT = 32;
localparam INPUT_FIXED_FRAC_BIT = 0;

localparam RESULT_FIXED_INT_BIT = 32; // unused
localparam RESULT_FIXED_FRAC_BIT = 0; // unused

localparam FLOAT_OUT_EXP = 5;
localparam FLOAT_OUT_FRAC = 11;

localparam WIDTH = 1 + EXP_WIDTH + MAN_WIDTH;

localparam FRAC_WIDTH = 1 + MAN_WIDTH;

localparam TDATA_WIDTH = (WIDTH[2:0] == 0) ? WIDTH : (((WIDTH >> 3) + 1) << 3);

localparam OUT_WIDTH = 1 + EXP_WIDTH + MAN_WIDTH;

localparam TDATA_OUT_WIDTH = (OUT_WIDTH[2:0] == 0) ? OUT_WIDTH : (((OUT_WIDTH >> 3) + 1) << 3);

localparam LATENCY_CONFIG = 0;

localparam PIPE_STAGE_NUM = LATENCY_CONFIG; // MAN_WIDTH + 3 + 2;

localparam RNE_SQRT = 1;

localparam ACCUM_MSB = 32;

localparam ACCUM_LSB = -31;

localparam ACCUM_INPUT_MSB = 32;

localparam INT_TYPE = 0; // unused
localparam PREC_INPUT = 0; // unused

localparam AXI_OPT = 0;

localparam OP_SEL = 12;

localparam BLOCKING = 0;

localparam OP_PLUS_MINUS = 0;

localparam OP_COMPARE = 0;

localparam TLAST_BEHAVIOR = 6;

localparam TLAST_TUSER_TDATA_A_WIDTH = TDATA_WIDTH + TUSER_IN_A_WIDTH;

localparam TLAST_TUSER_TDATA_B_WIDTH = TDATA_WIDTH + TUSER_IN_B_WIDTH;

localparam TLAST_TUSER_TDATA_C_WIDTH = TDATA_WIDTH + TUSER_IN_C_WIDTH;

localparam TLAST_TUSER_TDATA_OPERATION_WIDTH = 3 + TUSER_IN_OPERATION_WIDTH;

localparam TLAST_TUSER_TDATA_RESULT_WIDTH = TDATA_OUT_WIDTH + TUSER_RESULT_WIDTH;

localparam APM_USAGE = 0;

localparam ABCOP_TUSER = 0;


// INPUT AND OUTPUT PORTS


input i_aclk;

input [TDATA_WIDTH-1:0] i_axi4s_a_tdata;

input i_axi4s_a_tvalid;

output [TDATA_OUT_WIDTH-1:0] o_axi4s_result_tdata;

output o_axi4s_result_tvalid;

wire aclken;
wire areset_n;

wire [TDATA_OUT_WIDTH-1:0] s_fifo_tdata;
wire s_fifo_tlast;
wire accum_overflow, accum_input_overflow, divide_by_zero, invalid_op, underflow, overflow;



wire i_axi4s_and_abcoperation_tvalid;

wire [2:0] operation_tdata;

wire [TLAST_TUSER_TDATA_A_WIDTH-1:0] m_fifo_a_tlast_tuser_tdata;

wire m_fifo_tvalid;
wire s_fifo_tvalid;
wire s_fifo_tready;
wire dummy_tuser;

wire [TDATA_OUT_WIDTH-1:0] no_outreg_o_axi4s_result_tdata;

wire no_outreg_o_axi4s_result_tvalid;

// ACLKEN AND ARESETN

ipsxe_floating_point_aclken_aresetn_v1_0 u_aclken_aresetn (

    .i_aclken(1'b1),

    .i_areset_n(1'b1),

    .i_result_tready(1'b1),

    .o_aclken(aclken),
    .o_areset_n(areset_n),
    .o_dummy_tuser(dummy_tuser)
);

// TUSER



// TVALID

ipsxe_floating_point_abcop_tvalid_v1_0 u_abcop_tvalid (
    .i_axi4s_a_tvalid(i_axi4s_a_tvalid),

    .i_axi4s_b_tvalid(1'b1),

    .i_axi4s_c_tvalid(1'b1),

    .i_axi4s_operation_tvalid(1'b1),

    .o_axi4s_and_abcoperation_tvalid(i_axi4s_and_abcoperation_tvalid)
);

// MODULES INSTANTIATION

ipsxe_floating_point_op_tdata_v1_0 #(OP_SEL, OP_PLUS_MINUS, OP_COMPARE) u_op_tdata (

    .i_axi4s_operation_tdata(8'b0),

    .o_operation_tdata(operation_tdata)
);

generate
if (BLOCKING == 1) begin: blocking
// **********************************************************
//             Input Stream Buffer
// **********************************************************
    ipsxe_floating_point_axi_buffer_4io_v1_0 #(
        .TLAST_TUSER_TDATA_A_WIDTH(TLAST_TUSER_TDATA_A_WIDTH),
        .TLAST_TUSER_TDATA_B_WIDTH(TLAST_TUSER_TDATA_B_WIDTH),
        .TLAST_TUSER_TDATA_C_WIDTH(TLAST_TUSER_TDATA_C_WIDTH),
        .TLAST_TUSER_TDATA_OPERATION_WIDTH(TLAST_TUSER_TDATA_OPERATION_WIDTH)
    ) u_fifo_in (

        .i_aclk                       (i_aclk),

        .i_areset_n                    (areset_n),
        .i_a_tlast_tuser_tdata      ({

i_axi4s_a_tdata}),
        .o_a_tlast_tuser_tdata      (m_fifo_a_tlast_tuser_tdata),
        .i_a_tvalid                 (i_axi4s_a_tvalid),

        .o_a_tready                 (),

        .i_b_tlast_tuser_tdata      ({

i_axi4s_a_tdata

}),
        .o_b_tlast_tuser_tdata      (m_fifo_b_tlast_tuser_tdata),

        .i_b_tvalid                 (i_axi4s_a_tvalid),
        .o_b_tready                 (),

        .i_c_tlast_tuser_tdata      ({

i_axi4s_a_tdata

}),
        .o_c_tlast_tuser_tdata      (m_fifo_c_tlast_tuser_tdata),

        .i_c_tvalid                 (i_axi4s_a_tvalid),
        .o_c_tready                 (),

        .i_operation_tlast_tuser_tdata      ({

operation_tdata
}),
        .o_operation_tlast_tuser_tdata      (m_fifo_operation_tlast_tuser_tdata),

        .i_operation_tvalid                 (i_axi4s_a_tvalid),
        .o_operation_tready                 (),

        .i_tready                   (s_fifo_tready),
        .o_tvalid                   (m_fifo_tvalid)
    );
// **********************************************************
//             Top Instance
// **********************************************************
ipsxe_floating_point_fp_15ops_v1_0 #(
    TDATA_WIDTH,
    TDATA_OUT_WIDTH,
    OP_SEL,
    WIDTH,
    OUT_WIDTH,
    EXP_WIDTH,
    MAN_WIDTH,
    FRAC_WIDTH,
    ACCUM_MSB,
    ACCUM_LSB,
    ACCUM_INPUT_MSB,
    INPUT_FIXED_INT_BIT,
    INPUT_FIXED_FRAC_BIT,
    RESULT_FIXED_INT_BIT,
    RESULT_FIXED_FRAC_BIT,
    INT_TYPE,
    FLOAT_OUT_EXP,
    FLOAT_OUT_FRAC,
    PIPE_STAGE_NUM,
    RNE,
    RNE1,
    RNE2,
    RNE_SQRT,
    RNE_ADDSUB,
    TLAST_BEHAVIOR,
    APM_USAGE,
    PRECISION_INPUT,
    PREC_INPUT,
    LATENCY_CONFIG
) u_floating_top(

    .i_aclk(i_aclk),

    .i_aclken(s_fifo_tready),
    .i_areset_n(areset_n),
    .i_axi4s_a_tdata(m_fifo_a_tlast_tuser_tdata[TDATA_WIDTH-1:0]),

    .i_axi4s_b_tdata(i_axi4s_a_tdata),

    .i_axi4s_c_tdata(i_axi4s_a_tdata),

    .i_axi4s_operation_tdata(operation_tdata),

    .i_axi4s_a_tlast(1'b0),

    .i_axi4s_b_tlast(1'b0),

    .i_axi4s_c_tlast(1'b0),

    .i_axi4s_operation_tlast(1'b0),

    .i_axi4s_or_abcoperation_tvalid(m_fifo_tvalid),
    .o_axi4s_result_tdata(s_fifo_tdata),
    .o_axi4s_result_tlast(s_fifo_tlast),
    .o_axi4s_result_tvalid(s_fifo_tvalid),
    .o_accum_overflow(accum_overflow),
    .o_accum_input_overflow(accum_input_overflow),
    .o_divide_by_zero(divide_by_zero),
    .o_invalid_op(invalid_op),
    .o_underflow(underflow),
    .o_overflow(overflow)
);
// **********************************************************
//             Output Stream
// **********************************************************
    ipsxe_floating_point_axi_buffer_1io_v1_0 #( //parameters
        .TLAST_TUSER_TDATA_A_WIDTH(TLAST_TUSER_TDATA_RESULT_WIDTH)
    ) u_fifo_out(

        .i_aclk                       (i_aclk),

        .i_areset_n                    (areset_n),
        .i_a_tlast_tuser_tdata      ({

s_fifo_tdata}),
        .i_a_tvalid                 (s_fifo_tvalid),
        .o_a_tready                 (s_fifo_tready),


        .i_tready                   (1'b1),

        .o_tvalid                   (no_outreg_o_axi4s_result_tvalid),
        .o_a_tlast_tuser_tdata      ({

        no_outreg_o_axi4s_result_tdata})
    );
if (AXI_OPT == 1) begin // performance optimization
wire [(1+TLAST_TUSER_TDATA_RESULT_WIDTH)*2-1:0] out_delay;
// 2 last pipeline stages
ipsxe_floating_point_register_v1_0 #((1+TLAST_TUSER_TDATA_RESULT_WIDTH)*2-(1+TLAST_TUSER_TDATA_RESULT_WIDTH) + 1+TLAST_TUSER_TDATA_RESULT_WIDTH) u_reg_stagelast2(
    .i_clk(i_aclk),
    .i_aclken(aclken),
    .i_rst_n(areset_n),
    .i_d({out_delay[(1+TLAST_TUSER_TDATA_RESULT_WIDTH)*2-1-(1+TLAST_TUSER_TDATA_RESULT_WIDTH):0], no_outreg_o_axi4s_result_tvalid,

    no_outreg_o_axi4s_result_tdata}),
    .o_q(out_delay)
);
assign {o_axi4s_result_tvalid,

o_axi4s_result_tdata} = out_delay[(1+TLAST_TUSER_TDATA_RESULT_WIDTH)*2-1-:(1+TLAST_TUSER_TDATA_RESULT_WIDTH)];
end
else begin // resources optimization
assign {o_axi4s_result_tvalid,

o_axi4s_result_tdata} = {no_outreg_o_axi4s_result_tvalid,

    no_outreg_o_axi4s_result_tdata};
end
end
else begin: NON_BLOCKING
ipsxe_floating_point_fp_15ops_v1_0 #(
    TDATA_WIDTH,
    TDATA_OUT_WIDTH,
    OP_SEL,
    WIDTH,
    OUT_WIDTH,
    EXP_WIDTH,
    MAN_WIDTH,
    FRAC_WIDTH,
    ACCUM_MSB,
    ACCUM_LSB,
    ACCUM_INPUT_MSB,
    INPUT_FIXED_INT_BIT,
    INPUT_FIXED_FRAC_BIT,
    RESULT_FIXED_INT_BIT,
    RESULT_FIXED_FRAC_BIT,
    INT_TYPE,
    FLOAT_OUT_EXP,
    FLOAT_OUT_FRAC,
    PIPE_STAGE_NUM,
    RNE,
    RNE1,
    RNE2,
    RNE_SQRT,
    RNE_ADDSUB,
    TLAST_BEHAVIOR,
    APM_USAGE,
    PRECISION_INPUT,
    PREC_INPUT,
    LATENCY_CONFIG
) u_floating_point (

    .i_aclk(i_aclk),

    .i_aclken(aclken),
    .i_areset_n(areset_n),
    .i_axi4s_a_tdata(i_axi4s_a_tdata),

    .i_axi4s_b_tdata(i_axi4s_a_tdata),

    .i_axi4s_c_tdata(i_axi4s_a_tdata),

    .i_axi4s_operation_tdata(operation_tdata),

    .i_axi4s_a_tlast(1'b0),

    .i_axi4s_b_tlast(1'b0),

    .i_axi4s_c_tlast(1'b0),

    .i_axi4s_operation_tlast(1'b0),

    .i_axi4s_or_abcoperation_tvalid(i_axi4s_and_abcoperation_tvalid),

    .o_axi4s_result_tdata(o_axi4s_result_tdata),
    .o_axi4s_result_tlast(o_axi4s_result_tlast),
    .o_axi4s_result_tvalid(o_axi4s_result_tvalid),

    .o_accum_overflow(accum_overflow),
    .o_accum_input_overflow(accum_input_overflow),
    .o_divide_by_zero(divide_by_zero),
    .o_invalid_op(invalid_op),
    .o_underflow(underflow),
    .o_overflow(overflow)
);
end
endgenerate

endmodule

