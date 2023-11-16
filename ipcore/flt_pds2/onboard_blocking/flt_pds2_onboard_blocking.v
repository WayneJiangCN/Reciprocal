

module flt_pds2_onboard_blocking
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

output [TDATA_WIDTH-1:0] i_axi4s_a_tdata;

output i_axi4s_a_tvalid;

output [TDATA_OUT_WIDTH-1:0] o_axi4s_result_tdata;

output o_axi4s_result_tvalid;

wire [4:0] rd_addr;
wire i_axi4s_abcoperation_tvalid;

floating_point_rom_addr_counter u_floating_point_rom_addr_counter (
    i_aclk,
    i_areset_n,
    i_axi4s_abcoperation_tvalid,
    rd_addr
);

floating_point_rom_a u_floating_point_rom_a (
    i_aclk,
    rd_addr,
    i_axi4s_a_tdata
);

floating_point_rom_b u_floating_point_rom_b (
    i_aclk,
    rd_addr,
    i_axi4s_b_tdata
);

floating_point_rom_c u_floating_point_rom_c (
    i_aclk,
    rd_addr,
    i_axi4s_c_tdata
);

floating_point_rom_operation u_floating_point_rom_operation (
    i_aclk,
    rd_addr,
    i_axi4s_operation_tdata
);

floating_point_rom_abcop_tvalid_result_tready u_floating_point_rom_abcop_tvalid_result_tready (
    i_aclk,
    rd_addr,
    {i_axi4s_a_tvalid, i_axi4s_b_tvalid, i_axi4s_c_tvalid, i_axi4s_operation_tvalid, i_axi4s_result_tready}
);

flt_pds2 u_flt_pds2
(

    i_aclk,

    i_axi4s_a_tdata,

    i_axi4s_a_tvalid,

    o_axi4s_result_tdata,

    o_axi4s_result_tvalid
);

endmodule

