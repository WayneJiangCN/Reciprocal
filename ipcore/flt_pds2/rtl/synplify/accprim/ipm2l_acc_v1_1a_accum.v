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
// Filename:ipm2l_acc.v
// Function: p=p+/-z
//           zsize:2-240(singed)/239(unsigned)
//           psize:24,48,96,144,192,240,288
//////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns
module ipm2l_acc_v1_1a_accum
#(
    parameter               ZSIZE               = 41,       //signed:2-240;unsigned:2-239
    parameter               PSIZE               = 96,       //option:24,48,96,144,192,240,288

    parameter               OPTIMAL_TIMING      = 0,

    parameter               INREG_EN            = 0,        //input reg

    parameter               GRS_EN              = "FALSE",  //"TRUE","FALSE",enable global reset
    parameter               Z_SIGNED            = 0,        //signedness of Z

    parameter               ASYNC_RST           = 1,        //RST is sync/async
    //init value
    parameter  [0:0]        DYN_ACC_INIT        = 0,        //1:dynamic reload 0:static reload
    parameter  [PSIZE-1:0]  ACC_INIT_VALUE      = 0,        //static reload value

    parameter               DYN_ACC_ADDSUB_OP   = 0,        //1:dynamic acc 0:static acc
    parameter               ACC_ADDSUB_OP       = 0
)(
    input                   ce          ,
    input                   rst         ,
    input                   clk         ,
    input       [ZSIZE-1:0] z           ,
    input       [PSIZE-1:0] acc_init    ,
    input                   reload      ,
    input                   acc_addsub  ,                   //0:add 1:sub
    output wire [PSIZE-1:0] p
);


localparam OPTIMAL_TIMING_BOOL = 0 ; //@IPC bool


localparam ZSIZE_SIGNED  = (Z_SIGNED == 1) ? ZSIZE : (ZSIZE + 1);

localparam USE_SIMD      = (ZSIZE_SIGNED <= 24 && PSIZE == 24 ) ? 1 : 0 ;   // single add48 / dual add24

localparam MODE_24       = (USE_SIMD == 1 ) ? 24 : 48;

