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
// Filename:ipsxe_floating_point_exp_32_axi_v1_0.v
// Function: p=e^z
//           zsize:z < 8
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_exp_32_axi_v1_0

 #(
    parameter FLOAT_EXP_WIDTH = 8,
    parameter FLOAT_FRAC_WIDTH = 24,
    parameter DATA_WIDTH = 24,
    parameter DATA_WIDTH_CUT = 24,
    parameter ITERATION_NUM = 1,
    parameter INPUT_RANGE_ADD_OUTSIDE = 0,
    parameter LATENCY_CONFIG_OUTSIDE = 3 //latency clk = LATENCY_CONFIG-1
)
(
    input i_clk,
    input i_aclken,
    input i_rst_n, //aresetn
    input [FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1:0] i_data_float, //s_axis_a_tdata
    input i_valid, //s_axis_a_tvalid
    output [FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1:0] o_exp_float, //m_axis_result_tdata
    output reg o_overflow, 
    output reg o_underflow,
    output reg o_valid //m_axis_result_tvalid
);

localparam LATENCY_CONFIG = 8;
localparam INPUT_RANGE_ADD = 5;
//look up table 
reg [26:0] bm_exp;
wire [7:0] rom_index;
reg [7:0] rom_index_buffer0;
reg [7:0] rom_index_buffer1;
always @* begin
    case(rom_index_buffer1)
        8'd0: bm_exp <= 27'd67108864;
        8'd1: bm_exp <= 27'd67371521;
        8'd2: bm_exp <= 27'd67635205;
        8'd3: bm_exp <= 27'd67899922;
        8'd4: bm_exp <= 27'd68165675;
        8'd5: bm_exp <= 27'd68432468;
        8'd6: bm_exp <= 27'd68700305;
        8'd7: bm_exp <= 27'd68969190;
        8'd8: bm_exp <= 27'd69239128;
        8'd9: bm_exp <= 27'd69510122;
        8'd10: bm_exp <= 27'd69782177;
        8'd11: bm_exp <= 27'd70055297;
        8'd12: bm_exp <= 27'd70329486;
        8'd13: bm_exp <= 27'd70604747;
        8'd14: bm_exp <= 27'd70881087;
        8'd15: bm_exp <= 27'd71158507;
        8'd16: bm_exp <= 27'd71437014;
        8'd17: bm_exp <= 27'd71716610;
        8'd18: bm_exp <= 27'd71997301;
        8'd19: bm_exp <= 27'd72279091;
        8'd20: bm_exp <= 27'd72561983;
        8'd21: bm_exp <= 27'd72845983;
        8'd22: bm_exp <= 27'd73131094;
        8'd23: bm_exp <= 27'd73417321;
        8'd24: bm_exp <= 27'd73704668;
        8'd25: bm_exp <= 27'd73993140;
        8'd26: bm_exp <= 27'd74282741;
        8'd27: bm_exp <= 27'd74573475;
        8'd28: bm_exp <= 27'd74865348;
        8'd29: bm_exp <= 27'd75158362;
        8'd30: bm_exp <= 27'd75452524;
        8'd31: bm_exp <= 27'd75747837;
        8'd32: bm_exp <= 27'd76044305;
        8'd33: bm_exp <= 27'd76341934;
        8'd34: bm_exp <= 27'd76640728;
        8'd35: bm_exp <= 27'd76940692;
        8'd36: bm_exp <= 27'd77241829;
        8'd37: bm_exp <= 27'd77544145;
        8'd38: bm_exp <= 27'd77847644;
        8'd39: bm_exp <= 27'd78152331;
        8'd40: bm_exp <= 27'd78458211;
        8'd41: bm_exp <= 27'd78765288;
        8'd42: bm_exp <= 27'd79073566;
        8'd43: bm_exp <= 27'd79383051;
        8'd44: bm_exp <= 27'd79693748;
        8'd45: bm_exp <= 27'd80005660;
        8'd46: bm_exp <= 27'd80318794;
        8'd47: bm_exp <= 27'd80633153;
        8'd48: bm_exp <= 27'd80948742;
        8'd49: bm_exp <= 27'd81265566;
        8'd50: bm_exp <= 27'd81583631;
        8'd51: bm_exp <= 27'd81902940;
        8'd52: bm_exp <= 27'd82223499;
        8'd53: bm_exp <= 27'd82545313;
        8'd54: bm_exp <= 27'd82868386;
        8'd55: bm_exp <= 27'd83192724;
        8'd56: bm_exp <= 27'd83518331;
        8'd57: bm_exp <= 27'd83845212;
        8'd58: bm_exp <= 27'd84173373;
        8'd59: bm_exp <= 27'd84502818;
        8'd60: bm_exp <= 27'd84833553;
        8'd61: bm_exp <= 27'd85165582;
        8'd62: bm_exp <= 27'd85498911;
        8'd63: bm_exp <= 27'd85833544;
        8'd64: bm_exp <= 27'd86169487;
        8'd65: bm_exp <= 27'd86506745;
        8'd66: bm_exp <= 27'd86845323;
        8'd67: bm_exp <= 27'd87185226;
        8'd68: bm_exp <= 27'd87526459;
        8'd69: bm_exp <= 27'd87869028;
        8'd70: bm_exp <= 27'd88212938;
        8'd71: bm_exp <= 27'd88558193;
        8'd72: bm_exp <= 27'd88904800;
        8'd73: bm_exp <= 27'd89252764;
        8'd74: bm_exp <= 27'd89602089;
        8'd75: bm_exp <= 27'd89952782;
        8'd76: bm_exp <= 27'd90304847;
        8'd77: bm_exp <= 27'd90658290;
        8'd78: bm_exp <= 27'd91013117;
        8'd79: bm_exp <= 27'd91369332;
        8'd80: bm_exp <= 27'd91726942;
        8'd81: bm_exp <= 27'd92085951;
        8'd82: bm_exp <= 27'd92446365;
        8'd83: bm_exp <= 27'd92808190;
        8'd84: bm_exp <= 27'd93171431;
        8'd85: bm_exp <= 27'd93536093;
        8'd86: bm_exp <= 27'd93902183;
        8'd87: bm_exp <= 27'd94269706;
        8'd88: bm_exp <= 27'd94638667;
        8'd89: bm_exp <= 27'd95009072;
        8'd90: bm_exp <= 27'd95380927;
        8'd91: bm_exp <= 27'd95754238;
        8'd92: bm_exp <= 27'd96129009;
        8'd93: bm_exp <= 27'd96505248;
        8'd94: bm_exp <= 27'd96882959;
        8'd95: bm_exp <= 27'd97262148;
        8'd96: bm_exp <= 27'd97642821;
        8'd97: bm_exp <= 27'd98024984;
        8'd98: bm_exp <= 27'd98408643;
        8'd99: bm_exp <= 27'd98793804;
        8'd100: bm_exp <= 27'd99180472;
        8'd101: bm_exp <= 27'd99568653;
        8'd102: bm_exp <= 27'd99958354;
        8'd103: bm_exp <= 27'd100349580;
        8'd104: bm_exp <= 27'd100742337;
        8'd105: bm_exp <= 27'd101136631;
        8'd106: bm_exp <= 27'd101532469;
        8'd107: bm_exp <= 27'd101929856;
        8'd108: bm_exp <= 27'd102328798;
        8'd109: bm_exp <= 27'd102729301;
        8'd110: bm_exp <= 27'd103131372;
        8'd111: bm_exp <= 27'd103535017;
        8'd112: bm_exp <= 27'd103940242;
        8'd113: bm_exp <= 27'd104347052;
        8'd114: bm_exp <= 27'd104755455;
        8'd115: bm_exp <= 27'd105165457;
        8'd116: bm_exp <= 27'd105577063;
        8'd117: bm_exp <= 27'd105990279;
        8'd118: bm_exp <= 27'd106405114;
        8'd119: bm_exp <= 27'd106821572;
        8'd120: bm_exp <= 27'd107239659;
        8'd121: bm_exp <= 27'd107659383;
        8'd122: bm_exp <= 27'd108080750;
        8'd123: bm_exp <= 27'd108503766;
        8'd124: bm_exp <= 27'd108928438;
        8'd125: bm_exp <= 27'd109354772;
        8'd126: bm_exp <= 27'd109782775;
        8'd127: bm_exp <= 27'd110212452;
        8'd128: bm_exp <= 27'd110643812;
        8'd129: bm_exp <= 27'd111076859;
        8'd130: bm_exp <= 27'd111511602;
        8'd131: bm_exp <= 27'd111948046;
        8'd132: bm_exp <= 27'd112386198;
        8'd133: bm_exp <= 27'd112826065;
        8'd134: bm_exp <= 27'd113267654;
        8'd135: bm_exp <= 27'd113710971;
        8'd136: bm_exp <= 27'd114156023;
        8'd137: bm_exp <= 27'd114602817;
        8'd138: bm_exp <= 27'd115051360;
        8'd139: bm_exp <= 27'd115501658;
        8'd140: bm_exp <= 27'd115953719;
        8'd141: bm_exp <= 27'd116407549;
        8'd142: bm_exp <= 27'd116863155;
        8'd143: bm_exp <= 27'd117320545;
        8'd144: bm_exp <= 27'd117779724;
        8'd145: bm_exp <= 27'd118240701;
        8'd146: bm_exp <= 27'd118703482;
        8'd147: bm_exp <= 27'd119168074;
        8'd148: bm_exp <= 27'd119634485;
        8'd149: bm_exp <= 27'd120102721;
        8'd150: bm_exp <= 27'd120572790;
        8'd151: bm_exp <= 27'd121044699;
        8'd152: bm_exp <= 27'd121518454;
        8'd153: bm_exp <= 27'd121994064;
        8'd154: bm_exp <= 27'd122471535;
        8'd155: bm_exp <= 27'd122950875;
        8'd156: bm_exp <= 27'd123432091;
        8'd157: bm_exp <= 27'd123915191;
        8'd158: bm_exp <= 27'd124400181;
        8'd159: bm_exp <= 27'd124887070;
        8'd160: bm_exp <= 27'd125375864;
        8'd161: bm_exp <= 27'd125866571;
        8'd162: bm_exp <= 27'd126359199;
        8'd163: bm_exp <= 27'd126853755;
        8'd164: bm_exp <= 27'd127350246;
        8'd165: bm_exp <= 27'd127848681;
        8'd166: bm_exp <= 27'd128349067;
        8'd167: bm_exp <= 27'd128851411;
        8'd168: bm_exp <= 27'd129355721;
        8'd169: bm_exp <= 27'd129862005;
        8'd170: bm_exp <= 27'd130370271;
        8'd171: bm_exp <= 27'd130880525;
        8'd172: bm_exp <= 27'd131392777;
        8'd173: bm_exp <= 27'd131907034;
        8'd174: bm_exp <= 27'd132423304;
        8'd175: bm_exp <= 27'd132941594;
        8'd176: bm_exp <= 27'd133461912;
        8'd177: bm_exp <= 27'd133984268;
    endcase
