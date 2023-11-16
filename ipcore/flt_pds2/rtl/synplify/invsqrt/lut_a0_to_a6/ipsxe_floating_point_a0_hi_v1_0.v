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
// Filename: ipsxe_floating_point_a0_hi_v1_0.v
// Function: This module is a lut for o_a0_hi.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_a0_hi_v1_0 (
    input [8-1:0] i_x_hi8,
    output reg [9-1:0] o_a0_hi
);

// o_a0_hi is the highest 9 bits of the argument a0,
// which is in the taylor expression:
// a0 - a1 * (x - a) + a2 * (x - a)^2 - a3 * (x - a)^3 + a4 * (x - a)^4 - a5 * (x - a)^5 + a6 * (x - a)^6
always @(*) begin: blk_o_a0_hi
    case(i_x_hi8)
8'd0: o_a0_hi = 9'h169;   // highest 9 bits of a0: 55'h5a555a31ed6df5
8'd1: o_a0_hi = 9'h167;   // highest 9 bits of a0: 55'h59fbe468033447
8'd2: o_a0_hi = 9'h166;   // highest 9 bits of a0: 55'h59a3765d082498
8'd3: o_a0_hi = 9'h165;   // highest 9 bits of a0: 55'h594c0b0ae63f5e
8'd4: o_a0_hi = 9'h163;   // highest 9 bits of a0: 55'h58f59d8d90e84b
8'd5: o_a0_hi = 9'h162;   // highest 9 bits of a0: 55'h58a02921dea28e
8'd6: o_a0_hi = 9'h161;   // highest 9 bits of a0: 55'h584ba9246edb5e
8'd7: o_a0_hi = 9'h15f;   // highest 9 bits of a0: 55'h57f819109b2e67
8'd8: o_a0_hi = 9'h15e;   // highest 9 bits of a0: 55'h57a5747f739811
8'd9: o_a0_hi = 9'h15d;   // highest 9 bits of a0: 55'h5753b726c510ff
8'd10: o_a0_hi = 9'h15c;  // highest 9 bits of a0: 55'h5702dcd82a1588
8'd11: o_a0_hi = 9'h15a;  // highest 9 bits of a0: 55'h56b2e18024a29a
8'd12: o_a0_hi = 9'h159;  // highest 9 bits of a0: 55'h5663c1254137c4
8'd13: o_a0_hi = 9'h158;  // highest 9 bits of a0: 55'h561577e742742d
8'd14: o_a0_hi = 9'h157;  // highest 9 bits of a0: 55'h55c801fe54e9ca
8'd15: o_a0_hi = 9'h155;  // highest 9 bits of a0: 55'h557b5bba4ac76c
8'd16: o_a0_hi = 9'h154;  // highest 9 bits of a0: 55'h552f8181deff3e
8'd17: o_a0_hi = 9'h153;  // highest 9 bits of a0: 55'h54e46fd1ff93ef
8'd18: o_a0_hi = 9'h152;  // highest 9 bits of a0: 55'h549a233d1ebb20
8'd19: o_a0_hi = 9'h151;  // highest 9 bits of a0: 55'h5450986a8a87f0
8'd20: o_a0_hi = 9'h150;  // highest 9 bits of a0: 55'h5407cc15cad447
8'd21: o_a0_hi = 9'h14e;  // highest 9 bits of a0: 55'h53bfbb0e052344
8'd22: o_a0_hi = 9'h14d;  // highest 9 bits of a0: 55'h53786235663aa9
8'd23: o_a0_hi = 9'h14c;  // highest 9 bits of a0: 55'h5331be8091345f
8'd24: o_a0_hi = 9'h14b;  // highest 9 bits of a0: 55'h52ebccf613cc59
8'd25: o_a0_hi = 9'h14a;  // highest 9 bits of a0: 55'h52a68aaddfb1e5
8'd26: o_a0_hi = 9'h149;  // highest 9 bits of a0: 55'h5261f4d0c8a673
8'd27: o_a0_hi = 9'h148;  // highest 9 bits of a0: 55'h521e089807363c
8'd28: o_a0_hi = 9'h147;  // highest 9 bits of a0: 55'h51dac34cbfd9dd
8'd29: o_a0_hi = 9'h146;  // highest 9 bits of a0: 55'h519822478e5230
8'd30: o_a0_hi = 9'h145;  // highest 9 bits of a0: 55'h515622f01511f7
8'd31: o_a0_hi = 9'h144;  // highest 9 bits of a0: 55'h5114c2bc908af4
8'd32: o_a0_hi = 9'h143;  // highest 9 bits of a0: 55'h50d3ff316e3618
8'd33: o_a0_hi = 9'h142;  // highest 9 bits of a0: 55'h5093d5e0e7303d
8'd34: o_a0_hi = 9'h141;  // highest 9 bits of a0: 55'h5054446a9e46bf
8'd35: o_a0_hi = 9'h140;  // highest 9 bits of a0: 55'h5015487b4150e3
8'd36: o_a0_hi = 9'h13f;  // highest 9 bits of a0: 55'h4fd6dfcc2db4a0
8'd37: o_a0_hi = 9'h13e;  // highest 9 bits of a0: 55'h4f99082317f6e1
8'd38: o_a0_hi = 9'h13d;  // highest 9 bits of a0: 55'h4f5bbf51b638c2
8'd39: o_a0_hi = 9'h13c;  // highest 9 bits of a0: 55'h4f1f03356d84b4
8'd40: o_a0_hi = 9'h13b;  // highest 9 bits of a0: 55'h4ee2d1b701cfad
8'd41: o_a0_hi = 9'h13a;  // highest 9 bits of a0: 55'h4ea728ca4893da
8'd42: o_a0_hi = 9'h139;  // highest 9 bits of a0: 55'h4e6c066dddeb65
8'd43: o_a0_hi = 9'h138;  // highest 9 bits of a0: 55'h4e3168aadc1308
8'd44: o_a0_hi = 9'h137;  // highest 9 bits of a0: 55'h4df74d94953d24
8'd45: o_a0_hi = 9'h136;  // highest 9 bits of a0: 55'h4dbdb3484f9f36
8'd46: o_a0_hi = 9'h136;  // highest 9 bits of a0: 55'h4d8497ed03a44d
8'd47: o_a0_hi = 9'h135;  // highest 9 bits of a0: 55'h4d4bf9b31c3032
8'd48: o_a0_hi = 9'h134;  // highest 9 bits of a0: 55'h4d13d6d438dfc5
8'd49: o_a0_hi = 9'h133;  // highest 9 bits of a0: 55'h4cdc2d92f233ce
8'd50: o_a0_hi = 9'h132;  // highest 9 bits of a0: 55'h4ca4fc3a9f947b
8'd51: o_a0_hi = 9'h131;  // highest 9 bits of a0: 55'h4c6e411f1f1c56
8'd52: o_a0_hi = 9'h130;  // highest 9 bits of a0: 55'h4c37fa9c9f1a45
8'd53: o_a0_hi = 9'h130;  // highest 9 bits of a0: 55'h4c022717693ae3
8'd54: o_a0_hi = 9'h12f;  // highest 9 bits of a0: 55'h4bccc4fbaf4a07
8'd55: o_a0_hi = 9'h12e;  // highest 9 bits of a0: 55'h4b97d2bd597e10
8'd56: o_a0_hi = 9'h12d;  // highest 9 bits of a0: 55'h4b634ed7d63f05
8'd57: o_a0_hi = 9'h12c;  // highest 9 bits of a0: 55'h4b2f37cdeb5c35
8'd58: o_a0_hi = 9'h12b;  // highest 9 bits of a0: 55'h4afb8c2988a39d
8'd59: o_a0_hi = 9'h12b;  // highest 9 bits of a0: 55'h4ac84a7b9bceb5
8'd60: o_a0_hi = 9'h12a;  // highest 9 bits of a0: 55'h4a95715be5b8e8
8'd61: o_a0_hi = 9'h129;  // highest 9 bits of a0: 55'h4a62ff68d0d469
8'd62: o_a0_hi = 9'h128;  // highest 9 bits of a0: 55'h4a30f34748d271
8'd63: o_a0_hi = 9'h127;  // highest 9 bits of a0: 55'h49ff4ba2937489
8'd64: o_a0_hi = 9'h127;  // highest 9 bits of a0: 55'h49ce072c2a7cca
8'd65: o_a0_hi = 9'h126;  // highest 9 bits of a0: 55'h499d249b96b369
8'd66: o_a0_hi = 9'h125;  // highest 9 bits of a0: 55'h496ca2ae4bf84f
8'd67: o_a0_hi = 9'h124;  // highest 9 bits of a0: 55'h493c80278657d0
8'd68: o_a0_hi = 9'h124;  // highest 9 bits of a0: 55'h490cbbd02819e6
8'd69: o_a0_hi = 9'h123;  // highest 9 bits of a0: 55'h48dd547698c3b1
8'd70: o_a0_hi = 9'h122;  // highest 9 bits of a0: 55'h48ae48eea50352
8'd71: o_a0_hi = 9'h121;  // highest 9 bits of a0: 55'h487f98115f7e6f
8'd72: o_a0_hi = 9'h121;  // highest 9 bits of a0: 55'h485140bd027c0c
8'd73: o_a0_hi = 9'h120;  // highest 9 bits of a0: 55'h482341d4d262a9
8'd74: o_a0_hi = 9'h11f;  // highest 9 bits of a0: 55'h47f59a410103c3
8'd75: o_a0_hi = 9'h11f;  // highest 9 bits of a0: 55'h47c848ee91ae34
8'd76: o_a0_hi = 9'h11e;  // highest 9 bits of a0: 55'h479b4ccf3e0119
8'd77: o_a0_hi = 9'h11d;  // highest 9 bits of a0: 55'h476ea4d95b7929
8'd78: o_a0_hi = 9'h11d;  // highest 9 bits of a0: 55'h47425007c1b291
8'd79: o_a0_hi = 9'h11c;  // highest 9 bits of a0: 55'h47164d59b159ba
8'd80: o_a0_hi = 9'h11b;  // highest 9 bits of a0: 55'h46ea9bd2bbc57d
8'd81: o_a0_hi = 9'h11a;  // highest 9 bits of a0: 55'h46bf3a7aab3583
8'd82: o_a0_hi = 9'h11a;  // highest 9 bits of a0: 55'h4694285d6bafb5
8'd83: o_a0_hi = 9'h119;  // highest 9 bits of a0: 55'h4669648af477e9
8'd84: o_a0_hi = 9'h118;  // highest 9 bits of a0: 55'h463eee17321d02
8'd85: o_a0_hi = 9'h118;  // highest 9 bits of a0: 55'h4614c419f116fd
8'd86: o_a0_hi = 9'h117;  // highest 9 bits of a0: 55'h45eae5aec8f185
8'd87: o_a0_hi = 9'h117;  // highest 9 bits of a0: 55'h45c151f507fec9
8'd88: o_a0_hi = 9'h116;  // highest 9 bits of a0: 55'h4598080f9f8e8b
8'd89: o_a0_hi = 9'h115;  // highest 9 bits of a0: 55'h456f072510a55d
8'd90: o_a0_hi = 9'h115;  // highest 9 bits of a0: 55'h45464e5f593053
8'd91: o_a0_hi = 9'h114;  // highest 9 bits of a0: 55'h451ddcebe1b160
8'd92: o_a0_hi = 9'h113;  // highest 9 bits of a0: 55'h44f5b1fb6b60e9
8'd93: o_a0_hi = 9'h113;  // highest 9 bits of a0: 55'h44cdccc1fec106
8'd94: o_a0_hi = 9'h112;  // highest 9 bits of a0: 55'h44a62c76da9f29
8'd95: o_a0_hi = 9'h111;  // highest 9 bits of a0: 55'h447ed0546380f4
8'd96: o_a0_hi = 9'h111;  // highest 9 bits of a0: 55'h4457b79813791f
8'd97: o_a0_hi = 9'h110;  // highest 9 bits of a0: 55'h4430e1826a6171
8'd98: o_a0_hi = 9'h110;  // highest 9 bits of a0: 55'h440a4d56de76dd
8'd99: o_a0_hi = 9'h10f;  // highest 9 bits of a0: 55'h43e3fa5bcd5502
8'd100: o_a0_hi = 9'h10e; // highest 9 bits of a0: 55'h43bde7da6d4e4a
8'd101: o_a0_hi = 9'h10e; // highest 9 bits of a0: 55'h4398151ebf1e0b
8'd102: o_a0_hi = 9'h10d; // highest 9 bits of a0: 55'h437281777ff223
8'd103: o_a0_hi = 9'h10d; // highest 9 bits of a0: 55'h434d2c361bc99a
8'd104: o_a0_hi = 9'h10c; // highest 9 bits of a0: 55'h432814aea025de
8'd105: o_a0_hi = 9'h10c; // highest 9 bits of a0: 55'h43033a37af0c5e
8'd106: o_a0_hi = 9'h10b; // highest 9 bits of a0: 55'h42de9c2a725637
8'd107: o_a0_hi = 9'h10a; // highest 9 bits of a0: 55'h42ba39e28f4bd6
8'd108: o_a0_hi = 9'h10a; // highest 9 bits of a0: 55'h429612be1a8a78
8'd109: o_a0_hi = 9'h109; // highest 9 bits of a0: 55'h4272261d8c3173
8'd110: o_a0_hi = 9'h109; // highest 9 bits of a0: 55'h424e7363b4556e
8'd111: o_a0_hi = 9'h108; // highest 9 bits of a0: 55'h422af9f5afb789
8'd112: o_a0_hi = 9'h108; // highest 9 bits of a0: 55'h4207b93adcbea4
8'd113: o_a0_hi = 9'h107; // highest 9 bits of a0: 55'h41e4b09cd0b10a
8'd114: o_a0_hi = 9'h107; // highest 9 bits of a0: 55'h41c1df874d2cb4
8'd115: o_a0_hi = 9'h106; // highest 9 bits of a0: 55'h419f456835dc83
8'd116: o_a0_hi = 9'h105; // highest 9 bits of a0: 55'h417ce1af8668ce
8'd117: o_a0_hi = 9'h105; // highest 9 bits of a0: 55'h415ab3cf48a1b2
8'd118: o_a0_hi = 9'h104; // highest 9 bits of a0: 55'h4138bb3b8ae19f
8'd119: o_a0_hi = 9'h104; // highest 9 bits of a0: 55'h4116f76a56a6a1
8'd120: o_a0_hi = 9'h103; // highest 9 bits of a0: 55'h40f567d3a76104
8'd121: o_a0_hi = 9'h103; // highest 9 bits of a0: 55'h40d40bf16175dc
8'd122: o_a0_hi = 9'h102; // highest 9 bits of a0: 55'h40b2e33f49742a
8'd123: o_a0_hi = 9'h102; // highest 9 bits of a0: 55'h4091ed3afb7b41
8'd124: o_a0_hi = 9'h101; // highest 9 bits of a0: 55'h40712963e2d133
8'd125: o_a0_hi = 9'h101; // highest 9 bits of a0: 55'h4050973b31a7fb
8'd126: o_a0_hi = 9'h100; // highest 9 bits of a0: 55'h40303643d9103f
8'd127: o_a0_hi = 9'h100; // highest 9 bits of a0: 55'h4010060281187e
8'd128: o_a0_hi = 9'h1ff; // highest 9 bits of a0: 55'h7fc02fd822e09d
8'd129: o_a0_hi = 9'h1fd; // highest 9 bits of a0: 55'h7f41abd2f56ad7
8'd130: o_a0_hi = 9'h1fb; // highest 9 bits of a0: 55'h7ec49ccbf93d80
8'd131: o_a0_hi = 9'h1f9; // highest 9 bits of a0: 55'h7e48fba86180f7
8'd132: o_a0_hi = 9'h1f7; // highest 9 bits of a0: 55'h7dcec17d83f4e5
8'd133: o_a0_hi = 9'h1f5; // highest 9 bits of a0: 55'h7d55e78f38c90e
8'd134: o_a0_hi = 9'h1f3; // highest 9 bits of a0: 55'h7cde674e4b82d0
8'd135: o_a0_hi = 9'h1f1; // highest 9 bits of a0: 55'h7c683a56fc1d72
8'd136: o_a0_hi = 9'h1ef; // highest 9 bits of a0: 55'h7bf35a6f8f9f2a
8'd137: o_a0_hi = 9'h1ed; // highest 9 bits of a0: 55'h7b7fc186ef6759
8'd138: o_a0_hi = 9'h1ec; // highest 9 bits of a0: 55'h7b0d69b35684e0
8'd139: o_a0_hi = 9'h1ea; // highest 9 bits of a0: 55'h7a9c4d310c6cce
8'd140: o_a0_hi = 9'h1e8; // highest 9 bits of a0: 55'h7a2c66612c72ba
8'd141: o_a0_hi = 9'h1e6; // highest 9 bits of a0: 55'h79bdafc8796c7e
8'd142: o_a0_hi = 9'h1e5; // highest 9 bits of a0: 55'h7950240e3cf2fe
8'd143: o_a0_hi = 9'h1e3; // highest 9 bits of a0: 55'h78e3bdfb31b909
8'd144: o_a0_hi = 9'h1e1; // highest 9 bits of a0: 55'h78787878787878
8'd145: o_a0_hi = 9'h1e0; // highest 9 bits of a0: 55'h780e4e8e96fc46
8'd146: o_a0_hi = 9'h1de; // highest 9 bits of a0: 55'h77a53b6480d47a
8'd147: o_a0_hi = 9'h1dc; // highest 9 bits of a0: 55'h773d3a3ea946d1
8'd148: o_a0_hi = 9'h1db; // highest 9 bits of a0: 55'h76d6467e1e145d
8'd149: o_a0_hi = 9'h1d9; // highest 9 bits of a0: 55'h76705b9faab1a9
8'd150: o_a0_hi = 9'h1d8; // highest 9 bits of a0: 55'h760b753b0393db
8'd151: o_a0_hi = 9'h1d6; // highest 9 bits of a0: 55'h75a78f01f939e3
8'd152: o_a0_hi = 9'h1d5; // highest 9 bits of a0: 55'h7544a4bfb29d2e
8'd153: o_a0_hi = 9'h1d3; // highest 9 bits of a0: 55'h74e2b257eeb977
8'd154: o_a0_hi = 9'h1d2; // highest 9 bits of a0: 55'h7481b3c64cdf3d
8'd155: o_a0_hi = 9'h1d0; // highest 9 bits of a0: 55'h7421a51d9b880f
8'd156: o_a0_hi = 9'h1cf; // highest 9 bits of a0: 55'h73c282872d675e
8'd157: o_a0_hi = 9'h1cd; // highest 9 bits of a0: 55'h736448423475e2
8'd158: o_a0_hi = 9'h1cc; // highest 9 bits of a0: 55'h7306f2a322b8a5
8'd159: o_a0_hi = 9'h1ca; // highest 9 bits of a0: 55'h72aa7e131087d6
8'd160: o_a0_hi = 9'h1c9; // highest 9 bits of a0: 55'h724ee70f281c4a
8'd161: o_a0_hi = 9'h1c7; // highest 9 bits of a0: 55'h71f42a28162d33
8'd162: o_a0_hi = 9'h1c6; // highest 9 bits of a0: 55'h719a44017f6a25
8'd163: o_a0_hi = 9'h1c5; // highest 9 bits of a0: 55'h714131517a9fd5
8'd164: o_a0_hi = 9'h1c3; // highest 9 bits of a0: 55'h70e8eee00f5858
8'd165: o_a0_hi = 9'h1c2; // highest 9 bits of a0: 55'h70917986b8c9b4
8'd166: o_a0_hi = 9'h1c0; // highest 9 bits of a0: 55'h703ace2fece7aa
8'd167: o_a0_hi = 9'h1bf; // highest 9 bits of a0: 55'h6fe4e9d6a76f94
8'd168: o_a0_hi = 9'h1be; // highest 9 bits of a0: 55'h6f8fc985f8c700
8'd169: o_a0_hi = 9'h1bc; // highest 9 bits of a0: 55'h6f3b6a58988772
8'd170: o_a0_hi = 9'h1bb; // highest 9 bits of a0: 55'h6ee7c9787b9355
8'd171: o_a0_hi = 9'h1ba; // highest 9 bits of a0: 55'h6e94e41e6d91d5
8'd172: o_a0_hi = 9'h1b9; // highest 9 bits of a0: 55'h6e42b791adb0a7
8'd173: o_a0_hi = 9'h1b7; // highest 9 bits of a0: 55'h6df141278e8c6e
8'd174: o_a0_hi = 9'h1b6; // highest 9 bits of a0: 55'h6da07e4319218d
8'd175: o_a0_hi = 9'h1b5; // highest 9 bits of a0: 55'h6d506c54b2a8a6
8'd176: o_a0_hi = 9'h1b4; // highest 9 bits of a0: 55'h6d0108d9c54333
8'd177: o_a0_hi = 9'h1b2; // highest 9 bits of a0: 55'h6cb2515c6b5dce
8'd178: o_a0_hi = 9'h1b1; // highest 9 bits of a0: 55'h6c6443731daeda
8'd179: o_a0_hi = 9'h1b0; // highest 9 bits of a0: 55'h6c16dcc063b958
8'd180: o_a0_hi = 9'h1af; // highest 9 bits of a0: 55'h6bca1af286bca2
8'd181: o_a0_hi = 9'h1ad; // highest 9 bits of a0: 55'h6b7dfbc346fad3
8'd182: o_a0_hi = 9'h1ac; // highest 9 bits of a0: 55'h6b327cf793407d
8'd183: o_a0_hi = 9'h1ab; // highest 9 bits of a0: 55'h6ae79c5f42992d
8'd184: o_a0_hi = 9'h1aa; // highest 9 bits of a0: 55'h6a9d57d4d01d24
8'd185: o_a0_hi = 9'h1a9; // highest 9 bits of a0: 55'h6a53ad3d18c562
8'd186: o_a0_hi = 9'h1a8; // highest 9 bits of a0: 55'h6a0a9a871b33f1
8'd187: o_a0_hi = 9'h1a7; // highest 9 bits of a0: 55'h69c21dabb95f10
8'd188: o_a0_hi = 9'h1a5; // highest 9 bits of a0: 55'h697a34ad7c0e93
8'd189: o_a0_hi = 9'h1a4; // highest 9 bits of a0: 55'h6932dd98581b76
8'd190: o_a0_hi = 9'h1a3; // highest 9 bits of a0: 55'h68ec168175623d
8'd191: o_a0_hi = 9'h1a2; // highest 9 bits of a0: 55'h68a5dd86f7595e
8'd192: o_a0_hi = 9'h1a1; // highest 9 bits of a0: 55'h686030cfc73d83
8'd193: o_a0_hi = 9'h1a0; // highest 9 bits of a0: 55'h681b0e8b5fc5f5
8'd194: o_a0_hi = 9'h19f; // highest 9 bits of a0: 55'h67d674f19a541c
8'd195: o_a0_hi = 9'h19e; // highest 9 bits of a0: 55'h679262427d9168
8'd196: o_a0_hi = 9'h19d; // highest 9 bits of a0: 55'h674ed4c60d6f92
8'd197: o_a0_hi = 9'h19c; // highest 9 bits of a0: 55'h670bcacc1c7f74
8'd198: o_a0_hi = 9'h19b; // highest 9 bits of a0: 55'h66c942ac1e9348
8'd199: o_a0_hi = 9'h19a; // highest 9 bits of a0: 55'h66873ac4fca183
8'd200: o_a0_hi = 9'h199; // highest 9 bits of a0: 55'h6645b17ce9ddd1
8'd201: o_a0_hi = 9'h198; // highest 9 bits of a0: 55'h6604a54139fe45
8'd202: o_a0_hi = 9'h197; // highest 9 bits of a0: 55'h65c4148638a304
8'd203: o_a0_hi = 9'h196; // highest 9 bits of a0: 55'h6583fdc701d730
8'd204: o_a0_hi = 9'h195; // highest 9 bits of a0: 55'h65445f855ba20d
8'd205: o_a0_hi = 9'h194; // highest 9 bits of a0: 55'h65053849909fdb
8'd206: o_a0_hi = 9'h193; // highest 9 bits of a0: 55'h64c686a24b99fa
8'd207: o_a0_hi = 9'h192; // highest 9 bits of a0: 55'h64884924741669
8'd208: o_a0_hi = 9'h191; // highest 9 bits of a0: 55'h644a7e6b0bd6e1
8'd209: o_a0_hi = 9'h190; // highest 9 bits of a0: 55'h640d25170d401e
8'd210: o_a0_hi = 9'h18f; // highest 9 bits of a0: 55'h63d03bcf4aa21a
8'd211: o_a0_hi = 9'h18e; // highest 9 bits of a0: 55'h6393c1404e5a6a
8'd212: o_a0_hi = 9'h18d; // highest 9 bits of a0: 55'h6357b41c3bc9f4
8'd213: o_a0_hi = 9'h18c; // highest 9 bits of a0: 55'h631c131ab11796
8'd214: o_a0_hi = 9'h18b; // highest 9 bits of a0: 55'h62e0dcf8a9b990
8'd215: o_a0_hi = 9'h18a; // highest 9 bits of a0: 55'h62a6107861bfa1
8'd216: o_a0_hi = 9'h189; // highest 9 bits of a0: 55'h626bac6139d816
8'd217: o_a0_hi = 9'h188; // highest 9 bits of a0: 55'h6231af7f9c0a31
8'd218: o_a0_hi = 9'h187; // highest 9 bits of a0: 55'h61f818a4e1207d
8'd219: o_a0_hi = 9'h186; // highest 9 bits of a0: 55'h61bee6a736bde2
8'd220: o_a0_hi = 9'h186; // highest 9 bits of a0: 55'h61861861861862
8'd221: o_a0_hi = 9'h185; // highest 9 bits of a0: 55'h614dacb35b54ab
8'd222: o_a0_hi = 9'h184; // highest 9 bits of a0: 55'h6115a280cd7dc8
8'd223: o_a0_hi = 9'h183; // highest 9 bits of a0: 55'h60ddf8b267145f
8'd224: o_a0_hi = 9'h182; // highest 9 bits of a0: 55'h60a6ae350f311f
8'd225: o_a0_hi = 9'h181; // highest 9 bits of a0: 55'h606fc1f9f3361e
8'd226: o_a0_hi = 9'h180; // highest 9 bits of a0: 55'h603932f6710b05
8'd227: o_a0_hi = 9'h180; // highest 9 bits of a0: 55'h6003002401e01a
8'd228: o_a0_hi = 9'h17f; // highest 9 bits of a0: 55'h5fcd288025744c
8'd229: o_a0_hi = 9'h17e; // highest 9 bits of a0: 55'h5f97ab0c4dda88
8'd230: o_a0_hi = 9'h17d; // highest 9 bits of a0: 55'h5f6286cdcbbac7
8'd231: o_a0_hi = 9'h17c; // highest 9 bits of a0: 55'h5f2dbacdbb0b57
8'd232: o_a0_hi = 9'h17b; // highest 9 bits of a0: 55'h5ef94618f03ef5
8'd233: o_a0_hi = 9'h17b; // highest 9 bits of a0: 55'h5ec527bfe5e493
8'd234: o_a0_hi = 9'h17a; // highest 9 bits of a0: 55'h5e915ed6aab584
8'd235: o_a0_hi = 9'h179; // highest 9 bits of a0: 55'h5e5dea74d00f18
8'd236: o_a0_hi = 9'h178; // highest 9 bits of a0: 55'h5e2ac9b558d4a0
8'd237: o_a0_hi = 9'h177; // highest 9 bits of a0: 55'h5df7fbb6a8b716
8'd238: o_a0_hi = 9'h177; // highest 9 bits of a0: 55'h5dc57f9a73df83
8'd239: o_a0_hi = 9'h176; // highest 9 bits of a0: 55'h5d935485aef99a
8'd240: o_a0_hi = 9'h175; // highest 9 bits of a0: 55'h5d6179a07f9bc6
8'd241: o_a0_hi = 9'h174; // highest 9 bits of a0: 55'h5d2fee162d0a4d
8'd242: o_a0_hi = 9'h173; // highest 9 bits of a0: 55'h5cfeb1151152f1
8'd243: o_a0_hi = 9'h173; // highest 9 bits of a0: 55'h5ccdc1ce8abed6
8'd244: o_a0_hi = 9'h172; // highest 9 bits of a0: 55'h5c9d1f76ed9842
8'd245: o_a0_hi = 9'h171; // highest 9 bits of a0: 55'h5c6cc945764212
8'd246: o_a0_hi = 9'h170; // highest 9 bits of a0: 55'h5c3cbe743b9eb3
8'd247: o_a0_hi = 9'h170; // highest 9 bits of a0: 55'h5c0cfe4021c48f
8'd248: o_a0_hi = 9'h16f; // highest 9 bits of a0: 55'h5bdd87e8ccfdda
8'd249: o_a0_hi = 9'h16e; // highest 9 bits of a0: 55'h5bae5ab09511d8
8'd250: o_a0_hi = 9'h16d; // highest 9 bits of a0: 55'h5b7f75dc78d5a7
8'd251: o_a0_hi = 9'h16d; // highest 9 bits of a0: 55'h5b50d8b41202b4
8'd252: o_a0_hi = 9'h16c; // highest 9 bits of a0: 55'h5b228281895121
8'd253: o_a0_hi = 9'h16b; // highest 9 bits of a0: 55'h5af472918ad43d
8'd254: o_a0_hi = 9'h16b; // highest 9 bits of a0: 55'h5ac6a8333a977f
default: o_a0_hi = 9'h16a; // highest 9 bits of a0: 55'h5a9922b8297a4b
    endcase
end

endmodule