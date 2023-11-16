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
// Filename:ipsxe_floating_point_exp_64_axi_v1_0.v
// Function: p=e^z
//           zsize:z < 8
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_exp_64_axi_v1_0 #(
    parameter FLOAT_EXP_WIDTH = 11,
    parameter FLOAT_FRAC_WIDTH = 53,
    parameter DATA_WIDTH = 53,
    parameter DATA_WIDTH_CUT = 53,
    parameter ITERATION_NUM = 1,
    parameter INPUT_RANGE_ADD = 0,
    parameter LATENCY_CONFIG_OUTSIDE = 3 //latency clk = LATENCY_CONFIG-1
)
(
    input i_clk,
    input i_aclken,
    input i_rst_n, //aresetn
    input [FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1:0] i_data_float, //s_axis_a_tdata
    input i_valid, //s_axis_a_tvalid
    output [FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1:0] o_exp_float, //m_axis_result_tdata
    output o_overflow, 
    output o_underflow,
    output o_valid //m_axis_result_tvalid
);

localparam LATENCY_CONFIG = 5;
//look up table 
wire [52:0] bm_exp_rom [354:0];
assign bm_exp_rom[0] = 53'd4503599627370496;
assign bm_exp_rom[1] = 53'd4512404315922433;
assign bm_exp_rom[2] = 53'd4521226217936247;
assign bm_exp_rom[3] = 53'd4530065367064835;
assign bm_exp_rom[4] = 53'd4538921797026886;
assign bm_exp_rom[5] = 53'd4547795541607008;
assign bm_exp_rom[6] = 53'd4556686634655863;
assign bm_exp_rom[7] = 53'd4565595110090288;
assign bm_exp_rom[8] = 53'd4574521001893433;
assign bm_exp_rom[9] = 53'd4583464344114883;
assign bm_exp_rom[10] = 53'd4592425170870791;
assign bm_exp_rom[11] = 53'd4601403516344010;
assign bm_exp_rom[12] = 53'd4610399414784221;
assign bm_exp_rom[13] = 53'd4619412900508064;
assign bm_exp_rom[14] = 53'd4628444007899269;
assign bm_exp_rom[15] = 53'd4637492771408788;
assign bm_exp_rom[16] = 53'd4646559225554925;
assign bm_exp_rom[17] = 53'd4655643404923468;
assign bm_exp_rom[18] = 53'd4664745344167825;
assign bm_exp_rom[19] = 53'd4673865078009147;
assign bm_exp_rom[20] = 53'd4683002641236470;
assign bm_exp_rom[21] = 53'd4692158068706842;
assign bm_exp_rom[22] = 53'd4701331395345458;
assign bm_exp_rom[23] = 53'd4710522656145795;
assign bm_exp_rom[24] = 53'd4719731886169740;
assign bm_exp_rom[25] = 53'd4728959120547729;
assign bm_exp_rom[26] = 53'd4738204394478879;
assign bm_exp_rom[27] = 53'd4747467743231122;
assign bm_exp_rom[28] = 53'd4756749202141341;
assign bm_exp_rom[29] = 53'd4766048806615503;
assign bm_exp_rom[30] = 53'd4775366592128795;
assign bm_exp_rom[31] = 53'd4784702594225760;
assign bm_exp_rom[32] = 53'd4794056848520429;
assign bm_exp_rom[33] = 53'd4803429390696464;
assign bm_exp_rom[34] = 53'd4812820256507286;
assign bm_exp_rom[35] = 53'd4822229481776216;
assign bm_exp_rom[36] = 53'd4831657102396613;
assign bm_exp_rom[37] = 53'd4841103154332006;
assign bm_exp_rom[38] = 53'd4850567673616234;
assign bm_exp_rom[39] = 53'd4860050696353586;
assign bm_exp_rom[40] = 53'd4869552258718934;
assign bm_exp_rom[41] = 53'd4879072396957873;
assign bm_exp_rom[42] = 53'd4888611147386861;
assign bm_exp_rom[43] = 53'd4898168546393353;
assign bm_exp_rom[44] = 53'd4907744630435945;
assign bm_exp_rom[45] = 53'd4917339436044511;
assign bm_exp_rom[46] = 53'd4926952999820341;
assign bm_exp_rom[47] = 53'd4936585358436282;
assign bm_exp_rom[48] = 53'd4946236548636877;
assign bm_exp_rom[49] = 53'd4955906607238508;
assign bm_exp_rom[50] = 53'd4965595571129532;
assign bm_exp_rom[51] = 53'd4975303477270425;
assign bm_exp_rom[52] = 53'd4985030362693922;
assign bm_exp_rom[53] = 53'd4994776264505158;
assign bm_exp_rom[54] = 53'd5004541219881809;
assign bm_exp_rom[55] = 53'd5014325266074236;
assign bm_exp_rom[56] = 53'd5024128440405625;
assign bm_exp_rom[57] = 53'd5033950780272131;
assign bm_exp_rom[58] = 53'd5043792323143018;
assign bm_exp_rom[59] = 53'd5053653106560804;
assign bm_exp_rom[60] = 53'd5063533168141406;
assign bm_exp_rom[61] = 53'd5073432545574280;
assign bm_exp_rom[62] = 53'd5083351276622564;
assign bm_exp_rom[63] = 53'd5093289399123229;
assign bm_exp_rom[64] = 53'd5103246950987213;
assign bm_exp_rom[65] = 53'd5113223970199576;
assign bm_exp_rom[66] = 53'd5123220494819637;
assign bm_exp_rom[67] = 53'd5133236562981123;
assign bm_exp_rom[68] = 53'd5143272212892315;
assign bm_exp_rom[69] = 53'd5153327482836191;
assign bm_exp_rom[70] = 53'd5163402411170574;
assign bm_exp_rom[71] = 53'd5173497036328277;
assign bm_exp_rom[72] = 53'd5183611396817252;
assign bm_exp_rom[73] = 53'd5193745531220735;
assign bm_exp_rom[74] = 53'd5203899478197392;
assign bm_exp_rom[75] = 53'd5214073276481470;
assign bm_exp_rom[76] = 53'd5224266964882941;
assign bm_exp_rom[77] = 53'd5234480582287654;
assign bm_exp_rom[78] = 53'd5244714167657478;
assign bm_exp_rom[79] = 53'd5254967760030457;
assign bm_exp_rom[80] = 53'd5265241398520953;
assign bm_exp_rom[81] = 53'd5275535122319800;
assign bm_exp_rom[82] = 53'd5285848970694451;
assign bm_exp_rom[83] = 53'd5296182982989126;
assign bm_exp_rom[84] = 53'd5306537198624967;
assign bm_exp_rom[85] = 53'd5316911657100185;
assign bm_exp_rom[86] = 53'd5327306397990210;
assign bm_exp_rom[87] = 53'd5337721460947845;
assign bm_exp_rom[88] = 53'd5348156885703415;
assign bm_exp_rom[89] = 53'd5358612712064918;
assign bm_exp_rom[90] = 53'd5369088979918180;
assign bm_exp_rom[91] = 53'd5379585729227003;
assign bm_exp_rom[92] = 53'd5390103000033321;
assign bm_exp_rom[93] = 53'd5400640832457351;
assign bm_exp_rom[94] = 53'd5411199266697747;
assign bm_exp_rom[95] = 53'd5421778343031751;
assign bm_exp_rom[96] = 53'd5432378101815349;
assign bm_exp_rom[97] = 53'd5442998583483426;
assign bm_exp_rom[98] = 53'd5453639828549917;
assign bm_exp_rom[99] = 53'd5464301877607963;
assign bm_exp_rom[100] = 53'd5474984771330066;
assign bm_exp_rom[101] = 53'd5485688550468245;
assign bm_exp_rom[102] = 53'd5496413255854190;
assign bm_exp_rom[103] = 53'd5507158928399418;
assign bm_exp_rom[104] = 53'd5517925609095430;
assign bm_exp_rom[105] = 53'd5528713339013867;
assign bm_exp_rom[106] = 53'd5539522159306664;
assign bm_exp_rom[107] = 53'd5550352111206213;
assign bm_exp_rom[108] = 53'd5561203236025514;
assign bm_exp_rom[109] = 53'd5572075575158338;
assign bm_exp_rom[110] = 53'd5582969170079379;
assign bm_exp_rom[111] = 53'd5593884062344417;
assign bm_exp_rom[112] = 53'd5604820293590476;
assign bm_exp_rom[113] = 53'd5615777905535979;
assign bm_exp_rom[114] = 53'd5626756939980914;
assign bm_exp_rom[115] = 53'd5637757438806984;
assign bm_exp_rom[116] = 53'd5648779443977778;
assign bm_exp_rom[117] = 53'd5659822997538921;
assign bm_exp_rom[118] = 53'd5670888141618240;
assign bm_exp_rom[119] = 53'd5681974918425923;
assign bm_exp_rom[120] = 53'd5693083370254681;
assign bm_exp_rom[121] = 53'd5704213539479908;
assign bm_exp_rom[122] = 53'd5715365468559845;
assign bm_exp_rom[123] = 53'd5726539200035737;
assign bm_exp_rom[124] = 53'd5737734776532001;
assign bm_exp_rom[125] = 53'd5748952240756386;
assign bm_exp_rom[126] = 53'd5760191635500136;
assign bm_exp_rom[127] = 53'd5771453003638152;
assign bm_exp_rom[128] = 53'd5782736388129158;
assign bm_exp_rom[129] = 53'd5794041832015865;
assign bm_exp_rom[130] = 53'd5805369378425132;
assign bm_exp_rom[131] = 53'd5816719070568132;
assign bm_exp_rom[132] = 53'd5828090951740519;
assign bm_exp_rom[133] = 53'd5839485065322592;
assign bm_exp_rom[134] = 53'd5850901454779456;
assign bm_exp_rom[135] = 53'd5862340163661198;
assign bm_exp_rom[136] = 53'd5873801235603040;
assign bm_exp_rom[137] = 53'd5885284714325518;
assign bm_exp_rom[138] = 53'd5896790643634640;
assign bm_exp_rom[139] = 53'd5908319067422056;
assign bm_exp_rom[140] = 53'd5919870029665229;
assign bm_exp_rom[141] = 53'd5931443574427595;
assign bm_exp_rom[142] = 53'd5943039745858739;
assign bm_exp_rom[143] = 53'd5954658588194558;
assign bm_exp_rom[144] = 53'd5966300145757431;
assign bm_exp_rom[145] = 53'd5977964462956392;
assign bm_exp_rom[146] = 53'd5989651584287293;
assign bm_exp_rom[147] = 53'd6001361554332978;
assign bm_exp_rom[148] = 53'd6013094417763452;
assign bm_exp_rom[149] = 53'd6024850219336051;
assign bm_exp_rom[150] = 53'd6036629003895613;
assign bm_exp_rom[151] = 53'd6048430816374651;
assign bm_exp_rom[152] = 53'd6060255701793520;
assign bm_exp_rom[153] = 53'd6072103705260593;
assign bm_exp_rom[154] = 53'd6083974871972430;
assign bm_exp_rom[155] = 53'd6095869247213953;
assign bm_exp_rom[156] = 53'd6107786876358617;
assign bm_exp_rom[157] = 53'd6119727804868585;
assign bm_exp_rom[158] = 53'd6131692078294897;
assign bm_exp_rom[159] = 53'd6143679742277649;
assign bm_exp_rom[160] = 53'd6155690842546165;
assign bm_exp_rom[161] = 53'd6167725424919171;
assign bm_exp_rom[162] = 53'd6179783535304970;
assign bm_exp_rom[163] = 53'd6191865219701618;
assign bm_exp_rom[164] = 53'd6203970524197096;
assign bm_exp_rom[165] = 53'd6216099494969493;
assign bm_exp_rom[166] = 53'd6228252178287174;
assign bm_exp_rom[167] = 53'd6240428620508962;
assign bm_exp_rom[168] = 53'd6252628868084312;
assign bm_exp_rom[169] = 53'd6264852967553491;
assign bm_exp_rom[170] = 53'd6277100965547752;
assign bm_exp_rom[171] = 53'd6289372908789514;
assign bm_exp_rom[172] = 53'd6301668844092540;
assign bm_exp_rom[173] = 53'd6313988818362117;
assign bm_exp_rom[174] = 53'd6326332878595231;
assign bm_exp_rom[175] = 53'd6338701071880750;
assign bm_exp_rom[176] = 53'd6351093445399603;
assign bm_exp_rom[177] = 53'd6363510046424957;
assign bm_exp_rom[178] = 53'd6375950922322401;
assign bm_exp_rom[179] = 53'd6388416120550127;
assign bm_exp_rom[180] = 53'd6400905688659107;
assign bm_exp_rom[181] = 53'd6413419674293276;
assign bm_exp_rom[182] = 53'd6425958125189718;
assign bm_exp_rom[183] = 53'd6438521089178841;
assign bm_exp_rom[184] = 53'd6451108614184566;
assign bm_exp_rom[185] = 53'd6463720748224504;
assign bm_exp_rom[186] = 53'd6476357539410145;
assign bm_exp_rom[187] = 53'd6489019035947036;
assign bm_exp_rom[188] = 53'd6501705286134969;
assign bm_exp_rom[189] = 53'd6514416338368164;
assign bm_exp_rom[190] = 53'd6527152241135451;
assign bm_exp_rom[191] = 53'd6539913043020460;
assign bm_exp_rom[192] = 53'd6552698792701802;
assign bm_exp_rom[193] = 53'd6565509538953258;
assign bm_exp_rom[194] = 53'd6578345330643961;
assign bm_exp_rom[195] = 53'd6591206216738586;
assign bm_exp_rom[196] = 53'd6604092246297537;
assign bm_exp_rom[197] = 53'd6617003468477130;
assign bm_exp_rom[198] = 53'd6629939932529785;
assign bm_exp_rom[199] = 53'd6642901687804211;
assign bm_exp_rom[200] = 53'd6655888783745598;
assign bm_exp_rom[201] = 53'd6668901269895799;
assign bm_exp_rom[202] = 53'd6681939195893527;
assign bm_exp_rom[203] = 53'd6695002611474537;
assign bm_exp_rom[204] = 53'd6708091566471821;
assign bm_exp_rom[205] = 53'd6721206110815796;
assign bm_exp_rom[206] = 53'd6734346294534495;
assign bm_exp_rom[207] = 53'd6747512167753755;
assign bm_exp_rom[208] = 53'd6760703780697414;
assign bm_exp_rom[209] = 53'd6773921183687497;
assign bm_exp_rom[210] = 53'd6787164427144412;
assign bm_exp_rom[211] = 53'd6800433561587138;
assign bm_exp_rom[212] = 53'd6813728637633424;
assign bm_exp_rom[213] = 53'd6827049705999975;
assign bm_exp_rom[214] = 53'd6840396817502651;
assign bm_exp_rom[215] = 53'd6853770023056657;
assign bm_exp_rom[216] = 53'd6867169373676741;
assign bm_exp_rom[217] = 53'd6880594920477385;
assign bm_exp_rom[218] = 53'd6894046714673002;
assign bm_exp_rom[219] = 53'd6907524807578130;
assign bm_exp_rom[220] = 53'd6921029250607630;
assign bm_exp_rom[221] = 53'd6934560095276881;
assign bm_exp_rom[222] = 53'd6948117393201975;
assign bm_exp_rom[223] = 53'd6961701196099916;
assign bm_exp_rom[224] = 53'd6975311555788816;
assign bm_exp_rom[225] = 53'd6988948524188093;
assign bm_exp_rom[226] = 53'd7002612153318670;
assign bm_exp_rom[227] = 53'd7016302495303173;
assign bm_exp_rom[228] = 53'd7030019602366127;
assign bm_exp_rom[229] = 53'd7043763526834161;
assign bm_exp_rom[230] = 53'd7057534321136203;
assign bm_exp_rom[231] = 53'd7071332037803679;
assign bm_exp_rom[232] = 53'd7085156729470720;
assign bm_exp_rom[233] = 53'd7099008448874355;
assign bm_exp_rom[234] = 53'd7112887248854717;
assign bm_exp_rom[235] = 53'd7126793182355243;
assign bm_exp_rom[236] = 53'd7140726302422878;
assign bm_exp_rom[237] = 53'd7154686662208272;
assign bm_exp_rom[238] = 53'd7168674314965989;
assign bm_exp_rom[239] = 53'd7182689314054706;
assign bm_exp_rom[240] = 53'd7196731712937420;
assign bm_exp_rom[241] = 53'd7210801565181648;
assign bm_exp_rom[242] = 53'd7224898924459634;
assign bm_exp_rom[243] = 53'd7239023844548552;
assign bm_exp_rom[244] = 53'd7253176379330715;
assign bm_exp_rom[245] = 53'd7267356582793775;
assign bm_exp_rom[246] = 53'd7281564509030932;
assign bm_exp_rom[247] = 53'd7295800212241141;
assign bm_exp_rom[248] = 53'd7310063746729318;
assign bm_exp_rom[249] = 53'd7324355166906546;
assign bm_exp_rom[250] = 53'd7338674527290283;
assign bm_exp_rom[251] = 53'd7353021882504572;
assign bm_exp_rom[252] = 53'd7367397287280248;
assign bm_exp_rom[253] = 53'd7381800796455144;
assign bm_exp_rom[254] = 53'd7396232464974305;
assign bm_exp_rom[255] = 53'd7410692347890195;
assign bm_exp_rom[256] = 53'd7425180500362908;
assign bm_exp_rom[257] = 53'd7439696977660376;
assign bm_exp_rom[258] = 53'd7454241835158584;
assign bm_exp_rom[259] = 53'd7468815128341778;
assign bm_exp_rom[260] = 53'd7483416912802676;
assign bm_exp_rom[261] = 53'd7498047244242684;
assign bm_exp_rom[262] = 53'd7512706178472104;
assign bm_exp_rom[263] = 53'd7527393771410352;
assign bm_exp_rom[264] = 53'd7542110079086164;
assign bm_exp_rom[265] = 53'd7556855157637819;
assign bm_exp_rom[266] = 53'd7571629063313343;
assign bm_exp_rom[267] = 53'd7586431852470734;
assign bm_exp_rom[268] = 53'd7601263581578168;
assign bm_exp_rom[269] = 53'd7616124307214220;
assign bm_exp_rom[270] = 53'd7631014086068077;
assign bm_exp_rom[271] = 53'd7645932974939755;
assign bm_exp_rom[272] = 53'd7660881030740319;
assign bm_exp_rom[273] = 53'd7675858310492092;
assign bm_exp_rom[274] = 53'd7690864871328882;
assign bm_exp_rom[275] = 53'd7705900770496194;
assign bm_exp_rom[276] = 53'd7720966065351448;
assign bm_exp_rom[277] = 53'd7736060813364203;
assign bm_exp_rom[278] = 53'd7751185072116371;
assign bm_exp_rom[279] = 53'd7766338899302438;
assign bm_exp_rom[280] = 53'd7781522352729686;
assign bm_exp_rom[281] = 53'd7796735490318412;
assign bm_exp_rom[282] = 53'd7811978370102148;
assign bm_exp_rom[283] = 53'd7827251050227885;
assign bm_exp_rom[284] = 53'd7842553588956293;
assign bm_exp_rom[285] = 53'd7857886044661942;
assign bm_exp_rom[286] = 53'd7873248475833528;
assign bm_exp_rom[287] = 53'd7888640941074094;
assign bm_exp_rom[288] = 53'd7904063499101254;
assign bm_exp_rom[289] = 53'd7919516208747416;
assign bm_exp_rom[290] = 53'd7934999128960009;
assign bm_exp_rom[291] = 53'd7950512318801704;
assign bm_exp_rom[292] = 53'd7966055837450643;
assign bm_exp_rom[293] = 53'd7981629744200663;
assign bm_exp_rom[294] = 53'd7997234098461522;
assign bm_exp_rom[295] = 53'd8012868959759128;
assign bm_exp_rom[296] = 53'd8028534387735760;
assign bm_exp_rom[297] = 53'd8044230442150305;
assign bm_exp_rom[298] = 53'd8059957182878476;
assign bm_exp_rom[299] = 53'd8075714669913048;
assign bm_exp_rom[300] = 53'd8091502963364082;
assign bm_exp_rom[301] = 53'd8107322123459158;
assign bm_exp_rom[302] = 53'd8123172210543601;
assign bm_exp_rom[303] = 53'd8139053285080714;
assign bm_exp_rom[304] = 53'd8154965407652009;
assign bm_exp_rom[305] = 53'd8170908638957434;
assign bm_exp_rom[306] = 53'd8186883039815611;
assign bm_exp_rom[307] = 53'd8202888671164062;
assign bm_exp_rom[308] = 53'd8218925594059444;
assign bm_exp_rom[309] = 53'd8234993869677783;
assign bm_exp_rom[310] = 53'd8251093559314705;
assign bm_exp_rom[311] = 53'd8267224724385673;
assign bm_exp_rom[312] = 53'd8283387426426215;
assign bm_exp_rom[313] = 53'd8299581727092169;
assign bm_exp_rom[314] = 53'd8315807688159907;
assign bm_exp_rom[315] = 53'd8332065371526579;
assign bm_exp_rom[316] = 53'd8348354839210345;
assign bm_exp_rom[317] = 53'd8364676153350612;
assign bm_exp_rom[318] = 53'd8381029376208273;
assign bm_exp_rom[319] = 53'd8397414570165942;
assign bm_exp_rom[320] = 53'd8413831797728192;
assign bm_exp_rom[321] = 53'd8430281121521799;
assign bm_exp_rom[322] = 53'd8446762604295971;
assign bm_exp_rom[323] = 53'd8463276308922596;
assign bm_exp_rom[324] = 53'd8479822298396478;
assign bm_exp_rom[325] = 53'd8496400635835577;
assign bm_exp_rom[326] = 53'd8513011384481253;
assign bm_exp_rom[327] = 53'd8529654607698504;
assign bm_exp_rom[328] = 53'd8546330368976206;
assign bm_exp_rom[329] = 53'd8563038731927362;
assign bm_exp_rom[330] = 53'd8579779760289338;
assign bm_exp_rom[331] = 53'd8596553517924110;
assign bm_exp_rom[332] = 53'd8613360068818505;
assign bm_exp_rom[333] = 53'd8630199477084447;
assign bm_exp_rom[334] = 53'd8647071806959202;
assign bm_exp_rom[335] = 53'd8663977122805621;
assign bm_exp_rom[336] = 53'd8680915489112386;
assign bm_exp_rom[337] = 53'd8697886970494257;
assign bm_exp_rom[338] = 53'd8714891631692319;
assign bm_exp_rom[339] = 53'd8731929537574227;
assign bm_exp_rom[340] = 53'd8749000753134454;
assign bm_exp_rom[341] = 53'd8766105343494541;
assign bm_exp_rom[342] = 53'd8783243373903342;
assign bm_exp_rom[343] = 53'd8800414909737276;
assign bm_exp_rom[344] = 53'd8817620016500574;
assign bm_exp_rom[345] = 53'd8834858759825532;
assign bm_exp_rom[346] = 53'd8852131205472756;
assign bm_exp_rom[347] = 53'd8869437419331420;
assign bm_exp_rom[348] = 53'd8886777467419510;
assign bm_exp_rom[349] = 53'd8904151415884082;
assign bm_exp_rom[350] = 53'd8921559331001510;
assign bm_exp_rom[351] = 53'd8939001279177743;
assign bm_exp_rom[352] = 53'd8956477326948553;
assign bm_exp_rom[353] = 53'd8973987540979792;
assign bm_exp_rom[354] = 53'd8991531988067648;

