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
// Filename: ipsxe_floating_point_invsqrt_32_v1_0.v
// Function: This module calculates the inverse square-root
//           of the single precision floating-point numbers.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_invsqrt_32_apm_full_v1_0 #(parameter EXP_WIDTH = 8, MAN_WIDTH = 23, RNE = 2, RNE1 = 20, RNE2 = 21, LATENCY_CONFIG = 1) (
    input i_clk,
    input i_aclken,
    input i_rst_n,
    input i_valid,
    input [(1+EXP_WIDTH+MAN_WIDTH)-1:0] i_x_norm_or_denorm,
    output o_valid,
    output [(1+EXP_WIDTH+MAN_WIDTH)-1:0] o_invsqrt_x,
    output o_invalid_op,
    output o_divide_by_zero
);
// This module calculates the reciprocal square-root (o_invsqrt_x) of the input single precision floating-point number (i_x_norm_or_denorm),
// using the Taylor-series expansion
// According to the precision requirement, this "single precision" module uses the first 5 terms of the Taylor-series
// Reference paper: Floating-Point Inverse Square Root Algorithm Based on Taylor-Series Expansion, Author: Jianglin Wei et al.

// RNE, RNE1, RNE2 are the round-off bits at different pipeline stages
// MAN_WIDTH, RNE, RNE1, RNE2 should satisfy:
// 1. ((MAN_WIDTH+1)+RNE+RNE1)/2 is an integer, so (MAN_WIDTH+1)+RNE+RNE1 should be even
// 2. ((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2 is an integer, so (((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2 should be even
// 3. these two expressions cannot be greater than MAN_WIDTH

localparam WIDTH = 1+EXP_WIDTH+MAN_WIDTH;
localparam PIPE_STAGE_NUM_MAX = 7; // the last pipeline stage of this module

localparam P_INIT0_RNE = 2 ** (RNE-1);
localparam P_INIT1_RNE = (2 ** (RNE-1)) - 1;
localparam P_INIT0_RNE1 = 2 ** (RNE1-1);
localparam P_INIT1_RNE1 = (2 ** (RNE1-1)) - 1;
localparam P_INIT0_RNE2 = 2 ** (RNE2-1);
localparam P_INIT1_RNE2 = (2 ** (RNE2-1)) - 1;