end

reg overflow_buffer[LATENCY_CONFIG-1:0];
reg underflow_buffer[LATENCY_CONFIG-1:0];
reg in_valid_buffer[LATENCY_CONFIG-1:0];
wire [1:0] float_exp_nature;
reg [1:0] float_exp_nature_buffer[LATENCY_CONFIG:0]; //float_exp_nature_buffer[1] == 1: float_exp == 128; float_exp_nature_buffer[0] == 1: float_exp > 7
reg float_exp_pn_buffer[LATENCY_CONFIG-1:0];

wire [FLOAT_EXP_WIDTH-1:0] float_exp;
wire float_exp_pn;
wire [FLOAT_FRAC_WIDTH-1:0] float_value; //24bits
wire [FLOAT_FRAC_WIDTH+2:0] float_value_expand;
wire [DATA_WIDTH+4+INPUT_RANGE_ADD:0] iData_fixed; //+3bits
wire [DATA_WIDTH+3+INPUT_RANGE_ADD:0] iData_fixed_abs; //+3bits
wire [DATA_WIDTH+16+INPUT_RANGE_ADD:0] shift/*synthesis syn_dspstyle = "logic" */; //may decrease
wire shift_pn;
wire [DATA_WIDTH_CUT+3+INPUT_RANGE_ADD:0] w/*synthesis syn_dspstyle = "block_mult" */;
reg [DATA_WIDTH_CUT+3+INPUT_RANGE_ADD:0] w_buffer[2:0];
wire [DATA_WIDTH_CUT+3+INPUT_RANGE_ADD:0] r/*synthesis syn_dspstyle = "block_mult" */;
reg [DATA_WIDTH_CUT+3+INPUT_RANGE_ADD:0] r_buffer;

