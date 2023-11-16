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
// Filename:ipsxe_floating_point_log_32_axi_v1_0.v
// Function: p=ln(z)
//           zsize:z > 0
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_log_32_axi_v1_0
 #(
    parameter FLOAT_EXP_WIDTH = 8,
    parameter FLOAT_FRAC_WIDTH = 24,
    parameter FLOAT_FRAC_WIDTH_CUT = 12,
    parameter ITERATION_NUM = 10
)
(
    input i_clk, //aclk
    input i_aclken,
    input i_rst_n, //aresetn
    input [FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1:0] i_data, //s_axis_a_tdata
    input i_valid, //s_axis_a_tvalid
    output [FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1:0] o_ln_float, //m_axis_result_tdata
    output o_invalid_op,
    output o_overflow, 
    output o_underflow,
    output o_valid //m_axis_result_tvalid
)/* synthesis syn_allowed_resources = "blockrams=0" */;

localparam TAYLOR_DELAY = 5;
//look up table 
(*rom_style = "distributed" *)reg [26:0] f1;
reg [6:0] rom_index;

always @* begin
    case(rom_index)
        7'd0: f1 <= 27'd67108864;
        7'd1: f1 <= 26'd66584576;
        7'd2: f1 <= 26'd66060288;
        7'd3: f1 <= 26'd65536000;
        7'd4: f1 <= 26'd65011712;
        7'd5: f1 <= 26'd64487424;
        7'd6: f1 <= 26'd63963136;
        7'd7: f1 <= 26'd63438848;
        7'd8: f1 <= 26'd62914560;
        7'd9: f1 <= 26'd62914560;
        7'd10: f1 <= 26'd62390272;
        7'd11: f1 <= 26'd61865984;
        7'd12: f1 <= 26'd61341696;
        7'd13: f1 <= 26'd60817408;
        7'd14: f1 <= 26'd60293120;
        7'd15: f1 <= 26'd60293120;
        7'd16: f1 <= 26'd59768832;
        7'd17: f1 <= 26'd59244544;
        7'd18: f1 <= 26'd58720256;
        7'd19: f1 <= 26'd58195968;
        7'd20: f1 <= 26'd58195968;
        7'd21: f1 <= 26'd57671680;
        7'd22: f1 <= 26'd57147392;
        7'd23: f1 <= 26'd57147392;
        7'd24: f1 <= 26'd56623104;
        7'd25: f1 <= 26'd56098816;
        7'd26: f1 <= 26'd55574528;
        7'd27: f1 <= 26'd55574528;
        7'd28: f1 <= 26'd55050240;
        7'd29: f1 <= 26'd54525952;
        7'd30: f1 <= 26'd54525952;
        7'd31: f1 <= 26'd54001664;
        7'd32: f1 <= 26'd53477376;
        7'd33: f1 <= 26'd53477376;
        7'd34: f1 <= 26'd52953088;
        7'd35: f1 <= 26'd52953088;
        7'd36: f1 <= 26'd52428800;
        7'd37: f1 <= 26'd51904512;
        7'd38: f1 <= 26'd51904512;
        7'd39: f1 <= 26'd51380224;
        7'd40: f1 <= 26'd51380224;
        7'd41: f1 <= 26'd50855936;
        7'd42: f1 <= 26'd50331648;
        7'd43: f1 <= 26'd50331648;
        7'd44: f1 <= 26'd49807360;
        7'd45: f1 <= 26'd49807360;
        7'd46: f1 <= 26'd49283072;
        7'd47: f1 <= 26'd49283072;
        7'd48: f1 <= 26'd48758784;
        7'd49: f1 <= 26'd48758784;
        7'd50: f1 <= 26'd48234496;
        7'd51: f1 <= 26'd48234496;
        7'd52: f1 <= 26'd47710208;
        7'd53: f1 <= 26'd47710208;
        7'd54: f1 <= 26'd47185920;
        7'd55: f1 <= 26'd47185920;
        7'd56: f1 <= 26'd46661632;
        7'd57: f1 <= 26'd46661632;
        7'd58: f1 <= 26'd46137344;
        7'd59: f1 <= 26'd46137344;
        7'd60: f1 <= 26'd45613056;
        7'd61: f1 <= 26'd45613056;
        7'd62: f1 <= 26'd45088768;
        7'd63: f1 <= 26'd45088768;
        7'd64: f1 <= 26'd44564480;
        7'd65: f1 <= 26'd44564480;
        7'd66: f1 <= 26'd44040192;
        7'd67: f1 <= 26'd44040192;
        7'd68: f1 <= 26'd44040192;
        7'd69: f1 <= 26'd43515904;
        7'd70: f1 <= 26'd43515904;
        7'd71: f1 <= 26'd42991616;
        7'd72: f1 <= 26'd42991616;
        7'd73: f1 <= 26'd42991616;
        7'd74: f1 <= 26'd42467328;
        7'd75: f1 <= 26'd42467328;
        7'd76: f1 <= 26'd41943040;
        7'd77: f1 <= 26'd41943040;
        7'd78: f1 <= 26'd41943040;
        7'd79: f1 <= 26'd41418752;
        7'd80: f1 <= 26'd41418752;
        7'd81: f1 <= 26'd40894464;
        7'd82: f1 <= 26'd40894464;
        7'd83: f1 <= 26'd40894464;
        7'd84: f1 <= 26'd40370176;
        7'd85: f1 <= 26'd40370176;
        7'd86: f1 <= 26'd40370176;
        7'd87: f1 <= 26'd39845888;
        7'd88: f1 <= 26'd39845888;
        7'd89: f1 <= 26'd39845888;
        7'd90: f1 <= 26'd39321600;
        7'd91: f1 <= 26'd39321600;
        7'd92: f1 <= 26'd38797312;
        7'd93: f1 <= 26'd38797312;
        7'd94: f1 <= 26'd38797312;
        7'd95: f1 <= 26'd38273024;
        7'd96: f1 <= 26'd38273024;
        7'd97: f1 <= 26'd38273024;
        7'd98: f1 <= 26'd37748736;
        7'd99: f1 <= 26'd37748736;
        7'd100: f1 <= 26'd37748736;
        7'd101: f1 <= 26'd37748736;
        7'd102: f1 <= 26'd37224448;
        7'd103: f1 <= 26'd37224448;
        7'd104: f1 <= 26'd37224448;
        7'd105: f1 <= 26'd36700160;
        7'd106: f1 <= 26'd36700160;
        7'd107: f1 <= 26'd36700160;
        7'd108: f1 <= 26'd36175872;
        7'd109: f1 <= 26'd36175872;
        7'd110: f1 <= 26'd36175872;
        7'd111: f1 <= 26'd36175872;
        7'd112: f1 <= 26'd35651584;
        7'd113: f1 <= 26'd35651584;
        7'd114: f1 <= 26'd35651584;
        7'd115: f1 <= 26'd35127296;
        7'd116: f1 <= 26'd35127296;
        7'd117: f1 <= 26'd35127296;
        7'd118: f1 <= 26'd35127296;
        7'd119: f1 <= 26'd34603008;
        7'd120: f1 <= 26'd34603008;
        7'd121: f1 <= 26'd34603008;
        7'd122: f1 <= 26'd34603008;
        7'd123: f1 <= 26'd34078720;
        7'd124: f1 <= 26'd34078720;
        7'd125: f1 <= 26'd34078720;
        7'd126: f1 <= 26'd34078720;
        7'd127: f1 <= 26'd33554432;
    endcase
