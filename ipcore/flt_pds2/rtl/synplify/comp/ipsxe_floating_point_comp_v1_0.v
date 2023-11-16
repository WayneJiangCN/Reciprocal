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
// Filename:comp.v
// Function: output a signal according to users' requirement for two numbers
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_comp_v1_0 #(parameter EXPONENT_LENTH = 8, MANTISSA_LENTH = 23, LATENCY_CONFIG = 1) (
    i_clk,
    i_aclken,
    i_areset_n,
    i_axis_or_ab_tvalid,
    i_axis_a_tdata,
    i_axis_b_tdata,
    i_axis_operation_tdata,

    o_axis_result_tvalid_when_tready,
    o_axis_result_tdata
);
localparam LENTH = 1+EXPONENT_LENTH+MANTISSA_LENTH;
localparam PIPELINE_STAGE = 1;

//initialize input signals
input signed [LENTH-1:0] i_axis_a_tdata;
input signed [LENTH-1:0] i_axis_b_tdata;
input [2:0] i_axis_operation_tdata;
input i_clk;
input i_aclken;
input i_areset_n;
input i_axis_or_ab_tvalid;

//initialize output signals
output  [7:0] o_axis_result_tdata;
output o_axis_result_tvalid_when_tready;

//initialize  floating numbers components
wire a_sign;
wire b_sign;
wire [EXPONENT_LENTH-1:0] a_exponent;
wire [EXPONENT_LENTH-1:0] b_exponent;
wire [MANTISSA_LENTH-1:0] a_mantissa;
wire [MANTISSA_LENTH-1:0] b_mantissa;

//judge cases initialize
wire a_e_b;
wire a_sign_l_b_sign;
wire a_sign_e_b_sign;
wire a_exponent_g_b_exponent;
wire a_exponent_l_b_exponent;
wire a_exponent_e_b_exponent;
wire a_mantissa_g_b_mantissa;
wire a_mantissa_l_b_mantissa;

//propose some conditions to match the requirement of operation data
wire condition1,condition2,condition3,condition4,condition5,condition6;
wire greater_than;

//initialize some necessary constrains for outputs
wire [EXPONENT_LENTH-1:0] zero;
wire [EXPONENT_LENTH-1:0] exponent;
wire a_is_nan, b_is_nan;

//insert pipeline
reg no_outreg_o_axis_result_tvalid_when_tready;
reg [7:0] no_outreg_o_axis_result_tdata;

//component for each input number
//The floating point multiplier first intercepts the corresponding parts of the two input floating point numbers into sign bits, exponent bits and tail bits respectively.
assign a_sign  = i_axis_a_tdata[LENTH-1];
assign a_exponent = i_axis_a_tdata[LENTH-2:LENTH-EXPONENT_LENTH-1];
assign a_mantissa = i_axis_a_tdata[MANTISSA_LENTH-1:0];

assign b_sign  = i_axis_b_tdata[LENTH-1];
assign b_exponent = i_axis_b_tdata[LENTH-2:LENTH-EXPONENT_LENTH-1];
assign b_mantissa  = i_axis_b_tdata[MANTISSA_LENTH-1:0];
    
//judge cases
//Compare the corresponding positions of the two input data.
//assign a_e_b = ~(| (i_axis_a_tdata[LENTH-1:0] ^ i_axis_b_tdata[LENTH-1:0]));
assign a_e_b = (a_exponent_e_b_exponent & a_sign_e_b_sign &(a_mantissa==b_mantissa));

assign a_sign_l_b_sign = (~a_sign) & b_sign;
//assign a_sign_e_b_sign = ~(a_sign ^ b_sign);
assign a_sign_e_b_sign = (a_sign == b_sign);
assign a_exponent_g_b_exponent = a_exponent > b_exponent ? 1'b1:1'b0;
//assign a_exponent_l_b_exponent = a_exponent < b_exponent ? 1'b1:1'b0;
assign a_exponent_l_b_exponent = (!a_exponent_g_b_exponent) & (!a_exponent_e_b_exponent);

//assign a_exponent_e_b_exponent = ~(| (a_exponent[EXPONENT_LENTH-1:0] ^ b_exponent[EXPONENT_LENTH-1:0]));
assign a_exponent_e_b_exponent = a_exponent[EXPONENT_LENTH-1:0] == b_exponent[EXPONENT_LENTH-1:0];
assign a_mantissa_g_b_mantissa = a_mantissa > b_mantissa? 1'b1:1'b0;
//assign a_mantissa_l_b_mantissa = a_mantissa < b_mantissa? 1'b1:1'b0;
assign a_mantissa_l_b_mantissa = !a_mantissa_g_b_mantissa;


//In the module, this design mainly judges the size relationship of the two input floating point numbers through the size relationship of sign bits, exponential bits and tail bits.
//equal
assign condition1 = a_e_b || (a_exponent==0 && b_exponent==0);
//greater than
//assign condition2 = ~a_e_b & a_sign_l_b_sign;
//assign condition3 = ~a_e_b & a_sign_e_b_sign & (~a_sign) & a_exponent_g_b_exponent;
//assign condition4 = ~a_e_b & a_sign_e_b_sign & (~a_sign) & a_exponent_e_b_exponent & a_mantissa_g_b_mantissa;
//assign condition5 = ~a_e_b & a_sign_e_b_sign & (a_sign) & a_exponent_l_b_exponent;  
//assign condition6= ~a_e_b & a_sign_e_b_sign & (a_sign) & a_exponent_e_b_exponent & a_mantissa_l_b_mantissa;    
//assign greater_than = ( condition2 || condition3 || condition4 || condition5 || condition6) ? 1'b1:1'b0;
assign condition2 =   a_sign_l_b_sign;
wire condition_temp1 =  a_sign_e_b_sign& (~a_sign);
wire condition_temp2 =  a_sign_e_b_sign& (a_sign);

