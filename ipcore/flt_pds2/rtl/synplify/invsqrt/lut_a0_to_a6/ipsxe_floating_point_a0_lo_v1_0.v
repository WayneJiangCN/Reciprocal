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
// Filename: ipsxe_floating_point_a0_lo_v1_0.v
// Function: This module is a lut for o_a0_lo.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_a0_lo_v1_0 (
    input [8-1:0] i_x_hi8,
    output reg [46-1:0] o_a0_lo
);

// o_a0_lo is the lowest 46 bits of the argument a0,
// which is in the taylor expression:
// a0 - a1 * (x - a) + a2 * (x - a)^2 - a3 * (x - a)^3 + a4 * (x - a)^4 - a5 * (x - a)^5 + a6 * (x - a)^6
always @(*) begin: blk_o_a0_lo
    case(i_x_hi8)
8'd0: o_a0_lo = 46'h155a31ed6df5; // lowest 46 bits of a0:      55'h5a555a31ed6df5
8'd1: o_a0_lo = 46'h3be468033447; // lowest 46 bits of a0:      55'h59fbe468033447
8'd2: o_a0_lo = 46'h23765d082498; // lowest 46 bits of a0:      55'h59a3765d082498
8'd3: o_a0_lo = 46'hc0b0ae63f5e; // lowest 46 bits of a0:       55'h594c0b0ae63f5e
8'd4: o_a0_lo = 46'h359d8d90e84b; // lowest 46 bits of a0:      55'h58f59d8d90e84b
8'd5: o_a0_lo = 46'h202921dea28e; // lowest 46 bits of a0:      55'h58a02921dea28e
8'd6: o_a0_lo = 46'hba9246edb5e; // lowest 46 bits of a0:       55'h584ba9246edb5e
8'd7: o_a0_lo = 46'h3819109b2e67; // lowest 46 bits of a0:      55'h57f819109b2e67
8'd8: o_a0_lo = 46'h25747f739811; // lowest 46 bits of a0:      55'h57a5747f739811
8'd9: o_a0_lo = 46'h13b726c510ff; // lowest 46 bits of a0:      55'h5753b726c510ff
8'd10: o_a0_lo = 46'h2dcd82a1588; // lowest 46 bits of a0:      55'h5702dcd82a1588
8'd11: o_a0_lo = 46'h32e18024a29a; // lowest 46 bits of a0:     55'h56b2e18024a29a
8'd12: o_a0_lo = 46'h23c1254137c4; // lowest 46 bits of a0:     55'h5663c1254137c4
8'd13: o_a0_lo = 46'h1577e742742d; // lowest 46 bits of a0:     55'h561577e742742d
8'd14: o_a0_lo = 46'h801fe54e9ca; // lowest 46 bits of a0:      55'h55c801fe54e9ca
8'd15: o_a0_lo = 46'h3b5bba4ac76c; // lowest 46 bits of a0:     55'h557b5bba4ac76c
8'd16: o_a0_lo = 46'h2f8181deff3e; // lowest 46 bits of a0:     55'h552f8181deff3e
8'd17: o_a0_lo = 46'h246fd1ff93ef; // lowest 46 bits of a0:     55'h54e46fd1ff93ef
8'd18: o_a0_lo = 46'h1a233d1ebb20; // lowest 46 bits of a0:     55'h549a233d1ebb20
8'd19: o_a0_lo = 46'h10986a8a87f0; // lowest 46 bits of a0:     55'h5450986a8a87f0
8'd20: o_a0_lo = 46'h7cc15cad447; // lowest 46 bits of a0:      55'h5407cc15cad447
8'd21: o_a0_lo = 46'h3fbb0e052344; // lowest 46 bits of a0:     55'h53bfbb0e052344
8'd22: o_a0_lo = 46'h386235663aa9; // lowest 46 bits of a0:     55'h53786235663aa9
8'd23: o_a0_lo = 46'h31be8091345f; // lowest 46 bits of a0:     55'h5331be8091345f
8'd24: o_a0_lo = 46'h2bccf613cc59; // lowest 46 bits of a0:     55'h52ebccf613cc59
8'd25: o_a0_lo = 46'h268aaddfb1e5; // lowest 46 bits of a0:     55'h52a68aaddfb1e5
8'd26: o_a0_lo = 46'h21f4d0c8a673; // lowest 46 bits of a0:     55'h5261f4d0c8a673
8'd27: o_a0_lo = 46'h1e089807363c; // lowest 46 bits of a0:     55'h521e089807363c
8'd28: o_a0_lo = 46'h1ac34cbfd9dd; // lowest 46 bits of a0:     55'h51dac34cbfd9dd
8'd29: o_a0_lo = 46'h1822478e5230; // lowest 46 bits of a0:     55'h519822478e5230
8'd30: o_a0_lo = 46'h1622f01511f7; // lowest 46 bits of a0:     55'h515622f01511f7
8'd31: o_a0_lo = 46'h14c2bc908af4; // lowest 46 bits of a0:     55'h5114c2bc908af4
8'd32: o_a0_lo = 46'h13ff316e3618; // lowest 46 bits of a0:     55'h50d3ff316e3618
8'd33: o_a0_lo = 46'h13d5e0e7303d; // lowest 46 bits of a0:     55'h5093d5e0e7303d
8'd34: o_a0_lo = 46'h14446a9e46bf; // lowest 46 bits of a0:     55'h5054446a9e46bf
8'd35: o_a0_lo = 46'h15487b4150e3; // lowest 46 bits of a0:     55'h5015487b4150e3
8'd36: o_a0_lo = 46'h16dfcc2db4a0; // lowest 46 bits of a0:     55'h4fd6dfcc2db4a0
8'd37: o_a0_lo = 46'h19082317f6e1; // lowest 46 bits of a0:     55'h4f99082317f6e1
8'd38: o_a0_lo = 46'h1bbf51b638c2; // lowest 46 bits of a0:     55'h4f5bbf51b638c2
8'd39: o_a0_lo = 46'h1f03356d84b4; // lowest 46 bits of a0:     55'h4f1f03356d84b4
8'd40: o_a0_lo = 46'h22d1b701cfad; // lowest 46 bits of a0:     55'h4ee2d1b701cfad
8'd41: o_a0_lo = 46'h2728ca4893da; // lowest 46 bits of a0:     55'h4ea728ca4893da
8'd42: o_a0_lo = 46'h2c066dddeb65; // lowest 46 bits of a0:     55'h4e6c066dddeb65
8'd43: o_a0_lo = 46'h3168aadc1308; // lowest 46 bits of a0:     55'h4e3168aadc1308
8'd44: o_a0_lo = 46'h374d94953d24; // lowest 46 bits of a0:     55'h4df74d94953d24
8'd45: o_a0_lo = 46'h3db3484f9f36; // lowest 46 bits of a0:     55'h4dbdb3484f9f36
8'd46: o_a0_lo = 46'h497ed03a44d; // lowest 46 bits of a0:      55'h4d8497ed03a44d
8'd47: o_a0_lo = 46'hbf9b31c3032; // lowest 46 bits of a0:      55'h4d4bf9b31c3032
8'd48: o_a0_lo = 46'h13d6d438dfc5; // lowest 46 bits of a0:     55'h4d13d6d438dfc5
8'd49: o_a0_lo = 46'h1c2d92f233ce; // lowest 46 bits of a0:     55'h4cdc2d92f233ce
8'd50: o_a0_lo = 46'h24fc3a9f947b; // lowest 46 bits of a0:     55'h4ca4fc3a9f947b
8'd51: o_a0_lo = 46'h2e411f1f1c56; // lowest 46 bits of a0:     55'h4c6e411f1f1c56
8'd52: o_a0_lo = 46'h37fa9c9f1a45; // lowest 46 bits of a0:     55'h4c37fa9c9f1a45
8'd53: o_a0_lo = 46'h22717693ae3; // lowest 46 bits of a0:      55'h4c022717693ae3
8'd54: o_a0_lo = 46'hcc4fbaf4a07; // lowest 46 bits of a0:      55'h4bccc4fbaf4a07
8'd55: o_a0_lo = 46'h17d2bd597e10; // lowest 46 bits of a0:     55'h4b97d2bd597e10
8'd56: o_a0_lo = 46'h234ed7d63f05; // lowest 46 bits of a0:     55'h4b634ed7d63f05
8'd57: o_a0_lo = 46'h2f37cdeb5c35; // lowest 46 bits of a0:     55'h4b2f37cdeb5c35
8'd58: o_a0_lo = 46'h3b8c2988a39d; // lowest 46 bits of a0:     55'h4afb8c2988a39d
8'd59: o_a0_lo = 46'h84a7b9bceb5; // lowest 46 bits of a0:      55'h4ac84a7b9bceb5
8'd60: o_a0_lo = 46'h15715be5b8e8; // lowest 46 bits of a0:     55'h4a95715be5b8e8
8'd61: o_a0_lo = 46'h22ff68d0d469; // lowest 46 bits of a0:     55'h4a62ff68d0d469
8'd62: o_a0_lo = 46'h30f34748d271; // lowest 46 bits of a0:     55'h4a30f34748d271
8'd63: o_a0_lo = 46'h3f4ba2937489; // lowest 46 bits of a0:     55'h49ff4ba2937489
8'd64: o_a0_lo = 46'he072c2a7cca; // lowest 46 bits of a0:      55'h49ce072c2a7cca
8'd65: o_a0_lo = 46'h1d249b96b369; // lowest 46 bits of a0:     55'h499d249b96b369
8'd66: o_a0_lo = 46'h2ca2ae4bf84f; // lowest 46 bits of a0:     55'h496ca2ae4bf84f
8'd67: o_a0_lo = 46'h3c80278657d0; // lowest 46 bits of a0:     55'h493c80278657d0
8'd68: o_a0_lo = 46'hcbbd02819e6; // lowest 46 bits of a0:      55'h490cbbd02819e6
8'd69: o_a0_lo = 46'h1d547698c3b1; // lowest 46 bits of a0:     55'h48dd547698c3b1
8'd70: o_a0_lo = 46'h2e48eea50352; // lowest 46 bits of a0:     55'h48ae48eea50352
8'd71: o_a0_lo = 46'h3f98115f7e6f; // lowest 46 bits of a0:     55'h487f98115f7e6f
8'd72: o_a0_lo = 46'h1140bd027c0c; // lowest 46 bits of a0:     55'h485140bd027c0c
8'd73: o_a0_lo = 46'h2341d4d262a9; // lowest 46 bits of a0:     55'h482341d4d262a9
8'd74: o_a0_lo = 46'h359a410103c3; // lowest 46 bits of a0:     55'h47f59a410103c3
8'd75: o_a0_lo = 46'h848ee91ae34; // lowest 46 bits of a0:      55'h47c848ee91ae34
8'd76: o_a0_lo = 46'h1b4ccf3e0119; // lowest 46 bits of a0:     55'h479b4ccf3e0119
8'd77: o_a0_lo = 46'h2ea4d95b7929; // lowest 46 bits of a0:     55'h476ea4d95b7929
8'd78: o_a0_lo = 46'h25007c1b291; // lowest 46 bits of a0:      55'h47425007c1b291
8'd79: o_a0_lo = 46'h164d59b159ba; // lowest 46 bits of a0:     55'h47164d59b159ba
8'd80: o_a0_lo = 46'h2a9bd2bbc57d; // lowest 46 bits of a0:     55'h46ea9bd2bbc57d
8'd81: o_a0_lo = 46'h3f3a7aab3583; // lowest 46 bits of a0:     55'h46bf3a7aab3583
8'd82: o_a0_lo = 46'h14285d6bafb5; // lowest 46 bits of a0:     55'h4694285d6bafb5
8'd83: o_a0_lo = 46'h29648af477e9; // lowest 46 bits of a0:     55'h4669648af477e9
8'd84: o_a0_lo = 46'h3eee17321d02; // lowest 46 bits of a0:     55'h463eee17321d02
8'd85: o_a0_lo = 46'h14c419f116fd; // lowest 46 bits of a0:     55'h4614c419f116fd
8'd86: o_a0_lo = 46'h2ae5aec8f185; // lowest 46 bits of a0:     55'h45eae5aec8f185
8'd87: o_a0_lo = 46'h151f507fec9; // lowest 46 bits of a0:      55'h45c151f507fec9
8'd88: o_a0_lo = 46'h18080f9f8e8b; // lowest 46 bits of a0:     55'h4598080f9f8e8b
8'd89: o_a0_lo = 46'h2f072510a55d; // lowest 46 bits of a0:     55'h456f072510a55d
8'd90: o_a0_lo = 46'h64e5f593053; // lowest 46 bits of a0:      55'h45464e5f593053
8'd91: o_a0_lo = 46'h1ddcebe1b160; // lowest 46 bits of a0:     55'h451ddcebe1b160
8'd92: o_a0_lo = 46'h35b1fb6b60e9; // lowest 46 bits of a0:     55'h44f5b1fb6b60e9
8'd93: o_a0_lo = 46'hdccc1fec106; // lowest 46 bits of a0:      55'h44cdccc1fec106
8'd94: o_a0_lo = 46'h262c76da9f29; // lowest 46 bits of a0:     55'h44a62c76da9f29
8'd95: o_a0_lo = 46'h3ed0546380f4; // lowest 46 bits of a0:     55'h447ed0546380f4
8'd96: o_a0_lo = 46'h17b79813791f; // lowest 46 bits of a0:     55'h4457b79813791f
8'd97: o_a0_lo = 46'h30e1826a6171; // lowest 46 bits of a0:     55'h4430e1826a6171
8'd98: o_a0_lo = 46'ha4d56de76dd; // lowest 46 bits of a0:      55'h440a4d56de76dd
8'd99: o_a0_lo = 46'h23fa5bcd5502; // lowest 46 bits of a0:     55'h43e3fa5bcd5502
8'd100: o_a0_lo = 46'h3de7da6d4e4a; // lowest 46 bits of a0:    55'h43bde7da6d4e4a
8'd101: o_a0_lo = 46'h18151ebf1e0b; // lowest 46 bits of a0:    55'h4398151ebf1e0b
8'd102: o_a0_lo = 46'h3281777ff223; // lowest 46 bits of a0:    55'h437281777ff223
8'd103: o_a0_lo = 46'hd2c361bc99a; // lowest 46 bits of a0:     55'h434d2c361bc99a
8'd104: o_a0_lo = 46'h2814aea025de; // lowest 46 bits of a0:    55'h432814aea025de
8'd105: o_a0_lo = 46'h33a37af0c5e; // lowest 46 bits of a0:     55'h43033a37af0c5e
8'd106: o_a0_lo = 46'h1e9c2a725637; // lowest 46 bits of a0:    55'h42de9c2a725637
8'd107: o_a0_lo = 46'h3a39e28f4bd6; // lowest 46 bits of a0:    55'h42ba39e28f4bd6
8'd108: o_a0_lo = 46'h1612be1a8a78; // lowest 46 bits of a0:    55'h429612be1a8a78
8'd109: o_a0_lo = 46'h32261d8c3173; // lowest 46 bits of a0:    55'h4272261d8c3173
8'd110: o_a0_lo = 46'he7363b4556e; // lowest 46 bits of a0:     55'h424e7363b4556e
8'd111: o_a0_lo = 46'h2af9f5afb789; // lowest 46 bits of a0:    55'h422af9f5afb789
8'd112: o_a0_lo = 46'h7b93adcbea4; // lowest 46 bits of a0:     55'h4207b93adcbea4
8'd113: o_a0_lo = 46'h24b09cd0b10a; // lowest 46 bits of a0:    55'h41e4b09cd0b10a
8'd114: o_a0_lo = 46'h1df874d2cb4; // lowest 46 bits of a0:     55'h41c1df874d2cb4
8'd115: o_a0_lo = 46'h1f456835dc83; // lowest 46 bits of a0:    55'h419f456835dc83
8'd116: o_a0_lo = 46'h3ce1af8668ce; // lowest 46 bits of a0:    55'h417ce1af8668ce
8'd117: o_a0_lo = 46'h1ab3cf48a1b2; // lowest 46 bits of a0:    55'h415ab3cf48a1b2
8'd118: o_a0_lo = 46'h38bb3b8ae19f; // lowest 46 bits of a0:    55'h4138bb3b8ae19f
8'd119: o_a0_lo = 46'h16f76a56a6a1; // lowest 46 bits of a0:    55'h4116f76a56a6a1
8'd120: o_a0_lo = 46'h3567d3a76104; // lowest 46 bits of a0:    55'h40f567d3a76104
8'd121: o_a0_lo = 46'h140bf16175dc; // lowest 46 bits of a0:    55'h40d40bf16175dc
8'd122: o_a0_lo = 46'h32e33f49742a; // lowest 46 bits of a0:    55'h40b2e33f49742a
8'd123: o_a0_lo = 46'h11ed3afb7b41; // lowest 46 bits of a0:    55'h4091ed3afb7b41
8'd124: o_a0_lo = 46'h312963e2d133; // lowest 46 bits of a0:    55'h40712963e2d133
8'd125: o_a0_lo = 46'h10973b31a7fb; // lowest 46 bits of a0:    55'h4050973b31a7fb
8'd126: o_a0_lo = 46'h303643d9103f; // lowest 46 bits of a0:    55'h40303643d9103f
8'd127: o_a0_lo = 46'h10060281187e; // lowest 46 bits of a0:    55'h4010060281187e
8'd128: o_a0_lo = 46'h2fd822e09d; // lowest 46 bits of a0:      55'h7fc02fd822e09d
8'd129: o_a0_lo = 46'h1abd2f56ad7; // lowest 46 bits of a0:     55'h7f41abd2f56ad7
8'd130: o_a0_lo = 46'h49ccbf93d80; // lowest 46 bits of a0:     55'h7ec49ccbf93d80
8'd131: o_a0_lo = 46'h8fba86180f7; // lowest 46 bits of a0:     55'h7e48fba86180f7
8'd132: o_a0_lo = 46'hec17d83f4e5; // lowest 46 bits of a0:     55'h7dcec17d83f4e5
8'd133: o_a0_lo = 46'h15e78f38c90e; // lowest 46 bits of a0:    55'h7d55e78f38c90e
8'd134: o_a0_lo = 46'h1e674e4b82d0; // lowest 46 bits of a0:    55'h7cde674e4b82d0
8'd135: o_a0_lo = 46'h283a56fc1d72; // lowest 46 bits of a0:    55'h7c683a56fc1d72
8'd136: o_a0_lo = 46'h335a6f8f9f2a; // lowest 46 bits of a0:    55'h7bf35a6f8f9f2a
8'd137: o_a0_lo = 46'h3fc186ef6759; // lowest 46 bits of a0:    55'h7b7fc186ef6759
8'd138: o_a0_lo = 46'hd69b35684e0; // lowest 46 bits of a0:     55'h7b0d69b35684e0
8'd139: o_a0_lo = 46'h1c4d310c6cce; // lowest 46 bits of a0:    55'h7a9c4d310c6cce
8'd140: o_a0_lo = 46'h2c66612c72ba; // lowest 46 bits of a0:    55'h7a2c66612c72ba
8'd141: o_a0_lo = 46'h3dafc8796c7e; // lowest 46 bits of a0:    55'h79bdafc8796c7e
8'd142: o_a0_lo = 46'h10240e3cf2fe; // lowest 46 bits of a0:    55'h7950240e3cf2fe
8'd143: o_a0_lo = 46'h23bdfb31b909; // lowest 46 bits of a0:    55'h78e3bdfb31b909
8'd144: o_a0_lo = 46'h387878787878; // lowest 46 bits of a0:    55'h78787878787878
8'd145: o_a0_lo = 46'he4e8e96fc46; // lowest 46 bits of a0:     55'h780e4e8e96fc46
8'd146: o_a0_lo = 46'h253b6480d47a; // lowest 46 bits of a0:    55'h77a53b6480d47a
8'd147: o_a0_lo = 46'h3d3a3ea946d1; // lowest 46 bits of a0:    55'h773d3a3ea946d1
8'd148: o_a0_lo = 46'h16467e1e145d; // lowest 46 bits of a0:    55'h76d6467e1e145d
8'd149: o_a0_lo = 46'h305b9faab1a9; // lowest 46 bits of a0:    55'h76705b9faab1a9
8'd150: o_a0_lo = 46'hb753b0393db; // lowest 46 bits of a0:     55'h760b753b0393db
8'd151: o_a0_lo = 46'h278f01f939e3; // lowest 46 bits of a0:    55'h75a78f01f939e3
8'd152: o_a0_lo = 46'h4a4bfb29d2e; // lowest 46 bits of a0:     55'h7544a4bfb29d2e
8'd153: o_a0_lo = 46'h22b257eeb977; // lowest 46 bits of a0:    55'h74e2b257eeb977
8'd154: o_a0_lo = 46'h1b3c64cdf3d; // lowest 46 bits of a0:     55'h7481b3c64cdf3d
8'd155: o_a0_lo = 46'h21a51d9b880f; // lowest 46 bits of a0:    55'h7421a51d9b880f
8'd156: o_a0_lo = 46'h282872d675e; // lowest 46 bits of a0:     55'h73c282872d675e
8'd157: o_a0_lo = 46'h2448423475e2; // lowest 46 bits of a0:    55'h736448423475e2
8'd158: o_a0_lo = 46'h6f2a322b8a5; // lowest 46 bits of a0:     55'h7306f2a322b8a5
8'd159: o_a0_lo = 46'h2a7e131087d6; // lowest 46 bits of a0:    55'h72aa7e131087d6
8'd160: o_a0_lo = 46'hee70f281c4a; // lowest 46 bits of a0:     55'h724ee70f281c4a
8'd161: o_a0_lo = 46'h342a28162d33; // lowest 46 bits of a0:    55'h71f42a28162d33
8'd162: o_a0_lo = 46'h1a44017f6a25; // lowest 46 bits of a0:    55'h719a44017f6a25
8'd163: o_a0_lo = 46'h131517a9fd5; // lowest 46 bits of a0:     55'h714131517a9fd5
8'd164: o_a0_lo = 46'h28eee00f5858; // lowest 46 bits of a0:    55'h70e8eee00f5858
8'd165: o_a0_lo = 46'h117986b8c9b4; // lowest 46 bits of a0:    55'h70917986b8c9b4
8'd166: o_a0_lo = 46'h3ace2fece7aa; // lowest 46 bits of a0:    55'h703ace2fece7aa
8'd167: o_a0_lo = 46'h24e9d6a76f94; // lowest 46 bits of a0:    55'h6fe4e9d6a76f94
8'd168: o_a0_lo = 46'hfc985f8c700; // lowest 46 bits of a0:     55'h6f8fc985f8c700
8'd169: o_a0_lo = 46'h3b6a58988772; // lowest 46 bits of a0:    55'h6f3b6a58988772
8'd170: o_a0_lo = 46'h27c9787b9355; // lowest 46 bits of a0:    55'h6ee7c9787b9355
8'd171: o_a0_lo = 46'h14e41e6d91d5; // lowest 46 bits of a0:    55'h6e94e41e6d91d5
8'd172: o_a0_lo = 46'h2b791adb0a7; // lowest 46 bits of a0:     55'h6e42b791adb0a7
8'd173: o_a0_lo = 46'h3141278e8c6e; // lowest 46 bits of a0:    55'h6df141278e8c6e
8'd174: o_a0_lo = 46'h207e4319218d; // lowest 46 bits of a0:    55'h6da07e4319218d
8'd175: o_a0_lo = 46'h106c54b2a8a6; // lowest 46 bits of a0:    55'h6d506c54b2a8a6
8'd176: o_a0_lo = 46'h108d9c54333; // lowest 46 bits of a0:     55'h6d0108d9c54333
8'd177: o_a0_lo = 46'h32515c6b5dce; // lowest 46 bits of a0:    55'h6cb2515c6b5dce
8'd178: o_a0_lo = 46'h2443731daeda; // lowest 46 bits of a0:    55'h6c6443731daeda
8'd179: o_a0_lo = 46'h16dcc063b958; // lowest 46 bits of a0:    55'h6c16dcc063b958
8'd180: o_a0_lo = 46'ha1af286bca2; // lowest 46 bits of a0:     55'h6bca1af286bca2
8'd181: o_a0_lo = 46'h3dfbc346fad3; // lowest 46 bits of a0:    55'h6b7dfbc346fad3
8'd182: o_a0_lo = 46'h327cf793407d; // lowest 46 bits of a0:    55'h6b327cf793407d
8'd183: o_a0_lo = 46'h279c5f42992d; // lowest 46 bits of a0:    55'h6ae79c5f42992d
8'd184: o_a0_lo = 46'h1d57d4d01d24; // lowest 46 bits of a0:    55'h6a9d57d4d01d24
8'd185: o_a0_lo = 46'h13ad3d18c562; // lowest 46 bits of a0:    55'h6a53ad3d18c562
8'd186: o_a0_lo = 46'ha9a871b33f1; // lowest 46 bits of a0:     55'h6a0a9a871b33f1
8'd187: o_a0_lo = 46'h21dabb95f10; // lowest 46 bits of a0:     55'h69c21dabb95f10
8'd188: o_a0_lo = 46'h3a34ad7c0e93; // lowest 46 bits of a0:    55'h697a34ad7c0e93
8'd189: o_a0_lo = 46'h32dd98581b76; // lowest 46 bits of a0:    55'h6932dd98581b76
8'd190: o_a0_lo = 46'h2c168175623d; // lowest 46 bits of a0:    55'h68ec168175623d
8'd191: o_a0_lo = 46'h25dd86f7595e; // lowest 46 bits of a0:    55'h68a5dd86f7595e
8'd192: o_a0_lo = 46'h2030cfc73d83; // lowest 46 bits of a0:    55'h686030cfc73d83
8'd193: o_a0_lo = 46'h1b0e8b5fc5f5; // lowest 46 bits of a0:    55'h681b0e8b5fc5f5
8'd194: o_a0_lo = 46'h1674f19a541c; // lowest 46 bits of a0:    55'h67d674f19a541c
8'd195: o_a0_lo = 46'h1262427d9168; // lowest 46 bits of a0:    55'h679262427d9168
8'd196: o_a0_lo = 46'hed4c60d6f92; // lowest 46 bits of a0:     55'h674ed4c60d6f92
8'd197: o_a0_lo = 46'hbcacc1c7f74; // lowest 46 bits of a0:     55'h670bcacc1c7f74
8'd198: o_a0_lo = 46'h942ac1e9348; // lowest 46 bits of a0:     55'h66c942ac1e9348
8'd199: o_a0_lo = 46'h73ac4fca183; // lowest 46 bits of a0:     55'h66873ac4fca183
8'd200: o_a0_lo = 46'h5b17ce9ddd1; // lowest 46 bits of a0:     55'h6645b17ce9ddd1
8'd201: o_a0_lo = 46'h4a54139fe45; // lowest 46 bits of a0:     55'h6604a54139fe45
8'd202: o_a0_lo = 46'h4148638a304; // lowest 46 bits of a0:     55'h65c4148638a304
8'd203: o_a0_lo = 46'h3fdc701d730; // lowest 46 bits of a0:     55'h6583fdc701d730
8'd204: o_a0_lo = 46'h45f855ba20d; // lowest 46 bits of a0:     55'h65445f855ba20d
8'd205: o_a0_lo = 46'h53849909fdb; // lowest 46 bits of a0:     55'h65053849909fdb
8'd206: o_a0_lo = 46'h686a24b99fa; // lowest 46 bits of a0:     55'h64c686a24b99fa
8'd207: o_a0_lo = 46'h84924741669; // lowest 46 bits of a0:     55'h64884924741669
8'd208: o_a0_lo = 46'ha7e6b0bd6e1; // lowest 46 bits of a0:     55'h644a7e6b0bd6e1
8'd209: o_a0_lo = 46'hd25170d401e; // lowest 46 bits of a0:     55'h640d25170d401e
8'd210: o_a0_lo = 46'h103bcf4aa21a; // lowest 46 bits of a0:    55'h63d03bcf4aa21a
8'd211: o_a0_lo = 46'h13c1404e5a6a; // lowest 46 bits of a0:    55'h6393c1404e5a6a
8'd212: o_a0_lo = 46'h17b41c3bc9f4; // lowest 46 bits of a0:    55'h6357b41c3bc9f4
8'd213: o_a0_lo = 46'h1c131ab11796; // lowest 46 bits of a0:    55'h631c131ab11796
8'd214: o_a0_lo = 46'h20dcf8a9b990; // lowest 46 bits of a0:    55'h62e0dcf8a9b990
8'd215: o_a0_lo = 46'h26107861bfa1; // lowest 46 bits of a0:    55'h62a6107861bfa1
8'd216: o_a0_lo = 46'h2bac6139d816; // lowest 46 bits of a0:    55'h626bac6139d816
8'd217: o_a0_lo = 46'h31af7f9c0a31; // lowest 46 bits of a0:    55'h6231af7f9c0a31
8'd218: o_a0_lo = 46'h3818a4e1207d; // lowest 46 bits of a0:    55'h61f818a4e1207d
8'd219: o_a0_lo = 46'h3ee6a736bde2; // lowest 46 bits of a0:    55'h61bee6a736bde2
8'd220: o_a0_lo = 46'h61861861862; // lowest 46 bits of a0:     55'h61861861861862
8'd221: o_a0_lo = 46'hdacb35b54ab; // lowest 46 bits of a0:     55'h614dacb35b54ab
8'd222: o_a0_lo = 46'h15a280cd7dc8; // lowest 46 bits of a0:    55'h6115a280cd7dc8
8'd223: o_a0_lo = 46'h1df8b267145f; // lowest 46 bits of a0:    55'h60ddf8b267145f
8'd224: o_a0_lo = 46'h26ae350f311f; // lowest 46 bits of a0:    55'h60a6ae350f311f
8'd225: o_a0_lo = 46'h2fc1f9f3361e; // lowest 46 bits of a0:    55'h606fc1f9f3361e
8'd226: o_a0_lo = 46'h3932f6710b05; // lowest 46 bits of a0:    55'h603932f6710b05
8'd227: o_a0_lo = 46'h3002401e01a; // lowest 46 bits of a0:     55'h6003002401e01a
8'd228: o_a0_lo = 46'hd288025744c; // lowest 46 bits of a0:     55'h5fcd288025744c
8'd229: o_a0_lo = 46'h17ab0c4dda88; // lowest 46 bits of a0:    55'h5f97ab0c4dda88
8'd230: o_a0_lo = 46'h2286cdcbbac7; // lowest 46 bits of a0:    55'h5f6286cdcbbac7
8'd231: o_a0_lo = 46'h2dbacdbb0b57; // lowest 46 bits of a0:    55'h5f2dbacdbb0b57
8'd232: o_a0_lo = 46'h394618f03ef5; // lowest 46 bits of a0:    55'h5ef94618f03ef5
8'd233: o_a0_lo = 46'h527bfe5e493; // lowest 46 bits of a0:     55'h5ec527bfe5e493
8'd234: o_a0_lo = 46'h115ed6aab584; // lowest 46 bits of a0:    55'h5e915ed6aab584
8'd235: o_a0_lo = 46'h1dea74d00f18; // lowest 46 bits of a0:    55'h5e5dea74d00f18
8'd236: o_a0_lo = 46'h2ac9b558d4a0; // lowest 46 bits of a0:    55'h5e2ac9b558d4a0
8'd237: o_a0_lo = 46'h37fbb6a8b716; // lowest 46 bits of a0:    55'h5df7fbb6a8b716
8'd238: o_a0_lo = 46'h57f9a73df83; // lowest 46 bits of a0:     55'h5dc57f9a73df83
8'd239: o_a0_lo = 46'h135485aef99a; // lowest 46 bits of a0:    55'h5d935485aef99a
8'd240: o_a0_lo = 46'h2179a07f9bc6; // lowest 46 bits of a0:    55'h5d6179a07f9bc6
8'd241: o_a0_lo = 46'h2fee162d0a4d; // lowest 46 bits of a0:    55'h5d2fee162d0a4d
8'd242: o_a0_lo = 46'h3eb1151152f1; // lowest 46 bits of a0:    55'h5cfeb1151152f1
8'd243: o_a0_lo = 46'hdc1ce8abed6; // lowest 46 bits of a0:     55'h5ccdc1ce8abed6
8'd244: o_a0_lo = 46'h1d1f76ed9842; // lowest 46 bits of a0:    55'h5c9d1f76ed9842
8'd245: o_a0_lo = 46'h2cc945764212; // lowest 46 bits of a0:    55'h5c6cc945764212
8'd246: o_a0_lo = 46'h3cbe743b9eb3; // lowest 46 bits of a0:    55'h5c3cbe743b9eb3
8'd247: o_a0_lo = 46'hcfe4021c48f; // lowest 46 bits of a0:     55'h5c0cfe4021c48f
8'd248: o_a0_lo = 46'h1d87e8ccfdda; // lowest 46 bits of a0:    55'h5bdd87e8ccfdda
8'd249: o_a0_lo = 46'h2e5ab09511d8; // lowest 46 bits of a0:    55'h5bae5ab09511d8
8'd250: o_a0_lo = 46'h3f75dc78d5a7; // lowest 46 bits of a0:    55'h5b7f75dc78d5a7
8'd251: o_a0_lo = 46'h10d8b41202b4; // lowest 46 bits of a0:    55'h5b50d8b41202b4
8'd252: o_a0_lo = 46'h228281895121; // lowest 46 bits of a0:    55'h5b228281895121
8'd253: o_a0_lo = 46'h3472918ad43d; // lowest 46 bits of a0:    55'h5af472918ad43d
8'd254: o_a0_lo = 46'h6a8333a977f; // lowest 46 bits of a0:     55'h5ac6a8333a977f
default: o_a0_lo = 46'h1922b8297a4b; // lowest 46 bits of a0:    55'h5a9922b8297a4b
    endcase
end

endmodule