//wire [26:0] bm_exp;
wire [17:0] bl;
//reg [26:0] bm_exp_buffer[LATENCY_CONFIG-2:0];

reg [18-1:0] factor_bl;
reg [9-1:0] factor_bl_2;
wire [36-1:0] factor_bl_2_cal;

reg [7:0] shift_buffer [6:0];
reg shift_pn_buffer [7:0];

reg [19-1:0] exp_part_0;
reg [53-1:0] exp_part_1/*synthesis syn_dspstyle = "logic" */;
wire [53-1:0] exp_part_2;
reg [53-1:0] exp_part_2_buffer;

wire overflow/*synthesis syn_dspstyle = "block_mult" */;
wire underflow;

wire [FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1:0] exp_float0;
reg [FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1:0] exp_float0_buffer;

//compare the exponential bit with 127
assign float_exp_pn = i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] > 8'd127 ? 0 : 1;
//calculate the exponential bit of float input
assign float_exp = i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] > 8'd127 ? i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] - 8'd127 : 8'd127 - i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1];
assign float_exp_nature[1] = float_exp == 8'd128 ? 1 : 0;
assign float_exp_nature[0] = float_exp > 3'd7 ? 1 : 0;
//calculate the value of mantissa
assign float_value = {1'b1,i_data_float[FLOAT_FRAC_WIDTH-2:0]};
assign float_value_expand = {float_value, 3'b0};
//calculate the fixed value of input
assign iData_fixed[DATA_WIDTH+4+INPUT_RANGE_ADD] = i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1];
assign iData_fixed_abs[DATA_WIDTH+3+INPUT_RANGE_ADD:0] = i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] > 8'd127 ? {{(3+INPUT_RANGE_ADD){1'b0}},float_value_expand} <<< float_exp : {{(3+INPUT_RANGE_ADD){1'b0}},float_value_expand} >>> float_exp; 
assign iData_fixed[DATA_WIDTH+3+INPUT_RANGE_ADD:0] = i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1] ? -(iData_fixed_abs) : iData_fixed_abs;

//calculate the sign bit of shift number 0:left shift 1:right shift
reg in_fix_sign_buffer;
assign shift_pn = in_fix_sign_buffer; 
//calculate shift number
assign w = !i_rst_n ? {27{1'b1}} : {iData_fixed_abs};
assign shift = !i_rst_n ? {28{1'b1}} :
                in_fix_sign_buffer ? ((w_buffer[0] * 13'd5909) >> 38) +1 : ((w_buffer[0] * 13'd5909) >> 38); // (2^31)/23=ln2 * 2^27
//calculate value of r
wire [36:0] sub_value0/*synthesis syn_dspstyle = "block_mult" */;
//reg [36:0] sub_value0_buffer;
wire [33:0] sub_value;
reg [33:0] sub_value_buffer;
assign sub_value0 = shift_buffer[0] * 29'd372130559;
assign sub_value = sub_value0[4] == 1 ? (sub_value0 >> 3) + 1 : (sub_value0 >> 3);
assign r = !i_rst_n ? {27{1'b1}} :
	   shift_pn_buffer[1] ? sub_value_buffer - w_buffer[2] : w_buffer[2] - sub_value_buffer;
           //iData_fixed[DATA_WIDTH+3+INPUT_RANGE_ADD] ? (shift[7:0] * 23258160) - w : w - (shift[7:0] * 23258160); //ln2 * 2^8 = 177, ln2 * 2^23 = 5814540, ln2 * 2^27 = 93032640

//assign bm_exp = bm_exp_rom[r[23:16]];
assign rom_index = r_buffer[25:18];
assign bl = r_buffer[17:0];

assign factor_bl_2_cal = (bl * bl) >>> 27;

//exp_part_2 is used to remove the leading 1 of the exponential value
assign exp_part_2 = !i_rst_n ? 32'b111111111111111111111111111 : 
                    exp_part_1 > (1 <<< 52) ? exp_part_1 - (1 <<< 52) : (1 <<< 52) - exp_part_1;
//if input is smaller than 8, overflow = 0, otherwise 1
assign overflow = (i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1] == 1) ? 0 :
		  (i_data_float[FLOAT_FRAC_WIDTH-2:0] >= 22'd3240472) & (i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] == 8'd133) ? 1 :
		  (i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] >= 8'd134) ? 1 : 0;
                    //i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] > (8'd129 + INPUT_RANGE_ADD) ? 1 : 0;
assign underflow = (i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1] == 0) ? 0 :
                   (i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] > 8'b10000101) ? 1 :
                   (i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] == 8'b10000101) && (i_data_float[FLOAT_FRAC_WIDTH-2:0] >= 23'b01011101010110001010000) ? 1 : 0;

//wire [59:0] exp;
//assign exp = shift_pn_buffer[LATENCY_CONFIG-1] == 0 ? exp_part_1 <<< shift_buffer[LATENCY_CONFIG-1] : exp_part_1 >>> shift_buffer[LATENCY_CONFIG-1];

integer i0;
integer i1;
integer i2;
always @ ( posedge i_clk or negedge i_rst_n )
    if( !i_rst_n )
    begin
    //reset
    for (i0 = 0; i0 < 7; i0 = i0+1) begin
        shift_buffer[i0] <= 0;
        shift_pn_buffer[i0] <= 0;
    end
    shift_pn_buffer[7] <= 0;
    for (i1 = 0; i1 < 3; i1 = i1+1) begin
        w_buffer[i1] <= 0;
    end
    in_fix_sign_buffer <= 0;
    //sub_value0_buffer <= 0;
    sub_value_buffer <= 0;
    r_buffer <= 0;
    rom_index_buffer0 <= 0;
    rom_index_buffer1 <= 0;

    factor_bl <= 0;
    factor_bl_2 <= 0;
    exp_part_0 <= 0;
    exp_part_1 <= 0;
    exp_part_2_buffer <= 0;
    exp_float0_buffer <= 0;
    end
    else if (i_aclken) begin
        //initialize
        in_fix_sign_buffer <= iData_fixed[DATA_WIDTH+4+INPUT_RANGE_ADD];
        shift_buffer[0] <= shift[7:0];
        shift_pn_buffer[0] <= shift_pn;
        w_buffer[0] <= w;
        //sub_value0_buffer <= sub_value0;
        sub_value_buffer <= sub_value;
        r_buffer <= r;
        rom_index_buffer0 <= rom_index;
        rom_index_buffer1 <= rom_index_buffer0;

        factor_bl <= bl;
        factor_bl_2 <= factor_bl_2_cal[8:0];
        exp_part_0 <= factor_bl + factor_bl_2;
        exp_part_1 <= exp_part_0 * bm_exp + (bm_exp << 26);
        exp_part_2_buffer <= exp_part_2;
        exp_float0_buffer <= exp_float0;
        //iteration for calculating taylor expansion
        for (i0 = 1; i0 < 7; i0 = i0+1) begin
            shift_buffer[i0] <= shift_buffer[i0-1];
            shift_pn_buffer[i0] <= shift_pn_buffer[i0-1];
        end
        shift_pn_buffer[7] <= shift_pn_buffer[6];
        for (i1 = 1; i1 < 3; i1 = i1+1) begin
            w_buffer[i1] <= w_buffer[i1-1];
        end
    end

wire o_valid_wire;
wire o_overflow_wire;
wire o_underflow_wire;
assign o_valid_wire = in_valid_buffer[LATENCY_CONFIG-1];
assign o_overflow_wire = overflow_buffer[LATENCY_CONFIG-1];
assign o_underflow_wire = underflow_buffer[LATENCY_CONFIG-1];
//assign o_underflow_wire = ((shift_buffer[6] >= 7'd127) || (float_exp_nature_buffer[LATENCY_CONFIG-1][0])) && (float_exp_pn_buffer[LATENCY_CONFIG-1] == 0);

//calculate the sign bit of float result
assign exp_float0[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1] = !i_rst_n ? 1'b1 : 1'b0;
//calculate the exponential bits of float result
//wire shift_over;
//assign shift_over = shift_buffer[LATENCY_CONFIG-1] > 8'd127 ? 1 : 0;
assign exp_float0[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] = !i_rst_n ? 8'b11111111 :
                                                            shift_pn_buffer[6] == 0 ? 7'd127 + shift_buffer[6] : 7'd127 - shift_buffer[6];

//wire [7:0] expand_index;
//assign expand_index = shift_buffer[LATENCY_CONFIG-1];
//calculate the mantissa bits of float result
assign exp_float0[FLOAT_FRAC_WIDTH-2:0] = !i_rst_n ? 23'b11111111111111111111111 : 
					  //(shift_buffer[LATENCY_CONFIG-1] == 8'd127) & (shift_pn_buffer[LATENCY_CONFIG-1] == 1) ? {1'b1,exp_part_2[51:30]} :
                                          exp_part_2_buffer[51:29] == 23'h7f_ffff ? exp_part_2_buffer[51:29] :
					                      (exp_part_2_buffer[28] == 0) & (shift_pn_buffer[6] == 1) ? exp_part_2_buffer[51:29] :
					  (exp_part_2_buffer[28] == 0) & (shift_pn_buffer[6] == 0)  ?    exp_part_2_buffer[51:29]    :    exp_part_2_buffer[51:29]+1;
                                          //(exp_part_2[27:0] <= (1 << (27-expand_index))) & (shift_pn_buffer[LATENCY_CONFIG-1] == 0)  ?    exp_part_2[50:28]    :    exp_part_2[50:28]+1;
					  //exp_part_2[26:0] >= (1 << (25-expand_index))  ?  exp_part_2[49:27]+1    :    exp_part_2[49:27];
//adjust the output accorroding to the value of input 
assign o_exp_float = o_overflow ? {1'b0, {FLOAT_EXP_WIDTH{1'b1}}, {(FLOAT_FRAC_WIDTH-1){1'b0}}} :
		    float_exp_nature_buffer[LATENCY_CONFIG][1] ? 32'hffff_ffff :
                    shift_pn_buffer[7] == 0 ? exp_float0_buffer :
                    o_underflow == 1 ? 0 : exp_float0_buffer;
		    //(shift_buffer[LATENCY_CONFIG-1] >= 7'd127) && (float_exp_pn_buffer[LATENCY_CONFIG-1] == 0) ? 0 : 
                    //(float_exp_nature_buffer[LATENCY_CONFIG-1] >= 3'd7) && (float_exp_pn_buffer[LATENCY_CONFIG-1] == 0) ? 0 : exp_float0;
		            //(float_exp_pn_buffer[LATENCY_CONFIG-1] == 1) && (float_exp_nature_buffer[LATENCY_CONFIG-1] > 8'd7) ? 32'h3f800000 : exp_float0;

//delay i_valid, overflow, underflow, float_exp, and float_exp_pn to keep pace with output
integer i3;
always @(posedge i_clk or negedge i_rst_n)
    if(!i_rst_n) begin
    for (i3 = 0; i3 < LATENCY_CONFIG; i3 = i3+1) begin
        in_valid_buffer[i3] <= 0;
        overflow_buffer[i3] <= 0;
        underflow_buffer[i3] <= 0;
        float_exp_nature_buffer[i3] <= 0;
        float_exp_pn_buffer[i3] <= 0;
    end
        float_exp_nature_buffer[LATENCY_CONFIG] <= 0;
        o_valid <= 0;
        o_overflow <= 0;
        o_underflow <= 0;
    end
    else if (i_aclken) begin
        in_valid_buffer[0] <= i_valid;
        overflow_buffer[0] <= overflow;
        underflow_buffer[0] <= underflow;
        float_exp_nature_buffer[0] <= float_exp_nature;
        float_exp_pn_buffer[0] <= float_exp_pn;
        for (i3 = 1; i3 < LATENCY_CONFIG; i3 = i3+1) begin
            in_valid_buffer[i3] <= in_valid_buffer[i3-1];
            overflow_buffer[i3] <= overflow_buffer[i3-1];
            underflow_buffer[i3] <= underflow_buffer[i3-1];
            float_exp_nature_buffer[i3] <= float_exp_nature_buffer[i3-1];
            float_exp_pn_buffer[i3] <= float_exp_pn_buffer[i3-1];
        end
        float_exp_nature_buffer[LATENCY_CONFIG] <= float_exp_nature_buffer[LATENCY_CONFIG-1];
        o_valid <= o_valid_wire;
        o_overflow <= o_overflow_wire;
        o_underflow <= o_underflow_wire;
    end

endmodule