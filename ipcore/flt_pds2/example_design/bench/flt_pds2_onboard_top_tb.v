

module flt_pds2_onboard_top_tb();

localparam REPEAT_NUM = 1000;


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

reg i_aresetn;

wire o_success;

wire [TDATA_OUT_WIDTH-1:0] o_axi4s_result_tdata;

wire o_axi4s_result_tvalid;

flt_pds2_onboard_top u_flt_pds2_onboard_top
(

    i_aclk,

    o_success,

    o_axi4s_result_tdata,
    o_axi4s_result_tvalid
);



initial begin
    i_aclk = 1;
end
always #5 i_aclk = ~i_aclk;

initial begin
    i_aresetn = 0;
    #25 i_aresetn = 1;
    #50
    repeat(REPEAT_NUM) begin
        #10;
    end
    #10;
    #450 i_aresetn = 0;
    #500 $finish;
end



initial begin
    $fsdbDumpfile("flt_pds2.fsdb");
    $fsdbDumpvars;
    $fsdbDumpMDA;
end

endmodule

