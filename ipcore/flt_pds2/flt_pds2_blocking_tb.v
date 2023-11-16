

module flt_pds2_blocking_tb();

localparam REPEAT_NUM = 1000;


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

localparam LATENCY_CONFIG = 0;

localparam PIPE_STAGE_NUM = 14;

localparam RNE_SQRT = 1;

reg i_aclk;

reg [TDATA_WIDTH-1:0] i_axi4s_a_tdata;

reg i_axi4s_a_tvalid;

wire [TDATA_OUT_WIDTH-1:0] o_axi4s_result_tdata;

wire o_axi4s_result_tvalid;

flt_pds2 u_flt_pds2
(

    i_aclk,

    i_axi4s_a_tdata,

    i_axi4s_a_tvalid,

    o_axi4s_result_tdata,

    o_axi4s_result_tvalid
);


initial begin
    i_aclk = 1;
end
always #5 i_aclk = ~i_aclk;


integer a_special, b_special, c_special;
initial begin
    i_axi4s_a_tdata = 0;

    i_axi4s_a_tvalid = 0;

    #75

// a = random, b = random, c = random
    repeat(REPEAT_NUM) begin
        i_axi4s_a_tdata[14:0] = $random;

        i_axi4s_a_tdata[31:15] = $random;

        i_axi4s_a_tvalid = 1;

        #10;
    end

// a = 0, b = 0, c = 0
    i_axi4s_a_tdata = 0;

    #10;

// valid = 0
    i_axi4s_a_tvalid = 0;

    #500
    $finish;
end


wire [TDATA_WIDTH*PIPE_STAGE_NUM-1:0] i_axi4s_a_tdata_delay;
wire [TDATA_WIDTH-1:0] i_axi4s_a_tdata_delay_output = i_axi4s_a_tdata_delay[TDATA_WIDTH*PIPE_STAGE_NUM-1-:TDATA_WIDTH];
ipsxe_floating_point_register_v1_0 #(TDATA_WIDTH*PIPE_STAGE_NUM) u_reg_i_axi4s_a_tdata_delay(
    i_aclk,

    1'b1,

    1'b1,

    {i_axi4s_a_tdata_delay[TDATA_WIDTH*PIPE_STAGE_NUM-1-TDATA_WIDTH:0], i_axi4s_a_tdata},

    i_axi4s_a_tdata_delay
);


integer fp;
initial begin
    fp = $fopen("./flt_pds2_input_output.txt");
end

always @(posedge i_aclk) begin

    if (o_axi4s_result_tvalid) begin
        $fwrite(fp, "\%b \%b\n",

i_axi4s_a_tdata_delay_output,

o_axi4s_result_tdata);
    end
end

initial begin
    $fsdbDumpfile("flt_pds2.fsdb");
    $fsdbDumpvars;
    $fsdbDumpMDA;
end

endmodule

