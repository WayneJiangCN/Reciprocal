// Created by IP Generator (Version 2021.3 build 83302)


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
// Filename:ipm_distributed_shiftregister_v1_2_ips2t_apm_data_pipeline.v
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps

module ipm2l_apm_distributed_shiftregister
     #(
      parameter  FIXED_DEPTH            = 16              ,    //range:1-1024
      parameter  VARIABLE_MAX_DEPTH     = 16              ,    //range:1-1024
      parameter  DATA_WIDTH             = 16              ,    //data width      range:1-256
      parameter  SHIFT_REG_TYPE         = "fixed_latency" ,    //default value :"fixed_latency" or "dynamic_latency"
      parameter  RST_TYPE               = "ASYNC"              //reset type   "ASYNC" "SYNC"

     )
     (
      din ,
      addr,
      clk ,
      rst ,
      dout
     );

localparam  DEPTH       = (SHIFT_REG_TYPE=="fixed_latency"  ) ? FIXED_DEPTH :
                          (SHIFT_REG_TYPE=="dynamic_latency") ? VARIABLE_MAX_DEPTH : 0;

localparam  ADDR_WIDTH  = (DEPTH<=16 ) ? 4 :
                          (DEPTH<=32 ) ? 5 :
                          (DEPTH<=64 ) ? 6 :
                          (DEPTH<=128) ? 7 :
                          (DEPTH<=256) ? 8 :
                          (DEPTH<=512) ? 9 : 10;

//***********************************************************IO******************************
input   wire  [DATA_WIDTH-1:0]      din        ;
input   wire  [ADDR_WIDTH-1:0]      addr       ;
input   wire                        clk        ;
input   wire                        rst        ;
output  wire  [DATA_WIDTH-1:0]      dout       ;
//*******************************************************************************************
reg           [ADDR_WIDTH-1:0]      wr_addr    ;
wire           [ADDR_WIDTH-1:0]      rd_addr    ;

        always @(posedge clk or posedge rst) begin
            if (rst)
                wr_addr <= 0;
            else
                wr_addr <= wr_addr+1;
        end

generate
    if (SHIFT_REG_TYPE=="fixed_latency")
        assign rd_addr = wr_addr+2**ADDR_WIDTH-DEPTH;
    else if (SHIFT_REG_TYPE=="dynamic_latency")
        assign rd_addr = wr_addr+2**ADDR_WIDTH-addr;
endgenerate

//********************************************************* SDP INST **************************************************
ipm2l_apm_distributed_sdpram
 #(
   .ADDR_WIDTH      (ADDR_WIDTH )   ,
   .DATA_WIDTH      (DATA_WIDTH )   ,
   .RST_TYPE        (RST_TYPE   )   ,
   .OUT_REG         (1'b1       )   ,
   .INIT_FILE       ("NONE"     )   ,
   .FILE_FORMAT     ("BIN"      )
  ) u_ipm2l_apm_distributed_sdpram
  (
   .wr_data         (din        )   ,
   .wr_addr         (wr_addr    )   ,
   .rd_addr         (rd_addr    )   ,
   .wr_clk          (clk        )   ,
   .rd_clk          (clk        )   ,
   .wr_en           (1'b1       )   ,
   .rst             (rst        )   ,
   .rd_data         (dout       )
  );
endmodule

