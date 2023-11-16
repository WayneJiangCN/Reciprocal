	module reci
	#
	(
	    parameter FLT_WIDTH = 23
	)
	(
	    input clk,
	    input rst_n,
	    input [FLT_WIDTH-1:0] i_X,
	    output [FLT_WIDTH-1:0] o_result
	);

	parameter ADDR_TOTAL = 8;
	parameter ADDR_WIDTH = 3;
	parameter OUTPUT_BIT_WIDTH = 6;

	wire[ADDR_WIDTH-1:0] rd_addr;
	wire [ADDR_WIDTH+ADDR_WIDTH-1:0]Cout;
	assign rd_addr = i_X[FLT_WIDTH-1: FLT_WIDTH-ADDR_WIDTH];
	n_rom 
	#(
	    .ADDR_TOTAL       (ADDR_TOTAL       ),
	    .ADDR_WIDTH       (ADDR_WIDTH       ),    
	    .OUTPUT_BIT_WIDTH (OUTPUT_BIT_WIDTH  )
	)
	u_rom(
	    .rd_en   (1   ),
	    .rd_addr (rd_addr ),
	    .dout    (Cout)
	);

	wire [ADDR_WIDTH*2:0] X_d = {1'b1,i_X[FLT_WIDTH-1: FLT_WIDTH-ADDR_WIDTH],~i_X[FLT_WIDTH-1-ADDR_WIDTH: FLT_WIDTH-ADDR_WIDTH*2]} ;
	wire [ADDR_WIDTH*4:0] X_simlar /*synthesis syn_dspstyle = "logic" */;
	assign X_simlar = Cout * X_d; 



	wire [FLT_WIDTH:0] i_X_zero = {1'b1, i_X};


	wire [FLT_WIDTH+ADDR_WIDTH*4:0] i_X_fir_re = i_X_zero * X_simlar;
	wire [FLT_WIDTH-1:0] i_X_fir_rre = i_X_fir_re[FLT_WIDTH+ADDR_WIDTH*4:ADDR_WIDTH*4+1];
	wire [FLT_WIDTH+ADDR_WIDTH*4-1:0] i_X_fir_rrre;
	//wire [23:0] X= {1'b1,23'd0};
	wire Rst = 1'd0;
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
	.P(i_X_fir_rrre),
	.CPO(),
	.COUT(),
	.CXO(),
	.CXBO(),
	.X({1'b1,23'd0}),
	.CXI(),
	.CXBI    (),
	.Y(X_simlar),
	.Z(),
	.CPI(),
	.CIN(),
	.XB (i_X_fir_rre),
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



	//wire[FLT_WIDTH:0] i_X_fir_rre = i_X_fir_re[ADDR_WIDTH*4-1]?i_X_fir_re_q+1'd1:i_X_fir_re_q;
	//wire [FLT_WIDTH-1:0] com_re_fir_q = {1'b1,23'd0}-i_X_fir_rre;
	//wire [FLT_WIDTH:0] com_re_fir = {com_re_fir_q,1'd0};
	//(* use_dsp48 = "yes" *)wire [FLT_WIDTH+ADDR_WIDTH*4:0] i_X_fir_rrre = com_re_fir_q * X_simlar; // Fill the i_X with 1] 
	wire [FLT_WIDTH:0] i_X_fir = i_X_fir_rrre[FLT_WIDTH+ADDR_WIDTH*4-1:ADDR_WIDTH*4-1]; 

	//wire[FLT_WIDTH:0] i_X_fir = i_X_fir_rrre[ADDR_WIDTH*4-1]?i_X_fir_q+1'd1:i_X_fir_q;

	// Save for flip flop
	wire [FLT_WIDTH:0]i_X_fir_ff;

	assign i_X_fir_ff = i_X_fir;

	// Secondry calculate


	wire [FLT_WIDTH+ADDR_WIDTH*4:0] i_X_sec_re = i_X_fir_ff[FLT_WIDTH:FLT_WIDTH-ADDR_WIDTH*4] * i_X_zero;
	wire [FLT_WIDTH-1:0] i_X_sec_rre = i_X_sec_re[FLT_WIDTH+ADDR_WIDTH*4:ADDR_WIDTH*4+1];
	//wire[FLT_WIDTH:0] i_X_sec_rre = i_X_sec_re[ADDR_WIDTH*4-1]?i_X_sec_rre_q+1'd1:i_X_sec_rre_q;
	wire [FLT_WIDTH+ADDR_WIDTH*4-1:0] i_X_sec_rrre;
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
	.MULT_REG (0), //Ê¹ÓÃMULT_REG gaidong 
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
	u1_GTP_APM_E2
	(
	.P(i_X_sec_rrre),
	.CPO(),
	.COUT(),
	.CXO(),
	.CXBO(),
	.X({1'b1,23'd0}),
	.CXI(),
	.CXBI    (),
	.Y(i_X_fir_ff[FLT_WIDTH:FLT_WIDTH-ADDR_WIDTH*4]),
	.Z(),
	.CPI(),
	.CIN(),
	.XB (i_X_sec_rre),
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


	//wire [FLT_WIDTH-1:0] com_re_sec_q = {1'b1,23'd0}-i_X_sec_rre;
	//wire [FLT_WIDTH:0] com_re_sec = {com_re_sec_q,1'd0};




	//wire [FLT_WIDTH+ADDR_WIDTH*4:0] i_X_sec_rrre = com_re_sec * i_X_fir_ff[FLT_WIDTH:FLT_WIDTH-ADDR_WIDTH*4]; // Fill the i_X with 1] 
	wire [FLT_WIDTH:0] i_X_sec = i_X_sec_rrre[FLT_WIDTH+ADDR_WIDTH*4-1:ADDR_WIDTH*4-1]; 
	//wire[FLT_WIDTH:0] i_X_sec = i_X_sec_rrre[ADDR_WIDTH*4-1]?i_X_sec_q+1'd1:i_X_sec_q;
	// Save for flip flop
	wire [FLT_WIDTH:0]i_X_sec_ff;

	assign i_X_sec_ff = i_X_sec;

	// Third calculate
	wire [FLT_WIDTH+FLT_WIDTH:0] i_X_third_re = i_X_sec_ff * i_X_zero;
	wire [FLT_WIDTH+2:0] i_X_third_rre = i_X_third_re[FLT_WIDTH+FLT_WIDTH:FLT_WIDTH-2];
	//wire[FLT_WIDTH+4:0] i_X_third_rre = i_X_third_re[FLT_WIDTH-1+4]?i_X_third_rre_q+1'd1:i_X_third_rre_q;
	wire [FLT_WIDTH+2:0] com_re_third = ~i_X_third_rre[FLT_WIDTH+2:0] + 1'b1;
	wire [FLT_WIDTH+FLT_WIDTH+2:0] i_X_third_rrre = com_re_third * i_X_sec_ff; // Fill the i_X with 1] 
	//wire [FLT_WIDTH:0] i_X_third_q = i_X_third_rrre[FLT_WIDTH+FLT_WIDTH-1+2:FLT_WIDTH-1+2]; 
	//wire[FLT_WIDTH:0] i_X_third = i_X_third_rrre[FLT_WIDTH-2+2]?i_X_third_q+1'd1:i_X_third_q;
	wire[FLT_WIDTH:0] i_X_third = i_X_third_rrre[FLT_WIDTH+FLT_WIDTH-1+2:FLT_WIDTH-1+2];
	assign o_result = (|i_X) ? i_X_third[FLT_WIDTH-1 :0] : 23'b0;
        //assign o_result =i_X_third[FLT_WIDTH-1 :0] ;
	endmodule
