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
// Filename: ipsxe_floating_point_apm_primitive_a2lo_minus_a3_y_v1_0.v
// Function: This module instantiates an apm for i_a2_lo +- (a3 * y).
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_apm_primitive_a2lo_minus_a3_y_v1_0 #(parameter MAN_WIDTH = 52, RNE = 2, RNE1 = 49, RNE2 = 44, LATENCY_CONFIG = 1, PIPE_STAGE_NUM_MAX = 1) (
    input i_clk,
    input [(((MAN_WIDTH+1)+RNE+RNE1)/2)-9-1:0] i_a2_lo,
    input i_x_minus_a_is_pos,
    input [(((MAN_WIDTH+1)+RNE+RNE1)/2)-9-1:0] i_a3_y_dlt9zeros,
    output [48-1:0] o_a2lo_minus_a3y
);

localparam Y_REG = (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/4) - (12 / 8)) ? 2'b1 : 2'b0;

// a2lo +- i_a3_y_dlt9zeros
    GTP_APM_E2 #(
        .GRS_EN         ( "TRUE"                 ) ,  //"TRUE","FALSE",enable global reset
        .USE_POSTADD    ( 1'b1         ) ,  //enable postadder 0/1
        .USE_PREADD     ( 1'b0                ) ,  //enable preadder 0/1
        .PREADD_REG     ( 1'b0                   ) ,  //preadder reg 0/1

        .X_REG          ( (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/4) - (12 / 8))           ) ,  //X input reg 0/1
        .CXO_REG        ( 2'b0                   ) ,  //X cascade out reg latency, 0/1/2/3
        .XB_REG         ( 1'b0                   ) ,  //XB input reg 0/1
        .Y_REG          ( Y_REG           ) ,  //Y input reg 0/1
        .Z_REG          ( (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/4) - (12 / 8))           ) ,  //Z input reg 0/1
        .MULT_REG       ( 1'b0        ) ,  //multiplier reg 0/1
        .P_REG          ( 1'b0        ) ,  //post adder reg 0/1
        .MODEY_REG      ( 1'b0                   ) ,  //MODEY reg
        .MODEZ_REG      ( (LATENCY_CONFIG >= (PIPE_STAGE_NUM_MAX/4) - (12 / 8))           ) ,  //MODEZ reg
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
    u_a2lo_minus_a3y
    (
        .P         ( o_a2lo_minus_a3y                 ) ,
        .CPO       (            ) , //p cascade output
        .COUT      (                        ) ,
        .CXO       (                        ) , //x cascade output
        .CXBO      (                        ) , //x backward cascade output

        .X         ( i_a2_lo[18+:25] ) , // a2lo_hi25
        .CXI       (                   ) , //x cascade input
        .CXBI      (                   ) , //x backward cascade input
        .XB        (              ) , //x backward cascade input
        .Y         ( i_a2_lo[17:0]             ) , // a2lo_lo18
        .Z         ( i_a3_y_dlt9zeros             ) ,
        .CPI       (            ) , //p cascade input
        .CIN       (                    ) ,
        .MODEY     ( {1'b0, 2'b11}                   ) ,
        .MODEZ     ( {i_x_minus_a_is_pos, 3'd2}   ) ,
        .MODEIN    ( {1'b0, 1'b0, 3'b110}               ) ,

        .CLK       ( i_clk ) ,

        .CEX1      ( 1'b1  ) , //X1 enable signals
        .CEX2      ( 1'b1  ) , //X2 enable signals
        .CEX3      ( 1'b1  ) , //X3 enable signals
        .CEXB      ( 1'b1  ) , //XB enable signals
        .CEY1      ( 1'b1  ) , //Y1 enable signals
        .CEY2      ( 1'b1  ) , //Y2 enable signals
        .CEZ       ( 1'b1  ) , //Z enable signals
        .CEPRE     ( 1'b1  ) , //PRE enable signals
        .CEM       ( 1'b1  ) , //M enable signals
        .CEP       ( 1'b1  ) , //P enable signals
        .CEMODEY   ( 1'b1  ) , //MODEY enable signals
        .CEMODEZ   ( 1'b1  ) , //MODEZ enable signals
        .CEMODEIN  ( 1'b1  ) , //MODEIN enable signals

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

endmodule