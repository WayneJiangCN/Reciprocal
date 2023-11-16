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
// Filename:ipsxe_floating_point_log_32_axi_v1_0.v
// Function: p=ln(z)
//           zsize:z > 0
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns


module ipsxe_floating_point_log_16_axi_v1_0 #(
    parameter FLOAT_EXP_WIDTH = 5,
    parameter FLOAT_FRAC_WIDTH = 11,
    parameter FLOAT_FRAC_WIDTH_CUT = 12,
    parameter ITERATION_NUM = 13
)
(
    input i_clk, //aclk
    input i_aclken,
    input i_rst_n, //aresetn
    input [FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1:0] i_data, //s_axis_a_tdata
    input i_valid, //s_axis_a_tvalid
    output [FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1:0] o_ln_float, //m_axis_result_tdata
    output o_invalid_op,
    output o_overflow, 
    output o_underflow,
    output o_valid //m_axis_result_tvalid
);

//look up table of atanh value 
wire [14:0] atanh [14:0];
assign atanh[0] = 15'd18000;
assign atanh[1] = 15'd8369;  
assign atanh[2] = 15'd4118;  
assign atanh[3] = 15'd2051;  
assign atanh[4] = 15'd1024;
assign atanh[5] = 15'd512;   
assign atanh[6] = 15'd256;
assign atanh[7] = 15'd128; 
assign atanh[8] = 15'd64; 
assign atanh[9] = 15'd32; 
assign atanh[10] = 15'd16;
assign atanh[11] = 15'd8;  
assign atanh[12] = 15'd4;  
assign atanh[13] = 15'd2;  
assign atanh[14] = 15'd1;

wire [7:0] shift;
wire shift_pn;

reg signed [FLOAT_FRAC_WIDTH+6:0] x [ITERATION_NUM-1:0];
reg signed [FLOAT_FRAC_WIDTH+6:0] y [ITERATION_NUM-1:0];

reg signed [FLOAT_FRAC_WIDTH+6:0] alpha [ITERATION_NUM-1:0];

reg [7:0] shift_buffer [ITERATION_NUM-1:0];
reg shift_pn_buffer [ITERATION_NUM-1:0];
 
reg [7:0] i [ITERATION_NUM-1:0];
reg [7:0] k [ITERATION_NUM-1:0];
reg [5:0] valid_cnt;

wire [5:0] valid_cnt_next;

wire in_NaN;
wire in_INF;
wire invalid_op;
wire overflow;
wire underflow;

reg invalid_op_buffer[ITERATION_NUM-1:0];
reg overflow_buffer[ITERATION_NUM-1:0];
reg in_valid_buffer[ITERATION_NUM-1:0];

wire [FLOAT_FRAC_WIDTH+11:0] ln;
wire signed [FLOAT_FRAC_WIDTH+10:0] ln_0;
wire signed [FLOAT_FRAC_WIDTH+11:0] ln2_value;

wire    [4:0]   index;
wire    [15:0]   tmp3;
wire    [7:0]   tmp0;
wire    [3:0]   tmp1;
wire    [1:0]   tmp2;
wire    [31:0] ln_value;

wire [FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1:0] ln_float0;

wire [31:0] ln_value_shift;

assign shift_pn = i_data[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] >= 5'd15 ? 0 : 1; 
assign shift = i_data[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] >= 5'd15 ? i_data[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] - 15 : 15 - i_data[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1];
 
assign valid_cnt_next = (valid_cnt < ITERATION_NUM) ? valid_cnt + 1 : ITERATION_NUM;

