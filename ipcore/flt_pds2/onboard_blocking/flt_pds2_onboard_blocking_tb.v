

module floating_point_wrapper_onboard_blocking_tb ();


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

reg i_aclk;

wire [TDATA_WIDTH-1:0] i_axi4s_a_tdata;
wire i_axi4s_a_tvalid;

wire [TDATA_OUT_WIDTH-1:0] o_axi4s_result_tdata;

wire o_axi4s_result_tvalid;


initial begin
    i_aclk = 1;
end
always #5 i_aclk = ~i_aclk;
flt_pds2_onboard_blocking u_flt_pds2_onboard_blocking (

    i_aclk,

    i_axi4s_a_tdata,
    i_axi4s_a_tvalid,

    o_axi4s_result_tdata,

    o_axi4s_result_tvalid
);

initial begin
    $fsdbDumpfile("flt_pds2_onboard_blocking.fsdb");
    $fsdbDumpvars;
    $fsdbDumpMDA;
end

endmodule