localparam [287:0]   ACC_INIT_VALUE_IN = {{(288-PSIZE){1'b0}},ACC_INIT_VALUE};

//data_size error check
localparam N = (PSIZE < 24 || ZSIZE < 2 ) ? 0 :
               (PSIZE <= 24  ) ? 1  :       //ACC24
               (PSIZE <= 48  ) ? 1  :       //ACC48
               (PSIZE <= 96  ) ? 2  :       //ACC96
               (PSIZE <= 144 ) ? 3  :       //ACC144
               (PSIZE <= 192 ) ? 4  :       //ACC192
               (PSIZE <= 240 ) ? 5  :       //ACC240
               (PSIZE <= 288 ) ? 6  : 0;    //ACC288

localparam GTP_APM_E2_NUM = N;
//****************************************************************GTP_APM_E2 cascade****************************************
localparam [48*6-1:0] ACC_INIT_VALUE_IN_CS = (PSIZE <= 48 ) ? {240'b0,ACC_INIT_VALUE_IN[47:0]}  :    //ACC48
                                             (PSIZE <= 96 ) ? {192'b0,ACC_INIT_VALUE_IN[95:0]}  :    //ACC96
                                             (PSIZE <= 144) ? {144'b0,ACC_INIT_VALUE_IN[143:0]} :    //ACC144
                                             (PSIZE <= 192) ? {96'b0,ACC_INIT_VALUE_IN[191:0]}  :    //ACC192
                                             (PSIZE <= 240) ? {48'b0,ACC_INIT_VALUE_IN[239:0]}  :    //ACC240
                                             (PSIZE <= 288) ? {ACC_INIT_VALUE_IN[287:0]} : 288'b0 ;  //ACC288

localparam [5:0] CPO_REG   = (OPTIMAL_TIMING == 0 ) ? 6'b0 :
                             (PSIZE <= 96 ) ? 6'b0 :             //ACC96
                             (PSIZE <= 192) ? 6'b00_0010 :       //ACC192
                             (PSIZE <= 288) ? 6'b00_1010 : 6'b0; //ACC288

localparam [5:0] CIN_SEL   = 6'b11_1110;


//**************************************************************************************************************************
initial
begin
    if (N == 0)
    begin
        $display("Accumulator parameter setting error!!! DATA_SIZE must between 2-240(signed)/239(unsigned)");
    end
end

//**********************************************************reg & wire******************************************************
wire [ZSIZE_SIGNED-1:0]     z_signed            ;

wire [47:0]                 m_z_0               ;
wire [47:0]                 m_z_1               ;
wire [47:0]                 m_z_2               ;
wire [47:0]                 m_z_3               ;
wire [47:0]                 m_z_4               ;

wire [239:0]                m_z_sign_ext        ;
wire                        acc_addsub_in       ;
wire [287:0]                acc_init_value      ;
reg  [47:0]                 acc_init_in[5:0]    ;

reg  [47:0]                 m_z_div[5:0]        ;

reg  [3:0]                  modez_in[5:0]       ;
reg  [2:0]                  modey_in[5:0]       ;

wire [47:0]                 m_p[5:0]            ;
wire [6:0]                  cout                ;


wire                        rst_async           ;
wire                        rst_sync            ;


//rst
assign rst_async = (ASYNC_RST == 1'b1) ? rst : 1'b0;
assign rst_sync  = (ASYNC_RST == 1'b0) ? rst : 1'b0;

assign z_signed  = (Z_SIGNED == 1) ? z : {1'b0,z}; //unsigned -> signed

//*******************************************************partition input data***********************************************
assign m_z_sign_ext = {{{240-ZSIZE_SIGNED}{z_signed[ZSIZE_SIGNED-1]}},z_signed};

//partition data z
assign m_z_0 = m_z_sign_ext[47:0];
assign m_z_1 = m_z_sign_ext[95:48];
assign m_z_2 = m_z_sign_ext[143:96];
assign m_z_3 = m_z_sign_ext[191:144];
assign m_z_4 = m_z_sign_ext[239:192];

//**************************************accsub**********************************************
assign acc_addsub_in  = (DYN_ACC_ADDSUB_OP == 0) ? ACC_ADDSUB_OP : acc_addsub;
assign acc_init_value = {{(288-PSIZE){1'b0}},acc_init};

//*******************************************************input data***********************************************************
generate
begin:data_for_GTP
    if (ZSIZE_SIGNED <= 24) //ACC24,psize=24/48
    begin:ACC24
        always@(*)
        begin
            m_z_div[0]  = {{{48-MODE_24}{1'b0}},m_z_0[MODE_24-1:0]};
            modez_in[0] = reload ? 4'b0 : {acc_addsub_in,3'b010};
            modey_in[0] = {1'b0,(reload ? {2{DYN_ACC_INIT}} : 2'b10)};
            acc_init_in[0] = {{{48-PSIZE}{1'b0}},acc_init_value[PSIZE-1:0]};
        end
    end
    else if (ZSIZE_SIGNED > 24 && ZSIZE_SIGNED <= 48) //ACC48,psize=48/96
    begin:ACC48
        always@(*)
        begin
            m_z_div[0]  = m_z_0;
            m_z_div[1]  = {48{m_z_0[47]}};
            modez_in[0] = reload ? 4'b0 : {acc_addsub_in,3'b010};
            modez_in[1] = reload ? 4'b0 : {acc_addsub_in,3'b010};
            modey_in[0] = {1'b0,(reload ? {2{DYN_ACC_INIT}} : 2'b10)};
            modey_in[1] = {1'b0,(reload ? {2{DYN_ACC_INIT}} : 2'b10)};
            acc_init_in[0] = acc_init_value[47:0];
            acc_init_in[1] = acc_init_value[95:48];
        end
    end
    else if (ZSIZE_SIGNED > 48 && ZSIZE_SIGNED <= 96) //ACC96,psiz=96/144
    begin:ACC96
        always@(*)
        begin
            m_z_div[0]  = m_z_0;
            m_z_div[1]  = m_z_1;
            m_z_div[2]  = {48{m_z_1[47]}};
            modez_in[0] = {2'b0,~reload,1'b0};
            modez_in[1] = {2'b0,~reload,1'b0};
            modez_in[2] = {2'b0,~reload,1'b0};
            modey_in[0] = {1'b0,(reload ? {2{DYN_ACC_INIT}} : 2'b10)};
            modey_in[1] = {1'b0,(reload ? {2{DYN_ACC_INIT}} : 2'b10)};
            modey_in[2] = {1'b0,(reload ? {2{DYN_ACC_INIT}} : 2'b10)};
            acc_init_in[0] = acc_init_value[47:0];
            acc_init_in[1] = acc_init_value[95:48];
            acc_init_in[2] = acc_init_value[143:96];
        end
    end
    else if (ZSIZE_SIGNED > 96 && ZSIZE_SIGNED <= 144) //ACC144,psiz=144/192
    begin:ACC144
        always@(*)
        begin
            m_z_div[0]  = m_z_0;
            m_z_div[1]  = m_z_1;
            m_z_div[2]  = m_z_2;
            m_z_div[3]  = {48{m_z_2[47]}};
            modez_in[0] = {2'b0,~reload,1'b0};
            modez_in[1] = {2'b0,~reload,1'b0};
            modez_in[2] = {2'b0,~reload,1'b0};
            modez_in[3] = {2'b0,~reload,1'b0};
            modey_in[0] = {1'b0,(reload ? {2{DYN_ACC_INIT}} : 2'b10)};
            modey_in[1] = {1'b0,(reload ? {2{DYN_ACC_INIT}} : 2'b10)};
            modey_in[2] = {1'b0,(reload ? {2{DYN_ACC_INIT}} : 2'b10)};
            modey_in[3] = {1'b0,(reload ? {2{DYN_ACC_INIT}} : 2'b10)};
            acc_init_in[0] = acc_init_value[47:0];
            acc_init_in[1] = acc_init_value[95:48];
            acc_init_in[2] = acc_init_value[143:96];
            acc_init_in[3] = acc_init_value[191:144];
        end
    end
    else if (ZSIZE_SIGNED > 144 && ZSIZE_SIGNED <= 192) //ACC192,psiz=192/240
    begin:ACC192
        always@(*)
        begin
            m_z_div[0]  = m_z_0;
            m_z_div[1]  = m_z_1;
            m_z_div[2]  = m_z_2;
            m_z_div[3]  = m_z_3;
            m_z_div[4]  = {48{m_z_3[47]}};
            modez_in[0] = {2'b0,~reload,1'b0};
            modez_in[1] = {2'b0,~reload,1'b0};
            modez_in[2] = {2'b0,~reload,1'b0};
            modez_in[3] = {2'b0,~reload,1'b0};
            modez_in[4] = {2'b0,~reload,1'b0};
            modey_in[0] = {1'b0,(reload ? {2{DYN_ACC_INIT}} : 2'b10)};
            modey_in[1] = {1'b0,(reload ? {2{DYN_ACC_INIT}} : 2'b10)};
            modey_in[2] = {1'b0,(reload ? {2{DYN_ACC_INIT}} : 2'b10)};
            modey_in[3] = {1'b0,(reload ? {2{DYN_ACC_INIT}} : 2'b10)};
            modey_in[4] = {1'b0,(reload ? {2{DYN_ACC_INIT}} : 2'b10)};
            acc_init_in[0] = acc_init_value[47:0];
            acc_init_in[1] = acc_init_value[95:48];
            acc_init_in[2] = acc_init_value[143:96];
            acc_init_in[3] = acc_init_value[191:144];
            acc_init_in[4] = acc_init_value[239:192];
        end
    end
    else if (ZSIZE_SIGNED > 192 && ZSIZE_SIGNED <= 240) //ACC240,psiz=240/288
    begin:ACC240
        always@(*)
        begin
            m_z_div[0]  = m_z_0;
            m_z_div[1]  = m_z_1;
            m_z_div[2]  = m_z_2;
            m_z_div[3]  = m_z_3;
            m_z_div[4]  = m_z_4;
            m_z_div[5]  = {48{m_z_4[47]}};
            modez_in[0] = {2'b0,~reload,1'b0};
            modez_in[1] = {2'b0,~reload,1'b0};
            modez_in[2] = {2'b0,~reload,1'b0};
            modez_in[3] = {2'b0,~reload,1'b0};
            modez_in[4] = {2'b0,~reload,1'b0};
            modez_in[5] = {2'b0,~reload,1'b0};
            modey_in[0] = {1'b0,(reload ? {2{DYN_ACC_INIT}} : 2'b10)};
            modey_in[1] = {1'b0,(reload ? {2{DYN_ACC_INIT}} : 2'b10)};
            modey_in[2] = {1'b0,(reload ? {2{DYN_ACC_INIT}} : 2'b10)};
            modey_in[3] = {1'b0,(reload ? {2{DYN_ACC_INIT}} : 2'b10)};
            modey_in[4] = {1'b0,(reload ? {2{DYN_ACC_INIT}} : 2'b10)};
            modey_in[5] = {1'b0,(reload ? {2{DYN_ACC_INIT}} : 2'b10)};
            acc_init_in[0] = acc_init_value[47:0];
            acc_init_in[1] = acc_init_value[95:48];
            acc_init_in[2] = acc_init_value[143:96];
            acc_init_in[3] = acc_init_value[191:144];
            acc_init_in[4] = acc_init_value[239:192];
            acc_init_in[5] = acc_init_value[287:240];
        end
    end