integer i0;
integer i1;
integer i2;
always @ ( posedge i_clk or negedge i_rst_n )
    if( !i_rst_n )
    begin
    for (i0 = 0; i0 < ITERATION_NUM; i0 = i0+1) begin
        x[i0] <= 0;
        y[i0] <= 0;
        alpha[i0] <= 0;
        i[i0] <= 0;
        k[i0] <= 0;
        shift_buffer[i0] <= 0;
        shift_pn_buffer[i0] <= 0;
    end
    
    valid_cnt <= 0;
    end
    else if( i_aclken & i_valid ) begin
        shift_buffer[0] <= shift;
        shift_pn_buffer[0] <= shift_pn;
        valid_cnt <= valid_cnt_next;
        x[0] <= {{1'b1,i_data[FLOAT_FRAC_WIDTH-2:0]},5'b0} + (1 <<< 15); 
        y[0] <= {{1'b1,i_data[FLOAT_FRAC_WIDTH-2:0]},5'b0} - (1 <<< 15);
        alpha[0] <= 0;
        i[0] <= 0;
        k[0] <= 0;
    
        if(valid_cnt > 0) begin
            for (i2 = 1; i2 < ITERATION_NUM; i2 = i2+1) begin
                if(y[i2-1] < 0) begin
                    x[i2] <= x[i2-1] + (y[i2-1] >>> (i[i2-1]+1));
                    y[i2] <= y[i2-1] + (x[i2-1] >>> (i[i2-1]+1));
                    alpha[i2] <= alpha[i2-1] - atanh[i[i2-1]]; 
                end
                else begin
                    x[i2] <= x[i2-1] - (y[i2-1] >>> (i[i2-1]+1));
                    y[i2] <= y[i2-1] - (x[i2-1] >>> (i[i2-1]+1));
                    alpha[i2] <= alpha[i2-1] + atanh[i[i2-1]];
                end
    
                if(k[i2-1] == 4) begin
                    k[i2] <= 1;
                    i[i2] <= i[i2-1]+1;
                end
                else if (k[i2-1] == 3) begin
	                k[i2] <= k[i2-1] + 1;
                    i[i2] <= i[i2-1];
	            end
                else begin
                    k[i2] <= k[i2-1] + 1;
                    i[i2] <= i[i2-1] + 1;
                end
         
                shift_buffer[i2] <= shift_buffer[i2-1];
                shift_pn_buffer[i2] <= shift_pn_buffer[i2-1];
            end
        end
    end
    else begin
        for (i1 = 0; i1 < ITERATION_NUM; i1 = i1+1) begin
            x[i1] <= x[i1];
            y[i1] <= y[i1];
            alpha[i1] <= alpha[i1];
            i[i1] <= i[i1];
            k[i1] <= k[i1];
            shift_buffer[i1] <= shift_buffer[i1];
            shift_pn_buffer[i1] <= shift_pn_buffer[i1];
        end
    
        valid_cnt <= valid_cnt;
    end

assign o_valid = in_valid_buffer[ITERATION_NUM-1];
assign ln_0 = alpha[ITERATION_NUM-1] * 2;
assign ln2_value = shift_buffer[ITERATION_NUM-1]*22713;
assign ln = shift_pn_buffer[ITERATION_NUM-1] == 0 ? ln_0 + ln2_value : ln_0 - ln2_value;
 
assign ln_value = !i_rst_n ? 32'hffff_ffff :
    ln[FLOAT_FRAC_WIDTH+11] ? {9'b0,-(ln[FLOAT_FRAC_WIDTH+11:0])} : {9'b0,ln[FLOAT_FRAC_WIDTH+11:0]};
 
//find the leading one 
assign index[4] = (|ln_value[31:16]);
assign tmp3 = index[4] ? ln_value[31:16] : ln_value[15:0];

assign index[3] = (|tmp3[15:8]);
assign tmp0 = index[3] ? tmp3[15:8] : tmp3[7:0];

assign index[2] = (|tmp0[7:4]);
assign tmp1 = index[2] ? tmp0[7:4] : tmp0[3:0];

assign index[1] = (|tmp1[3:2]);
assign tmp2 = index[1] ? tmp1[3:2] : tmp1[1:0];

assign index[0] = tmp2[1];

//calculate the sign bit of float result
assign ln_float0[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1] = !i_rst_n ? 1'b1 : ln[FLOAT_FRAC_WIDTH+11];
//calculate the exponential bits of float result
assign ln_float0[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] = !i_rst_n ? 5'b11111 : 5'd0 + index; //99 = 127 - 28
//calculate the mantissa bits of float result
assign ln_value_shift = !i_rst_n ? 32'hffff_ffff : ln_value << (32 - index);
assign ln_float0[FLOAT_FRAC_WIDTH-2:0] = !i_rst_n ? 10'b1111111111 : 
                                        ln_value_shift[21] ? ln_value_shift[31:22] + 1 : ln_value_shift[31:22];

//adjust the output accorroding to the value of input 
assign o_ln_float = o_overflow ? {1'b0, {FLOAT_EXP_WIDTH{1'b1}}, {(FLOAT_FRAC_WIDTH-1){1'b0}}} :
                    o_invalid_op ? {1'b0, {FLOAT_EXP_WIDTH{1'b1}}, {(FLOAT_FRAC_WIDTH-1){1'b1}}} : ln_float0;

//judge if the input is valid
assign in_NaN = (i_data[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] == 5'b11111)&&(i_data[FLOAT_FRAC_WIDTH-2:0] != 0) ? 1 : 0;
assign in_INF = (i_data[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] == 5'b11111)&&(i_data[FLOAT_FRAC_WIDTH-2:0] == 0) ? 1 : 0;
assign o_invalid_op = invalid_op_buffer[ITERATION_NUM-1];
assign o_overflow = overflow_buffer[ITERATION_NUM-1];
assign o_underflow = underflow;

assign invalid_op = in_NaN || in_INF || i_data[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1] == 1;
assign overflow = in_INF;
assign underflow = ln_value == 0 ? 1 : 0;

//delay i_valid, invalid_op, overflow, to keep pace with output
integer i3;
always @(posedge i_clk or negedge i_rst_n)
    if(!i_rst_n) begin
        for (i3 = 0; i3 < ITERATION_NUM; i3 = i3+1) begin
            in_valid_buffer[i3] <= 0;
            invalid_op_buffer[i3] <= 0;
            overflow_buffer[i3] <= 0;
        end
    end
    else if (i_aclken) begin
        in_valid_buffer[0] <= i_valid;
        invalid_op_buffer[0] <= (i_data[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] == 5'b11111) || (i_data[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1] == 1);
        overflow_buffer[0] <= (i_data[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] == 5'b11111);
        for (i3 = 1; i3 < ITERATION_NUM; i3 = i3+1) begin
            in_valid_buffer[i3] <= in_valid_buffer[i3-1];
            invalid_op_buffer[i3] <= invalid_op_buffer[i3-1];
            overflow_buffer[i3] <= overflow_buffer[i3-1];
        end
    end

endmodule