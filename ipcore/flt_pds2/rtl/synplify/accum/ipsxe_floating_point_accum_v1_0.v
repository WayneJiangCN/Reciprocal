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
// Filename:ipsxe_floating_point_accum_v1_0.v
// Function: p=p+/-a
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_accum_v1_0 #(
    parameter EXP_WIDTH = 8,
    parameter MAN_WIDTH = 23,
    parameter MSB = 32,
    parameter LSB = -31,
    parameter INPUT_MSB = 32,
    parameter APM_USAGE = 0
)(
    input i_clk,
    input i_aclken,
    input i_rst_n,
    input [1+EXP_WIDTH+MAN_WIDTH-1:0] i_axis_a_tdata,
    input i_axis_operation_tdata,
    input i_axis_a_tvalid,
    input i_axis_a_tlast,
    output reg [1+EXP_WIDTH+MAN_WIDTH-1:0] o_axis_result_tdata,
    output o_axis_result_tvalid,
    output o_axis_result_tlast,

    output o_invalid_op,
    output o_accum_input_overflow,
    output o_accum_overflow
);

localparam WIDTH = 1 + EXP_WIDTH + MAN_WIDTH;
localparam FRAC_WIDTH = 1 + MAN_WIDTH;
localparam INPUT_FIXED_INT_BIT = INPUT_MSB - LSB + 1 + 1; // + 1: the sign bit
localparam ACCUM_WIDTH         =       MSB - LSB + 1 + 1; // + 1: the sign bit
localparam ACCUM_FIXED_INT_BIT  = (MSB >= 0 && LSB >= 0) ? (MSB + 1 + 1) : (MSB >= 0 && LSB < 0) ? (MSB + 1 + 1) : 1;
localparam ACCUM_FIXED_FRAC_BIT = (MSB >= 0 && LSB >= 0) ? 0             : (MSB >= 0 && LSB < 0) ? -LSB          : -LSB;
localparam ACCUM_FIXED_BIT      = ACCUM_FIXED_INT_BIT + ACCUM_FIXED_FRAC_BIT;

wire [WIDTH-1:0] a;
reg signed [ACCUM_WIDTH-1:0] sum;
wire signed [INPUT_FIXED_INT_BIT-1:0] a_fl2fx;

wire [1 + EXP_WIDTH-1:0] a_exp_minus_lsb_out_gen; // 移位数
wire [1 + ACCUM_WIDTH-1:0] sum_plus_a_fl2fx_out_gen;

