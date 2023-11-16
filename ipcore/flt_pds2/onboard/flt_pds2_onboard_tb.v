

module floating_point_wrapper_onboard_tb ();


localparam EXP_WIDTH = 8;
localparam MAN_WIDTH = 23;

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

reg i_areset_n;
wire [TDATA_OUT_WIDTH-1:0] o_axi4s_result_tdata;
wire [TDATA_WIDTH-1:0] i_axi4s_a_tdata_delay_output;

wire o_axi4s_result_tvalid;



initial begin
    i_aclk = 1;
end
always #5 i_aclk = ~i_aclk;

initial begin
    i_areset_n = 0;
    #25 i_areset_n = 1;
    #50
    #1450 i_areset_n = 0;
    #100 $finish;
end

flt_pds2_onboard u_flt_pds2_onboard (
    i_aclk,

    i_areset_n,
    o_axi4s_result_tdata,
    i_axi4s_a_tdata_delay_output,

    o_axi4s_result_tvalid
);

integer fp;
initial begin
    fp = $fopen("./flt_pds2_onboard_input_output.txt");
end

always @(posedge i_aclk) begin

    if (o_axi4s_result_tvalid) begin
        $fwrite(fp, "\%b \%b\n",


i_axi4s_a_tdata_delay_output,

o_axi4s_result_tdata);
    end
end

initial begin
    $fsdbDumpfile("flt_pds2_onboard.fsdb");
    $fsdbDumpvars;
    $fsdbDumpMDA;
end

endmodule