assign condition3 = condition_temp1 & a_exponent_g_b_exponent;
assign condition4 = condition_temp1 & a_exponent_e_b_exponent & a_mantissa_g_b_mantissa;
assign condition5 = condition_temp2 & a_exponent_l_b_exponent;  
assign condition6 = condition_temp2 & a_exponent_e_b_exponent & a_mantissa_l_b_mantissa;        
assign greater_than = ( condition2 || condition3 || condition4 || condition5 || condition6) ? 1'b1:1'b0;
//to describe NAN
//assign zero = 0;
//assign exponent = {1'b1,zero}-1;
//assign a_is_nan = (a_exponent==exponent)&&(a_mantissa!=0);
//assign b_is_nan = (b_exponent==exponent)&&(b_mantissa!=0);
assign a_is_nan = (&a_exponent)&(|a_mantissa);
assign b_is_nan = (&b_exponent)&(|b_mantissa);
 
//Output the corresponding result based on the operands given by the user.
always@(posedge i_clk or negedge i_areset_n)begin
    if (!i_areset_n) begin
        no_outreg_o_axis_result_tdata <= 0;
    end
    else if (i_aclken)
    if (i_axis_operation_tdata==3'b000)begin
        no_outreg_o_axis_result_tdata <= (a_is_nan||b_is_nan)?8'b0000_0001:8'b0000_0000;
    end
    else begin
        case (i_axis_operation_tdata)
            3'b001:begin//less than
                no_outreg_o_axis_result_tdata <= a_is_nan?8'b0:b_is_nan?8'b0:{7'b0,(~greater_than)&&(~condition1)};
            end
            3'b011:begin//less than or equal
                no_outreg_o_axis_result_tdata <= a_is_nan?8'b0:b_is_nan?8'b0:{7'b0,(~greater_than)||condition1};
            end
            3'b010:begin//equal
                no_outreg_o_axis_result_tdata <= a_is_nan?8'b0:b_is_nan?8'b0:{7'b0,condition1};
            end
            3'b100:begin//greater than
                no_outreg_o_axis_result_tdata <= a_is_nan?8'b0:b_is_nan?8'b0:{7'b0,greater_than&&(~condition1)};
            end
            3'b101:begin//not equal
                no_outreg_o_axis_result_tdata <= {7'b0,~condition1};
            end
            3'b110:begin//greater than or equal
                no_outreg_o_axis_result_tdata <= a_is_nan?8'b0:b_is_nan?8'b0:{7'b0,greater_than||condition1};
            end
            default begin//condition code
                if (a_is_nan|b_is_nan) no_outreg_o_axis_result_tdata <= 8'b0000_1000;//NAN
		else if (condition1) no_outreg_o_axis_result_tdata <= 8'b0000_0001;//equal
                else if (~greater_than) no_outreg_o_axis_result_tdata <= 8'b0000_0010;//less than
                else if (greater_than) no_outreg_o_axis_result_tdata <= 8'b0000_0100;//greater than
                
                else no_outreg_o_axis_result_tdata <= 8'b0000_0000;//else cases
            end
    endcase
    end
end

//pass input valid signal
always@(posedge i_clk or negedge i_areset_n)begin
    if (!i_areset_n) begin
        no_outreg_o_axis_result_tvalid_when_tready <=0;
    end
    else if (i_aclken) begin
        no_outreg_o_axis_result_tvalid_when_tready <= i_axis_or_ab_tvalid;
    end
end

generate
if (LATENCY_CONFIG == 1)begin
    assign {o_axis_result_tvalid_when_tready,o_axis_result_tdata} = {no_outreg_o_axis_result_tvalid_when_tready,no_outreg_o_axis_result_tdata};
end
else if (LATENCY_CONFIG == 2)begin
    wire [8:0] out_delay;
    ipsxe_floating_point_register_v1_0 #(9) outreg_further_inst(
        .i_clk(i_clk),
        .i_aclken(i_aclken),
        .i_rst_n(i_areset_n),
        .i_d({no_outreg_o_axis_result_tvalid_when_tready,no_outreg_o_axis_result_tdata}),
        .o_q(out_delay)
    );
    assign {o_axis_result_tvalid_when_tready,o_axis_result_tdata} = out_delay;
end
else begin //(LATENCY_CONFIG == 3)
    wire [17:0] out_delay;
    ipsxe_floating_point_register_v1_0 #(18) outreg_further_inst(
        .i_clk(i_clk),
        .i_aclken(i_aclken),
        .i_rst_n(i_areset_n),
        .i_d({out_delay[8:0],no_outreg_o_axis_result_tvalid_when_tready,no_outreg_o_axis_result_tdata}),
        .o_q(out_delay)
    );
    assign {o_axis_result_tvalid_when_tready,o_axis_result_tdata} = out_delay[17:9];
end
endgenerate

endmodule