end
reg [6:0] rom_index_buffer [TAYLOR_DELAY-1:0];
(*rom_style = "distributed" *)reg [25:0] f1_ln;
always @* begin
    case(rom_index_buffer[TAYLOR_DELAY-1])
        7'd0: f1_ln <= 26'd0;
        7'd1: f1_ln <= 26'd526347;
        7'd2: f1_ln <= 26'd1056854;
        7'd3: f1_ln <= 26'd1591589;
        7'd4: f1_ln <= 26'd2130619;
        7'd5: f1_ln <= 26'd2674014;
        7'd6: f1_ln <= 26'd3221844;
        7'd7: f1_ln <= 26'd3774184;
        7'd8: f1_ln <= 26'd4331107;
        7'd9: f1_ln <= 26'd4331107;
        7'd10: f1_ln <= 26'd4892691;
        7'd11: f1_ln <= 26'd5459013;
        7'd12: f1_ln <= 26'd6030156;
        7'd13: f1_ln <= 26'd6606201;
        7'd14: f1_ln <= 26'd7187234;
        7'd15: f1_ln <= 26'd7187234;
        7'd16: f1_ln <= 26'd7773342;
        7'd17: f1_ln <= 26'd8364613;
        7'd18: f1_ln <= 26'd8961140;
        7'd19: f1_ln <= 26'd9563017;
        7'd20: f1_ln <= 26'd9563017;
        7'd21: f1_ln <= 26'd10170342;
        7'd22: f1_ln <= 26'd10783212;
        7'd23: f1_ln <= 26'd10783212;
        7'd24: f1_ln <= 26'd11401731;
        7'd25: f1_ln <= 26'd12026004;
        7'd26: f1_ln <= 26'd12656139;
        7'd27: f1_ln <= 26'd12656139;
        7'd28: f1_ln <= 26'd13292247;
        7'd29: f1_ln <= 26'd13934442;
        7'd30: f1_ln <= 26'd13934442;
        7'd31: f1_ln <= 26'd14582842;
        7'd32: f1_ln <= 26'd15237568;
        7'd33: f1_ln <= 26'd15237568;
        7'd34: f1_ln <= 26'd15898744;
        7'd35: f1_ln <= 26'd15898744;
        7'd36: f1_ln <= 26'd16566499;
        7'd37: f1_ln <= 26'd17240966;
        7'd38: f1_ln <= 26'd17240966;
        7'd39: f1_ln <= 26'd17922280;
        7'd40: f1_ln <= 26'd17922280;
        7'd41: f1_ln <= 26'd18610582;
        7'd42: f1_ln <= 26'd19306017;
        7'd43: f1_ln <= 26'd19306017;
        7'd44: f1_ln <= 26'd20008734;
        7'd45: f1_ln <= 26'd20008734;
        7'd46: f1_ln <= 26'd20718887;
        7'd47: f1_ln <= 26'd20718887;
        7'd48: f1_ln <= 26'd21436636;
        7'd49: f1_ln <= 26'd21436636;
        7'd50: f1_ln <= 26'd22162144;
        7'd51: f1_ln <= 26'd22162144;
        7'd52: f1_ln <= 26'd22895582;
        7'd53: f1_ln <= 26'd22895582;
        7'd54: f1_ln <= 26'd23637124;
        7'd55: f1_ln <= 26'd23637124;
        7'd56: f1_ln <= 26'd24386951;
        7'd57: f1_ln <= 26'd24386951;
        7'd58: f1_ln <= 26'd25145252;
        7'd59: f1_ln <= 26'd25145252;
        7'd60: f1_ln <= 26'd25912219;
        7'd61: f1_ln <= 26'd25912219;
        7'd62: f1_ln <= 26'd26688052;
        7'd63: f1_ln <= 26'd26688052;
        7'd64: f1_ln <= 26'd27472960;
        7'd65: f1_ln <= 26'd27472960;
        7'd66: f1_ln <= 26'd28267157;
        7'd67: f1_ln <= 26'd28267157;
        7'd68: f1_ln <= 26'd28267157;
        7'd69: f1_ln <= 26'd29070866;
        7'd70: f1_ln <= 26'd29070866;
        7'd71: f1_ln <= 26'd29884316;
        7'd72: f1_ln <= 26'd29884316;
        7'd73: f1_ln <= 26'd29884316;
        7'd74: f1_ln <= 26'd30707748;
        7'd75: f1_ln <= 26'd30707748;
        7'd76: f1_ln <= 26'd31541410;
        7'd77: f1_ln <= 26'd31541410;
        7'd78: f1_ln <= 26'd31541410;
        7'd79: f1_ln <= 26'd32385557;
        7'd80: f1_ln <= 26'd32385557;
        7'd81: f1_ln <= 26'd33240459;
        7'd82: f1_ln <= 26'd33240459;
        7'd83: f1_ln <= 26'd33240459;
        7'd84: f1_ln <= 26'd34106392;
        7'd85: f1_ln <= 26'd34106392;
        7'd86: f1_ln <= 26'd34106392;
        7'd87: f1_ln <= 26'd34983644;
        7'd88: f1_ln <= 26'd34983644;
        7'd89: f1_ln <= 26'd34983644;
        7'd90: f1_ln <= 26'd35872516;
        7'd91: f1_ln <= 26'd35872516;
        7'd92: f1_ln <= 26'd36773320;
        7'd93: f1_ln <= 26'd36773320;
        7'd94: f1_ln <= 26'd36773320;
        7'd95: f1_ln <= 26'd37686380;
        7'd96: f1_ln <= 26'd37686380;
        7'd97: f1_ln <= 26'd37686380;
        7'd98: f1_ln <= 26'd38612034;
        7'd99: f1_ln <= 26'd38612034;
        7'd100: f1_ln <= 26'd38612034;
        7'd101: f1_ln <= 26'd38612034;
        7'd102: f1_ln <= 26'd39550635;
        7'd103: f1_ln <= 26'd39550635;
        7'd104: f1_ln <= 26'd39550635;
        7'd105: f1_ln <= 26'd40502550;
        7'd106: f1_ln <= 26'd40502550;
        7'd107: f1_ln <= 26'd40502550;
        7'd108: f1_ln <= 26'd41468162;
        7'd109: f1_ln <= 26'd41468162;
        7'd110: f1_ln <= 26'd41468162;
        7'd111: f1_ln <= 26'd41468162;
        7'd112: f1_ln <= 26'd42447870;
        7'd113: f1_ln <= 26'd42447870;
        7'd114: f1_ln <= 26'd42447870;
        7'd115: f1_ln <= 26'd43442094;
        7'd116: f1_ln <= 26'd43442094;
        7'd117: f1_ln <= 26'd43442094;
        7'd118: f1_ln <= 26'd43442094;
        7'd119: f1_ln <= 26'd44451269;
        7'd120: f1_ln <= 26'd44451269;
	    7'd121: f1_ln <= 26'd44451269;
        7'd122: f1_ln <= 26'd44451269;
        7'd123: f1_ln <= 26'd45475852;
        7'd124: f1_ln <= 26'd45475852;
        7'd125: f1_ln <= 26'd45475852;
        7'd126: f1_ln <= 26'd45475852;
        7'd127: f1_ln <= 26'd46516320;
    endcase
