//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2016 PANGO MICROSYSTEMS, INC
// ALL RIGHTS RESERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
//
//
// GTP model of APML device
//
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1 ns / 1 ps

`define assert(condition, message) \
        if (!(condition)) begin \
            $display($realtime, "ERROR: ASSERTION FAILED in %s, line %d: %s", `__FILE__, `__LINE__, message); \
            $finish; \
        end

// module declaration 
module GTP_APM_E1 #(

    parameter GRS_EN = "TRUE",  //"TRUE","FALSE",enable global reset
    parameter X_SIGNED = 0, //signedness of X. X[17:9] and X[8:0] share the same signedness in mult9x9 mode
    parameter Y_SIGNED = 0, //signedness of Y. Y[17:9] and Y[8:0] share the same signedness in mult9x9 mode

    parameter USE_POSTADD = 0, //enable postadder 0/1
    parameter USE_PREADD = 0,  //enable preadder 0/1
    parameter PREADD_REG = 0,  //preadder reg 0/1

    parameter X_REG = 0,  //X input reg 0/1
    parameter CXO_REG = 0, //X cascade out reg latency, 0/1/2/3
    parameter Y_REG = 0,  //Y input reg 0/1
    parameter Z_REG = 0,  //Z input reg 0/1
    parameter MULT_REG = 0,  //multiplier reg 0/1
    parameter P_REG = 0,  //post adder reg 0/1
    parameter MODEX_REG = 0,  //MODEX reg
    parameter MODEY_REG = 0,  //MODEY reg
    parameter MODEZ_REG = 0,  //MODEZ reg

    parameter X_SEL = 0,  // mult X input select X/CXI
    parameter XB_SEL = 0, //X back propagate mux select. 0/1/2/3
    parameter ASYNC_RST = 0,  // RST is sync/async
    parameter USE_SIMD = 0,   // single addsub18_mult18_add48 / dual addsub9_mult9_add24
    parameter [47:0] Z_INIT = {48{1'b0}},  //Z constant input (RTI parameter in APM of PG family)

    parameter CPO_REG = 0, // CPO,COUT use register output
    parameter USE_ACCLOW = 0, // accumulator use lower 18-bit feedback only
    parameter CIN_SEL = 0 // select CIN for postadder carry in

)(

    output [47:0] P,  //Postadder resout
    output [47:0] CPO, //P cascade out
    output COUT,         //Postadder carry out
    output [17:0] CXO, //X cascade out
    output [17:0] CXBO, //X backward cascade out

    input [17:0] X,
    input [17:0] CXI, //X cascade in
    input [17:0] CXBI, //X backward cascade in
    input [17:0] Y,
    input [47:0] Z,
    input [47:0] CPI, //P cascade in
    input CIN,          //Postadder carry in
    input       MODEX,  // preadder add/sub, 0/1
    input [2:0] MODEY,
// MODEY encoding: 0/1
// [0]     produce all-0 input to post adder / enable P register feedback. MODEY[1] needs to be 1 for MODEY[0] to take effect.
// [1]     enable/disable mult input for post adder
// [2]     +/- (mult-mux output polarity)

    input [3:0] MODEZ,
// MODEZ encoding: 0/1
// [0]     CPI / (CPI >>> 18) (select shift or non-shift CPI)
// [2:1]   Z_INIT/P/Z/CPI (zmux input select)
// [3]     +/- (zmux output polarity)       


    input CLK,

    input RSTX,
    input RSTY,
    input RSTZ,
    input RSTM,
    input RSTP,
    input RSTPRE,
    input RSTMODEX,
    input RSTMODEY,
    input RSTMODEZ,

    input CEX,
    input CEY,
    input CEZ,
    input CEM,
    input CEP,
    input CEPRE,
    input CEMODEX,
    input CEMODEY,
    input CEMODEZ

);

    wire grs;
    assign grs = (GRS_EN == "TRUE") ? !GRS_INST.GRSNET : 1'b0;


// prepare intermediate array  
    wire mode_ce [2:0];
    wire mode_rst [2:0];

    assign mode_ce[0] = CEMODEZ;
    assign mode_ce[1] = CEMODEY;
    assign mode_ce[2] = CEMODEX;

    assign mode_rst[0] = RSTMODEZ;
    assign mode_rst[1] = RSTMODEY;
    assign mode_rst[2] = RSTMODEX;

    wire [1:0] mode_group_idx [7:0]; //lookup table, each MODE register bit belongs to 1 of 3 groups

    assign mode_group_idx[0] = 0;
    assign mode_group_idx[1] = 0;
    assign mode_group_idx[2] = 0;
    assign mode_group_idx[3] = 0;
    assign mode_group_idx[4] = 1;
    assign mode_group_idx[5] = 1;
    assign mode_group_idx[6] = 1;
    assign mode_group_idx[7] = 2;

    genvar i;

    wire [7:0] MODE = {MODEX, MODEY, MODEZ};
    wire [2:0] MODEREG = {MODEX_REG[0], MODEY_REG[0], MODEZ_REG[0]};

    wire [17:0] Xv = X;
    wire [17:0] Yv = Y;
    wire [47:0] Zv = Z;
    wire [7:0] MODEv = MODE;

// registers 

    wire [17:0] X1; // X register (latency == 1)
// X cascade output bus
    localparam XREG_WIDTH = 18;
    localparam XREG_DEPTH = 3;
    wire [XREG_WIDTH-1:0] xreg_d; 
    assign xreg_d = X_SEL ? CXI : Xv;
    assign xreg_rsta = (ASYNC_RST == 1'b1) ? (RSTX | grs) : grs;
    assign xreg_rsts = (ASYNC_RST == 1'b1) ? 1'b0 : RSTX;

    reg [XREG_WIDTH-1:0] xreg_qarr[XREG_DEPTH:0];
    always @(*) begin
        // pragma translate_off
        if (CXO_REG < 0 || CXO_REG > XREG_DEPTH) begin
            $display("ERROR: GTP_APM_E1 instance %m parameter CXO_REG = %d is illegal. The legal values are 0,1,2,3.", CXO_REG);
            $finish;
        end
        // pragma translate_on
        xreg_qarr[0] = xreg_d ;
    end

    integer j;
    always @(posedge CLK or posedge xreg_rsta) begin
        for (j = 1; j <= XREG_DEPTH; j = j + 1) begin
            if (xreg_rsta == 1'b1) begin
                xreg_qarr[j] <= {XREG_WIDTH{1'b0}};
            end else if (xreg_rsts == 1'b1) begin
                xreg_qarr[j] <= {XREG_WIDTH{1'b0}};
            end else if (CEX == 1'b1) begin
                xreg_qarr[j] <= xreg_qarr[j - 1];
            end
        end
    end

    assign CXO = xreg_qarr[CXO_REG];
    assign X1 = xreg_qarr[1];


    wire [17:0] Xi; //registered (optional) X internal bus
    assign Xi = X_REG ? X1 : (X_SEL ? CXI : Xv);

    wire [17:0] Yi; //registered (optional) Y internal
    localparam YREG_WIDTH = 18;
    localparam YREG_DEPTH = 1;
    wire [YREG_WIDTH-1:0] yreg_d; 
    assign yreg_d = Yv;
    assign yreg_rsta = (ASYNC_RST == 1'b1) ? (RSTY | grs) : grs;
    assign yreg_rsts = (ASYNC_RST == 1'b1) ? 1'b0 : RSTY;

    reg [YREG_WIDTH-1:0] yreg_qarr[YREG_DEPTH:0];
    always @(*) begin
        // pragma translate_off
        if (Y_REG < 0 || Y_REG > YREG_DEPTH) begin
            $display("ERROR: GTP_APM_E1 instance %m parameter Y_REG = %d is illegal. The legal value is 0,1.", Y_REG);
            $finish;
        end
        // pragma translate_on
        yreg_qarr[0] = yreg_d ;
    end

    always @(posedge CLK or posedge yreg_rsta) begin
        for (j = 1; j <= YREG_DEPTH; j = j + 1) begin
            if (yreg_rsta == 1'b1) begin
                yreg_qarr[j] <= {YREG_WIDTH{1'b0}};
            end else if (yreg_rsts == 1'b1) begin
                yreg_qarr[j] <= {YREG_WIDTH{1'b0}};
            end else if (CEY == 1'b1) begin
                yreg_qarr[j] <= yreg_qarr[j - 1];
            end
        end
    end

    assign Yi = yreg_qarr[Y_REG];

    wire [47:0] Zi; //registered (optional) Z internal
    localparam ZREG_WIDTH = 48;
    localparam ZREG_DEPTH = 1;
    wire [ZREG_WIDTH-1:0] zreg_d; 
    assign zreg_d = Zv;
    assign zreg_rsta = (ASYNC_RST == 1'b1) ? (RSTZ | grs) : grs;
    assign zreg_rsts = (ASYNC_RST == 1'b1) ? 1'b0 : RSTZ;

    reg [ZREG_WIDTH-1:0] zreg_qarr[ZREG_DEPTH:0];
    always @(*) begin
        // pragma translate_off
        if (Z_REG < 0 || Z_REG > ZREG_DEPTH) begin
            $display("ERROR: GTP_APM_E1 instance %m parameter Z_REG = %d is illegal. The legal value is 0,1.", Z_REG);
            $finish;
        end
        // pragma translate_on
        zreg_qarr[0] = zreg_d ;
    end

    always @(posedge CLK or posedge zreg_rsta) begin
        for (j = 1; j <= ZREG_DEPTH; j = j + 1) begin
            if (zreg_rsta == 1'b1) begin
                zreg_qarr[j] <= {ZREG_WIDTH{1'b0}};
            end else if (zreg_rsts == 1'b1) begin
                zreg_qarr[j] <= {ZREG_WIDTH{1'b0}};
            end else if (CEZ == 1'b1) begin
                zreg_qarr[j] <= zreg_qarr[j - 1];
            end
        end
    end

    assign Zi = zreg_qarr[Z_REG];

    wire [7:0] MODEi; //registered (optional) MODE internal

    generate
    for (i = 0; i < 8; i = i + 1) begin
    localparam MODEREG_WIDTH = 1;
    localparam MODEREG_DEPTH = 1;
    wire [MODEREG_WIDTH-1:0] modereg_d; 
    assign modereg_d = MODEv[i];
    assign modereg_rsta = (ASYNC_RST == 1'b1) ? (mode_rst[mode_group_idx[i]] | grs) : grs;
    assign modereg_rsts = (ASYNC_RST == 1'b1) ? 1'b0 : mode_rst[mode_group_idx[i]];

    reg [MODEREG_WIDTH-1:0] modereg_qarr[MODEREG_DEPTH:0];
    always @(*) begin
        // pragma translate_off
        if (MODEREG[mode_group_idx[i]] < 0 || MODEREG[mode_group_idx[i]] > MODEREG_DEPTH) begin
            $display("ERROR: GTP_APM_E1 instance %m parameter MODE_REG = %d is illegal. The legal value is 0,1.", MODEREG[mode_group_idx[i]]);
            $finish;
        end
        // pragma translate_on
        modereg_qarr[0] = modereg_d ;
    end

    always @(posedge CLK or posedge modereg_rsta) begin
        for (j = 1; j <= MODEREG_DEPTH; j = j + 1) begin
            if (modereg_rsta == 1'b1) begin
                modereg_qarr[j] <= {MODEREG_WIDTH{1'b0}};
            end else if (modereg_rsts == 1'b1) begin
                modereg_qarr[j] <= {MODEREG_WIDTH{1'b0}};
            end else if (mode_ce[mode_group_idx[i]] == 1'b1) begin
                modereg_qarr[j] <= modereg_qarr[j - 1];
            end
        end
    end

    assign MODEi[i] = modereg_qarr[MODEREG[mode_group_idx[i]]];
    end
    endgenerate

// preadder
    wire [17:0] XBr; //registered CXBI
    localparam XBREG_WIDTH = 18;
    localparam XBREG_DEPTH = 1;
    wire [XBREG_WIDTH-1:0] xbreg_d; 
    assign xbreg_d = CXBI;
    assign xbreg_rsta = (ASYNC_RST == 1'b1) ? (RSTZ | grs) : grs;
    assign xbreg_rsts = (ASYNC_RST == 1'b1) ? 1'b0 : RSTZ;

    reg [XBREG_WIDTH-1:0] xbreg_qarr[XBREG_DEPTH:0];
    always @(*) begin
        xbreg_qarr[0] = xbreg_d ;
    end

    always @(posedge CLK or posedge xbreg_rsta) begin
        for (j = 1; j <= XBREG_DEPTH; j = j + 1) begin
            if (xbreg_rsta == 1'b1) begin
                xbreg_qarr[j] <= {XBREG_WIDTH{1'b0}};
            end else if (xbreg_rsts == 1'b1) begin
                xbreg_qarr[j] <= {XBREG_WIDTH{1'b0}};
            end else if (CEZ == 1'b1) begin
                xbreg_qarr[j] <= xbreg_qarr[j - 1];
            end
        end
    end

    assign XBr = xbreg_qarr[1];

    reg [17:0] XBi;
    always @(*) begin
        case (XB_SEL)
            2'b00 : XBi = Zi[47:30];
            2'b01 : XBi = CXBI;
            2'b10 : XBi = XBr;
            2'b11 : XBi = CXO;
        endcase
    end
    assign CXBO = XBi;

    //
    // PRE add/sub with SIMD feature
    //
    wire [17:0] PREc; //combinational preadder output
    localparam PREADD_WIDTH = 18;
    wire preadd_sub;
    wire [PREADD_WIDTH-1:0] preadd_S;
    wire [PREADD_WIDTH/2-1:0] preadd_A_hi, preadd_A_lo;
    wire [PREADD_WIDTH/2-1:0] preadd_B_hi, preadd_B_lo;
    wire [PREADD_WIDTH/2-1:0] preadd_S_hi, preadd_S_lo;
    assign preadd_sub = MODEi[7];
    assign preadd_A_hi = Xi[PREADD_WIDTH - 1 : PREADD_WIDTH/2];
    assign preadd_B_hi = XBi[PREADD_WIDTH - 1 : PREADD_WIDTH/2];
    assign preadd_A_lo = Xi[PREADD_WIDTH/2 - 1 : 0];
    assign preadd_B_lo = XBi[PREADD_WIDTH/2 - 1 : 0];
    // 18-bit addsub
    assign preadd_S = preadd_sub ? Xi - XBi : Xi + XBi;
    // dual 9-bit addsub
    assign preadd_S_hi = preadd_sub ? preadd_A_hi - preadd_B_hi : preadd_A_hi + preadd_B_hi;
    assign preadd_S_lo = preadd_sub ? preadd_A_lo - preadd_B_lo : preadd_A_lo + preadd_B_lo;
    //
    assign PREc = (USE_SIMD == 1'b1)? {preadd_S_hi, preadd_S_lo} : preadd_S;

    wire [17:0] PREi; //registered (optional) preadder output
    localparam PREREG_WIDTH = 18;
    localparam PREREG_DEPTH = 1;
    wire [PREREG_WIDTH-1:0] prereg_d; 
    assign prereg_d = PREc;
    assign prereg_rsta = (ASYNC_RST == 1'b1) ? (RSTPRE | grs) : grs;
    assign prereg_rsts = (ASYNC_RST == 1'b1) ? 1'b0 : RSTPRE;

    reg [PREREG_WIDTH-1:0] prereg_qarr[PREREG_DEPTH:0];
    always @(*) begin
        // pragma translate_off
        if (PREADD_REG < 0 || PREADD_REG > PREREG_DEPTH) begin
            $display("ERROR: GTP_APM_E1 instance %m parameter PREADD_REG = %d is illegal. The legal value is 0,1.", PREADD_REG);
            $finish;
        end
        // pragma translate_on
        prereg_qarr[0] = prereg_d ;
    end

    always @(posedge CLK or posedge prereg_rsta) begin
        for (j = 1; j <= PREREG_DEPTH; j = j + 1) begin
            if (prereg_rsta == 1'b1) begin
                prereg_qarr[j] <= {PREREG_WIDTH{1'b0}};
            end else if (prereg_rsts == 1'b1) begin
                prereg_qarr[j] <= {PREREG_WIDTH{1'b0}};
            end else if (CEPRE == 1'b1) begin
                prereg_qarr[j] <= prereg_qarr[j - 1];
            end
        end
    end

    assign PREi = prereg_qarr[PREADD_REG];

// multiplier
    wire [47:0] Mc; //mult combinational output
    wire [17:0] mult_x;
    wire [17:0] mult_y;
    assign mult_x = USE_PREADD ? PREi : Xi;
    assign mult_y = Yi;
    localparam MULT_IWIDTH = 18;
    localparam MULT_OWIDTH = 48;
    wire [MULT_OWIDTH-1:0] mult_p0;
    wire [MULT_OWIDTH-1:0] mult_p1;
    // mult18
    wire multp0_sign_x;
    wire multp0_sign_y;
    assign multp0_sign_x = X_SIGNED ? mult_x[MULT_IWIDTH-1] : 1'b0;
    assign multp0_sign_y = Y_SIGNED ? mult_y[MULT_IWIDTH-1] : 1'b0;
    wire [MULT_OWIDTH-1:0] multp0_Xi;
    wire [MULT_OWIDTH-1:0] multp0_Yi;
    assign multp0_Xi = {{(MULT_OWIDTH-MULT_IWIDTH){multp0_sign_x}},mult_x};
    assign multp0_Yi = {{(MULT_OWIDTH-MULT_IWIDTH){multp0_sign_y}},mult_y};
    assign mult_p0 = multp0_Xi * multp0_Yi;
    //mult9_0
    wire multp1_0_sign_x;
    wire multp1_0_sign_y;
    assign multp1_0_sign_x = X_SIGNED ? mult_x[MULT_IWIDTH/2-1] : 1'b0;
    //assign multp1_0_sign_y = Y_SIGNED ? mult_y[MULT_IWIDTH/2-1] : 1'b0;
    assign multp1_0_sign_y = Y_SIGNED ? mult_y[8] : 1'b0;
    wire [MULT_OWIDTH/2-1:0] multp1_0_Xi;
    wire [MULT_OWIDTH/2-1:0] multp1_0_Yi;
    assign multp1_0_Xi = {{(MULT_OWIDTH/2-MULT_IWIDTH/2){multp1_0_sign_x}},mult_x[MULT_IWIDTH/2-1:0]};
    assign multp1_0_Yi = {{(MULT_OWIDTH/2-MULT_IWIDTH/2){multp1_0_sign_y}},mult_y[MULT_IWIDTH/2-1:0]};
    assign mult_p1[MULT_OWIDTH/2-1:0] = multp1_0_Xi * multp1_0_Yi;
    //mult9_1
    wire multp1_1_sign_x;
    wire multp1_1_sign_y;
    assign multp1_1_sign_x = X_SIGNED ? mult_x[MULT_IWIDTH-1] : 1'b0;
    assign multp1_1_sign_y = Y_SIGNED ? mult_y[MULT_IWIDTH-1] : 1'b0;
    wire [MULT_OWIDTH-1:MULT_OWIDTH/2] multp1_1_Xi;
    wire [MULT_OWIDTH-1:MULT_OWIDTH/2] multp1_1_Yi;
    assign multp1_1_Xi = {{(MULT_OWIDTH/2-MULT_IWIDTH/2){multp1_1_sign_x}},mult_x[MULT_IWIDTH-1:MULT_IWIDTH/2]};
    assign multp1_1_Yi = {{(MULT_OWIDTH/2-MULT_IWIDTH/2){multp1_1_sign_y}},mult_y[MULT_IWIDTH-1:MULT_IWIDTH/2]};
    assign mult_p1[MULT_OWIDTH-1:MULT_OWIDTH/2] = multp1_1_Xi * multp1_1_Yi;

    assign Mc = (USE_SIMD == 1'b1) ? mult_p1 : mult_p0;

    wire [47:0] Mi; //registered (optional) mult internal output
    localparam MREG_WIDTH = 48;
    localparam MREG_DEPTH = 1;
    wire [MREG_WIDTH-1:0] mreg_d; 
    assign mreg_d = Mc;
    assign mreg_rsta = (ASYNC_RST == 1'b1) ? (RSTM | grs) : grs;
    assign mreg_rsts = (ASYNC_RST == 1'b1) ? 1'b0 : RSTM;

    reg [MREG_WIDTH-1:0] mreg_qarr[MREG_DEPTH:0];
    always @(*) begin
        // pragma translate_off
        if (MULT_REG < 0 || MULT_REG > MREG_DEPTH) begin
            $display("ERROR: GTP_APM_E1 instance %m parameter MULT_REG = %d is illegal. The legal value is 0,1.", MULT_REG);
            $finish;
        end
        // pragma translate_on
        mreg_qarr[0] = mreg_d ;
    end

    always @(posedge CLK or posedge mreg_rsta) begin
        for (j = 1; j <= MREG_DEPTH; j = j + 1) begin
            if (mreg_rsta == 1'b1) begin
                mreg_qarr[j] <= {MREG_WIDTH{1'b0}};
            end else if (mreg_rsts == 1'b1) begin
                mreg_qarr[j] <= {MREG_WIDTH{1'b0}};
            end else if (CEM == 1'b1) begin
                mreg_qarr[j] <= mreg_qarr[j - 1];
            end
        end
    end

    assign Mi = mreg_qarr[MULT_REG];

// post adder 
    reg  [47:0] Pai; // post adder input a before inverter
    wire [47:0] Pa = MODEi[6] ? ~Pai : Pai; // post adder input a after inverter
    reg  [47:0] Pbi; // post adder input b before inverter
    wire [47:0] Pb = MODEi[3] ? ~Pbi : Pbi; // post adder input b after inverter

    wire [47:0] Pc; // post adder combinational output
    wire [47:0] Pr; // post adder regstered feedback
    wire [47:0] Pri =  USE_ACCLOW ? { {30{1'b0}}, Pr[17:0] } : Pr; //post adder lower portion feedback

    always @ (*) begin
        case(MODEi[5])
            1'b0 : Pai = Mi;
            1'b1 : Pai = Pri & {48{MODEi[4]}};
        endcase
    end

    always @(*) begin
        case(MODEi[2:1])
            2'b00 : Pbi = Z_INIT;
            2'b01 : Pbi = Pri;
            2'b10 : Pbi = Zi;
            2'b11 : Pbi = MODEi[0] ? ($signed(CPI) >>> 18) : $signed(CPI); //both branch need $signed
        endcase
    end

    //
    // adder with SIMD feature
    //
    localparam ADD48_WIDTH = 48;
    wire add48_CO, add48_CI;
    wire [ADD48_WIDTH-1:0] add48_S;
    wire [ADD48_WIDTH/2-1:0] add48_A_hi, add48_A_lo;
    wire [ADD48_WIDTH/2-1:0] add48_B_hi, add48_B_lo;
    wire [ADD48_WIDTH/2-1:0] add48_S_hi, add48_S_lo;
    assign add48_CI = CIN_SEL ? CIN : (MODEi[6] | MODEi[3]);
    assign add48_A_hi = Pa[ADD48_WIDTH - 1 : ADD48_WIDTH/2];
    assign add48_B_hi = Pb[ADD48_WIDTH - 1 : ADD48_WIDTH/2];
    assign add48_A_lo = Pa[ADD48_WIDTH/2 - 1 : 0];
    assign add48_B_lo = Pb[ADD48_WIDTH/2 - 1 : 0];
    // 48-bit adder
    assign {add48_CO, add48_S} = Pa + Pb + add48_CI;
    // dual 24-bit adders with identical CI
    assign add48_S_hi = add48_A_hi + add48_B_hi + add48_CI;
    assign add48_S_lo = add48_A_lo + add48_B_lo + add48_CI;
    //
    assign Pc = (USE_SIMD == 1'b1) ? {add48_S_hi, add48_S_lo} : add48_S;

    wire [47:0] Pi;
    localparam PREG_WIDTH = 48;
    localparam PREG_DEPTH = 1;
    wire [PREG_WIDTH-1:0] preg_d; 
    assign preg_d = Pc;
    assign preg_rsta = (ASYNC_RST == 1'b1) ? (RSTP | grs) : grs;
    assign preg_rsts = (ASYNC_RST == 1'b1) ? 1'b0 : RSTP;

    reg [PREG_WIDTH-1:0] preg_qarr[PREG_DEPTH:0];
    always @(*) begin
        // pragma translate_off
        if (P_REG < 0 || P_REG > PREG_DEPTH) begin
            $display("ERROR: GTP_APM_E1 instance %m parameter P_REG = %d is illegal. The legal value is 0,1.", P_REG);
            $finish;
        end
        // pragma translate_on
        preg_qarr[0] = preg_d ;
    end

    always @(posedge CLK or posedge preg_rsta) begin
        for (j = 1; j <= PREG_DEPTH; j = j + 1) begin
            if (preg_rsta == 1'b1) begin
                preg_qarr[j] <= {PREG_WIDTH{1'b0}};
            end else if (preg_rsts == 1'b1) begin
                preg_qarr[j] <= {PREG_WIDTH{1'b0}};
            end else if (CEP == 1'b1) begin
                preg_qarr[j] <= preg_qarr[j - 1];
            end
        end
    end

    assign Pi = preg_qarr[P_REG];
    assign Pr = preg_qarr[1];

    assign P = USE_POSTADD ? Pi : Mi;
    assign CPO = USE_POSTADD? (CPO_REG ? Pr : Pc) : Mi;

    wire PCOr;
    localparam PCOREG_WIDTH = 1;
    localparam PCOREG_DEPTH = 1;
    wire [PCOREG_WIDTH-1:0] pcoreg_d; 
    assign pcoreg_d = add48_CO;
    assign pcoreg_rsta = (ASYNC_RST == 1'b1) ? (RSTP | grs) : grs;
    assign pcoreg_rsts = (ASYNC_RST == 1'b1) ? 1'b0 : RSTP;

    reg [PCOREG_WIDTH-1:0] pcoreg_qarr[PCOREG_DEPTH:0];
    always @(*) begin
        pcoreg_qarr[0] = pcoreg_d ;
    end

    always @(posedge CLK or posedge pcoreg_rsta) begin
        for (j = 1; j <= PCOREG_DEPTH; j = j + 1) begin
            if (pcoreg_rsta == 1'b1) begin
                pcoreg_qarr[j] <= {PCOREG_WIDTH{1'b0}};
            end else if (pcoreg_rsts == 1'b1) begin
                pcoreg_qarr[j] <= {PCOREG_WIDTH{1'b0}};
            end else if (CEP == 1'b1) begin
                pcoreg_qarr[j] <= pcoreg_qarr[j - 1];
            end
        end
    end

    assign PCOr = pcoreg_qarr[1];
    assign COUT = CPO_REG ? PCOr : add48_CO;

// DRC check
// pragma translate_off
    initial begin
        `assert(X_REG <= 1, "X_REG <= 1")
        `assert(XB_SEL != 3 || CXO_REG >=  X_REG, "X_REG <= CXO_REG in back-propogation mode")
        `assert(CXO_REG <= 3, "CXO_REG <= 3")
        `assert(Y_REG <= 1, "Y_REG <= 1")
        `assert(Z_REG <= 1, "Z_REG <= 1")
        `assert(MULT_REG <= 1, "MULT_REG <= 1")
        `assert(P_REG <= 1, "P_REG <= 1")
        `assert(PREADD_REG <= 1, "PREADD_REG <= 1")
        `assert(MODEX_REG <= 1, "MODEX_REG <= 1")
        `assert(MODEY_REG <= 1, "MODEY_REG <= 1")
        `assert(MODEZ_REG <= 1, "MODEZ_REG <= 1")
    end
// pragma translate_on

endmodule
