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
// Filename: ipsxe_floating_point_a6_v1_0.v
// Function: This module is a lut for o_a6.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_a6_v1_0 (
    input [8-1:0] i_x_hi8,
    output reg [22-1:0] o_a6
);

// o_a6 is the argument a1,
// which is in the taylor expression:
// a0 - a1 * (x - a) + a2 * (x - a)^2 - a3 * (x - a)^3 + a4 * (x - a)^4 - a5 * (x - a)^5 + a6 * (x - a)^6
always @(*) begin: blk_o_a6
    case(i_x_hi8)
8'd0:   o_a6 = 22'h27d048; // a6
8'd1:   o_a6 = 22'h25db70; // a6
8'd2:   o_a6 = 22'h2402c8; // a6
8'd3:   o_a6 = 22'h224485; // a6
8'd4:   o_a6 = 22'h209f00; // a6
8'd5:   o_a6 = 22'h1f10ae; // a6
8'd6:   o_a6 = 22'h1d981f; // a6
8'd7:   o_a6 = 22'h1c33fc; // a6
8'd8:   o_a6 = 22'h1ae307; // a6
8'd9:   o_a6 = 22'h19a416; // a6
8'd10:  o_a6 = 22'h187613; // a6
8'd11:  o_a6 = 22'h1757fc; // a6
8'd12:  o_a6 = 22'h1648de; // a6
8'd13:  o_a6 = 22'h1547d9; // a6
8'd14:  o_a6 = 22'h145418; // a6
8'd15:  o_a6 = 22'h136cd7; // a6
8'd16:  o_a6 = 22'h12915c; // a6
8'd17:  o_a6 = 22'h11c0fc; // a6
8'd18:  o_a6 = 22'h10fb13; // a6
8'd19:  o_a6 = 22'h103f0c; // a6
8'd20:  o_a6 =  22'hf8c56; // a6
8'd21:  o_a6 =  22'hee26e; // a6
8'd22:  o_a6 =  22'he40d6; // a6
8'd23:  o_a6 =  22'hda71a; // a6
8'd24:  o_a6 =  22'hd14ca; // a6
8'd25:  o_a6 =  22'hc8980; // a6
8'd26:  o_a6 =  22'hc04da; // a6
8'd27:  o_a6 =  22'hb867e; // a6
8'd28:  o_a6 =  22'hb0e14; // a6
8'd29:  o_a6 =  22'ha9b4d; // a6
8'd30:  o_a6 =  22'ha2ddd; // a6
8'd31:  o_a6 =  22'h9c57b; // a6
8'd32:  o_a6 =  22'h961e5; // a6
8'd33:  o_a6 =  22'h902db; // a6
8'd34:  o_a6 =  22'h8a821; // a6
8'd35:  o_a6 =  22'h8517e; // a6
8'd36:  o_a6 =  22'h7febe; // a6
8'd37:  o_a6 =  22'h7afae; // a6
8'd38:  o_a6 =  22'h7641f; // a6
8'd39:  o_a6 =  22'h71be4; // a6
8'd40:  o_a6 =  22'h6d6d3; // a6
8'd41:  o_a6 =  22'h694c3; // a6
8'd42:  o_a6 =  22'h65590; // a6
8'd43:  o_a6 =  22'h61914; // a6
8'd44:  o_a6 =  22'h5df30; // a6
8'd45:  o_a6 =  22'h5a7c1; // a6
8'd46:  o_a6 =  22'h572ac; // a6
8'd47:  o_a6 =  22'h53fd1; // a6
8'd48:  o_a6 =  22'h50f18; // a6
8'd49:  o_a6 =  22'h4e065; // a6
8'd50:  o_a6 =  22'h4b3a2; // a6
8'd51:  o_a6 =  22'h488b5; // a6
8'd52:  o_a6 =  22'h45f8a; // a6
8'd53:  o_a6 =  22'h4380d; // a6
8'd54:  o_a6 =  22'h41228; // a6
8'd55:  o_a6 =  22'h3edca; // a6
8'd56:  o_a6 =  22'h3cae1; // a6
8'd57:  o_a6 =  22'h3a95c; // a6
8'd58:  o_a6 =  22'h3892b; // a6
8'd59:  o_a6 =  22'h36a3f; // a6
8'd60:  o_a6 =  22'h34c89; // a6
8'd61:  o_a6 =  22'h32ffc; // a6
8'd62:  o_a6 =  22'h3148b; // a6
8'd63:  o_a6 =  22'h2fa28; // a6
8'd64:  o_a6 =  22'h2e0c9; // a6
8'd65:  o_a6 =  22'h2c863; // a6
8'd66:  o_a6 =  22'h2b0ea; // a6
8'd67:  o_a6 =  22'h29a54; // a6
8'd68:  o_a6 =  22'h28498; // a6
8'd69:  o_a6 =  22'h26fac; // a6
8'd70:  o_a6 =  22'h25b88; // a6
8'd71:  o_a6 =  22'h24822; // a6
8'd72:  o_a6 =  22'h23575; // a6
8'd73:  o_a6 =  22'h22376; // a6
8'd74:  o_a6 =  22'h21220; // a6
8'd75:  o_a6 =  22'h2016c; // a6
8'd76:  o_a6 =  22'h1f152; // a6
8'd77:  o_a6 =  22'h1e1cc; // a6
8'd78:  o_a6 =  22'h1d2d5; // a6
8'd79:  o_a6 =  22'h1c467; // a6
8'd80:  o_a6 =  22'h1b67c; // a6
8'd81:  o_a6 =  22'h1a90e; // a6
8'd82:  o_a6 =  22'h19c1a; // a6
8'd83:  o_a6 =  22'h18f99; // a6
8'd84:  o_a6 =  22'h18388; // a6
8'd85:  o_a6 =  22'h177e3; // a6
8'd86:  o_a6 =  22'h16ca4; // a6
8'd87:  o_a6 =  22'h161c8; // a6
8'd88:  o_a6 =  22'h1574b; // a6
8'd89:  o_a6 =  22'h14d2a; // a6
8'd90:  o_a6 =  22'h14360; // a6
8'd91:  o_a6 =  22'h139eb; // a6
8'd92:  o_a6 =  22'h130c8; // a6
8'd93:  o_a6 =  22'h127f2; // a6
8'd94:  o_a6 =  22'h11f68; // a6
8'd95:  o_a6 =  22'h11726; // a6
8'd96:  o_a6 =  22'h10f2b; // a6
8'd97:  o_a6 =  22'h10772; // a6
8'd98:  o_a6 =   22'hfffa; // a6
8'd99:  o_a6 =   22'hf8c0; // a6
8'd100: o_a6 =   22'hf1c2; // a6
8'd101: o_a6 =   22'heafe; // a6
8'd102: o_a6 =   22'he472; // a6
8'd103: o_a6 =   22'hde1b; // a6
8'd104: o_a6 =   22'hd7f8; // a6
8'd105: o_a6 =   22'hd207; // a6
8'd106: o_a6 =   22'hcc46; // a6
8'd107: o_a6 =   22'hc6b4; // a6
8'd108: o_a6 =   22'hc14e; // a6
8'd109: o_a6 =   22'hbc13; // a6
8'd110: o_a6 =   22'hb702; // a6
8'd111: o_a6 =   22'hb219; // a6
8'd112: o_a6 =   22'had57; // a6
8'd113: o_a6 =   22'ha8ba; // a6
8'd114: o_a6 =   22'ha441; // a6
8'd115: o_a6 =   22'h9feb; // a6
8'd116: o_a6 =   22'h9bb7; // a6
8'd117: o_a6 =   22'h97a3; // a6
8'd118: o_a6 =   22'h93af; // a6
8'd119: o_a6 =   22'h8fd9; // a6
8'd120: o_a6 =   22'h8c20; // a6
8'd121: o_a6 =   22'h8884; // a6
8'd122: o_a6 =   22'h8503; // a6
8'd123: o_a6 =   22'h819d; // a6
8'd124: o_a6 =   22'h7e50; // a6
8'd125: o_a6 =   22'h7b1c; // a6
8'd126: o_a6 =   22'h77ff; // a6
8'd127: o_a6 =   22'h74fa; // a6
8'd128: o_a6 = 22'h384e10; // a6
8'd129: o_a6 = 22'h3589c4; // a6
8'd130: o_a6 = 22'h32ed53; // a6
8'd131: o_a6 = 22'h307637; // a6
8'd132: o_a6 = 22'h2e2219; // a6
8'd133: o_a6 = 22'h2beeca; // a6
8'd134: o_a6 = 22'h29da41; // a6
8'd135: o_a6 = 22'h27e29a; // a6
8'd136: o_a6 = 22'h260612; // a6
8'd137: o_a6 = 22'h244305; // a6
8'd138: o_a6 = 22'h2297e9; // a6
8'd139: o_a6 = 22'h210351; // a6
8'd140: o_a6 = 22'h1f83e7; // a6
8'd141: o_a6 = 22'h1e186b; // a6
8'd142: o_a6 = 22'h1cbfb3; // a6
8'd143: o_a6 = 22'h1b78a8; // a6
8'd144: o_a6 = 22'h1a4244; // a6
8'd145: o_a6 = 22'h191b94; // a6
8'd146: o_a6 = 22'h1803b1; // a6
8'd147: o_a6 = 22'h16f9c7; // a6
8'd148: o_a6 = 22'h15fd0c; // a6
8'd149: o_a6 = 22'h150cc3; // a6
8'd150: o_a6 = 22'h14283c; // a6
8'd151: o_a6 = 22'h134ed1; // a6
8'd152: o_a6 = 22'h127fe7; // a6
8'd153: o_a6 = 22'h11baeb; // a6
8'd154: o_a6 = 22'h10ff53; // a6
8'd155: o_a6 = 22'h104ca0; // a6
8'd156: o_a6 =  22'hfa256; // a6
8'd157: o_a6 =  22'hf0004; // a6
8'd158: o_a6 =  22'he653f; // a6
8'd159: o_a6 =  22'hdd1a1; // a6
8'd160: o_a6 =  22'hd44cb; // a6
8'd161: o_a6 =  22'hcbe63; // a6
8'd162: o_a6 =  22'hc3e14; // a6
8'd163: o_a6 =  22'hbc38f; // a6
8'd164: o_a6 =  22'hb4e88; // a6
8'd165: o_a6 =  22'hadeb9; // a6
8'd166: o_a6 =  22'ha73dd; // a6
8'd167: o_a6 =  22'ha0db7; // a6
8'd168: o_a6 =  22'h9ac0a; // a6
8'd169: o_a6 =  22'h94e9d; // a6
8'd170: o_a6 =  22'h8f53c; // a6
8'd171: o_a6 =  22'h89fb3; // a6
8'd172: o_a6 =  22'h84dd3; // a6
8'd173: o_a6 =  22'h7ff6f; // a6
8'd174: o_a6 =  22'h7b45c; // a6
8'd175: o_a6 =  22'h76c72; // a6
8'd176: o_a6 =  22'h7278a; // a6
8'd177: o_a6 =  22'h6e580; // a6
8'd178: o_a6 =  22'h6a631; // a6
8'd179: o_a6 =  22'h6697d; // a6
8'd180: o_a6 =  22'h62f45; // a6
8'd181: o_a6 =  22'h5f76c; // a6
8'd182: o_a6 =  22'h5c1d5; // a6
8'd183: o_a6 =  22'h58e67; // a6
8'd184: o_a6 =  22'h55d08; // a6
8'd185: o_a6 =  22'h52da0; // a6
8'd186: o_a6 =  22'h5001a; // a6
8'd187: o_a6 =  22'h4d45f; // a6
8'd188: o_a6 =  22'h4aa5b; // a6
8'd189: o_a6 =  22'h481fa; // a6
8'd190: o_a6 =  22'h45b2a; // a6
8'd191: o_a6 =  22'h435da; // a6
8'd192: o_a6 =  22'h411f9; // a6
8'd193: o_a6 =  22'h3ef77; // a6
8'd194: o_a6 =  22'h3ce45; // a6
8'd195: o_a6 =  22'h3ae54; // a6
8'd196: o_a6 =  22'h38f97; // a6
8'd197: o_a6 =  22'h37201; // a6
8'd198: o_a6 =  22'h35585; // a6
8'd199: o_a6 =  22'h33a17; // a6
8'd200: o_a6 =  22'h31fad; // a6
8'd201: o_a6 =  22'h3063a; // a6
8'd202: o_a6 =  22'h2edb6; // a6
8'd203: o_a6 =  22'h2d616; // a6
8'd204: o_a6 =  22'h2bf51; // a6
8'd205: o_a6 =  22'h2a95d; // a6
8'd206: o_a6 =  22'h29434; // a6
8'd207: o_a6 =  22'h27fcb; // a6
8'd208: o_a6 =  22'h26c1c; // a6
8'd209: o_a6 =  22'h2591f; // a6
8'd210: o_a6 =  22'h246cc; // a6
8'd211: o_a6 =  22'h2351e; // a6
8'd212: o_a6 =  22'h2240e; // a6
8'd213: o_a6 =  22'h21395; // a6
8'd214: o_a6 =  22'h203ae; // a6
8'd215: o_a6 =  22'h1f452; // a6
8'd216: o_a6 =  22'h1e57d; // a6
8'd217: o_a6 =  22'h1d72a; // a6
8'd218: o_a6 =  22'h1c953; // a6
8'd219: o_a6 =  22'h1bbf3; // a6
8'd220: o_a6 =  22'h1af06; // a6
8'd221: o_a6 =  22'h1a288; // a6
8'd222: o_a6 =  22'h19674; // a6
8'd223: o_a6 =  22'h18ac7; // a6
8'd224: o_a6 =  22'h17f7d; // a6
8'd225: o_a6 =  22'h17491; // a6
8'd226: o_a6 =  22'h16a01; // a6
8'd227: o_a6 =  22'h15fc9; // a6
8'd228: o_a6 =  22'h155e6; // a6
8'd229: o_a6 =  22'h14c54; // a6
8'd230: o_a6 =  22'h14312; // a6
8'd231: o_a6 =  22'h13a1b; // a6
8'd232: o_a6 =  22'h1316d; // a6
8'd233: o_a6 =  22'h12906; // a6
8'd234: o_a6 =  22'h120e3; // a6
8'd235: o_a6 =  22'h11902; // a6
8'd236: o_a6 =  22'h1115f; // a6
8'd237: o_a6 =  22'h109fa; // a6
8'd238: o_a6 =  22'h102d0; // a6
8'd239: o_a6 =   22'hfbde; // a6
8'd240: o_a6 =   22'hf523; // a6
8'd241: o_a6 =   22'hee9d; // a6
8'd242: o_a6 =   22'he84a; // a6
8'd243: o_a6 =   22'he229; // a6
8'd244: o_a6 =   22'hdc37; // a6
8'd245: o_a6 =   22'hd673; // a6
8'd246: o_a6 =   22'hd0db; // a6
8'd247: o_a6 =   22'hcb6e; // a6
8'd248: o_a6 =   22'hc62b; // a6
8'd249: o_a6 =   22'hc110; // a6
8'd250: o_a6 =   22'hbc1c; // a6
8'd251: o_a6 =   22'hb74d; // a6
8'd252: o_a6 =   22'hb2a2; // a6
8'd253: o_a6 =   22'hae1a; // a6
8'd254: o_a6 =   22'ha9b4; // a6
default:o_a6 =   22'ha56e; // a6
    endcase
end

endmodule