end

(*use_dsp48 = "yes"*)wire [7:0] shift;
(*use_dsp48 = "yes"*)wire shift_pn;

//wire [26:0] f1;
//wire [25:0] f1_ln;
//wire [6:0] rom_index;

reg [7:0] shift_buffer [TAYLOR_DELAY-1:0];
reg shift_pn_buffer [TAYLOR_DELAY:0];
//reg signed [26:0] f1_ln_buffer [TAYLOR_DELAY-1:0];
//reg [6:0] rom_index_buffer [TAYLOR_DELAY-1:0];

(*use_dsp48 = "yes"*)wire [23:0] x0;
(*use_dsp48 = "yes"*)wire [24+27-1:0] x1_full;
(*use_dsp48 = "yes"*)wire [26:0] x1;

//wire [22:0] ln;
(*use_dsp48 = "yes"*)wire signed [20:0] a;
(*use_dsp48 = "yes"*)wire [19:0] a_abs;

//layer0
(*use_dsp48 = "yes"*)wire signed [20+20:0] layer0_value0_full; //a^2
//(*use_dsp48 = "yes"*)wire [20+20-1:0] layer0_value0_full; //a^2
(*use_dsp48 = "yes"*)reg signed [14:0] layer0_value0; 
(*use_dsp48 = "yes"*)reg signed [19:0] layer0_value1; // a/3
//(*use_dsp48 = "yes"*)wire [18:0] layer0_value1_abs;
(*use_dsp48 = "yes"*)wire [41:0] layer0_value1_abs;
(*use_dsp48 = "yes"*)wire [18:0] layer0_value1_fix;
(*use_dsp48 = "yes"*)reg signed [20:0] a_buffer_0;
reg signed [20:0] a_buffer_1;