wire [(((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2-7-1:0] a3_y_rne2_dlt7zeros;
wire [(MAN_WIDTH+1)+RNE+RNE1-5-1:0] a1_y_rne1_dlt5zeros;
wire [(((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2-10-1:0] a4_z_rne2_dlt10zeros;
wire [(MAN_WIDTH+1)+RNE+RNE1-9-1:0] z_group_rne1_dlt9zeros;

// reg [((MAN_WIDTH+1)+RNE)-1:0] a0;
reg [((MAN_WIDTH+1)+RNE)-3-1:0] a0_lo23;
reg [1:0] a0_hi2nd3rd;
reg [(((MAN_WIDTH+1)+RNE+RNE1)/2)-1-1:0] a1;
reg [(((MAN_WIDTH+1)+RNE+RNE1)/2)-1-1:0] a2;
reg [(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2)-1-1:0] a3;
reg [(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2)-2-1:0] a4;
reg [(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2/2)-2-1:0] a5;
wire [3:0] x_exp_lo1_man_hi3_dly1, x_exp_lo1_man_hi3_dly2, x_exp_lo1_man_hi3_dly3, x_exp_lo1_man_hi3_dly4;
wire x_is_denorm, i_valid_dly1;
wire [WIDTH-1:0] x, x_dly1;
wire x_is_neg, x_is_zero, x_is_nan_zero_neg, x_is_nan_zero_neg_dly8, x_is_pos_inf, x_is_pos_inf_dly8;
wire [EXP_WIDTH-1:0] invsqrt_x_exp, invsqrt_x_exp_dly1, invsqrt_x_exp_dly1p25, invsqrt_x_exp_dly2, invsqrt_x_exp_dly3, invsqrt_x_exp_dly4, invsqrt_x_exp_dly5, invsqrt_x_exp_minus1, invsqrt_x_exp_plus1;
wire x_minus_a_is_pos, x_minus_a_is_pos_dly1, x_minus_a_is_pos_dly1p25, x_minus_a_is_pos_dly2;
wire [MAN_WIDTH-3-1:0] y_dlt3zeros, y_dlt3zeros_dly1;
wire [(((MAN_WIDTH+1)+RNE+RNE1)/2 - 3 - 3)-1:0] y_dlt3zeros_cut_dly2;
wire y_dlt3zeros_hi1_dly2;
// wire [(MAN_WIDTH+1)+RNE-1:0] a0_dly1, a0_dly1p25, a0_dly2, a0_dly3, a0_dly4, a0_dly5, a0_dly6, a0_dly7;
wire [((MAN_WIDTH+1)+RNE)-3-1:0] a0_lo23_dly1;
wire [1:0] a0_hi2nd3rd_dly1;
wire [((MAN_WIDTH+1)+RNE+RNE1)/2-1-1:0] a1_dly1, a1_dly2;
wire [((MAN_WIDTH+1)+RNE+RNE1)/2-1-1:0] a2_dly1;
wire [(((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2-8-1:0] z_rne2_dlt7zeros_cutbit;
wire [((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2-1-1:0] a3_dly1;
wire [((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2-2-1:0] a4_dly1;
wire [((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2/2-2-1:0] a5_dly1;
wire [(((MAN_WIDTH+1)+RNE+RNE1)/2-1)+3-1-1:0] a1_y_rne1_hi, a1_y_rne1_hi_dly1;
wire [((MAN_WIDTH+1)+RNE+RNE1)/2-7-1:0] z_dlt7zeros, z_dlt7zeros_dly1, z_dlt7zeros_dly2;
wire [((MAN_WIDTH+1)+RNE+RNE1)/2-7-1:0] a3_y_dlt7zeros;
wire [(MAN_WIDTH+1)+RNE-5-1:0] a1_y_dlt5zeros;
wire [((MAN_WIDTH+1)+RNE+RNE1)/2-10-1:0] a4_z_dlt10zeros;
// wire [((MAN_WIDTH+1)+RNE+RNE1)/2-1-1:0] a2_plus_a4z_minus_a3y_dlt1zero_nosel, a2_plus_a4z_plus_a3y_dlt1zero_nosel;
wire [((MAN_WIDTH+1)+RNE+RNE1)/2-1-1:0] a2_plus_a3y_plus_a4z_dlt1zero;
wire [(MAN_WIDTH+1)+RNE-9-1:0] z_group_dlt9zeros;
// wire [1+(MAN_WIDTH+1)+RNE-1:0] a0_plus_zgroup_minus_a1y, a0_plus_zgroup_plus_a1y;
wire [1+(MAN_WIDTH+1)+RNE-1:0] invsqrt_x_taylor_rne;
wire [1 + (MAN_WIDTH+1)-1:0] invsqrt_x_taylor;
wire [WIDTH-1:0] invsqrt_x_valid_or_not;
wire [4:0] special_cases, special_cases_dly1, special_cases_dly1p25, special_cases_dly2, special_cases_dly3, special_cases_dly4;
wire [((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2-2-1:0] a4_plus_a5_y_dlt2zeros;
wire no_outreg_o_valid;
wire [(1+EXP_WIDTH+MAN_WIDTH)-1:0] no_outreg_o_invsqrt_x;
wire no_outreg_o_invalid_op;
wire no_outreg_o_divide_by_zero;

// determine whether x is a denormalized number, if so, set it to zero
assign x_is_denorm = (i_x_norm_or_denorm[WIDTH-2-:EXP_WIDTH] == {EXP_WIDTH{1'b0}}) & (i_x_norm_or_denorm[MAN_WIDTH-1:0] != {MAN_WIDTH{1'b0}});
assign x = x_is_denorm ? {WIDTH{1'b0}} : i_x_norm_or_denorm;

// determine whether x is a special floating point number, such as NaN or Inf
assign x_is_neg = (x_dly1[WIDTH-1] == 1'b1) & (((x_dly1[WIDTH-2-:EXP_WIDTH] == {EXP_WIDTH{1'b1}}) & (x_dly1[MAN_WIDTH-1:0] == {MAN_WIDTH{1'b0}})) | ((x_dly1[WIDTH-2-:EXP_WIDTH] <= ({EXP_WIDTH{1'b1}} - 1'b1)) & (x_dly1[WIDTH-2-:EXP_WIDTH] >= 1'b1)));
assign x_is_zero = (x_dly1[WIDTH-2:0] == {(WIDTH-1){1'b0}});
assign x_is_nan_zero_neg = ((x_dly1[WIDTH-2-:EXP_WIDTH] == {EXP_WIDTH{1'b1}}) & (x_dly1[MAN_WIDTH-1:0] != {MAN_WIDTH{1'b0}})) | x_is_zero | x_is_neg;
assign x_is_pos_inf = (x_dly1[WIDTH-1] == 1'b0) & (x_dly1[WIDTH-2-:EXP_WIDTH] == {EXP_WIDTH{1'b1}}) & (x_dly1[MAN_WIDTH-1:0] == {MAN_WIDTH{1'b0}});

// calculate the square-root of exp
ipsxe_floating_point_exp_invsqrt_minus1_v1_0 #(EXP_WIDTH) u_exp_invsqrt_minus1(
        .i_exp(x_dly1[WIDTH-2-:EXP_WIDTH]),
        .o_exp_invsqrt_minus1(invsqrt_x_exp)
);

generate
if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (1 / 2)) begin
// pipeline stage 0.5 (actually 1)
ipsxe_floating_point_register_v1_0 #(1 + WIDTH) u_reg_stage0p5(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({i_valid     , x     }),
    .o_q({i_valid_dly1, x_dly1})
);
end
else begin
assign {i_valid_dly1, x_dly1} = {i_valid     , x     };
end
endgenerate

// find the center a of the Taylor-series according to the 3 most significand bits of the man part of x, and then use the pre-calculated a0-a4 in the LUTs
always @(*) begin: blk_a1_a3_a4_a5
    case(x_dly1[MAN_WIDTH-:4])
        4'b0000: {a1, a3, a4, a5} = {22'h295232, 21'hb7038, 20'h96b7a, 9'hff};
        4'b0001: {a1, a3, a4, a5} = {22'h22f8b6, 21'h7bffb, 20'h5b5e1, 9'h8a};
        4'b0010: {a1, a3, a4, a5} = {22'h1e18b4, 21'h575ae, 20'h3a3c9, 9'h50};
        4'b0011: {a1, a3, a4, a5} = {22'h1a41eb, 21'h3f88c, 20'h26ac5, 9'h30};
        4'b0100: {a1, a3, a4, a5} = {22'h172ba4, 21'h2f740, 20'h1a92e, 9'h1f};
        4'b0101: {a1, a3, a4, a5} = {22'h14a4ee, 21'h243f7, 20'h12cb9, 9'h14};
        4'b0110: {a1, a3, a4, a5} = {22'h128bc0, 21'h1c3a1, 20'hda07 , 9'he };
        4'b0111: {a1, a3, a4, a5} = {22'h10c7c9, 21'h1659c, 20'ha180 , 9'h9 };
        4'b1000: {a1, a3, a4, a5} = {22'h3a6fd3, 21'h102d21, 20'hd5257, 9'h169};
        4'b1001: {a1, a3, a4, a5} = {22'h31750b, 21'haf5c5 , 20'h81369, 9'hc4 };
        4'b1010: {a1, a3, a4, a5} = {22'h2a9019, 21'h7b89e , 20'h525bf, 9'h71 };
        4'b1011: {a1, a3, a4, a5} = {22'h25223a, 21'h59d9d , 20'h36b12, 9'h44 };
        4'b1100: {a1, a3, a4, a5} = {22'h20c49c, 21'h431be , 20'h2594c, 9'h2b };
        4'b1101: {a1, a3, a4, a5} = {22'h1d3205, 21'h33432 , 20'h1a949, 9'h1c };
        4'b1110: {a1, a3, a4, a5} = {22'h1a3a55, 21'h27eb3 , 20'h13457, 9'h13 };
        default: {a1, a3, a4, a5} = {22'h17bb28, 21'h1f9bc , 20'he466 , 9'hd  };
    endcase
end

// next, calculate the Taylor-series expression, but in several pipeline stages
// assign a = {x[MAN_WIDTH-1-:3], 1'b1};
// o_invsqrt_x = a0 - a1 * (x - a) + a2 * (x - a)^2 - a3 * (x - a)^3 + a4 * (x - a)^4 - a5 * (x - a)^5
// set y = x - a, z = y^2
// o_invsqrt_x = a0 - a1 * y + a2 * y^2 - a3 * y^3 + a4 * y^4
//           = a0 - a1 * y + z * (a2 - a3 * y + z * (a4 - a5 * y))
// note: the post-fix _rne or _rne1 or _rne2 means this signal keeps RNE or RNE1 or RNE2 more bits,
// and these bits will be rounded off later by calling the "ipsxe_floating_point_rne_v1_0" module

// if x minus a is positive, then x_minus_a_is_pos is 1
assign x_minus_a_is_pos = x_dly1[MAN_WIDTH-4]; // which means: x[MAN_WIDTH-1:0] >= {a, {(MAN_WIDTH-4){1'b0}}};
// the selection according to x_minus_a_is_pos makes sure that y is positive
// y = (x - a) or (a - x)
assign y_dlt3zeros = x_minus_a_is_pos ? {1'b0, x_dly1[MAN_WIDTH-5:0]} : ({1'b1, {(MAN_WIDTH-4){1'b0}}} - {1'b0, x_dly1[MAN_WIDTH-5:0]}); // which means: x_minus_a_is_pos ? x[MAN_WIDTH-1:0] - {a, {(MAN_WIDTH-4){1'b0}}} : {a, {(MAN_WIDTH-4){1'b0}}} - x[MAN_WIDTH-1:0];

// gather all special cases signals
assign special_cases = {i_valid_dly1, x_is_neg, x_is_zero, x_is_nan_zero_neg, x_is_pos_inf};

generate
if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/2) - (2 / 4)) begin
// pipeline stage 2
ipsxe_floating_point_register_v1_0 #(6*1 + 4 + EXP_WIDTH + ((MAN_WIDTH+1)+RNE+RNE1)/2-1 + ((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2-1 + (((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2)-2 + (((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2/2)-2 + MAN_WIDTH-3) u_reg_stage1(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases     , x_minus_a_is_pos     , x_dly1[MAN_WIDTH-:4]  , invsqrt_x_exp     , a1     , a3     , a4     , a5     , y_dlt3zeros     }),
    .o_q({special_cases_dly1, x_minus_a_is_pos_dly1, x_exp_lo1_man_hi3_dly1, invsqrt_x_exp_dly1, a1_dly1, a3_dly1, a4_dly1, a5_dly1, y_dlt3zeros_dly1})
);
end
else begin
assign {special_cases_dly1, x_minus_a_is_pos_dly1, x_exp_lo1_man_hi3_dly1, invsqrt_x_exp_dly1, a1_dly1, a3_dly1, a4_dly1, a5_dly1, y_dlt3zeros_dly1} = {special_cases     , x_minus_a_is_pos     , x_dly1[MAN_WIDTH-:4]  , invsqrt_x_exp     , a1     , a3     , a4     , a5     , y_dlt3zeros     };
end
endgenerate

// z = y^2
// previously: assign z_rne2_dlt7zeros = y_dlt3zeros_dly1[MAN_WIDTH-3-1-:(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2 - 4)] * y_dlt3zeros_dly1[MAN_WIDTH-3-1-:(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2 - 2)];
// and after a pipeline stage: ipsxe_floating_point_rne_v1_0 #(((MAN_WIDTH+1)+RNE+RNE1)/2-7, RNE2) u_rne_z   (   z_rne2_dlt7zeros_dly2,    z_dlt7zeros);
// now: apm with the configurable pipeline stage 3 inside, at the output port of apm
    GTP_APM_E2 #(
        .GRS_EN         ( "TRUE"                 ) ,  //"TRUE","FALSE",enable global reset
        .USE_POSTADD    ( 1'b1            ) ,  //enable postadder 0/1
        .USE_PREADD     ( 1'b0                   ) ,  //enable preadder 0/1
        .PREADD_REG     ( 1'b0                   ) ,  //preadder reg 0/1

        .X_REG          ( 2'b0           ) ,  //X input reg 0/1
        .CXO_REG        ( 2'b0                   ) ,  //X cascade out reg latency, 0/1/2/3
        .XB_REG         ( 1'b0                   ) ,  //XB input reg 0/1
        .Y_REG          ( 2'b0        ) ,  //Y input reg 0/1
        .Z_REG          ( 2'b0           ) ,  //Z input reg 0/1
        .MULT_REG       ( 1'b0        ) ,  //multiplier reg 0/1
        .P_REG          ( (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (3 / 2))           ) ,  //post adder reg 0/1
        .MODEY_REG      ( 1'b0                   ) ,  //MODEY reg
        .MODEZ_REG      ( 1'b0        ) ,  //MODEZ reg
        .MODEIN_REG     ( 1'b0                   ) ,  //MODEZ reg

        .X_SEL          ( 1'b0                   ) ,  // mult X input select X/CXI
        .XB_SEL         ( 2'b0                   ) ,  //X back propagate mux select. 0/1/2/3
        .ASYNC_RST      ( 1'b0           ) ,  // RST is sync/async
        .USE_SIMD       ( 1'b0            ) ,  // single addsub25_mult25_add48 / dual addsub12_mult12_add24
        .P_INIT0        ( P_INIT0_RNE2             ) ,  //P constant input0 (RTI parameter in APM of PG family)
        .P_INIT1        ( P_INIT1_RNE2             ) ,  //P constant input1 (RTI parameter in APM of PG family)
        .ROUNDMODE_SEL  ( 1'b1                   ) ,  //round mode selection

        .CPO_REG        ( 1'b0          ) ,  // CPO,COUT use register output
        .USE_ACCLOW     ( 1'b0                   ) ,  // accumulator use lower 18-bit feedback only
        .CIN_SEL        ( 1'b0                   )    // select CIN for postadder carry in

    )
    u_z_rne2_dlt7zeros_cutbit
    (
        .P         ( z_rne2_dlt7zeros_cutbit                 ) ,
        .CPO       (            ) , //p cascade output
        .COUT      (                        ) ,
        .CXO       (                        ) , //x cascade output
        .CXBO      (                        ) , //x backward cascade output

        .X         ( y_dlt3zeros_dly1[MAN_WIDTH-3-1-:(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2 - 2)] ) ,
        .CXI       (                   ) , //x cascade input
        .CXBI      (                   ) , //x backward cascade input
        .XB        (              ) , //x backward cascade input
        .Y         ( y_dlt3zeros_dly1[MAN_WIDTH-4-1-:(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2 - 5)] ) ,
        .Z         (              ) ,
        .CPI       (            ) , //p cascade input
        .CIN       (                    ) ,
        .MODEY     ( 3'b001                   ) ,
        .MODEZ     ( 4'd0   ) ,
        .MODEIN    ( {1'b0, 1'b0, 3'b110}               ) ,

        .CLK       ( i_clk ) ,

        .CEX1      ( 1'b0  ) , //X1 enable signals
        .CEX2      ( 1'b0  ) , //X2 enable signals
        .CEX3      ( 1'b0  ) , //X3 enable signals
        .CEXB      ( 1'b0  ) , //XB enable signals
        .CEY1      ( 1'b0  ) , //Y1 enable signals
        .CEY2      ( 1'b0  ) , //Y2 enable signals
        .CEZ       ( 1'b0  ) , //Z enable signals
        .CEPRE     ( 1'b0  ) , //PRE enable signals
        .CEM       ( 1'b0  ) , //M enable signals
        .CEP       ( 1'b1  ) , //P enable signals
        .CEMODEY   ( 1'b0  ) , //MODEY enable signals
        .CEMODEZ   ( 1'b0  ) , //MODEZ enable signals
        .CEMODEIN  ( 1'b0  ) , //MODEIN enable signals

        .RSTX      ( 1'b0 ) , //X reset signals
        .RSTXB     ( 1'b0 ) , //XB reset signals
        .RSTY      ( 1'b0 ) , //Y reset signals
        .RSTZ      ( 1'b0 ) , //Z reset signals
        .RSTPRE    ( 1'b0 ) , //PRE reset signals
        .RSTM      ( 1'b0 ) , //M reset signals
        .RSTP      ( 1'b0 ) , //P reset signals
        .RSTMODEY  ( 1'b0 ) , //MODEY reset signals
        .RSTMODEZ  ( 1'b0 ) , //MODEZ reset signals
        .RSTMODEIN ( 1'b0 )   //MODEIN reset signals

    );

// if y_dlt3zeros_dly1[MAN_WIDTH-3-1] == 1, then y_dlt3zeros_dly1 should be 100000..., and z_rne2_dlt7zeros should be 100000...
assign z_dlt7zeros = {y_dlt3zeros_hi1_dly2, z_rne2_dlt7zeros_cutbit[(((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2-8-1:RNE2]};

// a3 * y
// previously: assign a3_y_rne2_dlt7zeros = a3_dly1 * y_dlt3zeros_dly1[MAN_WIDTH-3-1-:(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2 - 5)];
// and after a pipeline stage: ipsxe_floating_point_rne_v1_0 #(((MAN_WIDTH+1)+RNE+RNE1)/2-7, RNE2) u_rne_a3_y(a3_y_rne2_dlt7zeros_dly2, a3_y_dlt7zeros);
// now: apm with the configurable pipeline stage 3 inside, at the output port of apm
    GTP_APM_E2 #(
        .GRS_EN         ( "TRUE"                 ) ,  //"TRUE","FALSE",enable global reset
        .USE_POSTADD    ( 1'b1            ) ,  //enable postadder 0/1
        .USE_PREADD     ( 1'b0                   ) ,  //enable preadder 0/1
        .PREADD_REG     ( 1'b0                   ) ,  //preadder reg 0/1

        .X_REG          ( 2'b0           ) ,  //X input reg 0/1
        .CXO_REG        ( 2'b0                   ) ,  //X cascade out reg latency, 0/1/2/3
        .XB_REG         ( 1'b0                   ) ,  //XB input reg 0/1
        .Y_REG          ( 2'b0        ) ,  //Y input reg 0/1
        .Z_REG          ( 2'b0           ) ,  //Z input reg 0/1
        .MULT_REG       ( 1'b0        ) ,  //multiplier reg 0/1
        .P_REG          ( (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (3 / 2))           ) ,  //post adder reg 0/1
        .MODEY_REG      ( 1'b0                   ) ,  //MODEY reg
        .MODEZ_REG      ( 1'b0        ) ,  //MODEZ reg
        .MODEIN_REG     ( 1'b0                   ) ,  //MODEZ reg

        .X_SEL          ( 1'b0                   ) ,  // mult X input select X/CXI
        .XB_SEL         ( 2'b0                   ) ,  //X back propagate mux select. 0/1/2/3
        .ASYNC_RST      ( 1'b0           ) ,  // RST is sync/async
        .USE_SIMD       ( 1'b0            ) ,  // single addsub25_mult25_add48 / dual addsub12_mult12_add24
        .P_INIT0        ( P_INIT0_RNE2             ) ,  //P constant input0 (RTI parameter in APM of PG family)
        .P_INIT1        ( P_INIT1_RNE2             ) ,  //P constant input1 (RTI parameter in APM of PG family)
        .ROUNDMODE_SEL  ( 1'b1                   ) ,  //round mode selection

        .CPO_REG        ( 1'b0          ) ,  // CPO,COUT use register output
        .USE_ACCLOW     ( 1'b0                   ) ,  // accumulator use lower 18-bit feedback only
        .CIN_SEL        ( 1'b0                   )    // select CIN for postadder carry in

    )
    u_a3_y_rne2_dlt7zeros
    (
        .P         ( a3_y_rne2_dlt7zeros                 ) ,
        .CPO       (            ) , //p cascade output
        .COUT      (                        ) ,
        .CXO       (                        ) , //x cascade output
        .CXBO      (                        ) , //x backward cascade output

        .X         ( a3_dly1 ) ,
        .CXI       (                   ) , //x cascade input
        .CXBI      (                   ) , //x backward cascade input
        .XB        (              ) , //x backward cascade input
        .Y         ( y_dlt3zeros_dly1[MAN_WIDTH-3-1-:(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2 - 5)] ) ,
        .Z         (              ) ,
        .CPI       (            ) , //p cascade input
        .CIN       (                    ) ,
        .MODEY     ( 3'b001                   ) ,
        .MODEZ     ( 4'd0   ) ,
        .MODEIN    ( {1'b0, 1'b0, 3'b110}               ) ,

        .CLK       ( i_clk ) ,

        .CEX1      ( 1'b0  ) , //X1 enable signals
        .CEX2      ( 1'b0  ) , //X2 enable signals
        .CEX3      ( 1'b0  ) , //X3 enable signals
        .CEXB      ( 1'b0  ) , //XB enable signals
        .CEY1      ( 1'b0  ) , //Y1 enable signals
        .CEY2      ( 1'b0  ) , //Y2 enable signals
        .CEZ       ( 1'b0  ) , //Z enable signals
        .CEPRE     ( 1'b0  ) , //PRE enable signals
        .CEM       ( 1'b0  ) , //M enable signals
        .CEP       ( 1'b1  ) , //P enable signals
        .CEMODEY   ( 1'b0  ) , //MODEY enable signals
        .CEMODEZ   ( 1'b0  ) , //MODEZ enable signals
        .CEMODEIN  ( 1'b0  ) , //MODEIN enable signals

        .RSTX      ( 1'b0 ) , //X reset signals
        .RSTXB     ( 1'b0 ) , //XB reset signals
        .RSTY      ( 1'b0 ) , //Y reset signals
        .RSTZ      ( 1'b0 ) , //Z reset signals
        .RSTPRE    ( 1'b0 ) , //PRE reset signals
        .RSTM      ( 1'b0 ) , //M reset signals
        .RSTP      ( 1'b0 ) , //P reset signals
        .RSTMODEY  ( 1'b0 ) , //MODEY reset signals
        .RSTMODEZ  ( 1'b0 ) , //MODEZ reset signals
        .RSTMODEIN ( 1'b0 )   //MODEIN reset signals

    );

assign a3_y_dlt7zeros = a3_y_rne2_dlt7zeros[(((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2-7-1:RNE2];

// a1 * y[MSB-:3]
assign a1_y_rne1_hi = a1_dly1 * y_dlt3zeros_dly1[MAN_WIDTH-3-1-:3];

// a4 +- a5 * y
// previously: assign a5_y_dlt6zeros = a5_dly1 * y_dlt3zeros_dly1[MAN_WIDTH-3-1-:(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2/2 - 3)];
// and after a pipeline stage:
// assign a4_minus_a5_y_dlt2zeros_nosel = a4_dly1p25[((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2-2-1:0] - a5_y_dlt6zeros_dly1;
// assign a4_plus_a5_y_dlt2zeros_nosel  = a4_dly1p25[((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2-2-1:0] + a5_y_dlt6zeros_dly1;
// assign a4_plus_a5_y_dlt2zeros = x_minus_a_is_pos_dly1p25 ? a4_minus_a5_y_dlt2zeros_nosel : a4_plus_a5_y_dlt2zeros_nosel;
// now: apm with the configurable pipeline stage 3 inside, at the output port of apm
    GTP_APM_E2 #(
        .GRS_EN         ( "TRUE"                 ) ,  //"TRUE","FALSE",enable global reset
        .USE_POSTADD    ( 1'b1         ) ,  //enable postadder 0/1
        .USE_PREADD     ( 1'b0                ) ,  //enable preadder 0/1
        .PREADD_REG     ( 1'b0                   ) ,  //preadder reg 0/1

        .X_REG          ( 2'b0           ) ,  //X input reg 0/1
        .CXO_REG        ( 2'b0                   ) ,  //X cascade out reg latency, 0/1/2/3
        .XB_REG         ( 1'b0                   ) ,  //XB input reg 0/1
        .Y_REG          ( 2'b0        ) ,  //Y input reg 0/1
        .Z_REG          ( 2'b0           ) ,  //Z input reg 0/1
        .MULT_REG       ( 1'b0        ) ,  //multiplier reg 0/1
        .P_REG          ( (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (3 / 2))           ) ,  //post adder reg 0/1
        .MODEY_REG      ( 1'b0                   ) ,  //MODEY reg
        .MODEZ_REG      ( 1'b0        ) ,  //MODEZ reg
        .MODEIN_REG     ( 1'b0                   ) ,  //MODEZ reg

        .X_SEL          ( 1'b0                   ) ,  // mult X input select X/CXI
        .XB_SEL         ( 2'b0                   ) ,  //X back propagate mux select. 0/1/2/3
        .ASYNC_RST      ( 1'b0           ) ,  // RST is sync/async
        .USE_SIMD       ( 1'b0            ) ,  // single addsub25_mult25_add48 / dual addsub12_mult12_add24
        .P_INIT0        ( {48{1'b0}}             ) ,  //P constant input0 (RTI parameter in APM of PG family)
        .P_INIT1        ( {48{1'b0}}             ) ,  //P constant input1 (RTI parameter in APM of PG family)
        .ROUNDMODE_SEL  ( 1'b0                   ) ,  //round mode selection

        .CPO_REG        ( 1'b0          ) ,  // CPO,COUT use register output
        .USE_ACCLOW     ( 1'b0                   ) ,  // accumulator use lower 18-bit feedback only
        .CIN_SEL        ( 1'b0                   )    // select CIN for postadder carry in

    )
    u_a4_plus_a5_y_dlt2zeros
    (
        .P         ( a4_plus_a5_y_dlt2zeros                 ) ,
        .CPO       (            ) , //p cascade output
        .COUT      (                        ) ,
        .CXO       (                        ) , //x cascade output
        .CXBO      (                        ) , //x backward cascade output

        .X         ( y_dlt3zeros_dly1[MAN_WIDTH-3-1-:(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2/2 - 3)] ) ,
        .CXI       (                   ) , //x cascade input
        .CXBI      (                   ) , //x backward cascade input
        .XB        (              ) , //x backward cascade input
        .Y         ( a5_dly1             ) ,
        .Z         ( a4_dly1             ) ,
        .CPI       (            ) , //p cascade input
        .CIN       (                    ) ,
        .MODEY     ( {x_minus_a_is_pos_dly1, 2'b01}                   ) ,
        .MODEZ     ( 4'd2   ) ,
        .MODEIN    ( {1'b0, 1'b0, 3'b110}               ) ,

        .CLK       ( i_clk ) ,

        .CEX1      ( 1'b0  ) , //X1 enable signals
        .CEX2      ( 1'b0  ) , //X2 enable signals
        .CEX3      ( 1'b0  ) , //X3 enable signals
        .CEXB      ( 1'b0  ) , //XB enable signals
        .CEY1      ( 1'b0  ) , //Y1 enable signals
        .CEY2      ( 1'b0  ) , //Y2 enable signals
        .CEZ       ( 1'b0  ) , //Z enable signals
        .CEPRE     ( 1'b0  ) , //PRE enable signals
        .CEM       ( 1'b0  ) , //M enable signals
        .CEP       ( 1'b1  ) , //P enable signals
        .CEMODEY   ( 1'b0  ) , //MODEY enable signals
        .CEMODEZ   ( 1'b0  ) , //MODEZ enable signals
        .CEMODEIN  ( 1'b0  ) , //MODEIN enable signals

        .RSTX      ( 1'b0 ) , //X reset signals
        .RSTXB     ( 1'b0 ) , //XB reset signals
        .RSTY      ( 1'b0 ) , //Y reset signals
        .RSTZ      ( 1'b0 ) , //Z reset signals
        .RSTPRE    ( 1'b0 ) , //PRE reset signals
        .RSTM      ( 1'b0 ) , //M reset signals
        .RSTP      ( 1'b0 ) , //P reset signals
        .RSTMODEY  ( 1'b0 ) , //MODEY reset signals
        .RSTMODEZ  ( 1'b0 ) , //MODEZ reset signals
        .RSTMODEIN ( 1'b0 )   //MODEIN reset signals

    );

always @(*) begin: blk_a2
    case(x_exp_lo1_man_hi3_dly1)
        4'b0000: a2 = 22'h1d2af6; // remove the highest bit 0 of 23'h1d2af6;
        4'b0001: a2 = 22'h161658; // remove the highest bit 0 of 23'h161658;
        4'b0010: a2 = 22'h1132b0; // remove the highest bit 0 of 23'h1132b0;
        4'b0011: a2 = 22'hdb316 ; // remove the highest bit 0 of 23'hdb316 ;
        4'b0100: a2 = 22'hb1f30 ; // remove the highest bit 0 of 23'hb1f30 ;
        4'b0101: a2 = 22'h92cdc ; // remove the highest bit 0 of 23'h92cdc ;
        4'b0110: a2 = 22'h7ac96 ; // remove the highest bit 0 of 23'h7ac96 ;
        4'b0111: a2 = 22'h67ee2 ; // remove the highest bit 0 of 23'h67ee2 ;
        4'b1000: a2 = 22'h293fe0; // remove the highest bit 0 of 23'h293fe0;
        4'b1001: a2 = 22'h1f3c73; // remove the highest bit 0 of 23'h1f3c73;
        4'b1010: a2 = 22'h185257; // remove the highest bit 0 of 23'h185257;
        4'b1011: a2 = 22'h135fc5; // remove the highest bit 0 of 23'h135fc5;
        4'b1100: a2 = 22'hfba88 ; // remove the highest bit 0 of 23'hfba88 ;
        4'b1101: a2 = 22'hcf9c9 ; // remove the highest bit 0 of 23'hcf9c9 ;
        4'b1110: a2 = 22'hada58 ; // remove the highest bit 0 of 23'hada58 ;
        default: a2 = 22'h92fac ; // remove the highest bit 0 of 23'h92fac ;
    endcase
end

generate
if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (3 / 2)) begin
// pipeline stage 1.25 (actually 3)
ipsxe_floating_point_register_v1_0 #(6*1 + 4 + EXP_WIDTH + ((MAN_WIDTH+1)+RNE+RNE1)/2-1 + (((MAN_WIDTH+1)+RNE+RNE1)/2)-1 + (((MAN_WIDTH+1)+RNE+RNE1)/2-1)+3-1 + (((MAN_WIDTH+1)+RNE+RNE1)/2 - 3 - 3) + 1) u_reg_stage1p25(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly1,    x_minus_a_is_pos_dly1,    x_exp_lo1_man_hi3_dly1, invsqrt_x_exp_dly1,    a1_dly1, a2     , a1_y_rne1_hi     , y_dlt3zeros_dly1[MAN_WIDTH-3-3-1-:(((MAN_WIDTH+1)+RNE+RNE1)/2 - 3 - 3)], y_dlt3zeros_dly1[MAN_WIDTH-3-1]}),
    .o_q({special_cases_dly1p25, x_minus_a_is_pos_dly1p25, x_exp_lo1_man_hi3_dly2, invsqrt_x_exp_dly1p25, a1_dly2, a2_dly1, a1_y_rne1_hi_dly1, y_dlt3zeros_cut_dly2                                                   , y_dlt3zeros_hi1_dly2           })
);
end
else begin
assign {special_cases_dly1p25, x_minus_a_is_pos_dly1p25, x_exp_lo1_man_hi3_dly2, invsqrt_x_exp_dly1p25, a1_dly2, a2_dly1, a1_y_rne1_hi_dly1, y_dlt3zeros_cut_dly2, y_dlt3zeros_hi1_dly2} = {special_cases_dly1,    x_minus_a_is_pos_dly1,    x_exp_lo1_man_hi3_dly1, invsqrt_x_exp_dly1,    a1_dly1, a2     , a1_y_rne1_hi     , y_dlt3zeros_dly1[MAN_WIDTH-3-3-1-:(((MAN_WIDTH+1)+RNE+RNE1)/2 - 3 - 3)], y_dlt3zeros_dly1[MAN_WIDTH-3-1]};
end
endgenerate

// a1 * y
// previously: assign a1_y_rne1_dlt5zeros = a1_dly1 * y_dlt3zeros_dly1[MAN_WIDTH-3-1-:(((MAN_WIDTH+1)+RNE+RNE1)/2 - 3)];
// and after several pipeline stages: ipsxe_floating_point_rne_v1_0 #((MAN_WIDTH+1)+RNE-5, RNE1) u_rne_a1_y(a1_y_rne1_dlt5zeros_dly2, a1_y_dlt5zeros);
// now: apm with the configurable pipeline stage 4 inside, at the output port of apm
    GTP_APM_E2 #(
        .GRS_EN         ( "TRUE"                 ) ,  //"TRUE","FALSE",enable global reset
        .USE_POSTADD    ( 1'b1         ) ,  //enable postadder 0/1
        .USE_PREADD     ( 1'b0                ) ,  //enable preadder 0/1
        .PREADD_REG     ( 1'b0                   ) ,  //preadder reg 0/1

        .X_REG          ( 2'b0           ) ,  //X input reg 0/1
        .CXO_REG        ( 2'b0                   ) ,  //X cascade out reg latency, 0/1/2/3
        .XB_REG         ( 1'b0                   ) ,  //XB input reg 0/1
        .Y_REG          ( 2'b0        ) ,  //Y input reg 0/1
        .Z_REG          ( 2'b0           ) ,  //Z input reg 0/1
        .MULT_REG       ( 1'b0        ) ,  //multiplier reg 0/1
        .P_REG          ( (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/4) - (4 / 8))           ) ,  //post adder reg 0/1
        .MODEY_REG      ( 1'b0                   ) ,  //MODEY reg
        .MODEZ_REG      ( 1'b0        ) ,  //MODEZ reg
        .MODEIN_REG     ( 1'b0                   ) ,  //MODEZ reg

        .X_SEL          ( 1'b0                   ) ,  // mult X input select X/CXI
        .XB_SEL         ( 2'b0                   ) ,  //X back propagate mux select. 0/1/2/3
        .ASYNC_RST      ( 1'b0           ) ,  // RST is sync/async
        .USE_SIMD       ( 1'b0            ) ,  // single addsub25_mult25_add48 / dual addsub12_mult12_add24
        .P_INIT0        ( P_INIT0_RNE1             ) ,  //P constant input0 (RTI parameter in APM of PG family)
        .P_INIT1        ( P_INIT1_RNE1             ) ,  //P constant input1 (RTI parameter in APM of PG family)
        .ROUNDMODE_SEL  ( 1'b1                   ) ,  //round mode selection

        .CPO_REG        ( 1'b0          ) ,  // CPO,COUT use register output
        .USE_ACCLOW     ( 1'b0                   ) ,  // accumulator use lower 18-bit feedback only
        .CIN_SEL        ( 1'b0                   )    // select CIN for postadder carry in

    )
    u_a1_y_dlt5zeros
    (
        .P         ( a1_y_rne1_dlt5zeros                 ) ,
        .CPO       (            ) , //p cascade output
        .COUT      (                        ) ,
        .CXO       (                        ) , //x cascade output
        .CXBO      (                        ) , //x backward cascade output

        .X         ( a1_dly2 ) ,
        .CXI       (                   ) , //x cascade input
        .CXBI      (                   ) , //x backward cascade input
        .XB        (              ) , //x backward cascade input
        .Y         ( y_dlt3zeros_cut_dly2             ) ,
        .Z         ( {a1_y_rne1_hi_dly1, {((((MAN_WIDTH+1)+RNE+RNE1)/2 - 3) - 3){1'b0}}}             ) ,
        .CPI       (            ) , //p cascade input
        .CIN       (                    ) ,
        .MODEY     ( {1'b0, 2'b01}                   ) ,
        .MODEZ     ( 4'd2   ) ,
        .MODEIN    ( {1'b0, 1'b0, 3'b110}               ) ,

        .CLK       ( i_clk ) ,

        .CEX1      ( 1'b0  ) , //X1 enable signals
        .CEX2      ( 1'b0  ) , //X2 enable signals
        .CEX3      ( 1'b0  ) , //X3 enable signals
        .CEXB      ( 1'b0  ) , //XB enable signals
        .CEY1      ( 1'b0  ) , //Y1 enable signals
        .CEY2      ( 1'b0  ) , //Y2 enable signals
        .CEZ       ( 1'b0  ) , //Z enable signals
        .CEPRE     ( 1'b0  ) , //PRE enable signals
        .CEM       ( 1'b0  ) , //M enable signals
        .CEP       ( 1'b1  ) , //P enable signals
        .CEMODEY   ( 1'b0  ) , //MODEY enable signals
        .CEMODEZ   ( 1'b0  ) , //MODEZ enable signals
        .CEMODEIN  ( 1'b0  ) , //MODEIN enable signals

        .RSTX      ( 1'b0 ) , //X reset signals
        .RSTXB     ( 1'b0 ) , //XB reset signals
        .RSTY      ( 1'b0 ) , //Y reset signals
        .RSTZ      ( 1'b0 ) , //Z reset signals
        .RSTPRE    ( 1'b0 ) , //PRE reset signals
        .RSTM      ( 1'b0 ) , //M reset signals
        .RSTP      ( 1'b0 ) , //P reset signals
        .RSTMODEY  ( 1'b0 ) , //MODEY reset signals
        .RSTMODEZ  ( 1'b0 ) , //MODEZ reset signals
        .RSTMODEIN ( 1'b0 )   //MODEIN reset signals

    );

assign a1_y_dlt5zeros = a1_y_rne1_dlt5zeros[(MAN_WIDTH+1)+RNE+RNE1-5-1:RNE1];

// z * (a4 - a5 * y)
// previously: assign a4_z_rne2_dlt10zeros = a4_plus_a5_y_dlt2zeros_dly2 * z_dlt7zeros_dly2[(((MAN_WIDTH+1)+RNE+RNE1)/2)-7-1-:(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2 - 7)];
// and after a pipeline stage: ipsxe_floating_point_rne_v1_0 #(((MAN_WIDTH+1)+RNE+RNE1)/2-10, RNE2) u_rne_a4_z(a4_z_rne2_dlt10zeros_dly1, a4_z_dlt10zeros);
// now: apm with the configurable pipeline stage 4 inside, at the output port of apm
    GTP_APM_E2 #(
        .GRS_EN         ( "TRUE"                 ) ,  //"TRUE","FALSE",enable global reset
        .USE_POSTADD    ( 1'b1            ) ,  //enable postadder 0/1
        .USE_PREADD     ( 1'b0                   ) ,  //enable preadder 0/1
        .PREADD_REG     ( 1'b0                   ) ,  //preadder reg 0/1

        .X_REG          ( 2'b0           ) ,  //X input reg 0/1
        .CXO_REG        ( 2'b0                   ) ,  //X cascade out reg latency, 0/1/2/3
        .XB_REG         ( 1'b0                   ) ,  //XB input reg 0/1
        .Y_REG          ( 2'b0        ) ,  //Y input reg 0/1
        .Z_REG          ( 2'b0           ) ,  //Z input reg 0/1
        .MULT_REG       ( 1'b0        ) ,  //multiplier reg 0/1
        .P_REG          ( (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/4) - (4 / 8))           ) ,  //post adder reg 0/1
        .MODEY_REG      ( 1'b0                   ) ,  //MODEY reg
        .MODEZ_REG      ( 1'b0        ) ,  //MODEZ reg
        .MODEIN_REG     ( 1'b0                   ) ,  //MODEZ reg

        .X_SEL          ( 1'b0                   ) ,  // mult X input select X/CXI
        .XB_SEL         ( 2'b0                   ) ,  //X back propagate mux select. 0/1/2/3
        .ASYNC_RST      ( 1'b0           ) ,  // RST is sync/async
        .USE_SIMD       ( 1'b0            ) ,  // single addsub25_mult25_add48 / dual addsub12_mult12_add24
        .P_INIT0        ( P_INIT0_RNE2             ) ,  //P constant input0 (RTI parameter in APM of PG family)
        .P_INIT1        ( P_INIT1_RNE2             ) ,  //P constant input1 (RTI parameter in APM of PG family)
        .ROUNDMODE_SEL  ( 1'b1                   ) ,  //round mode selection

        .CPO_REG        ( 1'b0          ) ,  // CPO,COUT use register output
        .USE_ACCLOW     ( 1'b0                   ) ,  // accumulator use lower 18-bit feedback only
        .CIN_SEL        ( 1'b0                   )    // select CIN for postadder carry in

    )
    u_a4_z_rne2_dlt10zeros
    (
        .P         ( a4_z_rne2_dlt10zeros                 ) ,
        .CPO       (            ) , //p cascade output
        .COUT      (                        ) ,
        .CXO       (                        ) , //x cascade output
        .CXBO      (                        ) , //x backward cascade output

        .X         ( a4_plus_a5_y_dlt2zeros ) ,
        .CXI       (                   ) , //x cascade input
        .CXBI      (                   ) , //x backward cascade input
        .XB        (              ) , //x backward cascade input
        .Y         ( z_dlt7zeros[(((MAN_WIDTH+1)+RNE+RNE1)/2)-7-1-:(((((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2)/2 - 7)] ) ,
        .Z         (              ) ,
        .CPI       (            ) , //p cascade input
        .CIN       (                    ) ,
        .MODEY     ( 3'b001                   ) ,
        .MODEZ     ( 4'd0   ) ,
        .MODEIN    ( {1'b0, 1'b0, 3'b110}               ) ,

        .CLK       ( i_clk ) ,

        .CEX1      ( 1'b0  ) , //X1 enable signals
        .CEX2      ( 1'b0  ) , //X2 enable signals
        .CEX3      ( 1'b0  ) , //X3 enable signals
        .CEXB      ( 1'b0  ) , //XB enable signals
        .CEY1      ( 1'b0  ) , //Y1 enable signals
        .CEY2      ( 1'b0  ) , //Y2 enable signals
        .CEZ       ( 1'b0  ) , //Z enable signals
        .CEPRE     ( 1'b0  ) , //PRE enable signals
        .CEM       ( 1'b0  ) , //M enable signals
        .CEP       ( 1'b1  ) , //P enable signals
        .CEMODEY   ( 1'b0  ) , //MODEY enable signals
        .CEMODEZ   ( 1'b0  ) , //MODEZ enable signals
        .CEMODEIN  ( 1'b0  ) , //MODEIN enable signals

        .RSTX      ( 1'b0 ) , //X reset signals
        .RSTXB     ( 1'b0 ) , //XB reset signals
        .RSTY      ( 1'b0 ) , //Y reset signals
        .RSTZ      ( 1'b0 ) , //Z reset signals
        .RSTPRE    ( 1'b0 ) , //PRE reset signals
        .RSTM      ( 1'b0 ) , //M reset signals
        .RSTP      ( 1'b0 ) , //P reset signals
        .RSTMODEY  ( 1'b0 ) , //MODEY reset signals
        .RSTMODEZ  ( 1'b0 ) , //MODEZ reset signals
        .RSTMODEIN ( 1'b0 )   //MODEIN reset signals

    );

assign a4_z_dlt10zeros = a4_z_rne2_dlt10zeros[(((MAN_WIDTH+1)+RNE+RNE1)/2)+RNE2-10-1:RNE2];

always @(*) begin: blk_a0_lo23
    case(x_exp_lo1_man_hi3_dly2)
        4'b0000: a0_lo23 = 23'h3e754d; // the 22th to 0th bit of 26'h2be754d (LSB is the 0th bit);
        4'b0001: a0_lo23 = 23'h18757d; // the 22th to 0th bit of 26'h298757d (LSB is the 0th bit);
        4'b0010: a0_lo23 = 23'h7806ca; // the 22th to 0th bit of 26'h27806ca (LSB is the 0th bit);
        4'b0011: a0_lo23 = 23'h5bec19; // the 22th to 0th bit of 26'h25bec19 (LSB is the 0th bit);
        4'b0100: a0_lo23 = 23'h43430a; // the 22th to 0th bit of 26'h243430a (LSB is the 0th bit);
        4'b0101: a0_lo23 = 23'h2d651f; // the 22th to 0th bit of 26'h22d651f (LSB is the 0th bit);
        4'b0110: a0_lo23 = 23'h19d4c6; // the 22th to 0th bit of 26'h219d4c6 (LSB is the 0th bit);
        4'b0111: a0_lo23 = 23'h083149; // the 22th to 0th bit of 26'h2083149 (LSB is the 0th bit);
        4'b1000: a0_lo23 = 23'h616d09; // the 22th to 0th bit of 26'h3e16d09 (LSB is the 0th bit);
        4'b1001: a0_lo23 = 23'h2bafd5; // the 22th to 0th bit of 26'h3abafd5 (LSB is the 0th bit);
        4'b1010: a0_lo23 = 23'h7dd20b; // the 22th to 0th bit of 26'h37dd20b (LSB is the 0th bit);
        4'b1011: a0_lo23 = 23'h561336; // the 22th to 0th bit of 26'h3561336 (LSB is the 0th bit);
        4'b1100: a0_lo23 = 23'h333333; // the 22th to 0th bit of 26'h3333333 (LSB is the 0th bit);
        4'b1101: a0_lo23 = 23'h14468c; // the 22th to 0th bit of 26'h314468c (LSB is the 0th bit);
        4'b1110: a0_lo23 = 23'h789bad; // the 22th to 0th bit of 26'h2f89bad (LSB is the 0th bit);
        default: a0_lo23 = 23'h5fa9cf; // the 22th to 0th bit of 26'h2dfa9cf (LSB is the 0th bit);
    endcase
end

generate
if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/4) - (4 / 8)) begin
// pipeline stage 4
ipsxe_floating_point_register_v1_0 #(6*1 + 4 + EXP_WIDTH + (MAN_WIDTH+1)+RNE-3 + ((((MAN_WIDTH+1)+RNE+RNE1)/2)-7)) u_reg_stage3(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly1p25, x_minus_a_is_pos_dly1p25, x_exp_lo1_man_hi3_dly2, invsqrt_x_exp_dly1p25, a0_lo23     , z_dlt7zeros     }),
    .o_q({special_cases_dly2,    x_minus_a_is_pos_dly2,    x_exp_lo1_man_hi3_dly3, invsqrt_x_exp_dly2,    a0_lo23_dly1, z_dlt7zeros_dly1})
);
end
else begin
assign {special_cases_dly2,    x_minus_a_is_pos_dly2,    x_exp_lo1_man_hi3_dly3, invsqrt_x_exp_dly2,    a0_lo23_dly1, z_dlt7zeros_dly1} = {special_cases_dly1p25, x_minus_a_is_pos_dly1p25, x_exp_lo1_man_hi3_dly2, invsqrt_x_exp_dly1p25, a0_lo23     , z_dlt7zeros     };
end
endgenerate

// minus or plus according to x_minus_a_is_pos
// a2 - a3 * y + z * (a4 - a5 * y)
// assign a2_plus_a4z_minus_a3y_dlt1zero_nosel = (a2_dly4[((MAN_WIDTH+1)+RNE+RNE1)/2-1-1:0] + {9'b0, a4_z_dlt10zeros_dly2} - {4'b0, a3_y_dlt7zeros_dly4, 2'b0});
// assign a2_plus_a4z_plus_a3y_dlt1zero_nosel  = (a2_dly4[((MAN_WIDTH+1)+RNE+RNE1)/2-1-1:0] + {9'b0, a4_z_dlt10zeros_dly2} + {4'b0, a3_y_dlt7zeros_dly4, 2'b0});
// assign a2_plus_a3y_plus_a4z_dlt1zero = x_minus_a_is_pos_dly4 ? a2_plus_a4z_minus_a3y_dlt1zero_nosel : a2_plus_a4z_plus_a3y_dlt1zero_nosel;
// now: apm with the configurable pipeline stage 4 inside, and the configurable pipeline stage 5 at the output port of apm
    GTP_APM_E2 #(
        .GRS_EN         ( "TRUE"                 ) ,  //"TRUE","FALSE",enable global reset
        .USE_POSTADD    ( 1'b1         ) ,  //enable postadder 0/1
        .USE_PREADD     ( 1'b1                   ) ,  //enable preadder 0/1
        .PREADD_REG     ( (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/4) - (4 / 8))                   ) ,  //preadder reg 0/1

        .X_REG          ( 2'b0           ) ,  //X input reg 0/1
        .CXO_REG        ( 2'b0                   ) ,  //X cascade out reg latency, 0/1/2/3
        .XB_REG         ( 1'b0                   ) ,  //XB input reg 0/1
        .Y_REG          ( 2'b0        ) ,  //Y input reg 0/1
        .Z_REG          ( 2'b0           ) ,  //Z input reg 0/1
        .MULT_REG       ( 1'b0        ) ,  //multiplier reg 0/1
        .P_REG          ( (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (5 / 2))           ) ,  //post adder reg 0/1
        .MODEY_REG      ( 1'b0                   ) ,  //MODEY reg
        .MODEZ_REG      ( 1'b0        ) ,  //MODEZ reg
        .MODEIN_REG     ( 1'b0                   ) ,  //MODEZ reg

        .X_SEL          ( 1'b0                   ) ,  // mult X input select X/CXI
        .XB_SEL         ( 2'b0                   ) ,  //X back propagate mux select. 0/1/2/3
        .ASYNC_RST      ( 1'b0           ) ,  // RST is sync/async
        .USE_SIMD       ( 1'b0            ) ,  // single addsub25_mult25_add48 / dual addsub12_mult12_add24
        .P_INIT0        ( {48{1'b0}}             ) ,  //P constant input0 (RTI parameter in APM of PG family)
        .P_INIT1        ( {48{1'b0}}             ) ,  //P constant input1 (RTI parameter in APM of PG family)
        .ROUNDMODE_SEL  ( 1'b0                   ) ,  //round mode selection

        .CPO_REG        ( 1'b0          ) ,  // CPO,COUT use register output
        .USE_ACCLOW     ( 1'b0                   ) ,  // accumulator use lower 18-bit feedback only
        .CIN_SEL        ( 1'b0                   )    // select CIN for postadder carry in

    )
    u_3add_a2_plus_a3y_plus_a4z_dlt1zero
    (
        .P         ( a2_plus_a3y_plus_a4z_dlt1zero                 ) ,
        .CPO       (            ) , //p cascade output
        .COUT      (                        ) ,
        .CXO       (                        ) , //x cascade output
        .CXBO      (                        ) , //x backward cascade output

        .X         ( {1'b0, a2_dly1} ) ,
        .CXI       (                   ) , //x cascade input
        .CXBI      (                   ) , //x backward cascade input
        .XB        ( {a3_y_dlt7zeros, 2'b0}             ) , //x backward cascade input
        .Y         ( 18'd1         ) ,
        .Z         ( a4_z_dlt10zeros             ) ,
        .CPI       (            ) , //p cascade input
        .CIN       (                    ) ,
        .MODEY     ( 3'b1                   ) ,
        .MODEZ     ( 4'd2   ) ,
        .MODEIN    ( {1'b0, x_minus_a_is_pos_dly1p25, 3'b110}               ) ,

        .CLK       ( i_clk ) ,

        .CEX1      ( 1'b0  ) , //X1 enable signals
        .CEX2      ( 1'b0  ) , //X2 enable signals
        .CEX3      ( 1'b0  ) , //X3 enable signals
        .CEXB      ( 1'b0  ) , //XB enable signals
        .CEY1      ( 1'b0  ) , //Y1 enable signals
        .CEY2      ( 1'b0  ) , //Y2 enable signals
        .CEZ       ( 1'b0  ) , //Z enable signals
        .CEPRE     ( 1'b1  ) , //PRE enable signals
        .CEM       ( 1'b0  ) , //M enable signals
        .CEP       ( 1'b1  ) , //P enable signals
        .CEMODEY   ( 1'b0  ) , //MODEY enable signals
        .CEMODEZ   ( 1'b0  ) , //MODEZ enable signals
        .CEMODEIN  ( 1'b0  ) , //MODEIN enable signals

        .RSTX      ( 1'b0 ) , //X reset signals
        .RSTXB     ( 1'b0 ) , //XB reset signals
        .RSTY      ( 1'b0 ) , //Y reset signals
        .RSTZ      ( 1'b0 ) , //Z reset signals
        .RSTPRE    ( 1'b0 ) , //PRE reset signals
        .RSTM      ( 1'b0 ) , //M reset signals
        .RSTP      ( 1'b0 ) , //P reset signals
        .RSTMODEY  ( 1'b0 ) , //MODEY reset signals
        .RSTMODEZ  ( 1'b0 ) , //MODEZ reset signals
        .RSTMODEIN ( 1'b0 )   //MODEIN reset signals

    );

generate
if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (5 / 2)) begin
// pipeline stage 5
ipsxe_floating_point_register_v1_0 #(5*1 + 4 + EXP_WIDTH + (((MAN_WIDTH+1)+RNE+RNE1)/2-7)) u_reg_stage6(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly2, x_exp_lo1_man_hi3_dly3, invsqrt_x_exp_dly2, z_dlt7zeros_dly1}),
    .o_q({special_cases_dly3, x_exp_lo1_man_hi3_dly4, invsqrt_x_exp_dly3, z_dlt7zeros_dly2})
);
end
else begin
assign {special_cases_dly3, x_exp_lo1_man_hi3_dly4, invsqrt_x_exp_dly3, z_dlt7zeros_dly2} = {special_cases_dly2, x_exp_lo1_man_hi3_dly3, invsqrt_x_exp_dly2, z_dlt7zeros_dly1};
end
endgenerate

// z * (a2 - a3 * y + z * (a4 - a5 * y))
// previously: assign z_group_rne1_dlt9zeros = z_dlt7zeros_dly5 * a2_plus_a3y_plus_a4z_dlt1zero_dly1;
// and after a pipeline stage: ipsxe_floating_point_rne_v1_0 #((MAN_WIDTH+1)+RNE-9, RNE1) u_rne_z_group(z_group_rne1_dlt9zeros_dly1, z_group_dlt9zeros);
// now: apm with the configurable pipeline stage 6 inside, at the output port of apm
    GTP_APM_E2 #(
        .GRS_EN         ( "TRUE"                 ) ,  //"TRUE","FALSE",enable global reset
        .USE_POSTADD    ( 1'b1            ) ,  //enable postadder 0/1
        .USE_PREADD     ( 1'b0                   ) ,  //enable preadder 0/1
        .PREADD_REG     ( 1'b0                   ) ,  //preadder reg 0/1

        .X_REG          ( 2'b0           ) ,  //X input reg 0/1
        .CXO_REG        ( 2'b0                   ) ,  //X cascade out reg latency, 0/1/2/3
        .XB_REG         ( 1'b0                   ) ,  //XB input reg 0/1
        .Y_REG          ( 2'b0        ) ,  //Y input reg 0/1
        .Z_REG          ( 2'b0           ) ,  //Z input reg 0/1
        .MULT_REG       ( 1'b0        ) ,  //multiplier reg 0/1
        .P_REG          ( (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/2) - (6 / 4))           ) ,  //post adder reg 0/1
        .MODEY_REG      ( 1'b0                   ) ,  //MODEY reg
        .MODEZ_REG      ( 1'b0        ) ,  //MODEZ reg
        .MODEIN_REG     ( 1'b0                   ) ,  //MODEZ reg

        .X_SEL          ( 1'b0                   ) ,  // mult X input select X/CXI
        .XB_SEL         ( 2'b0                   ) ,  //X back propagate mux select. 0/1/2/3
        .ASYNC_RST      ( 1'b0           ) ,  // RST is sync/async
        .USE_SIMD       ( 1'b0            ) ,  // single addsub25_mult25_add48 / dual addsub12_mult12_add24
        .P_INIT0        ( P_INIT0_RNE1             ) ,  //P constant input0 (RTI parameter in APM of PG family)
        .P_INIT1        ( P_INIT1_RNE1             ) ,  //P constant input1 (RTI parameter in APM of PG family)
        .ROUNDMODE_SEL  ( 1'b1                   ) ,  //round mode selection

        .CPO_REG        ( 1'b0          ) ,  // CPO,COUT use register output
        .USE_ACCLOW     ( 1'b0                   ) ,  // accumulator use lower 18-bit feedback only
        .CIN_SEL        ( 1'b0                   )    // select CIN for postadder carry in

    )
    u_z_group_rne1_dlt9zeros
    (
        .P         ( z_group_rne1_dlt9zeros                 ) ,
        .CPO       (            ) , //p cascade output
        .COUT      (                        ) ,
        .CXO       (                        ) , //x cascade output
        .CXBO      (                        ) , //x backward cascade output

        .X         ( a2_plus_a3y_plus_a4z_dlt1zero ) ,
        .CXI       (                   ) , //x cascade input
        .CXBI      (                   ) , //x backward cascade input
        .XB        (              ) , //x backward cascade input
        .Y         ( z_dlt7zeros_dly2 ) ,
        .Z         (              ) ,
        .CPI       (            ) , //p cascade input
        .CIN       (                    ) ,
        .MODEY     ( 3'b001                   ) ,
        .MODEZ     ( 4'd0   ) ,
        .MODEIN    ( {1'b0, 1'b0, 3'b110}               ) ,

        .CLK       ( i_clk ) ,

        .CEX1      ( 1'b0  ) , //X1 enable signals
        .CEX2      ( 1'b0  ) , //X2 enable signals
        .CEX3      ( 1'b0  ) , //X3 enable signals
        .CEXB      ( 1'b0  ) , //XB enable signals
        .CEY1      ( 1'b0  ) , //Y1 enable signals
        .CEY2      ( 1'b0  ) , //Y2 enable signals
        .CEZ       ( 1'b0  ) , //Z enable signals
        .CEPRE     ( 1'b0  ) , //PRE enable signals
        .CEM       ( 1'b0  ) , //M enable signals
        .CEP       ( 1'b1  ) , //P enable signals
        .CEMODEY   ( 1'b0  ) , //MODEY enable signals
        .CEMODEZ   ( 1'b0  ) , //MODEZ enable signals
        .CEMODEIN  ( 1'b0  ) , //MODEIN enable signals

        .RSTX      ( 1'b0 ) , //X reset signals
        .RSTXB     ( 1'b0 ) , //XB reset signals
        .RSTY      ( 1'b0 ) , //Y reset signals
        .RSTZ      ( 1'b0 ) , //Z reset signals
        .RSTPRE    ( 1'b0 ) , //PRE reset signals
        .RSTM      ( 1'b0 ) , //M reset signals
        .RSTP      ( 1'b0 ) , //P reset signals
        .RSTMODEY  ( 1'b0 ) , //MODEY reset signals
        .RSTMODEZ  ( 1'b0 ) , //MODEZ reset signals
        .RSTMODEIN ( 1'b0 )   //MODEIN reset signals

    );

assign z_group_dlt9zeros = z_group_rne1_dlt9zeros[(MAN_WIDTH+1)+RNE+RNE1-9-1:RNE1];

always @(*) begin: blk_a0_hi2nd3rd
    case(x_exp_lo1_man_hi3_dly4)
        4'b0000: a0_hi2nd3rd = 2'b01; // the 24th and 23th bit of 26'h2be754d (LSB is the 0th bit);
        4'b0001: a0_hi2nd3rd = 2'b01; // the 24th and 23th bit of 26'h298757d (LSB is the 0th bit);
        4'b0010: a0_hi2nd3rd = 2'b00; // the 24th and 23th bit of 26'h27806ca (LSB is the 0th bit);
        4'b0011: a0_hi2nd3rd = 2'b00; // the 24th and 23th bit of 26'h25bec19 (LSB is the 0th bit);
        4'b0100: a0_hi2nd3rd = 2'b00; // the 24th and 23th bit of 26'h243430a (LSB is the 0th bit);
        4'b0101: a0_hi2nd3rd = 2'b00; // the 24th and 23th bit of 26'h22d651f (LSB is the 0th bit);
        4'b0110: a0_hi2nd3rd = 2'b00; // the 24th and 23th bit of 26'h219d4c6 (LSB is the 0th bit);
        4'b0111: a0_hi2nd3rd = 2'b00; // the 24th and 23th bit of 26'h2083149 (LSB is the 0th bit);
        4'b1000: a0_hi2nd3rd = 2'b11; // the 24th and 23th bit of 26'h3e16d09 (LSB is the 0th bit);
        4'b1001: a0_hi2nd3rd = 2'b11; // the 24th and 23th bit of 26'h3abafd5 (LSB is the 0th bit);
        4'b1010: a0_hi2nd3rd = 2'b10; // the 24th and 23th bit of 26'h37dd20b (LSB is the 0th bit);
        4'b1011: a0_hi2nd3rd = 2'b10; // the 24th and 23th bit of 26'h3561336 (LSB is the 0th bit);
        4'b1100: a0_hi2nd3rd = 2'b10; // the 24th and 23th bit of 26'h3333333 (LSB is the 0th bit);
        4'b1101: a0_hi2nd3rd = 2'b10; // the 24th and 23th bit of 26'h314468c (LSB is the 0th bit);
        4'b1110: a0_hi2nd3rd = 2'b01; // the 24th and 23th bit of 26'h2f89bad (LSB is the 0th bit);
        default: a0_hi2nd3rd = 2'b01; // the 24th and 23th bit of 26'h2dfa9cf (LSB is the 0th bit);
    endcase
end

generate
if (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/2) - (6 / 4)) begin
// pipeline stage 6
ipsxe_floating_point_register_v1_0 #(5*1 + EXP_WIDTH + 2) u_reg_stage7(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly3, invsqrt_x_exp_dly3, a0_hi2nd3rd     }),
    .o_q({special_cases_dly4, invsqrt_x_exp_dly4, a0_hi2nd3rd_dly1})
);
end
else begin
assign {special_cases_dly4, invsqrt_x_exp_dly4, a0_hi2nd3rd_dly1} = {special_cases_dly3, invsqrt_x_exp_dly3, a0_hi2nd3rd     };
end
endgenerate

// minus or plus according to x_minus_a_is_pos
// a0 - a1 * y + z * (a2 - a3 * y + a4 * z)
// previously:
// assign a0_plus_zgroup_minus_a1y = a0_dly7 + z_group_dlt9zeros_dly2 - a1_y_dlt5zeros_dly6;
// assign a0_plus_zgroup_plus_a1y  = a0_dly7 + z_group_dlt9zeros_dly2 + a1_y_dlt5zeros_dly6;
// assign invsqrt_x_taylor_rne = x_minus_a_is_pos_dly7 ? a0_plus_zgroup_minus_a1y : a0_plus_zgroup_plus_a1y;
// now: apm with the configurable pipeline stage 7 inside, at the output port of apm
    GTP_APM_E2 #(
        .GRS_EN         ( "TRUE"                 ) ,  //"TRUE","FALSE",enable global reset
        .USE_POSTADD    ( 1'b1         ) ,  //enable postadder 0/1
        .USE_PREADD     ( 1'b1                   ) ,  //enable preadder 0/1
        .PREADD_REG     ( (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (5 / 2))                   ) ,  //preadder reg 0/1

        .X_REG          ( 2'b0           ) ,  //X input reg 0/1
        .CXO_REG        ( 2'b0                   ) ,  //X cascade out reg latency, 0/1/2/3
        .XB_REG         ( 1'b0                   ) ,  //XB input reg 0/1
        .Y_REG          ( 2'b0        ) ,  //Y input reg 0/1
        .Z_REG          ( 2'b0           ) ,  //Z input reg 0/1
        .MULT_REG       ( (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/2) - (6 / 4))           ) ,  //multiplier reg 0/1
        .P_REG          ( (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (7 / 2))           ) ,  //post adder reg 0/1
        .MODEY_REG      ( 1'b0                   ) ,  //MODEY reg
        .MODEZ_REG      ( 1'b0        ) ,  //MODEZ reg
        .MODEIN_REG     ( 1'b0                   ) ,  //MODEZ reg

        .X_SEL          ( 1'b0                   ) ,  // mult X input select X/CXI
        .XB_SEL         ( 2'b0                   ) ,  //X back propagate mux select. 0/1/2/3
        .ASYNC_RST      ( 1'b0           ) ,  // RST is sync/async
        .USE_SIMD       ( 1'b0            ) ,  // single addsub25_mult25_add48 / dual addsub12_mult12_add24
        .P_INIT0        ( P_INIT0_RNE             ) ,  //P constant input0 (RTI parameter in APM of PG family)
        .P_INIT1        ( P_INIT1_RNE             ) ,  //P constant input1 (RTI parameter in APM of PG family)
        .ROUNDMODE_SEL  ( 1'b1                   ) ,  //round mode selection

        .CPO_REG        ( 1'b0          ) ,  // CPO,COUT use register output
        .USE_ACCLOW     ( 1'b0                   ) ,  // accumulator use lower 18-bit feedback only
        .CIN_SEL        ( 1'b0                   )    // select CIN for postadder carry in

    )
    u_3add_invsqrt_x_taylor_rne
    (
        .P         ( invsqrt_x_taylor_rne                 ) ,
        .CPO       (            ) , //p cascade output
        .COUT      (                        ) ,
        .CXO       (                        ) , //x cascade output
        .CXBO      (                        ) , //x backward cascade output

        .X         ( a0_lo23_dly1 ) ,
        .CXI       (                   ) , //x cascade input
        .CXBI      (                   ) , //x backward cascade input
        .XB        ( a1_y_dlt5zeros             ) , //x backward cascade input
        .Y         ( 18'd1         ) ,
        .Z         ( {1'b1, a0_hi2nd3rd_dly1, 6'b0, z_group_dlt9zeros}             ) ,
        .CPI       (            ) , //p cascade input
        .CIN       (                    ) ,
        .MODEY     ( 3'b1                   ) ,
        .MODEZ     ( 4'd2   ) ,
        .MODEIN    ( {1'b0, x_minus_a_is_pos_dly2, 3'b110}               ) ,

        .CLK       ( i_clk ) ,

        .CEX1      ( 1'b0  ) , //X1 enable signals
        .CEX2      ( 1'b0  ) , //X2 enable signals
        .CEX3      ( 1'b0  ) , //X3 enable signals
        .CEXB      ( 1'b0  ) , //XB enable signals
        .CEY1      ( 1'b0  ) , //Y1 enable signals
        .CEY2      ( 1'b0  ) , //Y2 enable signals
        .CEZ       ( 1'b0  ) , //Z enable signals
        .CEPRE     ( 1'b1  ) , //PRE enable signals
        .CEM       ( 1'b1  ) , //M enable signals
        .CEP       ( 1'b1  ) , //P enable signals
        .CEMODEY   ( 1'b0  ) , //MODEY enable signals
        .CEMODEZ   ( 1'b0  ) , //MODEZ enable signals
        .CEMODEIN  ( 1'b0  ) , //MODEIN enable signals

        .RSTX      ( 1'b0 ) , //X reset signals
        .RSTXB     ( 1'b0 ) , //XB reset signals
        .RSTY      ( 1'b0 ) , //Y reset signals
        .RSTZ      ( 1'b0 ) , //Z reset signals
        .RSTPRE    ( 1'b0 ) , //PRE reset signals
        .RSTM      ( 1'b0 ) , //M reset signals
        .RSTP      ( 1'b0 ) , //P reset signals
        .RSTMODEY  ( 1'b0 ) , //MODEY reset signals
        .RSTMODEZ  ( 1'b0 ) , //MODEZ reset signals
        .RSTMODEIN ( 1'b0 )   //MODEIN reset signals

    );

assign invsqrt_x_taylor = invsqrt_x_taylor_rne[1+(MAN_WIDTH+1)+RNE-1:RNE];

generate
if (LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX     - (7 / 2)) begin
// pipeline stage 7
ipsxe_floating_point_register_v1_0 #(5*1 + EXP_WIDTH) u_reg_stage9(
    .i_clk(i_clk),
    .i_aclken(i_aclken),
    .i_rst_n(i_rst_n),
    .i_d({special_cases_dly4                                                                                                     , invsqrt_x_exp_dly4}),
    .o_q({no_outreg_o_valid    , no_outreg_o_invalid_op   , no_outreg_o_divide_by_zero, x_is_nan_zero_neg_dly8, x_is_pos_inf_dly8, invsqrt_x_exp_dly5})
);
end
else begin
assign {no_outreg_o_valid    , no_outreg_o_invalid_op   , no_outreg_o_divide_by_zero, x_is_nan_zero_neg_dly8, x_is_pos_inf_dly8, invsqrt_x_exp_dly5} = {special_cases_dly4                                                                                                     , invsqrt_x_exp_dly4};
end
endgenerate

assign invsqrt_x_exp_minus1 = invsqrt_x_exp_dly5 - 1'b1;
assign invsqrt_x_exp_plus1 = invsqrt_x_exp_dly5 + 1'b1;
// normalization of the result according to invsqrt_x_taylor[MAN_WIDTH+1] and invsqrt_x_taylor[MAN_WIDTH]
assign invsqrt_x_valid_or_not = invsqrt_x_taylor[MAN_WIDTH+1] ? {1'b0, invsqrt_x_exp_plus1, invsqrt_x_taylor[MAN_WIDTH:1]} : invsqrt_x_taylor[MAN_WIDTH] ? {1'b0, invsqrt_x_exp_dly5, invsqrt_x_taylor[MAN_WIDTH-1:0]} : {1'b0, invsqrt_x_exp_minus1, invsqrt_x_taylor[MAN_WIDTH-2:0], 1'b0};

// set the result to special numbers in special cases
assign no_outreg_o_invsqrt_x = x_is_nan_zero_neg_dly8 ? {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}} : x_is_pos_inf_dly8 ? {WIDTH{1'b0}} : invsqrt_x_valid_or_not;

generate
if (LATENCY_CONFIG < PIPE_STAGE_NUM_MAX + 1) begin
assign {o_valid, o_invalid_op, o_divide_by_zero, o_invsqrt_x} = {no_outreg_o_valid, no_outreg_o_invalid_op, no_outreg_o_divide_by_zero, no_outreg_o_invsqrt_x};
end
else begin // LATENCY_CONFIG >= PIPE_STAGE_NUM_MAX + 1
wire [(3*1 + WIDTH-1)-1:0] out_delay;
// pipeline stage PIPE_STAGE_NUM_MAX + 1 to ...
ipm_distributed_shiftregister_wrapper_v1_3 #((LATENCY_CONFIG - PIPE_STAGE_NUM_MAX), 3*1 + WIDTH-1) u_shift_register (
    .din({no_outreg_o_valid, no_outreg_o_invalid_op, no_outreg_o_divide_by_zero, no_outreg_o_invsqrt_x[WIDTH-1-1:0]}),      // input [12:0]
    .clk(i_clk),      // input
    .i_aclken(i_aclken),
    .rst(~i_rst_n),      // input
    .dout(out_delay)     // output [12:0]
);
assign {o_valid, o_invalid_op, o_divide_by_zero, o_invsqrt_x[WIDTH-1-1:0]} = out_delay;
assign o_invsqrt_x[WIDTH-1] = 1'b0;
end
endgenerate

endmodule