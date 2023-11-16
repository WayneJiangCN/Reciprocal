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
// Filename:ipsxe_floating_point_exp_32_axi_v1_0.v
// Function: p=e^z
//           zsize:z < 8
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns


module ipsxe_floating_point_exp_16_axi_v1_0 #(
    parameter FLOAT_EXP_WIDTH = 5,
    parameter FLOAT_FRAC_WIDTH = 11,
    parameter DATA_WIDTH = 11,
    parameter DATA_WIDTH_CUT = 11,
    parameter ITERATION_NUM = 7,
    parameter INPUT_RANGE_ADD = 0,
    parameter LATENCY_CONFIG = 9 //latency clk = LATENCY_CONFIG-1
)
(
    input i_clk,
    input i_aclken,
    input i_rst_n, //aresetn
    input [FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1:0] i_data_float, //s_axis_a_tdata
    input i_valid, //s_axis_a_tvalid
    output [FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1:0] o_exp_float, //m_axis_result_tdata
    output o_overflow, 
    output o_underflow,
    output o_valid //m_axis_result_tvalid
);

//look up table of denominator value 
wire [12:0] under_value [6:0];
assign under_value[0] = 13'd1;
assign under_value[1] = 13'd2;
assign under_value[2] = 13'd6;
assign under_value[3] = 13'd24;
assign under_value[4] = 13'd120;
assign under_value[5] = 13'd720;
assign under_value[6] = 13'd5040;

/*reg overflow_buffer[ITERATION_NUM-1:0];
reg underflow_buffer[ITERATION_NUM-1:0];
reg in_valid_buffer[ITERATION_NUM-1:0];
reg [FLOAT_EXP_WIDTH-1:0] float_exp_buffer [ITERATION_NUM-1:0];
reg float_exp_pn_buffer [ITERATION_NUM-1:0];*/
reg overflow_buffer[LATENCY_CONFIG-2:0];
reg underflow_buffer[LATENCY_CONFIG-2:0];
reg in_valid_buffer[LATENCY_CONFIG-2:0];
reg [FLOAT_EXP_WIDTH-1:0] float_exp_buffer [LATENCY_CONFIG-2:0];
reg float_exp_pn_buffer [LATENCY_CONFIG-2:0];

wire [FLOAT_EXP_WIDTH-1:0] float_exp;
wire float_exp_pn;
wire [FLOAT_FRAC_WIDTH-1:0] float_value; //24bits
wire [DATA_WIDTH+2+INPUT_RANGE_ADD:0] iData_fixed; //+3bits
wire [DATA_WIDTH+1+INPUT_RANGE_ADD:0] iData_fixed_abs; //+3bits
wire [DATA_WIDTH+2+INPUT_RANGE_ADD:0] shift; //may decrease
wire shift_pn;
wire [DATA_WIDTH_CUT+2+INPUT_RANGE_ADD:0] w;
wire [DATA_WIDTH_CUT+2+INPUT_RANGE_ADD:0] r;

/*reg [16-1:0] up_value [ITERATION_NUM-1:0]; 
reg [16-1:0] ex [ITERATION_NUM-1:0]; // max:2 * 2^27 = 29 bits + sign bit = 30
reg [6-1:0] x0_buffer [ITERATION_NUM-1:0]; //x0 < ln(2) * 2^27*/
wire [16-1:0] up_value [ITERATION_NUM-1:0]; 
wire [16-1:0] ex [ITERATION_NUM-1:0]; // max:2 * 2^27 = 29 bits + sign bit = 30
wire [6-1:0] x0_buffer [ITERATION_NUM-1:0];

wire [30:0] up_value_product [7:0];

/*reg [7:0] shift_buffer [ITERATION_NUM-1:0];
reg shift_pn_buffer [ITERATION_NUM-1:0];
 
reg [5:0] valid_cnt;*/
wire [7:0] shift_buffer [ITERATION_NUM-1:0];
wire shift_pn_buffer [ITERATION_NUM-1:0];
 
wire [5:0] valid_cnt;
 
wire [5:0] valid_cnt_next;

wire [27-1:0] exp_part;
wire [27-1:0] exp_part_2;

wire [5:0] x0;

wire [FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1:0] exp_float0;

wire [5:0] r_msb;
wire [3:0] r_lsb;
//reg [3:0] r_lsb_buffer [ITERATION_NUM-1:0];
wire [3:0] r_lsb_buffer [ITERATION_NUM-1:0];

wire [FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1:0] o_exp_float0;

