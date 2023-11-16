

module flt_pds2_onboard_top
(
    i_aclk,

    i_areset_n,

    o_success,

    o_axi4s_result_tdata,
    o_axi4s_result_tvalid
);


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

localparam LATENCY_CONFIG = 0;

localparam PIPE_STAGE_NUM = 14;

localparam RNE_SQRT = 1;

localparam OP_SEL = 12;


input i_aclk;

input i_areset_n;

output reg o_success;

output [TDATA_OUT_WIDTH-1:0] o_axi4s_result_tdata;
output o_axi4s_result_tvalid;

wire [3:0] rd_addr;
wire i_axi4s_abcoperation_tvalid;
wire [TDATA_WIDTH-1:0] i_axi4s_a_tdata, i_axi4s_b_tdata, i_axi4s_c_tdata;
wire [7:0] i_axi4s_operation_tdata;

ipsxe_floating_point_rom_addr_counter u_floating_point_rom_addr_counter (
    i_aclk,
    i_areset_n,
    i_axi4s_abcoperation_tvalid,
    rd_addr
);

ipsxe_floating_point_rom_a #(EXP_WIDTH, MAN_WIDTH) u_floating_point_rom_a (
    i_aclk,
    rd_addr,
    i_axi4s_a_tdata
);

ipsxe_floating_point_rom_b #(EXP_WIDTH, MAN_WIDTH) u_floating_point_rom_b (
    i_aclk,
    rd_addr,
    i_axi4s_b_tdata
);

ipsxe_floating_point_rom_c #(EXP_WIDTH, MAN_WIDTH) u_floating_point_rom_c (
    i_aclk,
    rd_addr,
    i_axi4s_c_tdata
);

ipsxe_floating_point_rom_operation u_floating_point_rom_operation (
    i_aclk,
    rd_addr,
    i_axi4s_operation_tdata
);

flt_pds2 u_flt_pds2
(

    i_aclk,

    i_axi4s_a_tdata,

    i_axi4s_abcoperation_tvalid,

    o_axi4s_result_tdata,

    o_axi4s_result_tvalid
);



wire [TDATA_OUT_WIDTH-1:0] golden_result;
ipsxe_floating_point_rom_golden_result #(EXP_WIDTH, MAN_WIDTH, OP_SEL) u_floating_point_rom_golden_result (
    i_aclk,
    rd_addr,
    golden_result
);


wire [TDATA_OUT_WIDTH*PIPE_STAGE_NUM-1:0] golden_result_delay;
wire [TDATA_OUT_WIDTH-1:0] golden_result_delay_output = golden_result_delay[TDATA_OUT_WIDTH*PIPE_STAGE_NUM-1-:TDATA_OUT_WIDTH];
ipsxe_floating_point_register_v1_0 #(TDATA_OUT_WIDTH*PIPE_STAGE_NUM) u_reg_golden_result_delay(
    i_aclk,

    1'b1,

    1'b1,

    {golden_result_delay[TDATA_OUT_WIDTH*PIPE_STAGE_NUM-1-TDATA_OUT_WIDTH:0], golden_result},

    golden_result_delay
);


always @(posedge i_aclk)

        if ((golden_result_delay_output == o_axi4s_result_tdata) && o_axi4s_result_tvalid)
            o_success <= 1;
        else if ((golden_result_delay_output != o_axi4s_result_tdata) && o_axi4s_result_tvalid)
            o_success <= 0;
        else
            o_success <= o_success;


endmodule