reg overflow_buffer[LATENCY_CONFIG-1:0];
reg underflow_buffer[LATENCY_CONFIG-1:0];
reg in_valid_buffer[LATENCY_CONFIG-1:0];
reg [FLOAT_EXP_WIDTH-1:0] float_exp_buffer[LATENCY_CONFIG-1:0];
reg float_exp_pn_buffer[LATENCY_CONFIG-1:0];

wire [FLOAT_EXP_WIDTH-1:0] float_exp;
wire float_exp_pn;
wire [FLOAT_FRAC_WIDTH-1:0] float_value; 
wire [FLOAT_FRAC_WIDTH+2:0] float_value_expand;
wire [DATA_WIDTH+5+INPUT_RANGE_ADD:0] iData_fixed; //+3bits
wire [DATA_WIDTH+4+INPUT_RANGE_ADD:0] iData_fixed_abs; //+3bits
wire [DATA_WIDTH+5+INPUT_RANGE_ADD:0] shift; //may decrease
wire shift_pn;
wire [DATA_WIDTH_CUT+5+INPUT_RANGE_ADD:0] w;
wire [DATA_WIDTH_CUT+5+INPUT_RANGE_ADD:0] r;

wire [52:0] bm_exp;
wire [45:0] bl;
reg [52:0] bm_exp_buffer[LATENCY_CONFIG-2:0];