//compare the exponential bit with 127
assign float_exp_pn = i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] > 5'd15 ? 0 : 1;
//calculate the exponential bit of float input
assign float_exp = i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] > 5'd15 ? i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] - 5'd15 : 5'd15 - i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1];
//calculate the value of mantissa
assign float_value = {1'b1,i_data_float[FLOAT_FRAC_WIDTH-2:0]};
//calculate the fixed value of input
assign iData_fixed[DATA_WIDTH+2+INPUT_RANGE_ADD] = i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1];
assign iData_fixed_abs[DATA_WIDTH+1+INPUT_RANGE_ADD:0] = i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] > 5'd15 ? {{(3+INPUT_RANGE_ADD){1'b0}},float_value} <<< float_exp : {{(3+INPUT_RANGE_ADD){1'b0}},float_value} >>> float_exp; 
assign iData_fixed[DATA_WIDTH+1+INPUT_RANGE_ADD:0] = i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1] ? -(iData_fixed_abs) : iData_fixed_abs;

//calculate the sign bit of shift number 0:left shift 1:right shift
assign shift_pn = iData_fixed[DATA_WIDTH+2+INPUT_RANGE_ADD]; 
//calculate shift number
assign w = !i_rst_n ? {14{1'b1}} : {1'b0,iData_fixed_abs};
assign shift = !i_rst_n ? {14{1'b1}} :
                iData_fixed[DATA_WIDTH+2+INPUT_RANGE_ADD] ? (w / 710) +1 : (w / 710); // (2^31)/23=ln2 * 2^27
//calculate value of r
assign r = !i_rst_n ? {14{1'b1}} :
            iData_fixed[DATA_WIDTH+2+INPUT_RANGE_ADD] ? (shift[7:0] * 710) - w : w - (shift[7:0] * 710); //ln2 * 2^8 = 177, ln2 * 2^23 = 5814540, ln2 * 2^27 = 93032640

assign r_msb = r[9:4];
assign r_lsb = r[3:0];

//calculation of taylor expansion
assign up_value_product[0] = {x0_buffer[0], 24'b0}; //24 = 9 + 15
assign up_value_product[1] = (up_value[1] * x0_buffer[1]) << 9;
assign up_value_product[2] = (up_value[2] * x0_buffer[2]) << 9;
assign up_value_product[3] = (up_value[3] * x0_buffer[3]) << 9;
assign up_value_product[4] = (up_value[4] * x0_buffer[4]) << 9;
assign up_value_product[5] = (up_value[5] * x0_buffer[5]) << 9;
assign up_value_product[6] = (up_value[6] * x0_buffer[6]) << 9;
assign up_value_product[7] = (up_value[7] * x0_buffer[7]) << 9;
 
assign valid_cnt_next = (valid_cnt < ITERATION_NUM) ? valid_cnt + 1 : ITERATION_NUM;

//exp_part is the value of ex_n
assign exp_part = !i_rst_n ? {27{1'b1}} : (ex[ITERATION_NUM-1] * r_lsb_buffer[ITERATION_NUM-1]) + (ex[ITERATION_NUM-1] << 10);
//exp_part_2 is used to remove the leading 1 of the exponential value
assign exp_part_2 = !i_rst_n ? {27{1'b1}} : 
                    exp_part > (1 <<< 25) ? exp_part - (1 <<< 25) : (1 <<< 25) - exp_part; 
//if input is smaller than 8, overflow = 0, otherwise 1
assign overflow = i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1] == 1 ? 0 :
                    i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] > (5'd17 + INPUT_RANGE_ADD) ? 1 : 0;
assign underflow = (i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] < 5'b00110) ? 1 : 0;


assign x0 = r_msb;

/*integer i0;
integer i2;
always @ ( posedge i_clk or negedge i_rst_n )
    if( !i_rst_n )
    begin
    //reset
    for (i0 = 0; i0 < ITERATION_NUM; i0 = i0+1) begin
        up_value[i0] <= 0;
        ex[i0] <= 0;
        x0_buffer[i0] <= 0;
        shift_buffer[i0] <= 0;
        shift_pn_buffer[i0] <= 0;
        r_lsb_buffer[i0] <= 0;
    end

    valid_cnt <= 0;
    end
    else if (i_aclken) begin
        //initialize
        shift_buffer[0] <= shift[7:0];
        shift_pn_buffer[0] <= shift_pn;
        valid_cnt <= valid_cnt_next;
        up_value[0] <= 32768;// 2^26;
        ex[0] <= 32768;
        x0_buffer[0] <= x0;
        r_lsb_buffer[0] <= r_lsb;
    
        if(valid_cnt > 0) begin
        //iteration for calculating taylor expansion
        for (i2 = 1; i2 < ITERATION_NUM; i2 = i2+1) begin
            up_value[i2] <= up_value_product[i2-1][30:15];
            ex[i2] <= ex[i2-1] + (up_value_product[i2-1][30:15] / under_value[i2-1]);
            x0_buffer[i2] <= x0_buffer[i2-1];
            r_lsb_buffer[i2] <= r_lsb_buffer[i2-1];
         
            shift_buffer[i2] <= shift_buffer[i2-1];
            shift_pn_buffer[i2] <= shift_pn_buffer[i2-1];
        end
        end
    end*/

assign shift_buffer[0] = shift[7:0];
assign shift_pn_buffer[0] = shift_pn;
assign valid_cnt = valid_cnt_next;
assign up_value[0] = 32768;
assign ex[0] = 32768;
assign x0_buffer[0] = x0;
assign r_lsb_buffer[0] = r_lsb;
generate
genvar i0, i2;
for (i0 = 1; i0 < ITERATION_NUM; i0 = i0 + 1) begin: cal_gen
    if (LATENCY_CONFIG-1 >= i0)
        ipsxe_floating_point_register_v1_0 #(16 + 16 + 6 + 8 + 1 + 4) u_register(
            .i_clk(i_clk),
            .i_aclken(i_aclken),
            .i_rst_n(i_rst_n),
            .i_d({up_value_product[i0-1][14] ? up_value_product[i0-1][30:15]+1 : up_value_product[i0-1][30:15], ex[i0-1] + (up_value_product[i0-1][30:15] / under_value[i0-1]), x0_buffer[i0-1], shift_buffer[i0-1], shift_pn_buffer[i0-1], r_lsb_buffer[i0-1]}),
            .o_q({up_value[i0], ex[i0], x0_buffer[i0], shift_buffer[i0], shift_pn_buffer[i0], r_lsb_buffer[i0]})
        );
    else
        assign {up_value[i0], ex[i0], x0_buffer[i0], shift_buffer[i0], shift_pn_buffer[i0], r_lsb_buffer[i0]} = {up_value_product[i0-1][14] ? up_value_product[i0-1][30:15]+1 : up_value_product[i0-1][30:15], ex[i0-1] + (up_value_product[i0-1][30:15] / under_value[i0-1]), x0_buffer[i0-1], shift_buffer[i0-1], shift_pn_buffer[i0-1], r_lsb_buffer[i0-1]};
end
endgenerate

assign o_valid = in_valid_buffer[ITERATION_NUM-1];
assign o_overflow = overflow_buffer[ITERATION_NUM-1];
assign o_underflow = underflow_buffer[ITERATION_NUM-1];

//calculate the sign bit of float result
assign exp_float0[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1] = !i_rst_n ? 1'b1 : 1'b0;
//calculate the exponential bits of float result
assign exp_float0[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] = !i_rst_n ? 5'b11111 :
                                                            shift_pn_buffer[ITERATION_NUM-1] == 0 ? 5'd15 + shift_buffer[ITERATION_NUM-1] : 5'd15 - shift_buffer[ITERATION_NUM-1];
//calculate the mantissa bits of float result
assign exp_float0[FLOAT_FRAC_WIDTH-2:0] = !i_rst_n ? {10{1'b1}} : 
                                            exp_part_2[14] ? exp_part_2[24:15]+1   : exp_part_2[24:15];
//adjust the output accorroding to the value of input 
assign o_exp_float0 = o_overflow ? {1'b0, {FLOAT_EXP_WIDTH{1'b1}}, {(FLOAT_FRAC_WIDTH-1){1'b0}}} :
                    shift_pn_buffer[ITERATION_NUM-1] == 0 ? exp_float0 :
                    (float_exp_buffer[ITERATION_NUM-1] > 5'd2) && (float_exp_pn_buffer[ITERATION_NUM-1] == 0) ? 0 :
		            (float_exp_pn_buffer[ITERATION_NUM-1] == 1) && (float_exp_buffer[ITERATION_NUM-1] > 5'd7) ? 16'b0_01111_0000000000 : exp_float0;

//delay i_valid, overflow, underflow, float_exp, and float_exp_pn to keep pace with output
integer i3;
always @(posedge i_clk or negedge i_rst_n)
    if(!i_rst_n) begin
    for (i3 = 0; i3 < LATENCY_CONFIG-1; i3 = i3+1) begin
        in_valid_buffer[i3] <= 0;
        overflow_buffer[i3] <= 0;
        underflow_buffer[i3] <= 0;
        float_exp_buffer[i3] <= 0;
        float_exp_pn_buffer[i3] <= 0;
    end
    end
    else if (i_aclken) begin
        in_valid_buffer[0] <= i_valid;
        overflow_buffer[0] <= overflow;
        underflow_buffer[0] <= underflow;
        float_exp_buffer[0] <= float_exp;
        float_exp_pn_buffer[0] <= float_exp_pn;
        for (i3 = 1; i3 < LATENCY_CONFIG-1; i3 = i3+1) begin
            in_valid_buffer[i3] <= in_valid_buffer[i3-1];
            overflow_buffer[i3] <= overflow_buffer[i3-1];
            underflow_buffer[i3] <= underflow_buffer[i3-1];
            float_exp_buffer[i3] <= float_exp_buffer[i3-1];
            float_exp_pn_buffer[i3] <= float_exp_pn_buffer[i3-1];
        end
    end

generate
genvar i4;
if (LATENCY_CONFIG > ITERATION_NUM) begin
    //for (i4 = 0; i4 < LATENCY_CONFIG-ITERATION_NUM; i4 = i4 + 1) begin: delay_gen
        ipsxe_floating_point_linebuffer_delay_v1_0 #(
        .N(FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH),
        .DELAY_NUM(LATENCY_CONFIG - ITERATION_NUM)
        ) u_linebuffer_delay(
        .i_clk(i_clk),
        .i_aclken(i_aclken),
        .i_rst_n(i_rst_n),
        .i_d(o_exp_float0),
        .o_q(o_exp_float)
        );
    //end
end
else begin
    assign o_exp_float = o_exp_float0;
end
endgenerate

endmodule