end
endgenerate


//************************************************************GTP*********************************************************
genvar i;
generate
    for (i=0; i< GTP_APM_E2_NUM; i=i+1)
    begin:acc
        GTP_APM_E2 #(
            .GRS_EN         ( GRS_EN                 ) ,  //"TRUE","FALSE",enable global reset
            .USE_POSTADD    ( 1'b1                   ) ,  //enable postadder 0/1
            .USE_PREADD     ( 1'b0                   ) ,  //enable preadder 0/1
            .PREADD_REG     ( 1'b0                   ) ,  //preadder reg 0/1

            .X_REG          ( INREG_EN               ) ,  //X input reg 0/1
            .CXO_REG        ( 2'b0                   ) ,  //X cascade out reg latency, 0/1/2/3
            .XB_REG         ( 1'b0                   ) ,  //XB input reg 0/1
            .Y_REG          ( INREG_EN               ) ,  //Y input reg 0/1
            .Z_REG          ( INREG_EN               ) ,  //Z input reg 0/1
            .MULT_REG       ( 1'b0                   ) ,  //multiplier reg 0/1
            .P_REG          ( 1'b1                   ) ,  //post adder reg 0/1
            .MODEY_REG      ( INREG_EN               ) ,  //MODEY reg
            .MODEZ_REG      ( INREG_EN               ) ,  //MODEZ reg
            .MODEIN_REG     ( 1'b0                   ) ,  //MODEZ reg
            .USE_MULT       ( 1'b0                   ) ,  //enable mult 1/0

            .X_SEL          ( 1'b0                   ) ,  // mult X input select X/CXI
            .XB_SEL         ( 2'b0                   ) ,  //X back propagate mux select. 0/1/2/3
            .ASYNC_RST      ( ASYNC_RST              ) ,  // RST is sync/async
            .USE_SIMD       ( USE_SIMD               ) ,  // single addsub25_mult25_add48 / dual addsub12_mult12_add24
            .P_INIT0        ( {48{1'b0}}             ) ,  //P constant input0 (RTI parameter in APM of PG family) MAC INIT value
            .P_INIT1        ( ACC_INIT_VALUE_IN_CS[48*(i+1)-1:48*i] ) ,  //P constant input1 (RTI parameter in APM of PG family)
            .ROUNDMODE_SEL  ( 1'b0                   ) ,  //round mode selection

            .CPO_REG        ( CPO_REG[i]             ) ,  // CPO,COUT use register output
            .USE_ACCLOW     ( 1'b0                   ) ,  // accumulator use lower 18-bit feedback only
            .CIN_SEL        ( CIN_SEL[i]             )    // select CIN for postadder carry in

        )
        acc
        (
            .P         ( m_p[i]                ) ,
            .CPO       (                       ) , //p cascade output
            .COUT      ( cout[i+1]             ) ,
            .CXO       (                       ) , //x cascade output
            .CXBO      (                       ) , //x backward cascade output

            .X         ( acc_init_in[i][47:18] ) ,
            .CXI       ( 30'b0                 ) , //x cascade input
            .CXBI      ( 25'b0                 ) , //x backward cascade input
            .XB        ( {25{1'b1}}            ) , //x backward cascade input
            .Y         ( acc_init_in[i][17:0]  ) ,
            .Z         ( m_z_div[i]            ) ,
            .CPI       ( 48'b0                 ) , //p cascade input
            .CIN       ( cout[i]               ) ,
            .MODEY     ( modey_in[i]           ) ,
            .MODEZ     ( modez_in[i]           ) ,
            .MODEIN    ( 5'b00010              ) ,

            .CLK       ( clk)   ,

            .CEX1      ( ce )  ,  //X1 enable signals
            .CEX2      ( ce )  ,  //X2 enable signals
            .CEX3      ( ce )  ,  //X3 enable signals
            .CEXB      ( ce )  ,  //XB enable signals
            .CEY1      ( ce )  ,  //Y1 enable signals
            .CEY2      ( ce )  ,  //Y2 enable signals
            .CEZ       ( ce )  ,  //Z enable signals
            .CEPRE     ( ce )  ,  //PRE enable signals
            .CEM       ( ce )  ,  //M enable signals
            .CEP       ( ce )  ,  //P enable signals
            .CEMODEY   ( ce )  ,  //MODEY enable signals
            .CEMODEZ   ( ce )  ,  //MODEZ enable signals
            .CEMODEIN  ( ce )  ,  //MODEIN enable signals

            .RSTX      ( rst ) , //X reset signals
            .RSTXB     ( rst ) , //XB reset signals
            .RSTY      ( rst ) , //Y reset signals
            .RSTZ      ( rst ) , //Z reset signals
            .RSTPRE    ( rst ) , //PRE reset signals
            .RSTM      ( rst ) , //M reset signals
            .RSTP      ( rst ) , //P reset signals
            .RSTMODEY  ( 1'b0) , //MODEY reset signals
            .RSTMODEZ  ( 1'b0) , //MODEZ reset signals
            .RSTMODEIN ( rst )   //MODEIN reset signals

        );
    end
endgenerate

//*****************************************************************output***************************************************
 
generate
begin:outdata
    if (PSIZE <= 24)   //ACC24
        assign p[23:0] = m_p[0][23:0];
    else if (PSIZE > 24 && PSIZE <= 48)    //ACC48
        assign p[47:0] = m_p[0];
    else if (PSIZE > 48 &&PSIZE <= 96)     //ACC96
        assign p[95:0] = {m_p[1],m_p[0]};
    else if (PSIZE > 96 &&PSIZE <= 144)    //ACC144
        assign p[143:0] = {m_p[2],m_p[1],m_p[0]};
    else if (PSIZE > 144 &&PSIZE <= 192)   //ACC192
        assign p[191:0] = {m_p[3],m_p[2],m_p[1],m_p[0]};
    else if (PSIZE > 192 &&PSIZE <= 240)   //ACC240
        assign p[239:0] = {m_p[4],m_p[3],m_p[2],m_p[1],m_p[0]};
    else if (PSIZE > 240 &&PSIZE <= 288)   //ACC288
        assign p[287:0] = {m_p[5],m_p[4],m_p[3],m_p[2],m_p[1],m_p[0]};
end
endgenerate

endmodule
