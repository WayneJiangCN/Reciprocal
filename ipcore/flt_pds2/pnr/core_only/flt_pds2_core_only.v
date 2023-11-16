

module flt_pds2_core_only
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


localparam EXP_WIDTH = 8;
localparam MAN_WIDTH = 23;
localparam RNE = 6;
localparam RNE1 = 20;
localparam RNE2 = 19;

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

input i_aclk;

input [TDATA_WIDTH-1:0] i_axi4s_a_tdata;

input i_axi4s_a_tvalid;

output [TDATA_OUT_WIDTH-1:0] o_axi4s_result_tdata;

output o_axi4s_result_tvalid;

flt_pds2 u_flt_pds2
(

    i_aclk,

    i_axi4s_a_tdata,

    i_axi4s_a_tvalid,

    o_axi4s_result_tdata,

    o_axi4s_result_tvalid
);

endmodule

