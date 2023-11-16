

module flt_pds2_onboard_tlast_tuser
(

    i_aclk,

    i_axi4s_a_tvalid,

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

wire [TDATA_WIDTH-1:0] i_axi4s_a_tdata;

output i_axi4s_a_tvalid;

wire [TDATA_OUT_WIDTH-1:0] o_axi4s_result_tdata;

output o_axi4s_result_tvalid;

wire [3:0] rd_addr;
wire i_axi4s_abcoperation_tvalid;

floating_point_rom_addr_counter u_floating_point_rom_addr_counter (
    i_aclk,
    i_areset_n,
    i_axi4s_abcoperation_tvalid,
    rd_addr
);

floating_point_rom_a #(EXP_WIDTH, MAN_WIDTH) u_floating_point_rom_a (
    i_aclk,
    rd_addr,
    i_axi4s_a_tdata
);



floating_point_rom_tlast_tuser u_floating_point_rom_tlast_tuser (
    i_aclk,
    rd_addr,
    {i_axi4s_a_tlast, i_axi4s_b_tlast, i_axi4s_c_tlast, i_axi4s_operation_tlast, i_axi4s_operation_tuser, i_axi4s_c_tuser, i_axi4s_b_tuser, i_axi4s_a_tuser}
);

flt_pds2 u_flt_pds2
(

    i_aclk,

    i_axi4s_a_tdata,

    i_axi4s_abcoperation_tvalid,

    o_axi4s_result_tdata,

    o_axi4s_result_tvalid
);

endmodule