//layer1
(*use_dsp48 = "yes"*)reg signed [20:0] layer1_value0; //a-(a^2)/2
(*use_dsp48 = "yes"*)wire signed [14+19:0] layer1_value1_full; // (a^3)/3
(*use_dsp48 = "yes"*)reg signed [7:0] layer1_value1;

(*use_dsp48 = "yes"*)wire in_NaN;
(*use_dsp48 = "yes"*)wire in_INF;
(*use_dsp48 = "yes"*)wire invalid_op;
(*use_dsp48 = "yes"*)wire in_ZERO;
//wire in_ONE;
(*use_dsp48 = "yes"*)wire overflow;
(*use_dsp48 = "yes"*)wire underflow;

reg invalid_op_buffer[ITERATION_NUM-1:0];
reg overflow_buffer[ITERATION_NUM-1:0];
reg underflow_buffer[ITERATION_NUM-1:0];
reg in_valid_buffer[ITERATION_NUM-1:0];

(*use_dsp48 = "yes"*)wire [34:0] ln;
(*use_dsp48 = "yes"*)reg [34:0] ln_buffer;
(*use_dsp48 = "yes"*)wire signed [27:0] ln_0;
(*use_dsp48 = "yes"*)reg signed [27:0] ln_0_buffer;
(*use_dsp48 = "yes"*)wire [28:0] ln2_value;
(*use_dsp48 = "yes"*)reg [28:0] ln2_value_buffer;