reg [55:0] layer0_value0; //2^55+bl
reg [37-1:0] layer0_value1; //bl^2
reg [45-1:0] layer0_value2; //bl/3
wire [92-1:0] layer0_value1_cal; //bl*bl

reg [55:0] layer1_value0; //2^55+bl+(bl^2)/2
reg [19-1:0] layer1_value1; //bl^4
reg [26-1:0] layer1_value2; //(bl^3)/(3*2)
wire [74-1:0] layer1_value1_cal; //bl^2 * bl^2
wire [81-1:0] layer1_value2_cal; //(bl/3)*bl^2/2

reg [55:0] layer2_value0; //layer1_value0 + layer1_value2
reg [15-1:0] layer2_value1;

reg [55:0] layer3_value0;

reg [7:0] shift_buffer [LATENCY_CONFIG-1:0];
reg shift_pn_buffer [LATENCY_CONFIG-1:0];

//reg [25-1:0] exp_part_0;
reg [109-1:0] exp_part_1;
wire [109-1:0] exp_part_2;

wire overflow;
wire underflow;

wire [FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1:0] exp_float0;

//compare the exponential bit with 1023
assign float_exp_pn = i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] > 11'd1023 ? 0 : 1;
//calculate the exponential bit of float input
assign float_exp = i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] > 11'd1023 ? i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] - 11'd1023 : 11'd1023 - i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1];
//calculate the value of mantissa
assign float_value = {1'b1,i_data_float[FLOAT_FRAC_WIDTH-2:0]};
assign float_value_expand = {float_value, 3'b0};
//calculate the fixed value of input
assign iData_fixed[DATA_WIDTH+5+INPUT_RANGE_ADD] = i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1];
assign iData_fixed_abs[DATA_WIDTH+4+INPUT_RANGE_ADD:0] = i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] > 11'd1023 ? {{(3+INPUT_RANGE_ADD){1'b0}},float_value_expand} <<< float_exp : {{(3+INPUT_RANGE_ADD){1'b0}},float_value_expand} >>> float_exp; 
assign iData_fixed[DATA_WIDTH+4+INPUT_RANGE_ADD:0] = i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1] ? -(iData_fixed_abs) : iData_fixed_abs;

//calculate the sign bit of shift number 0:left shift 1:right shift
assign shift_pn = iData_fixed[DATA_WIDTH+5+INPUT_RANGE_ADD]; 
//calculate shift number
assign w = !i_rst_n ? {59{1'b1}} : {1'b0,iData_fixed_abs};
assign shift = !i_rst_n ? {59{1'b1}} :
                iData_fixed[DATA_WIDTH+5+INPUT_RANGE_ADD] ? (w / 55'd24973259072661437) +1 : (w / 55'd24973259072661437); // (2^31)/23=ln2 * 2^27
//calculate value of r
assign r = !i_rst_n ? {59{1'b1}} :
            iData_fixed[DATA_WIDTH+5+INPUT_RANGE_ADD] ? (shift[7:0] * 55'd24973259072661437) - w : w - (shift[7:0] * 55'd24973259072661437); //ln2 * 2^8 = 177, ln2 * 2^23 = 5814540, ln2 * 2^27 = 93032640

assign bm_exp = bm_exp_rom[r[54:46]];
assign bl = r[45:0];

assign layer0_value1_cal = (bl * bl) >>> 55;
assign layer1_value1_cal = (layer0_value1 * layer0_value1) >>> 55;
assign layer1_value2_cal = (layer0_value1 * layer0_value2) >>> 56;

//exp_part_2 is used to remove the leading 1 of the exponential value
assign exp_part_2 = !i_rst_n ? {109{1'b1}} : 
                    exp_part_1 > (1 <<< 107) ? exp_part_1 - (1 <<< 107) : (1 <<< 107) - exp_part_1;
//if input is smaller than 8, overflow = 0, otherwise 1
assign overflow = i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1] == 1 ? 0 :
                    i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] > (11'd1025 + INPUT_RANGE_ADD) ? 1 : 0;
assign underflow = (i_data_float[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] < 11'b01111000000) ? 1 : 0;

integer i0;
integer i2;
always @ ( posedge i_clk or negedge i_rst_n )
    if( !i_rst_n )
    begin
    //reset
    for (i0 = 0; i0 < LATENCY_CONFIG; i0 = i0+1) begin
        shift_buffer[i0] <= 0;
        shift_pn_buffer[i0] <= 0;
        bm_exp_buffer[i0] <= 0;
    end
    
    shift_buffer[LATENCY_CONFIG-1] <= 0;
    shift_pn_buffer[LATENCY_CONFIG-1] <= 0;

    layer0_value0 <= 0;
    layer0_value1 <= 0;
    layer0_value2 <= 0;

    layer1_value0 <= 0;
    layer1_value1 <= 0;
    layer1_value2 <= 0;

    layer2_value0 <= 0;
    layer2_value1 <= 0;

    layer3_value0 <= 0;

    exp_part_1 <= 0;
    end
    else if (i_aclken) begin
        //initialize
        shift_buffer[0] <= shift[7:0];
        shift_pn_buffer[0] <= shift_pn;
        bm_exp_buffer[0] <= bm_exp;
        layer0_value0 <= (1 <<< 55) + bl;
        layer0_value1 <= layer0_value1_cal[36:0];
        layer0_value2 <= bl / 3;

        layer1_value0 <= layer0_value0 + (layer0_value1 >>> 1);
        layer1_value1 <= layer1_value1_cal[18:0];
        layer1_value2 <= layer1_value2_cal[25:0];

        layer2_value0 <= layer1_value0 + layer1_value2;
        layer2_value1 <= (layer1_value1 / 3) >>> 3;

        layer3_value0 <= layer2_value0 + layer2_value1;
    
        exp_part_1 <= layer3_value0 * bm_exp_buffer[LATENCY_CONFIG-2];
        //iteration for calculating taylor expansion
        for (i2 = 1; i2 < LATENCY_CONFIG-1; i2 = i2+1) begin
            shift_buffer[i2] <= shift_buffer[i2-1];
            shift_pn_buffer[i2] <= shift_pn_buffer[i2-1];
            bm_exp_buffer[i2] <= bm_exp_buffer[i2-1];
        end
        shift_buffer[LATENCY_CONFIG-1] <= shift_buffer[LATENCY_CONFIG-2];
        shift_pn_buffer[LATENCY_CONFIG-1] <= shift_pn_buffer[LATENCY_CONFIG-2];
    end

assign o_valid = in_valid_buffer[LATENCY_CONFIG-1];
assign o_overflow = overflow_buffer[LATENCY_CONFIG-1];
assign o_underflow = underflow_buffer[LATENCY_CONFIG-1];

//calculate the sign bit of float result
assign exp_float0[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-1] = !i_rst_n ? 1'b1 : 1'b0;
//calculate the exponential bits of float result
assign exp_float0[FLOAT_EXP_WIDTH+FLOAT_FRAC_WIDTH-2:FLOAT_FRAC_WIDTH-1] = !i_rst_n ? 11'b11111111111 :
                                                            shift_pn_buffer[LATENCY_CONFIG-1] == 0 ? 11'd1023 + shift_buffer[LATENCY_CONFIG-1] : 11'd1023 - shift_buffer[LATENCY_CONFIG-1];
//calculate the mantissa bits of float result
assign exp_float0[FLOAT_FRAC_WIDTH-2:0] = !i_rst_n ? 52'hffff_ffff_ffff_f : 
                                            exp_part_2[54:53] ? exp_part_2[106:55]+1 : exp_part_2[106:55];
//adjust the output accorroding to the value of input 
assign o_exp_float = o_overflow ? {1'b0, {FLOAT_EXP_WIDTH{1'b1}}, {(FLOAT_FRAC_WIDTH-1){1'b0}}} :
                    shift_pn_buffer[LATENCY_CONFIG-1] == 0 ? exp_float0 :
                    (float_exp_buffer[LATENCY_CONFIG-1] > 11'd2) && (float_exp_pn_buffer[LATENCY_CONFIG-1] == 0) ? 0 : exp_float0;
		            //(float_exp_pn_buffer[LATENCY_CONFIG-1] == 1) && (float_exp_buffer[LATENCY_CONFIG-1] > 8'd7) ? 32'h3f800000 : exp_float0;

//delay i_valid, overflow, underflow, float_exp, and float_exp_pn to keep pace with output
integer i3;
always @(posedge i_clk or negedge i_rst_n)
    if(!i_rst_n) begin
    for (i3 = 0; i3 < LATENCY_CONFIG; i3 = i3+1) begin
        in_valid_buffer[i3] <= 0;
        overflow_buffer[i3] <= 0;
        underflow_buffer[i3] <= 0;
        float_exp_buffer[i3] <= 0;
        float_exp_pn_buffer[i3] <= 0;
    end
    end
    else if (i_aclken) begin
        in_valid_buffer[0] <= i_valid;
        overflow_buffer[0] <= overflow;
        underflow_buffer[0] <= underflow;
        float_exp_buffer[0] <= float_exp;
        float_exp_pn_buffer[0] <= float_exp_pn;
        for (i3 = 1; i3 < LATENCY_CONFIG; i3 = i3+1) begin
            in_valid_buffer[i3] <= in_valid_buffer[i3-1];
            overflow_buffer[i3] <= overflow_buffer[i3-1];
            underflow_buffer[i3] <= underflow_buffer[i3-1];
            float_exp_buffer[i3] <= float_exp_buffer[i3-1];
            float_exp_pn_buffer[i3] <= float_exp_pn_buffer[i3-1];
        end
    end

endmodule