wire i_axis_a_tlast_reg1, i_axis_a_tlast_reg2, i_axis_a_tlast_reg3;
ipsxe_floating_point_register_v1_0 #(1) u_reg_tlast_reg1(i_clk, i_aclken, i_rst_n, i_axis_a_tlast     , i_axis_a_tlast_reg1);
ipsxe_floating_point_register_v1_0 #(1) u_reg_tlast_reg2(i_clk, i_aclken, i_rst_n, i_axis_a_tlast_reg1, i_axis_a_tlast_reg2);
ipsxe_floating_point_register_v1_0 #(1) u_reg_tlast_reg3(i_clk, i_aclken, i_rst_n, i_axis_a_tlast_reg2, i_axis_a_tlast_reg3);
generate
    if (APM_USAGE == 0) begin
        wire [EXP_WIDTH-1:0] a_exp_minus_lsb /*synthesis syn_dspstyle = "logic" */;
        wire signed [ACCUM_WIDTH-1:0] sum_plus_a_fl2fx /*synthesis syn_dspstyle = "logic" */;
        assign a_exp_minus_lsb = a[MAN_WIDTH+:EXP_WIDTH] - LSB;
        assign sum_plus_a_fl2fx =  i_axis_a_tlast_reg3 ==1?  (!a_fl2fx[INPUT_FIXED_INT_BIT-2:0]==1?{1'b0,a_fl2fx[INPUT_FIXED_INT_BIT-2:0]}:a_fl2fx)   : sum + (!a_fl2fx[INPUT_FIXED_INT_BIT-2:0]==1?{1'b0,a_fl2fx[INPUT_FIXED_INT_BIT-2:0]}:a_fl2fx);
        assign a_exp_minus_lsb_out_gen = {1'b0, a_exp_minus_lsb};
        assign sum_plus_a_fl2fx_out_gen = {1'b0, sum_plus_a_fl2fx};
    end
    else if (APM_USAGE == 1) begin
        wire [EXP_WIDTH-1:0] a_exp_minus_lsb /*synthesis syn_dspstyle = "logic" */;
        wire signed [ACCUM_WIDTH-1:0] sum_plus_a_fl2fx /*synthesis syn_dspstyle = "block_mult" */;
        assign a_exp_minus_lsb = a[MAN_WIDTH+:EXP_WIDTH] - LSB;
        assign sum_plus_a_fl2fx =  i_axis_a_tlast_reg3 ==1?  (!a_fl2fx[INPUT_FIXED_INT_BIT-2:0]==1?{1'b0,a_fl2fx[INPUT_FIXED_INT_BIT-2:0]}:a_fl2fx)   : sum + (!a_fl2fx[INPUT_FIXED_INT_BIT-2:0]==1?{1'b0,a_fl2fx[INPUT_FIXED_INT_BIT-2:0]}:a_fl2fx);
        assign a_exp_minus_lsb_out_gen = {1'b0, a_exp_minus_lsb};
        assign sum_plus_a_fl2fx_out_gen = {1'b0, sum_plus_a_fl2fx};
    end
    else begin // APM_USAGE == 2
        wire [EXP_WIDTH-1:0] a_exp_minus_lsb /*synthesis syn_dspstyle = "block_mult" */;
        wire signed [ACCUM_WIDTH-1:0] sum_plus_a_fl2fx /*synthesis syn_dspstyle = "block_mult" */;
        assign a_exp_minus_lsb = a[MAN_WIDTH+:EXP_WIDTH] - LSB;
        assign sum_plus_a_fl2fx =  i_axis_a_tlast_reg3 ==1?  (!a_fl2fx[INPUT_FIXED_INT_BIT-2:0]==1?{1'b0,a_fl2fx[INPUT_FIXED_INT_BIT-2:0]}:a_fl2fx)   : sum + (!a_fl2fx[INPUT_FIXED_INT_BIT-2:0]==1?{1'b0,a_fl2fx[INPUT_FIXED_INT_BIT-2:0]}:a_fl2fx);

        assign a_exp_minus_lsb_out_gen = {1'b0, a_exp_minus_lsb};
        assign sum_plus_a_fl2fx_out_gen = {1'b0, sum_plus_a_fl2fx};
    end
endgenerate

// denormalized -> zero, operation = 0 then add
wire a_is_denorm = (i_axis_a_tdata[WIDTH-2-:EXP_WIDTH] == 0) & (i_axis_a_tdata[MAN_WIDTH-1:0] != 0);
wire a_sign_operation = i_axis_operation_tdata ? ~i_axis_a_tdata[WIDTH-1] : i_axis_a_tdata[WIDTH-1];
assign a = a_is_denorm ? 0 : {a_sign_operation, i_axis_a_tdata[WIDTH-2:0]};

// judge whether a is positive infinite or negative infinite or not-a-number
wire is_pinf = (a[WIDTH-2:WIDTH-EXP_WIDTH-1]=={EXP_WIDTH{1'b1}}) & (~|a[MAN_WIDTH-1:0]) & ~a[WIDTH-1];
wire is_pinf_reg1, pos_infinite_fl2fx;

ipsxe_floating_point_register_v1_0 #(1) u_reg_is_pinf_reg1(i_clk, i_aclken, i_rst_n, is_pinf, is_pinf_reg1); // pipeline stage 1
ipsxe_floating_point_register_v1_0 #(1) u_reg_pos_infinite_fl2fx(i_clk, i_aclken, i_rst_n, is_pinf_reg1, pos_infinite_fl2fx); // pipeline stage 2

wire is_ninf = (a[WIDTH-2:WIDTH-EXP_WIDTH-1]=={EXP_WIDTH{1'b1}}) & (~|a[MAN_WIDTH-1:0]) &  a[WIDTH-1];
wire is_ninf_reg1, neg_infinite_fl2fx;

ipsxe_floating_point_register_v1_0 #(1) u_reg_is_ninf_reg1(i_clk, i_aclken, i_rst_n, is_ninf, is_ninf_reg1); // pipeline stage 1
ipsxe_floating_point_register_v1_0 #(1) u_reg_neg_infinite_fl2fx(i_clk, i_aclken, i_rst_n, is_ninf_reg1, neg_infinite_fl2fx); // pipeline stage 2

wire is_nan  = (a[WIDTH-2:WIDTH-EXP_WIDTH-1]=={EXP_WIDTH{1'b1}}) & ( |a[MAN_WIDTH-1:0]);
wire is_nan_reg1, nan_fl2fx;

ipsxe_floating_point_register_v1_0 #(1) u_reg_is_nan_reg1(i_clk, i_aclken, i_rst_n, is_nan, is_nan_reg1); // pipeline stage 1
ipsxe_floating_point_register_v1_0 #(1) u_reg_nan_fl2fx(i_clk, i_aclken, i_rst_n, is_nan_reg1, nan_fl2fx); // pipeline stage 2

// o_accum_input_overflow
wire accum_input_overflow_input = (a[MAN_WIDTH+:EXP_WIDTH] != {EXP_WIDTH{1'b1}}) && (a[MAN_WIDTH+:EXP_WIDTH] > INPUT_MSB + {(EXP_WIDTH-1){1'b1}});
wire accum_input_overflow_reg1, accum_input_overflow_fl2fx;
ipsxe_floating_point_register_v1_0 #(1) u_reg_accum_input_overflow_reg1(i_clk, i_aclken, i_rst_n, accum_input_overflow_input, accum_input_overflow_reg1);
ipsxe_floating_point_register_v1_0 #(1) u_reg_accum_input_overflow_fl2fx(i_clk, i_aclken, i_rst_n, accum_input_overflow_reg1, accum_input_overflow_fl2fx);

wire valid_fl2fx, overflow_fl2fx, underflow_fl2fx;
ipsxe_floating_point_float_to_fixed_v1_0 #(
    .FLOAT_EXP_BIT(EXP_WIDTH),
    .FLOAT_FRAC_BIT(FRAC_WIDTH),
    .FIXED_INT_BIT(INPUT_FIXED_INT_BIT),
    .FIXED_FRAC_BIT(0)
) u1 (
    i_clk,
    i_aclken,
    i_rst_n,
    {a[WIDTH-1], a_exp_minus_lsb_out_gen[EXP_WIDTH-1:0], a[MAN_WIDTH-1:0]},
    i_axis_a_tvalid,
    a_fl2fx,
    1'b1,
    valid_fl2fx,
    underflow_fl2fx,
    overflow_fl2fx
);

wire accum_overflow_fl2fx =  i_axis_a_tlast_reg1 !=0 &(a_fl2fx[INPUT_FIXED_INT_BIT-1] == sum[ACCUM_WIDTH-1]) & (sum_plus_a_fl2fx_out_gen[ACCUM_WIDTH-1] != sum[ACCUM_WIDTH-1]);



reg [1:0] sum_state, output_state;
wire invalid_op_fl2fx = (sum_state == 2 && neg_infinite_fl2fx) || (sum_state == 3 && pos_infinite_fl2fx);

wire testb = ~i_axis_a_tlast_reg3;
wire testaaa = nan_fl2fx || accum_input_overflow_fl2fx || ( accum_overflow_fl2fx & testb ) || sum_state ==1 || ( sum_state==2 && neg_infinite_fl2fx )  ||( sum_state==3 && pos_infinite_fl2fx )       || ( sum_state==3 && pos_infinite_fl2fx );

always @(posedge i_clk or negedge i_rst_n) begin: blk_sum
    if(~i_rst_n) begin
        sum <= 0;
        sum_state <= 0; // 0: sum is positive or negative or zero
        output_state <= 0; // 0: sum is positive or negative or zero
    end else if (i_aclken)
        if(valid_fl2fx)
            if(i_axis_a_tlast_reg2) begin
                sum_state <= 0; // 0: sum is positive or negative or zero

                 if(   testaaa )  begin
                //if( (i_axis_a_tlast_reg3 !=1)&&  ((nan_fl2fx || accum_input_overflow_fl2fx || accum_overflow_fl2fx || sum_state ==1   ))   )  begin

                    sum <= 0;
                    output_state <= 1; // 1: NaN
                end else if(pos_infinite_fl2fx | sum_state == 2 ) begin
                    sum <= 0;
                    output_state <= 2; // 2: positive infinite
                end else if(neg_infinite_fl2fx | sum_state == 3 ) begin
                    sum <= 0;
                    output_state <= 3; // 3: negative infinite
                end else begin
                    sum <= sum_plus_a_fl2fx_out_gen[ACCUM_WIDTH-1:0];
                    output_state <= 0; // 0: sum is positive or negative or zero
                end
            end else begin
                if(nan_fl2fx | accum_input_overflow_fl2fx) begin
                    sum <= 0;
                    output_state <= 1; // 1: NaN
                    sum_state <= 1; // 1: NaN
                end else begin
                case(sum_state)
                    2'd0:
                        if(accum_overflow_fl2fx & testb ) begin
                            sum <= 0;
                            sum_state <= 1; // 1: NaN
                            output_state <= 1; // 1: NaN
                        end else if(pos_infinite_fl2fx) begin
                            sum <= 0;
                            sum_state <= 2; // 2: positive infinite
                            output_state <= 2; // 2: positive infinite
                        end else if(neg_infinite_fl2fx) begin
                            sum <= 0;
                            sum_state <= 3; // 3: negative infinite
                            output_state <= 3; // 3: negative infinite
                        end else begin
                            sum <= sum_plus_a_fl2fx_out_gen[ACCUM_WIDTH-1:0];
                            sum_state <= 0; // 0: sum is positive or negative or zero
                            output_state <= 0; // 0: sum is positive or negative or zero
                        end
                    2'd1: begin
                        sum <= 0;
                        sum_state <= 1; // 1: NaN
                        output_state <= 1; // 1: NaN
                    end
                    2'd2:
                        if(neg_infinite_fl2fx) begin
                            sum <= 0;
                            sum_state <= 1; // 1: NaN
                            output_state <= 1; // 1: NaN
                        end else begin
                            sum <= 0;
                            sum_state <= 2; // 2: positive infinite
                            output_state <= 2; // 2: positive infinite
                        end
                    2'd3:
                        if(pos_infinite_fl2fx) begin
                            sum <= 0;
                            sum_state <= 1; // 1: NaN
                            output_state <= 1; // 1: NaN
                        end else begin
                            sum <= 0;
                            sum_state <= 3; // 3: negative infinite
                            output_state <= 3; // 3: negative infinite
                        end
                    default: begin
                        sum <= sum;
                        sum_state <= sum_state;
                        output_state <= output_state;
                    end
                endcase
                end
            end
        else begin
            sum <= sum;
            sum_state <= sum_state;
            output_state <= output_state;
        end
end

wire valid_fl2fx_reg1;
ipsxe_floating_point_register_v1_0 #(1) u_reg_valid_fl2fx(i_clk, i_aclken, i_rst_n, valid_fl2fx, valid_fl2fx_reg1);
wire [1:0] output_state_reg1;
ipsxe_floating_point_register_v1_0 #(2) u_reg_output_state(i_clk, i_aclken, i_rst_n, output_state, output_state_reg1);

wire signed [ACCUM_FIXED_BIT-1:0] sum_fixed1 = ((LSB >= 0) ? (sum << LSB) : sum);  //////////
wire signed [63:0] sum_fixed2 = sum_fixed1[ACCUM_FIXED_BIT-1:ACCUM_FIXED_BIT-64];

wire [WIDTH-1:0] sum_fx2fl;
ipsxe_floating_point_fx2fl_axi_v1_0 #(
    .FIXED_INT_BIT(ACCUM_FIXED_INT_BIT),
    .FIXED_FRAC_BIT(((ACCUM_FIXED_INT_BIT+ACCUM_FIXED_FRAC_BIT)>64)?64-ACCUM_FIXED_INT_BIT:ACCUM_FIXED_FRAC_BIT),
    .FLOAT_EXP_BIT(EXP_WIDTH),
    .FLOAT_FRAC_BIT(FRAC_WIDTH),
    .INT_TYPE(1'b0) // 1'b0: int; 1'b1: uint
) u4 (
    i_clk,
    i_aclken,
    i_rst_n,
    (((ACCUM_FIXED_INT_BIT+ACCUM_FIXED_FRAC_BIT)>64)?sum_fixed2:sum_fixed1),
    valid_fl2fx_reg1,
    sum_fx2fl,
    o_axis_result_tvalid
);
always @(*) begin: blk_o_axis_result_tdata
    case (output_state_reg1)
        2'd1: o_axis_result_tdata = {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
        2'd2: o_axis_result_tdata = {1'b0, {EXP_WIDTH{1'b1}}, {MAN_WIDTH{1'b0}}}; // pos inf
        2'd3: o_axis_result_tdata = {1'b1, {EXP_WIDTH{1'b1}}, {MAN_WIDTH{1'b0}}}; // neg inf
        default: o_axis_result_tdata = sum_fx2fl;
    endcase
end

wire accum_overflow_fl2fx_reg1;
ipsxe_floating_point_register_v1_0 #(1) u_reg_accum_overflow_fl2fx_reg1(i_clk, i_aclken, i_rst_n, accum_overflow_fl2fx     , accum_overflow_fl2fx_reg1);
ipsxe_floating_point_register_v1_0 #(1) u_reg_accum_overflow_fl2fx_reg2(i_clk, i_aclken, i_rst_n, accum_overflow_fl2fx_reg1, o_accum_overflow);

wire accum_input_overflow_fl2fx_reg1;
ipsxe_floating_point_register_v1_0 #(1) u_reg_accum_input_overflow_fl2fx_reg1(i_clk, i_aclken, i_rst_n, accum_input_overflow_fl2fx     , accum_input_overflow_fl2fx_reg1);
ipsxe_floating_point_register_v1_0 #(1) u_reg_accum_input_overflow_fl2fx_reg2(i_clk, i_aclken, i_rst_n, accum_input_overflow_fl2fx_reg1, o_accum_input_overflow);

wire invalid_op_fl2fx_reg1;
ipsxe_floating_point_register_v1_0 #(1) u_reg_invalid_op_fl2fx_reg1(i_clk, i_aclken, i_rst_n, invalid_op_fl2fx     , invalid_op_fl2fx_reg1);
ipsxe_floating_point_register_v1_0 #(1) u_reg_invalid_op_fl2fx_reg2(i_clk, i_aclken, i_rst_n, invalid_op_fl2fx_reg1, o_invalid_op);

wire i_axis_a_tlast_reg4;
ipsxe_floating_point_register_v1_0 #(1) u_reg_tlast_reg4(i_clk, i_aclken, i_rst_n, i_axis_a_tlast_reg3, o_axis_result_tlast);
//ipsxe_floating_point_register_v1_0 #(1) u_reg_tlast_reg5(i_clk, i_aclken, i_rst_n, i_axis_a_tlast_reg4, o_axis_result_tlast);

endmodule