(*use_dsp48 = "yes"*)wire    [5:0]   index;
(*use_dsp48 = "yes"*)reg [5:0] index_buffer_0;
reg [5:0] index_buffer_1;
(*use_dsp48 = "yes"*)wire    [31:0]   tmp4;
(*use_dsp48 = "yes"*)wire    [15:0]   tmp3;
(*use_dsp48 = "yes"*)wire    [7:0]   tmp0;
(*use_dsp48 = "yes"*)wire    [3:0]   tmp1;
(*use_dsp48 = "yes"*)wire    [1:0]   tmp2;
(*use_dsp48 = "yes"*)wire [63:0] ln_value;
(*use_dsp48 = "yes"*)reg [63:0] ln_value_buffer_0;
(*use_dsp48 = "yes"*)reg [63:0] ln_value_buffer_1;
reg ln_sign0;
reg ln_sign1;
reg ln_sign2;

(*use_dsp48 = "yes"*)wire [FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1:0] ln_float0;

(*use_dsp48 = "yes"*)wire [63:0] ln_value_shift;
(*use_dsp48 = "yes"*)reg [63:0] ln_value_shift_buffer;

assign shift_pn = i_data[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] >= 8'd127 ? 0 : 1; 
assign shift = i_data[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] >= 8'd127 ? i_data[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] - 127 : 127 - i_data[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1];

(*use_dsp48 = "yes"*)wire [6:0] rom_index_wire;
always @* begin
    rom_index <= rom_index_wire;
end
assign rom_index_wire = i_data[FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-8] == 7'd127 ? 7'd127 :
                   i_data[FLOAT_FRAC_WIDTH-9] ? i_data[FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-8]+1 : i_data[FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-8];
