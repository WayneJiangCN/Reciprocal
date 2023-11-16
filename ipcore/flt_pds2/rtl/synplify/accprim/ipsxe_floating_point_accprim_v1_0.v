///////////////////////////////////////////////////////////////////////////////
// Filename: float_acc_top.v
// Description:
//      accumulate function: p = p + a.
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_accprim_v1_0 #(
    parameter DATA_WIDTH = 32, //FIXED_INT_BIT + FIXED_FRAC_BIT = FLOAT_EXP_BIT + FLOAT_FRAC_BIT
    parameter FIXED_INT_BIT = 24, //with sign bit
    parameter FIXED_FRAC_BIT = 8,
    parameter FLOAT_EXP_BIT = 8,
    parameter FLOAT_FRAC_BIT = 24,//include the hidden one
    parameter INT_TYPE = 0
)(
    input i_aclk,
    input i_aclken,
    input i_areset_n,

    input [DATA_WIDTH-1:0] i_axi4s_a_tdata,
    input i_axi4s_tvalid,

    output o_axi4s_result_tvalid,
    output [DATA_WIDTH-1:0] o_axi4s_result_tdata
);

localparam ZSIZE = 32 ; //@IPC int 2,240
localparam PSIZE = 48 ; //@IPC enum 24,48,96,144,192,240,288
localparam Z_SIGNED = 1 ; //@IPC enum 0,1
localparam ASYNC_RST = 1 ; //@IPC enum 0,1
localparam OPTIMAL_TIMING = 0 ; //@IPC enum 0,1
localparam INREG_EN = 1 ; //@IPC enum 0,1
localparam ACC_ADDSUB_OP = 0 ; //@IPC bool
localparam DYN_ACC_ADDSUB_OP = 1 ; //@IPC bool
localparam DYN_ACC_INIT = 1 ; //@IPC bool
localparam [PSIZE-1:0] ACC_INIT_VALUE = 48'h0 ; //@IPC string
//tmp variable for ipc purpose
localparam PIPE_STATUS = 2 ; //@IPC enum 0,1
localparam ASYNC_RST_BOOL = 1 ; //@IPC bool
localparam OPTIMAL_TIMING_BOOL = 0 ; //@IPC bool
//end of tmp variable
localparam  GRS_EN       = "FALSE"        ;

wire [ZSIZE-1:0] o_fix_tdata_a;
wire o_fix_tvalid;

wire [PSIZE-1:0] i_acc_fx2fl_data;
reg i_acc_fx2fl_valid;

always @(posedge i_aclk or negedge i_areset_n) begin
    if(!i_areset_n) begin
        i_acc_fx2fl_valid <= 1'b0;
    end
    else if(i_aclken) begin
        i_acc_fx2fl_valid <= o_fix_tvalid;
    end
end

ipsxe_floating_point_fl2fx_axi_v1_0 #(
    .FLOAT_EXP_BIT(FLOAT_EXP_BIT),
    .FLOAT_FRAC_BIT(FLOAT_FRAC_BIT),
    .FIXED_INT_BIT(FIXED_INT_BIT),
    .FIXED_FRAC_BIT(FIXED_FRAC_BIT)
) u_fl2fx_a (
    .i_aclk(i_aclk),
    .i_aclken(i_aclken),
    .i_areset_n(i_areset_n),
    .i_axi4s_a_tdata(i_axi4s_a_tdata),
    .i_axi4s_or_abcoperation_tvalid(i_axi4s_tvalid),
    .o_axi4s_result_tdata(o_fix_tdata_a),
    .o_axi4s_result_tvalid(o_fix_tvalid),
    .o_invalid_op(),
    .o_overflow()
);

ipm2l_acc_v1_1a_accum #(  
    .ZSIZE              ( ZSIZE             ),
    .PSIZE              ( PSIZE             ),
    .OPTIMAL_TIMING     ( OPTIMAL_TIMING    ),
    .INREG_EN           ( INREG_EN          ),     
    .GRS_EN             ( GRS_EN            ), 
    .Z_SIGNED           ( Z_SIGNED          ),    
    .ASYNC_RST          ( ASYNC_RST         ),     
    .ACC_INIT_VALUE     ( ACC_INIT_VALUE    ), 
    .DYN_ACC_INIT       ( DYN_ACC_INIT      ),
    .ACC_ADDSUB_OP      ( ACC_ADDSUB_OP     ),   
    .DYN_ACC_ADDSUB_OP  ( DYN_ACC_ADDSUB_OP ) 
) u_ipm2l_acc_accum (
    /*input */.ce         ( i_aclken          ),
    /*input */.rst        ( ~i_areset_n       ),
    /*input */.clk        ( i_aclk            ),
    /*input */.z          ( o_fix_tdata_a     ),

    /*input */.acc_init   ( {PSIZE{1'b0}}     ), //@IPC show DYN_ACC_INIT
    /*input */.acc_addsub ( 1'b0              ), //@IPC show DYN_ACC_ADDSUB_OP
    /*input */.reload     ( 1'b0              ),

    /*output*/.p          ( i_acc_fx2fl_data  )
);

ipsxe_floating_point_fx2fl_axi_v1_0 #(
    .FLOAT_EXP_BIT(FLOAT_EXP_BIT),
    .FLOAT_FRAC_BIT(FLOAT_FRAC_BIT),
    .FIXED_INT_BIT(FIXED_INT_BIT),
    .FIXED_FRAC_BIT(FIXED_FRAC_BIT),
    .INT_TYPE(INT_TYPE)
) u_fl2fx (
    .i_aclk(i_aclk),
    .i_aclken(i_aclken),
    .i_areset_n(i_areset_n),
    .i_axi4s_a_tdata(i_acc_fx2fl_data[DATA_WIDTH-1:0]),
    .i_axi4s_or_abcoperation_tvalid(i_acc_fx2fl_valid),
    .o_axi4s_result_tdata(o_axi4s_result_tdata),
    .o_axi4s_result_tvalid(o_axi4s_result_tvalid)
);


endmodule