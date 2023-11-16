
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
// Filename: a1_y_mul.v                 
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module a1_y_mul
( 
     ce  ,
     rst ,
     clk ,
     a   ,
     b   ,
     p
);



localparam ASIZE               = 51 ; //@IPC int 2,82

localparam BSIZE               = 45 ; //@IPC int 2,82

localparam A_SIGNED            = 0 ; //@IPC enum 0,1

localparam B_SIGNED            = 0 ; //@IPC enum 0,1

localparam ASYNC_RST           = 1 ; //@IPC enum 0,1

localparam OPTIMAL_TIMING      = 0 ; //@IPC enum 0,1

//tmp variable for ipc purpose 

localparam PIPE_STATUS         = 5 ; //@IPC enum 0,1,2,3,4,5

localparam ASYNC_RST_BOOL      = 1 ; //@IPC bool

localparam OPTIMAL_TIMING_BOOL = 0 ; //@IPC bool

localparam ADVANCED_BOOL       = 1 ; //@IPC bool

localparam XYREG               = 1 ; //@IPC bool

localparam MREG                = 1 ; //@IPC bool

localparam PREG                = 0 ; //@IPC bool

localparam INREG               = 0 ; //@IPC bool

localparam OUTREG              = 0 ; //@IPC bool

localparam CPO_REG             = 14'b00000000101010 ; //@IPC string

//end of tmp variable
localparam  GRS_EN       = "FALSE"         ;  

localparam  PSIZE = ASIZE + BSIZE          ;  

input                 ce  ;
input                 rst ;
input                 clk ;
input  [ASIZE-1:0]    a   ;
input  [BSIZE-1:0]    b   ;
output [PSIZE-1:0]    p   ;

ipm2l_mult_v1_2
#(  
    .ASIZE           ( ASIZE            ),
    .BSIZE           ( BSIZE            ),
    .OPTIMAL_TIMING  ( OPTIMAL_TIMING   ), 

    .ADVANCED_BOOL   ( ADVANCED_BOOL    ),

    .INREG_EN        ( INREG            ),    
    .PIPEREG_EN_1    ( XYREG            ),     
    .PIPEREG_EN_2    ( MREG             ),
    .PIPEREG_EN_3    ( PREG             ),
    .OUTREG_EN       ( OUTREG           ),
    .CPO_REG         ( {1'b0,CPO_REG}   ),
    .PIPE_STATUS     ( PIPE_STATUS      ),

    .GRS_EN          ( GRS_EN           ),  
    .A_SIGNED        ( A_SIGNED         ),     
    .B_SIGNED        ( B_SIGNED         ),     
    .ASYNC_RST       ( ASYNC_RST        )      
)u_ipm2l_mult_a1_y_mul
(
    .ce              ( ce     ),
    .rst             ( rst    ),
    .clk             ( clk    ),
    .a               ( a      ),
    .b               ( b      ),
    .p               ( p      )
);

endmodule