//assign f1 = f1_rom[rom_index];
//assign f1_ln = f1_ln_rom[rom_index];
(*use_dsp48 = "yes"*)reg [26:0] f1_buffer;
(*use_dsp48 = "yes"*)reg [23:0] x0_buffer;
(*use_dsp48 = "yes"*)reg [26:0] x1_buffer;
assign x0 = {1'b1,i_data[FLOAT_FRAC_WIDTH-2:0]}; //delay 1
assign x1_full = (x0_buffer * f1_buffer) >>> 23; //delay 2
assign x1 = x1_full[26:0];

(*use_dsp48 = "yes"*)reg [19:0] a_abs_buffer;
assign a = x1_buffer - (1 <<< 26);
//assign a_abs = x1[26] == 1 ? x1 - (1 <<< 26) : (1 <<< 26) - x1;
assign a_abs = a[20] == 1 ? -(a[19:0]) : a[19:0]; //delay 3
//assign layer0_value1_abs = a_abs / 2'd3;
assign layer0_value1_abs = (a_abs_buffer * 1398101) >> 22; //delay 4
assign layer0_value1_fix = a_buffer_0[20] == 1 ? -(layer0_value1_abs[18:0]) : layer0_value1_abs[18:0];
//assign layer0_value1_abs = a_abs / 2'd3;
//assign layer0_value1_fix = x1[26] == 1 ?  layer0_value1_abs : -(layer0_value1_abs);

assign layer0_value0_full = a_buffer_0 * a_buffer_0;

assign layer1_value1_full = layer0_value0 * layer0_value1; //delay 5

integer i0;
integer i1;
integer i2;
always @ ( posedge i_clk or negedge i_rst_n )
    if( !i_rst_n )
    begin
    for (i0 = 0; i0 < TAYLOR_DELAY; i0 = i0+1) begin
      shift_buffer[i0] <= 0;
      shift_pn_buffer[i0] <= 0;
      //f1_ln_buffer[i0] <= 0;
      rom_index_buffer[i0] <= 0;
    end
    shift_pn_buffer[TAYLOR_DELAY] <= 0;
    
    layer0_value0 <= 0;
    layer0_value1 <= 0;
    layer1_value0 <= 0;
    layer1_value1 <= 0;
    a_buffer_0 <= 0;
    a_buffer_1 <= 0;
    f1_buffer <= 0;
    x0_buffer <= 0;
    x1_buffer <= 0;
    a_abs_buffer <= 0;
    ln_0_buffer <= 0;
    ln2_value_buffer <= 0;
    ln_buffer <= 0;
    ln_value_buffer_0 <= 0;
    ln_value_buffer_1 <= 0;
    ln_sign0 <= 0;
    ln_sign1 <= 0;
    ln_sign2 <= 0;
    index_buffer_0 <= 0;
    index_buffer_1 <= 0;
    ln_value_shift_buffer <= 0;

    end
    else if( i_aclken ) begin
        shift_buffer[0] <= shift;
        shift_pn_buffer[0] <= shift_pn;
        //f1_ln_buffer[0] <= f1_ln;
        rom_index_buffer[0] <= rom_index;

        layer0_value0 <= layer0_value0_full[40:26];
        layer0_value1[19] <= a_buffer_0[20];
        layer0_value1[18:0] <= layer0_value1_fix;
        a_buffer_0 <= a;
        a_buffer_1 <= a_buffer_0;
        f1_buffer <= f1;
        x0_buffer <= x0;
        x1_buffer <= x1;
        a_abs_buffer <= a_abs;
        layer1_value0 <= a_buffer_1 - (layer0_value0 >>> 1);
        layer1_value1 <= layer1_value1_full[33:26];
        ln_0_buffer <= ln_0;
        ln2_value_buffer <= ln2_value;
        ln_buffer <= ln;
        ln_value_buffer_0 <= ln_value;
        ln_value_buffer_1 <= ln_value_buffer_0;
        ln_sign0 <= ln_buffer[34];
        ln_sign1 <= ln_sign0;
        ln_sign2 <= ln_sign1;
        index_buffer_0 <= index;
        index_buffer_1 <= index_buffer_0;
        ln_value_shift_buffer <= ln_value_shift;
    
        for (i2 = 1; i2 < TAYLOR_DELAY; i2 = i2+1) begin
            shift_buffer[i2] <= shift_buffer[i2-1];
            shift_pn_buffer[i2] <= shift_pn_buffer[i2-1];
            //f1_ln_buffer[i2] <= f1_ln_buffer[i2-1];
            rom_index_buffer[i2] <= rom_index_buffer[i2-1];
        end
        shift_pn_buffer[TAYLOR_DELAY] <= shift_pn_buffer[TAYLOR_DELAY-1];
    end
    else begin
        layer0_value0 <= layer0_value0;
        layer0_value1 <= layer0_value1;
        a_buffer_0 <= a_buffer_0;
        a_buffer_1 <= a_buffer_1;
        f1_buffer <= f1_buffer;
        x0_buffer <= x0_buffer;
        x1_buffer <= x1_buffer;
        a_abs_buffer <= a_abs_buffer;
        layer1_value0 <= layer1_value0;
        layer1_value1 <= layer1_value1;
        ln_0_buffer <= ln_0_buffer;
        ln2_value_buffer <= ln2_value_buffer;
        ln_buffer <= ln_buffer;
        ln_value_buffer_0 <= ln_value_buffer_0;
        ln_value_buffer_1 <= ln_value_buffer_1;
        ln_sign0 <= ln_sign0;
        ln_sign1 <= ln_sign1;
        ln_sign2 <= ln_sign2;
        index_buffer_0 <= index_buffer_0;
        index_buffer_1 <= index_buffer_1;
        ln_value_shift_buffer <= ln_value_shift_buffer;

        for (i1 = 0; i1 < TAYLOR_DELAY; i1 = i1+1) begin
            shift_buffer[i1] <= shift_buffer[i1];
            shift_pn_buffer[i1] <= shift_pn_buffer[i1];
            //f1_ln_buffer[i1] <= f1_ln_buffer[i1];
            rom_index_buffer[i1] <= rom_index_buffer[i1];
        end
        shift_pn_buffer[TAYLOR_DELAY] <= shift_pn_buffer[TAYLOR_DELAY];
    end

wire signed [26:0] f1_ln_sign;
assign f1_ln_sign = f1_ln;
assign o_valid = in_valid_buffer[ITERATION_NUM-1];
assign ln_0 = layer1_value0 + layer1_value1 + f1_ln_sign;
assign ln2_value = shift_buffer[TAYLOR_DELAY-1]*1453635;
//assign ln = shift_pn_buffer[ITERATION_NUM-1] == 0 ? ln_0 + (ln2_value <<< 5) : ln_0 - (ln2_value <<< 5);
assign ln = shift_pn_buffer[TAYLOR_DELAY] == 0 ? ln_0_buffer + {ln2_value_buffer,5'b0} : ln_0_buffer - {ln2_value_buffer,5'b0};
 
assign ln_value = !i_rst_n ? 64'hffff_ffff_ffff_ffff :
                    ln_buffer[34] ? {29'b0,-(ln_buffer)} : {29'b0,ln_buffer};
 
//find the leading one 
assign index[5] = (|ln_value_buffer_0[63:32]);
assign tmp4 = index[5] ? ln_value_buffer_0[63:32] : ln_value_buffer_0[31:0];

assign index[4] = (|tmp4[31:16]);
assign tmp3 = index[4] ? tmp4[31:16] : tmp4[15:0];

assign index[3] = (|tmp3[15:8]);
assign tmp0 = index[3] ? tmp3[15:8] : tmp3[7:0];

assign index[2] = (|tmp0[7:4]);
assign tmp1 = index[2] ? tmp0[7:4] : tmp0[3:0];

assign index[1] = (|tmp1[3:2]);
assign tmp2 = index[1] ? tmp1[3:2] : tmp1[1:0];

assign index[0] = tmp2[1];

//calculate the sign bit of float result
assign ln_float0[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1] = !i_rst_n ? 1'b1 : ln_sign2;
//calculate the exponential bits of float result
assign ln_float0[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] = !i_rst_n ? 8'hff : 8'd101 + index_buffer_1; //101 = 127 - 26
//calculate the mantissa bits of float result
assign ln_value_shift = !i_rst_n ? 64'hffff_ffff_ffff_ffff : ln_value_buffer_1 << (64 - index_buffer_0);
assign ln_float0[FLOAT_FRAC_WIDTH-2:0] = !i_rst_n ? 23'b11111111111111111111111 : ln_value_shift_buffer[63:41];

//adjust the output accorroding to the value of input 
assign o_ln_float = o_overflow ? 32'h7F80_0000 :
                    o_underflow ? 32'hFF80_0000 :
                    o_invalid_op ? 32'h7FC0_0000 :
		            ln_float0 == 32'h32800000 ? 0 : ln_float0;

//judge if the input is valid
assign in_NaN = (i_data[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] == 8'b11111111)&&(i_data[FLOAT_FRAC_WIDTH-2:0] != 0) ? 1 : 0;
assign in_INF = (i_data[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] == 8'b11111111)&&(i_data[FLOAT_FRAC_WIDTH-2:0] == 0) ? 1 : 0;
assign in_ZERO = i_data[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] == 8'b0;
//assign in_ONE = i_data == 3F800000;
assign o_invalid_op = invalid_op_buffer[ITERATION_NUM-1];
assign o_overflow = overflow_buffer[ITERATION_NUM-1];
assign o_underflow = underflow_buffer[ITERATION_NUM-1];

assign invalid_op = in_NaN || i_data[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1] == 1;
assign overflow = in_INF;
assign underflow = in_ZERO;

//delay i_valid, invalid_op, overflow, to keep pace with output
integer i3;
always @(posedge i_clk or negedge i_rst_n)
    if(!i_rst_n) begin
        for (i3 = 0; i3 < ITERATION_NUM; i3 = i3+1) begin
            in_valid_buffer[i3] <= 0;
            invalid_op_buffer[i3] <= 0;
            overflow_buffer[i3] <= 0;
            underflow_buffer[i3] <= 0;
        end
    end
    else if (i_aclken) begin
        in_valid_buffer[0] <= i_valid;
	    invalid_op_buffer[0] <= invalid_op;
	    overflow_buffer[0] <= overflow;
        underflow_buffer[0] <= underflow;
        for (i3 = 1; i3 < ITERATION_NUM; i3 = i3+1) begin
            in_valid_buffer[i3] <= in_valid_buffer[i3-1];
            invalid_op_buffer[i3] <= invalid_op_buffer[i3-1];
            overflow_buffer[i3] <= overflow_buffer[i3-1];
            underflow_buffer[i3] <= underflow_buffer[i3-1];
        end
    end

endmodule