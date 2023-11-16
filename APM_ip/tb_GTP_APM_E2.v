`timescale  1ns / 1ps

module tb_GTP_APM_E2;

// flt_reciprocal Parameters
parameter PERIOD  = 10;


// flt_reciprocal Inputs
reg   clk                                  = 0 ;
reg   Rst                                = 0;

// flt_reciprocal Outputs
reg [24:0] X ;
reg [23:0] XB;
reg [16:0] Y;
wire [47:0] P;
initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    $fsdbDumpfile("fma_64.fsdb");
    $fsdbDumpvars;
    $fsdbDumpMDA;
end 
initial
begin
    #(PERIOD*4) Rst  =  0;
end

//newton  u_flt_reciprocal (
//    .clk                     ( clk              ),
//    .rst_n                   ( rst_n            ),
//    .i_X                     ( i_X  ),

//    .o_result                ( o_result         )
//);
GTP_APM_E2 #(
.GRS_EN ("TRUE"),
.USE_POSTADD (0), //²»Ê¹ÄÜÀÛ¼Ó¹¦ÄÜ
.USE_PREADD (1), //Ê¹ÄÜÔ¤¼Ó¹¦ÄÜ
.PREADD_REG (0), //²»Ê¹ÄÜÔ¤¼Ó¼Ä´æÆ÷
.X_REG (0),
.CXO_REG (0), // X¼¶ÁªÊä³ö¼Ä´æÆ÷ÑÓ³Ù, 0/1/2/3
.XB_REG (0),
.Y_REG (0),
.Z_REG (0),
.MULT_REG (0), //Ê¹ÓÃMULT_REG
.P_REG (0), //²»Ê¹ÄÜÀÛ¼Ó¼Ä´æÆ÷
.MODEY_REG (0),
.MODEZ_REG (0),
.MODEIN_REG (0),
.X_SEL (0),
.XB_SEL (0),
.ASYNC_RST (0),
.USE_SIMD (0),
.P_INIT0 (48'd0),
.P_INIT1 (48'd0),
.ROUNDMODE_SEL (0),
.CPO_REG (0), // PO,CPO²»Ê¹ÄÜ¼Ä´æÆ÷
.USE_ACCLOW (0), // ÀÛ¼Ó½öÊ¹ÓÃµÍ17bit×÷Îª·´À¡²»Ê¹ÄÜ
.CIN_SEL (0) // ²»Ñ¡ÔñCPI×÷ÎªÀÛ¼ÓµÄÊäÈë
)
u0_GTP_APM_E2
(
.P(P),
.CPO(),
.COUT(),
.CXO(),
.CXBO(),
.X(X),
.CXI(),
.CXBI	(),
.Y(Y),
.Z(),
.CPI(),
.CIN(),
.XB (XB),
.MODEIN(5'b01110),
.MODEY(3'b000),
.MODEZ(4'b0000),
.CLK(clk),
.RSTX(Rst),
.RSTXB(Rst),
.RSTY(Rst),
.RSTZ(Rst),
.RSTM(Rst),
.RSTP(Rst),
.RSTPRE(Rst),
.RSTMODEIN(Rst),
.RSTMODEY(Rst),
.RSTMODEZ(Rst),
.CEX1(1'b0),
.CEX2(1'b0),
.CEX3(1'b0),
.CEXB(1'b0),
.CEY1(1'b0),
.CEY2(1'b0),
.CEZ(1'b0),
.CEM(1'b1),
.CEP(1'b0),
.CEPRE(1'b0),
.CEMODEIN(1'b0),
.CEMODEY(1'b0),
.CEMODEZ(1'b0)
);
initial
begin
    #40 
    X = {{(1){1'b0}},{(1){1'b1}},{23{1'b0}}};
     XB = 24'h41_070d;
   // XB = {2'd0,1'd1,21'd0};
    Y = 17'h99d;
    #1000
    $finish;
end

endmodule
