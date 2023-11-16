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
// Filename: ipsxe_floating_point_a2_hi_v1_0.v
// Function: This module is a lut for o_a2_hi.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_a2_hi_v1_0 (
    input [8-1:0] i_x_hi8,
    output reg [8-1:0] o_a2_hi
);

// o_a2_hi is the highest 8 bits of the argument a2,
// which is in the taylor expression:
// a0 - a1 * (x - a) + a2 * (x - a)^2 - a3 * (x - a)^3 + a4 * (x - a)^4 - a5 * (x - a)^5 + a6 * (x - a)^6
always @(*) begin: blk_o_a2_hi
    case(i_x_hi8)
8'd0: o_a2_hi = 8'h86; // highest 8 bits of a2:    52'h43394dd0833b8
8'd1: o_a2_hi = 8'h83; // highest 8 bits of a2:    52'h41eeffe795c07
8'd2: o_a2_hi = 8'h81; // highest 8 bits of a2:    52'h40ad80cc37fa3
8'd3: o_a2_hi = 8'h7e; // highest 8 bits of a2:    52'h3f7483c61e1e2
8'd4: o_a2_hi = 8'h7c; // highest 8 bits of a2:    52'h3e43bf479deac
8'd5: o_a2_hi = 8'h7a; // highest 8 bits of a2:    52'h3d1aecc66f982
8'd6: o_a2_hi = 8'h77; // highest 8 bits of a2:    52'h3bf9c8969be2a
8'd7: o_a2_hi = 8'h75; // highest 8 bits of a2:    52'h3ae011c774705
8'd8: o_a2_hi = 8'h73; // highest 8 bits of a2:    52'h39cd8a0276374
8'd9: o_a2_hi = 8'h71; // highest 8 bits of a2:    52'h38c1f56bf7c52
8'd10: o_a2_hi = 8'h6f; // highest 8 bits of a2:   52'h37bd1a858755f
8'd11: o_a2_hi = 8'h6d; // highest 8 bits of a2:   52'h36bec211de8f5
8'd12: o_a2_hi = 8'h6b; // highest 8 bits of a2:   52'h35c6b6fa5376d
8'd13: o_a2_hi = 8'h69; // highest 8 bits of a2:   52'h34d4c635afdcc
8'd14: o_a2_hi = 8'h67; // highest 8 bits of a2:   52'h33e8beb059f61
8'd15: o_a2_hi = 8'h66; // highest 8 bits of a2:   52'h33027135ba47e
8'd16: o_a2_hi = 8'h64; // highest 8 bits of a2:   52'h3221b05acc52e
8'd17: o_a2_hi = 8'h62; // highest 8 bits of a2:   52'h31465069c8a1b
8'd18: o_a2_hi = 8'h60; // highest 8 bits of a2:   52'h3070274ed7fc6
8'd19: o_a2_hi = 8'h5f; // highest 8 bits of a2:   52'h2f9f0c85c08dc
8'd20: o_a2_hi = 8'h5d; // highest 8 bits of a2:   52'h2ed2d9087ebe1
8'd21: o_a2_hi = 8'h5c; // highest 8 bits of a2:   52'h2e0b673ebc6e6
8'd22: o_a2_hi = 8'h5a; // highest 8 bits of a2:   52'h2d4892ee1a148
8'd23: o_a2_hi = 8'h59; // highest 8 bits of a2:   52'h2c8a392b3e00f
8'd24: o_a2_hi = 8'h57; // highest 8 bits of a2:   52'h2bd0384b9ed0d
8'd25: o_a2_hi = 8'h56; // highest 8 bits of a2:   52'h2b1a6fd7febb9
8'd26: o_a2_hi = 8'h54; // highest 8 bits of a2:   52'h2a68c07f8e0d9
8'd27: o_a2_hi = 8'h53; // highest 8 bits of a2:   52'h29bb0c0babb7b
8'd28: o_a2_hi = 8'h52; // highest 8 bits of a2:   52'h291135543b68c
8'd29: o_a2_hi = 8'h50; // highest 8 bits of a2:   52'h286b203489282
8'd30: o_a2_hi = 8'h4f; // highest 8 bits of a2:   52'h27c8b180b2e46
8'd31: o_a2_hi = 8'h4e; // highest 8 bits of a2:   52'h2729cefb90db6
8'd32: o_a2_hi = 8'h4d; // highest 8 bits of a2:   52'h268e5f4d162b9
8'd33: o_a2_hi = 8'h4b; // highest 8 bits of a2:   52'h25f649f923438
8'd34: o_a2_hi = 8'h4a; // highest 8 bits of a2:   52'h25617756c441b
8'd35: o_a2_hi = 8'h49; // highest 8 bits of a2:   52'h24cfd087d5aef
8'd36: o_a2_hi = 8'h48; // highest 8 bits of a2:   52'h24413f710a4ee
8'd37: o_a2_hi = 8'h47; // highest 8 bits of a2:   52'h23b5aeb24d118
8'd38: o_a2_hi = 8'h46; // highest 8 bits of a2:   52'h232d099f7a751
8'd39: o_a2_hi = 8'h45; // highest 8 bits of a2:   52'h22a73c396cef3
8'd40: o_a2_hi = 8'h44; // highest 8 bits of a2:   52'h2224332758315
8'd41: o_a2_hi = 8'h43; // highest 8 bits of a2:   52'h21a3dbb06f57c
8'd42: o_a2_hi = 8'h42; // highest 8 bits of a2:   52'h212623b5d24d2
8'd43: o_a2_hi = 8'h41; // highest 8 bits of a2:   52'h20aaf9acbedcf
8'd44: o_a2_hi = 8'h40; // highest 8 bits of a2:   52'h20324c990224e
8'd45: o_a2_hi = 8'h3f; // highest 8 bits of a2:   52'h1fbc0c07a73f5
8'd46: o_a2_hi = 8'h3e; // highest 8 bits of a2:   52'h1f482809e030a
8'd47: o_a2_hi = 8'h3d; // highest 8 bits of a2:   52'h1ed6913026468
8'd48: o_a2_hi = 8'h3c; // highest 8 bits of a2:   52'h1e6738858f41c
8'd49: o_a2_hi = 8'h3b; // highest 8 bits of a2:   52'h1dfa0f8b54c59
8'd50: o_a2_hi = 8'h3b; // highest 8 bits of a2:   52'h1d8f08348ba9f
8'd51: o_a2_hi = 8'h3a; // highest 8 bits of a2:   52'h1d2614e208efe
8'd52: o_a2_hi = 8'h39; // highest 8 bits of a2:   52'h1cbf285e72326
8'd53: o_a2_hi = 8'h38; // highest 8 bits of a2:   52'h1c5a35da778e5
8'd54: o_a2_hi = 8'h37; // highest 8 bits of a2:   52'h1bf730e935141
8'd55: o_a2_hi = 8'h37; // highest 8 bits of a2:   52'h1b960d7cb9efc
8'd56: o_a2_hi = 8'h36; // highest 8 bits of a2:   52'h1b36bfe2b38df
8'd57: o_a2_hi = 8'h35; // highest 8 bits of a2:   52'h1ad93cc13b17e
8'd58: o_a2_hi = 8'h34; // highest 8 bits of a2:   52'h1a7d7913c3b7f
8'd59: o_a2_hi = 8'h34; // highest 8 bits of a2:   52'h1a236a28282c0
8'd60: o_a2_hi = 8'h33; // highest 8 bits of a2:   52'h19cb059bd63d3
8'd61: o_a2_hi = 8'h32; // highest 8 bits of a2:   52'h1974415916c7f
8'd62: o_a2_hi = 8'h32; // highest 8 bits of a2:   52'h191f1394710df
8'd63: o_a2_hi = 8'h31; // highest 8 bits of a2:   52'h18cb72ca281ef
8'd64: o_a2_hi = 8'h30; // highest 8 bits of a2:   52'h187955bbd1310
8'd65: o_a2_hi = 8'h30; // highest 8 bits of a2:   52'h1828b36e01d1d
8'd66: o_a2_hi = 8'h2f; // highest 8 bits of a2:   52'h17d9832614e76
8'd67: o_a2_hi = 8'h2f; // highest 8 bits of a2:   52'h178bbc6805824
8'd68: o_a2_hi = 8'h2e; // highest 8 bits of a2:   52'h173f56f45e91d
8'd69: o_a2_hi = 8'h2d; // highest 8 bits of a2:   52'h16f44ac63e947
8'd70: o_a2_hi = 8'h2d; // highest 8 bits of a2:   52'h16aa90116e6a0
8'd71: o_a2_hi = 8'h2c; // highest 8 bits of a2:   52'h16621f408a780
8'd72: o_a2_hi = 8'h2c; // highest 8 bits of a2:   52'h161af0f33d5a9
8'd73: o_a2_hi = 8'h2b; // highest 8 bits of a2:   52'h15d4fdfc8b63b
8'd74: o_a2_hi = 8'h2b; // highest 8 bits of a2:   52'h15903f612e369
8'd75: o_a2_hi = 8'h2a; // highest 8 bits of a2:   52'h154cae55ffd26
8'd76: o_a2_hi = 8'h2a; // highest 8 bits of a2:   52'h150a443e7468e
8'd77: o_a2_hi = 8'h29; // highest 8 bits of a2:   52'h14c8faab22654
8'd78: o_a2_hi = 8'h29; // highest 8 bits of a2:   52'h1488cb58580e2
8'd79: o_a2_hi = 8'h28; // highest 8 bits of a2:   52'h1449b02cbe33c
8'd80: o_a2_hi = 8'h28; // highest 8 bits of a2:   52'h140ba33807640
8'd81: o_a2_hi = 8'h27; // highest 8 bits of a2:   52'h13ce9eb1ab219
8'd82: o_a2_hi = 8'h27; // highest 8 bits of a2:   52'h13929cf7aca31
8'd83: o_a2_hi = 8'h26; // highest 8 bits of a2:   52'h1357988d6ca3d
8'd84: o_a2_hi = 8'h26; // highest 8 bits of a2:   52'h131d8c1a85d52
8'd85: o_a2_hi = 8'h25; // highest 8 bits of a2:   52'h12e47269b3847
8'd86: o_a2_hi = 8'h25; // highest 8 bits of a2:   52'h12ac4667c20ed
8'd87: o_a2_hi = 8'h24; // highest 8 bits of a2:   52'h1275032288bfc
8'd88: o_a2_hi = 8'h24; // highest 8 bits of a2:   52'h123ea3c7ecbc4
8'd89: o_a2_hi = 8'h24; // highest 8 bits of a2:   52'h120923a4eca01
8'd90: o_a2_hi = 8'h23; // highest 8 bits of a2:   52'h11d47e24b477d
8'd91: o_a2_hi = 8'h23; // highest 8 bits of a2:   52'h11a0aecfb9c38
8'd92: o_a2_hi = 8'h22; // highest 8 bits of a2:   52'h116db14adf346
8'd93: o_a2_hi = 8'h22; // highest 8 bits of a2:   52'h113b81569fd90
8'd94: o_a2_hi = 8'h22; // highest 8 bits of a2:   52'h110a1ace416fc
8'd95: o_a2_hi = 8'h21; // highest 8 bits of a2:   52'h10d979a70d9a9
8'd96: o_a2_hi = 8'h21; // highest 8 bits of a2:   52'h10a999ef91b0c
8'd97: o_a2_hi = 8'h20; // highest 8 bits of a2:   52'h107a77cee4f01
8'd98: o_a2_hi = 8'h20; // highest 8 bits of a2:   52'h104c0f83f4cf1
8'd99: o_a2_hi = 8'h20; // highest 8 bits of a2:   52'h101e5d64d7377
8'd100: o_a2_hi = 8'h1f; // highest 8 bits of a2:  52'hff15dde226f6,
8'd101: o_a2_hi = 8'h1f; // highest 8 bits of a2:  52'hfc50d724a7ca,
8'd102: o_a2_hi = 8'h1f; // highest 8 bits of a2:  52'hf9968b903cd7,
8'd103: o_a2_hi = 8'h1e; // highest 8 bits of a2:  52'hf6e6c5eaaf6a,
8'd104: o_a2_hi = 8'h1e; // highest 8 bits of a2:  52'hf441523b156b,
8'd105: o_a2_hi = 8'h1e; // highest 8 bits of a2:  52'hf1a5fdc0e709,
8'd106: o_a2_hi = 8'h1d; // highest 8 bits of a2:  52'hef1496eb5d2c,
8'd107: o_a2_hi = 8'h1d; // highest 8 bits of a2:  52'hec8ced511610,
8'd108: o_a2_hi = 8'h1d; // highest 8 bits of a2:  52'hea0ed1a7fd76,
8'd109: o_a2_hi = 8'h1c; // highest 8 bits of a2:  52'he79a15bd761b,
8'd110: o_a2_hi = 8'h1c; // highest 8 bits of a2:  52'he52e8c6ec208,
8'd111: o_a2_hi = 8'h1c; // highest 8 bits of a2:  52'he2cc09a1a797,
8'd112: o_a2_hi = 8'h1c; // highest 8 bits of a2:  52'he072623d5100,
8'd113: o_a2_hi = 8'h1b; // highest 8 bits of a2:  52'hde216c236461,
8'd114: o_a2_hi = 8'h1b; // highest 8 bits of a2:  52'hdbd8fe295249,
8'd115: o_a2_hi = 8'h1b; // highest 8 bits of a2:  52'hd998f011d8df,
8'd116: o_a2_hi = 8'h1a; // highest 8 bits of a2:  52'hd7611a86b9d3,
8'd117: o_a2_hi = 8'h1a; // highest 8 bits of a2:  52'hd5315712a15c,
8'd118: o_a2_hi = 8'h1a; // highest 8 bits of a2:  52'hd309801b3c89,
8'd119: o_a2_hi = 8'h1a; // highest 8 bits of a2:  52'hd0e970db7d54,
8'd120: o_a2_hi = 8'h19; // highest 8 bits of a2:  52'hced1055e0adc,
8'd121: o_a2_hi = 8'h19; // highest 8 bits of a2:  52'hccc01a77dc49,
8'd122: o_a2_hi = 8'h19; // highest 8 bits of a2:  52'hcab68dc2fcf0,
8'd123: o_a2_hi = 8'h19; // highest 8 bits of a2:  52'hc8b43d997849,
8'd124: o_a2_hi = 8'h18; // highest 8 bits of a2:  52'hc6b909106c61,
8'd125: o_a2_hi = 8'h18; // highest 8 bits of a2:  52'hc4c4cff3418f,
8'd126: o_a2_hi = 8'h18; // highest 8 bits of a2:  52'hc2d772bf0615,
8'd127: o_a2_hi = 8'h18; // highest 8 bits of a2:  52'hc0f0d29dec8f,
8'd128: o_a2_hi = 8'hbe; // highest 8 bits of a2:  52'h5f11a18d5ddf6
8'd129: o_a2_hi = 8'hba; // highest 8 bits of a2:  52'h5d3e829bf8bfe
8'd130: o_a2_hi = 8'hb6; // highest 8 bits of a2:  52'h5b77d87073707
8'd131: o_a2_hi = 8'hb3; // highest 8 bits of a2:  52'h59bd368b3b3d1
8'd132: o_a2_hi = 8'hb0; // highest 8 bits of a2:  52'h580e34e725370
8'd133: o_a2_hi = 8'hac; // highest 8 bits of a2:  52'h566a6fc1ed843
8'd134: o_a2_hi = 8'ha9; // highest 8 bits of a2:  52'h54d18767ca8b4
8'd135: o_a2_hi = 8'ha6; // highest 8 bits of a2:  52'h53432001e2d86
8'd136: o_a2_hi = 8'ha3; // highest 8 bits of a2:  52'h51bee16777f9c
8'd137: o_a2_hi = 8'ha0; // highest 8 bits of a2:  52'h504476f19bbb2
8'd138: o_a2_hi = 8'h9d; // highest 8 bits of a2:  52'h4ed38f51480c8
8'd139: o_a2_hi = 8'h9a; // highest 8 bits of a2:  52'h4d6bdc67b4931
8'd140: o_a2_hi = 8'h98; // highest 8 bits of a2:  52'h4c0d1320c75ed
8'd141: o_a2_hi = 8'h95; // highest 8 bits of a2:  52'h4ab6eb4f808e4
8'd142: o_a2_hi = 8'h92; // highest 8 bits of a2:  52'h49691f8c42cc8
8'd143: o_a2_hi = 8'h90; // highest 8 bits of a2:  52'h48236d14dc8ff
8'd144: o_a2_hi = 8'h8d; // highest 8 bits of a2:  52'h46e593ae37d8e
8'd145: o_a2_hi = 8'h8b; // highest 8 bits of a2:  52'h45af558797e03
8'd146: o_a2_hi = 8'h89; // highest 8 bits of a2:  52'h4480771f4dbf5
8'd147: o_a2_hi = 8'h86; // highest 8 bits of a2:  52'h4358bf28ce918
8'd148: o_a2_hi = 8'h84; // highest 8 bits of a2:  52'h4237f67416ece
8'd149: o_a2_hi = 8'h82; // highest 8 bits of a2:  52'h411de7d648d87
8'd150: o_a2_hi = 8'h80; // highest 8 bits of a2:  52'h400a601372923
8'd151: o_a2_hi = 8'h7d; // highest 8 bits of a2:  52'h3efd2dc96d946
8'd152: o_a2_hi = 8'h7b; // highest 8 bits of a2:  52'h3df6215bc64d6
8'd153: o_a2_hi = 8'h79; // highest 8 bits of a2:  52'h3cf50ce09df62
8'd154: o_a2_hi = 8'h77; // highest 8 bits of a2:  52'h3bf9c40e78d3e
8'd155: o_a2_hi = 8'h76; // highest 8 bits of a2:  52'h3b041c2aec0a7
8'd156: o_a2_hi = 8'h74; // highest 8 bits of a2:  52'h3a13ebfa1ee80
8'd157: o_a2_hi = 8'h72; // highest 8 bits of a2:  52'h39290baf14504
8'd158: o_a2_hi = 8'h70; // highest 8 bits of a2:  52'h384354dcb1972
8'd159: o_a2_hi = 8'h6e; // highest 8 bits of a2:  52'h3762a26778c03
8'd160: o_a2_hi = 8'h6d; // highest 8 bits of a2:  52'h3686d077ecac9
8'd161: o_a2_hi = 8'h6b; // highest 8 bits of a2:  52'h35afbc6d96521
8'd162: o_a2_hi = 8'h69; // highest 8 bits of a2:  52'h34dd44d2a297e
8'd163: o_a2_hi = 8'h68; // highest 8 bits of a2:  52'h340f495010f33
8'd164: o_a2_hi = 8'h66; // highest 8 bits of a2:  52'h3345aaa26b51b
8'd165: o_a2_hi = 8'h65; // highest 8 bits of a2:  52'h32804a8f004cc
8'd166: o_a2_hi = 8'h63; // highest 8 bits of a2:  52'h31bf0bd99906a
8'd167: o_a2_hi = 8'h62; // highest 8 bits of a2:  52'h3101d23aa4723
8'd168: o_a2_hi = 8'h60; // highest 8 bits of a2:  52'h30488255d21f4
8'd169: o_a2_hi = 8'h5f; // highest 8 bits of a2:  52'h2f9301b116fb4
8'd170: o_a2_hi = 8'h5d; // highest 8 bits of a2:  52'h2ee136ac16c2c
8'd171: o_a2_hi = 8'h5c; // highest 8 bits of a2:  52'h2e330877ed2d3
8'd172: o_a2_hi = 8'h5b; // highest 8 bits of a2:  52'h2d885f0f521f0
8'd173: o_a2_hi = 8'h59; // highest 8 bits of a2:  52'h2ce1232f14731
8'd174: o_a2_hi = 8'h58; // highest 8 bits of a2:  52'h2c3d3e4ee7273
8'd175: o_a2_hi = 8'h57; // highest 8 bits of a2:  52'h2b9c9a9a7cf32
8'd176: o_a2_hi = 8'h55; // highest 8 bits of a2:  52'h2aff22eaee872
8'd177: o_a2_hi = 8'h54; // highest 8 bits of a2:  52'h2a64c2c067e34
8'd178: o_a2_hi = 8'h53; // highest 8 bits of a2:  52'h29cd663c19675
8'd179: o_a2_hi = 8'h52; // highest 8 bits of a2:  52'h2938fa1a696ba
8'd180: o_a2_hi = 8'h51; // highest 8 bits of a2:  52'h28a76bad6359f
8'd181: o_a2_hi = 8'h50; // highest 8 bits of a2:  52'h2818a8d76169f
8'd182: o_a2_hi = 8'h4f; // highest 8 bits of a2:  52'h278ca005ee47b
8'd183: o_a2_hi = 8'h4e; // highest 8 bits of a2:  52'h2703402cdc10d
8'd184: o_a2_hi = 8'h4c; // highest 8 bits of a2:  52'h267c78c18e350
8'd185: o_a2_hi = 8'h4b; // highest 8 bits of a2:  52'h25f839b673e7f
8'd186: o_a2_hi = 8'h4a; // highest 8 bits of a2:  52'h25767376b0f02
8'd187: o_a2_hi = 8'h49; // highest 8 bits of a2:  52'h24f716e1f2ba5
8'd188: o_a2_hi = 8'h48; // highest 8 bits of a2:  52'h247a15486fb51
8'd189: o_a2_hi = 8'h47; // highest 8 bits of a2:  52'h23ff60670f10f
8'd190: o_a2_hi = 8'h47; // highest 8 bits of a2:  52'h2386ea63b718f
8'd191: o_a2_hi = 8'h46; // highest 8 bits of a2:  52'h2310a5c9c06f6
8'd192: o_a2_hi = 8'h45; // highest 8 bits of a2:  52'h229c85868c8f1
8'd193: o_a2_hi = 8'h44; // highest 8 bits of a2:  52'h222a7ce63e064
8'd194: o_a2_hi = 8'h43; // highest 8 bits of a2:  52'h21ba7f9090f30
8'd195: o_a2_hi = 8'h42; // highest 8 bits of a2:  52'h214c8185d25bb
8'd196: o_a2_hi = 8'h41; // highest 8 bits of a2:  52'h20e0771bf50f5
8'd197: o_a2_hi = 8'h40; // highest 8 bits of a2:  52'h207654fbc2c92
8'd198: o_a2_hi = 8'h40; // highest 8 bits of a2:  52'h200e101e28630
8'd199: o_a2_hi = 8'h3f; // highest 8 bits of a2:  52'h1fa79dc99bf0c
8'd200: o_a2_hi = 8'h3e; // highest 8 bits of a2:  52'h1f42f38f9bac9
8'd201: o_a2_hi = 8'h3d; // highest 8 bits of a2:  52'h1ee0074a44a83
8'd202: o_a2_hi = 8'h3c; // highest 8 bits of a2:  52'h1e7ecf1a00467
8'd203: o_a2_hi = 8'h3c; // highest 8 bits of a2:  52'h1e1f416347886
8'd204: o_a2_hi = 8'h3b; // highest 8 bits of a2:  52'h1dc154cc7b483
8'd205: o_a2_hi = 8'h3a; // highest 8 bits of a2:  52'h1d65003bd0842
8'd206: o_a2_hi = 8'h3a; // highest 8 bits of a2:  52'h1d0a3ad54fe75
8'd207: o_a2_hi = 8'h39; // highest 8 bits of a2:  52'h1cb0fbf8e7c6e
8'd208: o_a2_hi = 8'h38; // highest 8 bits of a2:  52'h1c593b408fd48
8'd209: o_a2_hi = 8'h38; // highest 8 bits of a2:  52'h1c02f07e7dcdb
8'd210: o_a2_hi = 8'h37; // highest 8 bits of a2:  52'h1bae13bb6a79f
8'd211: o_a2_hi = 8'h36; // highest 8 bits of a2:  52'h1b5a9d34e6505
8'd212: o_a2_hi = 8'h36; // highest 8 bits of a2:  52'h1b08855bbd247
8'd213: o_a2_hi = 8'h35; // highest 8 bits of a2:  52'h1ab7c4d268425
8'd214: o_a2_hi = 8'h34; // highest 8 bits of a2:  52'h1a68546b8e67a
8'd215: o_a2_hi = 8'h34; // highest 8 bits of a2:  52'h1a1a2d28910df
8'd216: o_a2_hi = 8'h33; // highest 8 bits of a2:  52'h19cd48382681f
8'd217: o_a2_hi = 8'h33; // highest 8 bits of a2:  52'h19819ef500463
8'd218: o_a2_hi = 8'h32; // highest 8 bits of a2:  52'h19372ae47d496
8'd219: o_a2_hi = 8'h31; // highest 8 bits of a2:  52'h18ede5b567798
8'd220: o_a2_hi = 8'h31; // highest 8 bits of a2:  52'h18a5c93ebc458
8'd221: o_a2_hi = 8'h30; // highest 8 bits of a2:  52'h185ecf7e7fa18
8'd222: o_a2_hi = 8'h30; // highest 8 bits of a2:  52'h1818f29899279
8'd223: o_a2_hi = 8'h2f; // highest 8 bits of a2:  52'h17d42cd5baf2e
8'd224: o_a2_hi = 8'h2f; // highest 8 bits of a2:  52'h179078a251d79
8'd225: o_a2_hi = 8'h2e; // highest 8 bits of a2:  52'h174dd08d7e9c0
8'd226: o_a2_hi = 8'h2e; // highest 8 bits of a2:  52'h170c2f4817df6
8'd227: o_a2_hi = 8'h2d; // highest 8 bits of a2:  52'h16cb8fa3b458d
8'd228: o_a2_hi = 8'h2d; // highest 8 bits of a2:  52'h168bec91bd20f
8'd229: o_a2_hi = 8'h2c; // highest 8 bits of a2:  52'h164d412287b99
8'd230: o_a2_hi = 8'h2c; // highest 8 bits of a2:  52'h160f8884778b1
8'd231: o_a2_hi = 8'h2b; // highest 8 bits of a2:  52'h15d2be032690a
8'd232: o_a2_hi = 8'h2b; // highest 8 bits of a2:  52'h1596dd0694f15
8'd233: o_a2_hi = 8'h2a; // highest 8 bits of a2:  52'h155be1125f452
8'd234: o_a2_hi = 8'h2a; // highest 8 bits of a2:  52'h1521c5c4fb488
8'd235: o_a2_hi = 8'h29; // highest 8 bits of a2:  52'h14e886d6fac2e
8'd236: o_a2_hi = 8'h29; // highest 8 bits of a2:  52'h14b0201a5467d
8'd237: o_a2_hi = 8'h28; // highest 8 bits of a2:  52'h14788d79b27b5
8'd238: o_a2_hi = 8'h28; // highest 8 bits of a2:  52'h1441caf7c705e
8'd239: o_a2_hi = 8'h28; // highest 8 bits of a2:  52'h140bd4aea5658
8'd240: o_a2_hi = 8'h27; // highest 8 bits of a2:  52'h13d6a6cf210ac
8'd241: o_a2_hi = 8'h27; // highest 8 bits of a2:  52'h13a23da031347
8'd242: o_a2_hi = 8'h26; // highest 8 bits of a2:  52'h136e957e597c8
8'd243: o_a2_hi = 8'h26; // highest 8 bits of a2:  52'h133baadb170b1
8'd244: o_a2_hi = 8'h26; // highest 8 bits of a2:  52'h13097a3c52477
8'd245: o_a2_hi = 8'h25; // highest 8 bits of a2:  52'h12d8003bd4de3
8'd246: o_a2_hi = 8'h25; // highest 8 bits of a2:  52'h12a73986c3f67
8'd247: o_a2_hi = 8'h24; // highest 8 bits of a2:  52'h127722dd1e72a
8'd248: o_a2_hi = 8'h24; // highest 8 bits of a2:  52'h1247b9113f17e
8'd249: o_a2_hi = 8'h24; // highest 8 bits of a2:  52'h1218f907627ba
8'd250: o_a2_hi = 8'h23; // highest 8 bits of a2:  52'h11eadfb530958
8'd251: o_a2_hi = 8'h23; // highest 8 bits of a2:  52'h11bd6a2149d70
8'd252: o_a2_hi = 8'h23; // highest 8 bits of a2:  52'h11909562d7aa1
8'd253: o_a2_hi = 8'h22; // highest 8 bits of a2:  52'h11645ea12039e
8'd254: o_a2_hi = 8'h22; // highest 8 bits of a2:  52'h1138c3131d69a
default: o_a2_hi = 8'h22; // highest 8 bits of a2: 52'h110dbfff16de0
    endcase
end

endmodule