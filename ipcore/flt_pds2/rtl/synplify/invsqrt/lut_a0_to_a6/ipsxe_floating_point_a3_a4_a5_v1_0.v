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
// Filename: ipsxe_floating_point_a3_a4_a5_v1_0.v
// Function: This module is a lut for o_a3, o_a4 and o_a5.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_a3_a4_a5_v1_0 (
    input [8-1:0] i_x_hi8,
    output reg [47-1:0] o_a3,
    output reg [47-1:0] o_a4,
    output reg [22-1:0] o_a5
);

// o_a3, o_a4, o_a5 are the argument a3, a4, a5,
// which are in the taylor expression:
// a0 - a1 * (x - a) + a2 * (x - a)^2 - a3 * (x - a)^3 + a4 * (x - a)^4 - a5 * (x - a)^5 + a6 * (x - a)^6
always @(*) begin: blk_a3_a4_a5
    case(i_x_hi8)
8'd0:   {o_a3, o_a4, o_a5} = {47'h37cd48e4ddd4, 47'h30a2fccb76a3, 22'h2b9a49}; // a3, a4, a5
8'd1:   {o_a3, o_a4, o_a5} = {47'h364ee8876697, 47'h2ef8230d51cf, 22'h29c860}; // a3, a4, a5
8'd2:   {o_a3, o_a4, o_a5} = {47'h34dd975ff971, 47'h2d5f09459e2c, 22'h280d46}; // a3, a4, a5
8'd3:   {o_a3, o_a4, o_a5} = {47'h3378caedecf4, 47'h2bd6d1d36781, 22'h2667b4}; // a3, a4, a5
8'd4:   {o_a3, o_a4, o_a5} = {47'h321fff6b90d7, 47'h2a5eab76f049, 22'h24d677}; // a3, a4, a5
8'd5:   {o_a3, o_a4, o_a5} = {47'h30d2b76e4a76, 47'h28f5d08a8d18, 22'h23586f}; // a3, a4, a5
8'd6:   {o_a3, o_a4, o_a5} = {47'h2f907b8cb230, 47'h279b864961f1, 22'h21ec8f}; // a3, a4, a5
8'd7:   {o_a3, o_a4, o_a5} = {47'h2e58da0a46e1, 47'h264f1c22f1d9, 22'h2091da}; // a3, a4, a5
8'd8:   {o_a3, o_a4, o_a5} = {47'h2d2b668854e0, 47'h250feb1a8749, 22'h1f4763}; // a3, a4, a5
8'd9:   {o_a3, o_a4, o_a5} = {47'h2c07b9bbb559, 47'h23dd553190ed, 22'h1e0c4a}; // a3, a4, a5
8'd10:  {o_a3, o_a4, o_a5} = {47'h2aed712711aa, 47'h22b6c4dc20c5, 22'h1cdfbd}; // a3, a4, a5
8'd11:  {o_a3, o_a4, o_a5} = {47'h29dc2ed95ccc, 47'h219bac7ecccc, 22'h1bc0f8}; // a3, a4, a5
8'd12:  {o_a3, o_a4, o_a5} = {47'h28d399303a82, 47'h208b85f53ff3, 22'h1aaf42}; // a3, a4, a5
8'd13:  {o_a3, o_a4, o_a5} = {47'h27d35a9e1163, 47'h1f85d220d864, 22'h19a9eb}; // a3, a4, a5
8'd14:  {o_a3, o_a4, o_a5} = {47'h26db217389b4, 47'h1e8a187ebd12, 22'h18b050}; // a3, a4, a5
8'd15:  {o_a3, o_a4, o_a5} = {47'h25ea9fac3f8a, 47'h1d97e6c4e06c, 22'h17c1d7}; // a3, a4, a5
8'd16:  {o_a3, o_a4, o_a5} = {47'h25018abe72ce, 47'h1caed08570e6, 22'h16dded}; // a3, a4, a5
8'd17:  {o_a3, o_a4, o_a5} = {47'h241f9b6d838b, 47'h1bce6ed84211, 22'h16040a}; // a3, a4, a5
8'd18:  {o_a3, o_a4, o_a5} = {47'h23448d9f0c83, 47'h1af66009c1ec, 22'h1533ab}; // a3, a4, a5
8'd19:  {o_a3, o_a4, o_a5} = {47'h227020327137, 47'h1a26474f169e, 22'h146c58}; // a3, a4, a5
8'd20:  {o_a3, o_a4, o_a5} = {47'h21a214dab78e, 47'h195dcc7f0849, 22'h13ad9d}; // a3, a4, a5
8'd21:  {o_a3, o_a4, o_a5} = {47'h20da2ffa8828, 47'h189c9bcf61b9, 22'h12f70d}; // a3, a4, a5
8'd22:  {o_a3, o_a4, o_a5} = {47'h2018388232ce, 47'h17e265967928, 22'h124842}; // a3, a4, a5
8'd23:  {o_a3, o_a4, o_a5} = {47'h1f5bf7cf96f5, 47'h172ede109827, 22'h11a0da}; // a3, a4, a5
8'd24:  {o_a3, o_a4, o_a5} = {47'h1ea5398fd268, 47'h1681bd28ff40, 22'h110079}; // a3, a4, a5
8'd25:  {o_a3, o_a4, o_a5} = {47'h1df3cba29a38, 47'h15dabe4646d5, 22'h1066cb}; // a3, a4, a5
8'd26:  {o_a3, o_a4, o_a5} = {47'h1d477dff23f0, 47'h1539a019e35f,  22'hfd37b}; // a3, a4, a5
8'd27:  {o_a3, o_a4, o_a5} = {47'h1ca0229a86ce, 47'h149e2472976c,  22'hf463d}; // a3, a4, a5
8'd28:  {o_a3, o_a4, o_a5} = {47'h1bfd8d4f7e5f, 47'h14081011a198,  22'hebec7}; // a3, a4, a5
8'd29:  {o_a3, o_a4, o_a5} = {47'h1b5f93c77955, 47'h13772a82786a,  22'he3cd4}; // a3, a4, a5
8'd30:  {o_a3, o_a4, o_a5} = {47'h1ac60d64e0d6, 47'h12eb3df4e92c,  22'hdc023}; // a3, a4, a5
8'd31:  {o_a3, o_a4, o_a5} = {47'h1a30d32e85ca, 47'h126417197202,  22'hd4874}; // a3, a4, a5
8'd32:  {o_a3, o_a4, o_a5} = {47'h199fbfbc22f0, 47'h11e184ffb24d,  22'hcd58c}; // a3, a4, a5
8'd33:  {o_a3, o_a4, o_a5} = {47'h1912af23e382, 47'h116358f6ceeb,  22'hc6734}; // a3, a4, a5
8'd34:  {o_a3, o_a4, o_a5} = {47'h18897ee8df59, 47'h10e9666faa7b,  22'hbfd36}; // a3, a4, a5
8'd35:  {o_a3, o_a4, o_a5} = {47'h18040dea7e5c, 47'h107382e0d3d1,  22'hb9760}; // a3, a4, a5
8'd36:  {o_a3, o_a4, o_a5} = {47'h17823c54b605, 47'h100185ac0efe,  22'hb3583}; // a3, a4, a5
8'd37:  {o_a3, o_a4, o_a5} = {47'h1703eb91148a,  47'hf9348055f1c,  22'had770}; // a3, a4, a5
8'd38:  {o_a3, o_a4, o_a5} = {47'h1688fe388e01,  47'hf28a4db78e4,  22'ha7cfc}; // a3, a4, a5
8'd39:  {o_a3, o_a4, o_a5} = {47'h161158060098,  47'hec178c187a8,  22'ha2600}; // a3, a4, a5
8'd40:  {o_a3, o_a4, o_a5} = {47'h159cddc965a9,  47'he5da1da2fd2,  22'h9d252}; // a3, a4, a5
8'd41:  {o_a3, o_a4, o_a5} = {47'h152b755ba5f9,  47'hdfcffc3bb74,  22'h981d0}; // a3, a4, a5
8'd42:  {o_a3, o_a4, o_a5} = {47'h14bd05930832,  47'hd9f73855eb9,  22'h93455}; // a3, a4, a5
8'd43:  {o_a3, o_a4, o_a5} = {47'h14517638310d,  47'hd44df7d834c,  22'h8e9bf}; // a3, a4, a5
8'd44:  {o_a3, o_a4, o_a5} = {47'h13e8affbad3b,  47'hced27510ad1,  22'h8a1f0}; // a3, a4, a5
8'd45:  {o_a3, o_a4, o_a5} = {47'h13829c6bfd92,  47'hc982fdb79a3,  22'h85cc9}; // a3, a4, a5
8'd46:  {o_a3, o_a4, o_a5} = {47'h131f25ec1e6f,  47'hc45df1ffc10,  22'h81a2d}; // a3, a4, a5
8'd47:  {o_a3, o_a4, o_a5} = {47'h12be37aa83b1,  47'hbf61c3b390f,  22'h7da00}; // a3, a4, a5
8'd48:  {o_a3, o_a4, o_a5} = {47'h125fbd98830e,  47'hba8cf55e662,  22'h79c29}; // a3, a4, a5
8'd49:  {o_a3, o_a4, o_a5} = {47'h1203a46226ed,  47'hb5de19812cb,  22'h7608e}; // a3, a4, a5
8'd50:  {o_a3, o_a4, o_a5} = {47'h11a9d9666431,  47'hb153d1d1bba,  22'h72718}; // a3, a4, a5
8'd51:  {o_a3, o_a4, o_a5} = {47'h11524aafadd7,  47'hacecce84489,  22'h6efaf}; // a3, a4, a5
8'd52:  {o_a3, o_a4, o_a5} = {47'h10fce6ece163,  47'ha8a7cd9e5ea,  22'h6ba40}; // a3, a4, a5
8'd53:  {o_a3, o_a4, o_a5} = {47'h10a99d6a879d,  47'ha4839a52ce6,  22'h686b4}; // a3, a4, a5
8'd54:  {o_a3, o_a4, o_a5} = {47'h10585e0c6529,  47'ha07f0c66126,  22'h654f8}; // a3, a4, a5
8'd55:  {o_a3, o_a4, o_a5} = {47'h1009194756ed,  47'h9c99079aaf1,  22'h624fa}; // a3, a4, a5
8'd56:  {o_a3, o_a4, o_a5} = { 47'hfbbc01b7660,  47'h98d07b25193,  22'h5f6a7}; // a3, a4, a5
8'd57:  {o_a3, o_a4, o_a5} = { 47'hf70440e8220,  47'h95246126b8c,  22'h5c9ef}; // a3, a4, a5
8'd58:  {o_a3, o_a4, o_a5} = { 47'hf2697268746,  47'h9193be2fa13,  22'h59ec1}; // a3, a4, a5
8'd59:  {o_a3, o_a4, o_a5} = { 47'hedeabe4c859,  47'h8e1da0c6a05,  22'h5750e}; // a3, a4, a5
8'd60:  {o_a3, o_a4, o_a5} = { 47'he987540dea3,  47'h8ac120f74aa,  22'h54cc6}; // a3, a4, a5
8'd61:  {o_a3, o_a4, o_a5} = { 47'he53e6a41321,  47'h877d5fe5b02,  22'h525dc}; // a3, a4, a5
8'd62:  {o_a3, o_a4, o_a5} = { 47'he10f3e4ec35,  47'h845187676b7,  22'h50042}; // a3, a4, a5
8'd63:  {o_a3, o_a4, o_a5} = { 47'hdcf9142ed93,  47'h813cc9a1bfe,  22'h4dbeb}; // a3, a4, a5
8'd64:  {o_a3, o_a4, o_a5} = { 47'hd8fb36287dd,  47'h7e3e60ac811,  22'h4b8cb}; // a3, a4, a5
8'd65:  {o_a3, o_a4, o_a5} = { 47'hd514f4935b4,  47'h7b558e39823,  22'h496d4}; // a3, a4, a5
8'd66:  {o_a3, o_a4, o_a5} = { 47'hd145a59c3f3,  47'h78819b404e8,  22'h475fe}; // a3, a4, a5
8'd67:  {o_a3, o_a4, o_a5} = { 47'hcd8ca50c30f,  47'h75c1d7adf0d,  22'h4563b}; // a3, a4, a5
8'd68:  {o_a3, o_a4, o_a5} = { 47'hc9e95411f94,  47'h73159a18934,  22'h43782}; // a3, a4, a5
8'd69:  {o_a3, o_a4, o_a5} = { 47'hc65b190dfe8,  47'h707c3f76c2e,  22'h419ca}; // a3, a4, a5
8'd70:  {o_a3, o_a4, o_a5} = { 47'hc2e15f60599,  47'h6df52ada26f,  22'h3fd07}; // a3, a4, a5
8'd71:  {o_a3, o_a4, o_a5} = { 47'hbf7b9739066,  47'h6b7fc52d7cd,  22'h3e132}; // a3, a4, a5
8'd72:  {o_a3, o_a4, o_a5} = { 47'hbc29356a199,  47'h691b7cf5ae8,  22'h3c641}; // a3, a4, a5
8'd73:  {o_a3, o_a4, o_a5} = { 47'hb8e9b33be09,  47'h66c7c615d8f,  22'h3ac2c}; // a3, a4, a5
8'd74:  {o_a3, o_a4, o_a5} = { 47'hb5bc8e42d6a,  47'h648419961cf,  22'h392eb}; // a3, a4, a5
8'd75:  {o_a3, o_a4, o_a5} = { 47'hb2a14837587,  47'h624ff56d15a,  22'h37a77}; // a3, a4, a5
8'd76:  {o_a3, o_a4, o_a5} = { 47'haf9766cf026,  47'h602adc4bd1c,  22'h362c7}; // a3, a4, a5
8'd77:  {o_a3, o_a4, o_a5} = { 47'hac9e7397a4a,  47'h5e14556c2f6,  22'h34bd5}; // a3, a4, a5
8'd78:  {o_a3, o_a4, o_a5} = { 47'ha9b5fbd3bbe,  47'h5c0bec617b9,  22'h33599}; // a3, a4, a5
8'd79:  {o_a3, o_a4, o_a5} = { 47'ha6dd90585c2,  47'h5a1130eb388,  22'h3200f}; // a3, a4, a5
8'd80:  {o_a3, o_a4, o_a5} = { 47'ha414c56c7d3,  47'h5823b6c9ee8,  22'h30b2e}; // a3, a4, a5
8'd81:  {o_a3, o_a4, o_a5} = { 47'ha15b32a9986,  47'h56431595ee8,  22'h2f6f1}; // a3, a4, a5
8'd82:  {o_a3, o_a4, o_a5} = { 47'h9eb072dd898,  47'h546ee897ecc,  22'h2e353}; // a3, a4, a5
8'd83:  {o_a3, o_a4, o_a5} = { 47'h9c1423eda32,  47'h52a6cea35d1,  22'h2d04d}; // a3, a4, a5
8'd84:  {o_a3, o_a4, o_a5} = { 47'h9985e6bae99,  47'h50ea69f279e,  22'h2bdda}; // a3, a4, a5
8'd85:  {o_a3, o_a4, o_a5} = { 47'h97055f07677,  47'h4f396003e25,  22'h2abf6}; // a3, a4, a5
8'd86:  {o_a3, o_a4, o_a5} = { 47'h9492335c8ee,  47'h4d935979ba3,  22'h29a9c}; // a3, a4, a5
8'd87:  {o_a3, o_a4, o_a5} = { 47'h922c0cf29c0,  47'h4bf801fa3a8,  22'h289c5}; // a3, a4, a5
8'd88:  {o_a3, o_a4, o_a5} = { 47'h8fd29798ed9,  47'h4a670811a02,  22'h2796f}; // a3, a4, a5
8'd89:  {o_a3, o_a4, o_a5} = { 47'h8d85819f489,  47'h48e01d1567e,  22'h26995}; // a3, a4, a5
8'd90:  {o_a3, o_a4, o_a5} = { 47'h8b447bbffd7,  47'h4762f508c83,  22'h25a32}; // a3, a4, a5
8'd91:  {o_a3, o_a4, o_a5} = { 47'h890f390ae3f,  47'h45ef4682598,  22'h24b43}; // a3, a4, a5
8'd92:  {o_a3, o_a4, o_a5} = { 47'h86e56ed1262,  47'h4484ca92de9,  22'h23cc3}; // a3, a4, a5
8'd93:  {o_a3, o_a4, o_a5} = { 47'h84c6d491d03,  47'h43233cad1fe,  22'h22eaf}; // a3, a4, a5
8'd94:  {o_a3, o_a4, o_a5} = { 47'h82b323e71d4,  47'h41ca5a8ecc9,  22'h22103}; // a3, a4, a5
8'd95:  {o_a3, o_a4, o_a5} = { 47'h80aa1874797,  47'h4079e42a54f,  22'h213bc}; // a3, a4, a5
8'd96:  {o_a3, o_a4, o_a5} = { 47'h7eab6fd5319,  47'h3f319b91b34,  22'h206d6}; // a3, a4, a5
8'd97:  {o_a3, o_a4, o_a5} = { 47'h7cb6e98bc84,  47'h3df144e2177,  22'h1fa4f}; // a3, a4, a5
8'd98:  {o_a3, o_a4, o_a5} = { 47'h7acc46f1eb6,  47'h3cb8a6306b5,  22'h1ee22}; // a3, a4, a5
8'd99:  {o_a3, o_a4, o_a5} = { 47'h78eb4b2900b,  47'h3b878776a5c,  22'h1e24e}; // a3, a4, a5
8'd100: {o_a3, o_a4, o_a5} = { 47'h7713bb0b465,  47'h3a5db281e29,  22'h1d6d0}; // a3, a4, a5
8'd101: {o_a3, o_a4, o_a5} = { 47'h75455d1d7e2,  47'h393af2e1377,  22'h1cba3}; // a3, a4, a5
8'd102: {o_a3, o_a4, o_a5} = { 47'h737ff98120d,  47'h381f15d53bd,  22'h1c0c7}; // a3, a4, a5
8'd103: {o_a3, o_a4, o_a5} = { 47'h71c359e710e,  47'h3709ea403d4,  22'h1b638}; // a3, a4, a5
8'd104: {o_a3, o_a4, o_a5} = { 47'h700f4982ca8,  47'h35fb4097174,  22'h1abf3}; // a3, a4, a5
8'd105: {o_a3, o_a4, o_a5} = { 47'h6e6394fe097,  47'h34f2ead2a7e,  22'h1a1f8}; // a3, a4, a5
8'd106: {o_a3, o_a4, o_a5} = { 47'h6cc00a6ce11,  47'h33f0bc61da5,  22'h19842}; // a3, a4, a5
8'd107: {o_a3, o_a4, o_a5} = { 47'h6b247942423,  47'h32f48a1c401,  22'h18ed0}; // a3, a4, a5
8'd108: {o_a3, o_a4, o_a5} = { 47'h6990b244e96,  47'h31fe2a35339,  22'h185a1}; // a3, a4, a5
8'd109: {o_a3, o_a4, o_a5} = { 47'h68048784b2d,  47'h310d742f7cc,  22'h17cb0}; // a3, a4, a5
8'd110: {o_a3, o_a4, o_a5} = { 47'h667fcc504e3,  47'h302240d173a,  22'h173fe}; // a3, a4, a5
8'd111: {o_a3, o_a4, o_a5} = { 47'h6502552b508,  47'h2f3c6a1999a,  22'h16b88}; // a3, a4, a5
8'd112: {o_a3, o_a4, o_a5} = { 47'h638bf7c49eb,  47'h2e5bcb33a60,  22'h1634b}; // a3, a4, a5
8'd113: {o_a3, o_a4, o_a5} = { 47'h621c8aed2e4,  47'h2d80406dff3,  22'h15b47}; // a3, a4, a5
8'd114: {o_a3, o_a4, o_a5} = { 47'h60b3e68f18c,  47'h2ca9a72f9da,  22'h15379}; // a3, a4, a5
8'd115: {o_a3, o_a4, o_a5} = { 47'h5f51e3a4fe2,  47'h2bd7ddee523,  22'h14be0}; // a3, a4, a5
8'd116: {o_a3, o_a4, o_a5} = { 47'h5df65c31b3b,  47'h2b0ac4256d0,  22'h1447b}; // a3, a4, a5
8'd117: {o_a3, o_a4, o_a5} = { 47'h5ca12b383c6,  47'h2a423a4cc05,  22'h13d47}; // a3, a4, a5
8'd118: {o_a3, o_a4, o_a5} = { 47'h5b522cb4078,  47'h297e21cffb2,  22'h13643}; // a3, a4, a5
8'd119: {o_a3, o_a4, o_a5} = { 47'h5a093d91733,  47'h28be5d06585,  22'h12f6e}; // a3, a4, a5
8'd120: {o_a3, o_a4, o_a5} = { 47'h58c63ba6907,  47'h2802cf2a9ed,  22'h128c6}; // a3, a4, a5
8'd121: {o_a3, o_a4, o_a5} = { 47'h578905ac256,  47'h274b5c536eb,  22'h1224a}; // a3, a4, a5
8'd122: {o_a3, o_a4, o_a5} = { 47'h56517b36ecd,  47'h2697e96bd8c,  22'h11bf9}; // a3, a4, a5
8'd123: {o_a3, o_a4, o_a5} = { 47'h551f7cb10ee,  47'h25e85c2c3d9,  22'h115d2}; // a3, a4, a5
8'd124: {o_a3, o_a4, o_a5} = { 47'h53f2eb53d29,  47'h253c9b13702,  22'h10fd2}; // a3, a4, a5
8'd125: {o_a3, o_a4, o_a5} = { 47'h52cba921847,  47'h24948d601a3,  22'h109fa}; // a3, a4, a5
8'd126: {o_a3, o_a4, o_a5} = { 47'h51a998df91e,  47'h23f01b0a5f6,  22'h10447}; // a3, a4, a5
8'd127: {o_a3, o_a4, o_a5} = { 47'h508c9e10d5a,  47'h234f2cbdbc5,   22'hfeb9}; // a3, a4, a5
8'd128: {o_a3, o_a4, o_a5} = {47'h4eea718449f0, 47'h44c85af8c7ea, 22'h3da9db}; // a3, a4, a5
8'd129: {o_a3, o_a4, o_a5} = {47'h4ccdae769633, 47'h426cb2901333, 22'h3b16f5}; // a3, a4, a5
8'd130: {o_a3, o_a4, o_a5} = {47'h4ac3636c9697, 47'h402a244993e1, 22'h38a451}; // a3, a4, a5
8'd131: {o_a3, o_a4, o_a5} = {47'h48cacc87005b, 47'h3dff76b71e7a, 22'h365020}; // a3, a4, a5
8'd132: {o_a3, o_a4, o_a5} = {47'h46e32f6b2fab, 47'h3beb81ec7971, 22'h3418b0}; // a3, a4, a5
8'd133: {o_a3, o_a4, o_a5} = {47'h450bdabb8c3d, 47'h39ed2e65bba5, 22'h31fc6b}; // a3, a4, a5
8'd134: {o_a3, o_a4, o_a5} = {47'h434425986b56, 47'h380374014d02, 22'h2ff9d2}; // a3, a4, a5
8'd135: {o_a3, o_a4, o_a5} = {47'h418b6f28d85c, 47'h362d590c08cd, 22'h2e0f81}; // a3, a4, a5
8'd136: {o_a3, o_a4, o_a5} = {47'h3fe11e2ab867, 47'h3469f15e2126, 22'h2c3c27}; // a3, a4, a5
8'd137: {o_a3, o_a4, o_a5} = {47'h3e44a089c7f0, 47'h32b85d87806a, 22'h2a7e8a}; // a3, a4, a5
8'd138: {o_a3, o_a4, o_a5} = {47'h3cb56afcfb6b, 47'h3117ca0a7f87, 22'h28d57f}; // a3, a4, a5
8'd139: {o_a3, o_a4, o_a5} = {47'h3b32f8a9d465, 47'h2f876ea3e0aa, 22'h273ff2}; // a3, a4, a5
8'd140: {o_a3, o_a4, o_a5} = {47'h39bccacd4510, 47'h2e068d9f1386, 22'h25bcdb}; // a3, a4, a5
8'd141: {o_a3, o_a4, o_a5} = {47'h38526869c382, 47'h2c947335dcc9, 22'h244b44}; // a3, a4, a5
8'd142: {o_a3, o_a4, o_a5} = {47'h36f35dfa34ff, 47'h2b3074fa8c76, 22'h22ea46}; // a3, a4, a5
8'd143: {o_a3, o_a4, o_a5} = {47'h359f3d295fdc, 47'h29d9f14bffe4, 22'h219905}; // a3, a4, a5
8'd144: {o_a3, o_a4, o_a5} = {47'h34559c8d988b, 47'h28904ed2bb54, 22'h2056b3}; // a3, a4, a5
8'd145: {o_a3, o_a4, o_a5} = {47'h33161768639c, 47'h2752fc067525, 22'h1f2290}; // a3, a4, a5
8'd146: {o_a3, o_a4, o_a5} = {47'h31e04d69cbaf, 47'h26216ebb79a4, 22'h1dfbe2}; // a3, a4, a5
8'd147: {o_a3, o_a4, o_a5} = {47'h30b3e2772eb2, 47'h24fb23b75a20, 22'h1ce1ff}; // a3, a4, a5
8'd148: {o_a3, o_a4, o_a5} = {47'h2f907e754a38, 47'h23df9e4c64cc, 22'h1bd443}; // a3, a4, a5
8'd149: {o_a3, o_a4, o_a5} = {47'h2e75cd155283, 47'h22ce67fb6ce8, 22'h1ad214}; // a3, a4, a5
8'd150: {o_a3, o_a4, o_a5} = {47'h2d637da4e37d, 47'h21c7101b73b6, 22'h19dae2}; // a3, a4, a5
8'd151: {o_a3, o_a4, o_a5} = {47'h2c5942e09e43, 47'h20c92b86cb2d, 22'h18ee22}; // a3, a4, a5
8'd152: {o_a3, o_a4, o_a5} = {47'h2b56d2c948f4, 47'h1fd4544d52f5, 22'h180b54}; // a3, a4, a5
8'd153: {o_a3, o_a4, o_a5} = {47'h2a5be67b495b, 47'h1ee8296b7766, 22'h1731fd}; // a3, a4, a5
8'd154: {o_a3, o_a4, o_a5} = {47'h29683a0855a1, 47'h1e044e85a0aa, 22'h1661a8}; // a3, a4, a5
8'd155: {o_a3, o_a4, o_a5} = {47'h287b8c5338d3, 47'h1d286ba7c627, 22'h1599e9}; // a3, a4, a5
8'd156: {o_a3, o_a4, o_a5} = {47'h27959eed8b1d, 47'h1c542d08dfe1, 22'h14da58}; // a3, a4, a5
8'd157: {o_a3, o_a4, o_a5} = {47'h26b635f73fe0, 47'h1b8742d1f488, 22'h142291}; // a3, a4, a5
8'd158: {o_a3, o_a4, o_a5} = {47'h25dd17ffedb0, 47'h1ac160e887a7, 22'h137239}; // a3, a4, a5
8'd159: {o_a3, o_a4, o_a5} = {47'h250a0de9b623, 47'h1a023ebc2fa5, 22'h12c8f7}; // a3, a4, a5
8'd160: {o_a3, o_a4, o_a5} = {47'h243ce2cdb4f3, 47'h194997171f5e, 22'h122677}; // a3, a4, a5
8'd161: {o_a3, o_a4, o_a5} = {47'h237563e1dfb7, 47'h189727f172ba, 22'h118a6a}; // a3, a4, a5
8'd162: {o_a3, o_a4, o_a5} = {47'h22b3606040b8, 47'h17eab2471109, 22'h10f485}; // a3, a4, a5
8'd163: {o_a3, o_a4, o_a5} = {47'h21f6a96f78ec, 47'h1743f9effb27, 22'h106481}; // a3, a4, a5
8'd164: {o_a3, o_a4, o_a5} = {47'h213f120c765a, 47'h16a2c57ade32,  22'hfda1a}; // a3, a4, a5
8'd165: {o_a3, o_a4, o_a5} = {47'h208c6ef54d47, 47'h1606de09c679,  22'hf550f}; // a3, a4, a5
8'd166: {o_a3, o_a4, o_a5} = {47'h1fde969523c4, 47'h15700f30d090,  22'hed525}; // a3, a4, a5
8'd167: {o_a3, o_a4, o_a5} = {47'h1f3560f12020, 47'h14de26d6b904,  22'he5a20}; // a3, a4, a5
8'd168: {o_a3, o_a4, o_a5} = {47'h1e90a7964bca, 47'h1450f5172d0f,  22'hde3ca}; // a3, a4, a5
8'd169: {o_a3, o_a4, o_a5} = {47'h1df045885d00, 47'h13c84c26c0d9,  22'hd71ee}; // a3, a4, a5
8'd170: {o_a3, o_a4, o_a5} = {47'h1d5417315a90, 47'h13440038718b,  22'hd045b}; // a3, a4, a5
8'd171: {o_a3, o_a4, o_a5} = {47'h1cbbfa520dab, 47'h12c3e7649b36,  22'hc9ae1}; // a3, a4, a5
8'd172: {o_a3, o_a4, o_a5} = {47'h1c27cdf3367e, 47'h1247d9914c31,  22'hc3553}; // a3, a4, a5
8'd173: {o_a3, o_a4, o_a5} = {47'h1b9772577906, 47'h11cfb05be0f0,  22'hbd387}; // a3, a4, a5
8'd174: {o_a3, o_a4, o_a5} = {47'h1b0ac8edf826, 47'h115b4703d4d1,  22'hb7554}; // a3, a4, a5
8'd175: {o_a3, o_a4, o_a5} = {47'h1a81b445959b, 47'h10ea7a56b58a,  22'hb1a92}; // a3, a4, a5
8'd176: {o_a3, o_a4, o_a5} = {47'h19fc1800ce0a, 47'h107d289d2818,  22'hac31d}; // a3, a4, a5
8'd177: {o_a3, o_a4, o_a5} = {47'h1979d8ca28cc, 47'h10133188ef32,  22'ha6ed2}; // a3, a4, a5
8'd178: {o_a3, o_a4, o_a5} = {47'h18fadc4933c0,  47'hfac7623e43d,  22'ha1d8e}; // a3, a4, a5
8'd179: {o_a3, o_a4, o_a5} = {47'h187f091803b2,  47'hf48d8bfd4ab,  22'h9cf33}; // a3, a4, a5
8'd180: {o_a3, o_a4, o_a5} = {47'h180646b93270,  47'hee83ce736b3,  22'h983a0}; // a3, a4, a5
8'd181: {o_a3, o_a4, o_a5} = {47'h17907d8e540c,  47'he8a874ea8ef,  22'h93abb}; // a3, a4, a5
8'd182: {o_a3, o_a4, o_a5} = {47'h171d96cedd18,  47'he2f9dc7316b,  22'h8f465}; // a3, a4, a5
8'd183: {o_a3, o_a4, o_a5} = {47'h16ad7c7f7410,  47'hdd767313137,  22'h8b086}; // a3, a4, a5
8'd184: {o_a3, o_a4, o_a5} = {47'h16401969a879,  47'hd81cb70025e,  22'h86f03}; // a3, a4, a5
8'd185: {o_a3, o_a4, o_a5} = {47'h15d559140a87,  47'hd2eb35e36a8,  22'h82fc5}; // a3, a4, a5
8'd186: {o_a3, o_a4, o_a5} = {47'h156d27ba9e64,  47'hcde08c26e38,  22'h7f2b5}; // a3, a4, a5
8'd187: {o_a3, o_a4, o_a5} = {47'h15077247a688,  47'hc8fb644bd96,  22'h7b7bc}; // a3, a4, a5
8'd188: {o_a3, o_a4, o_a5} = {47'h14a4264cc0af,  47'hc43a7649b3a,  22'h77ec5}; // a3, a4, a5
8'd189: {o_a3, o_a4, o_a5} = {47'h144331fc516e,  47'hbf9c86f4d2c,  22'h747bd}; // a3, a4, a5
8'd190: {o_a3, o_a4, o_a5} = {47'h13e484233a66,  47'hbb20676cfb0,  22'h7128f}; // a3, a4, a5
8'd191: {o_a3, o_a4, o_a5} = {47'h13880c22d778,  47'hb6c4f492e7a,  22'h6df2b}; // a3, a4, a5
8'd192: {o_a3, o_a4, o_a5} = {47'h132db9eb3f7a,  47'hb2891684a2b,  22'h6ad7d}; // a3, a4, a5
8'd193: {o_a3, o_a4, o_a5} = {47'h12d57df5c524,  47'hae6bc02044c,  22'h67d76}; // a3, a4, a5
8'd194: {o_a3, o_a4, o_a5} = {47'h127f493fb50f,  47'haa6bee8cc4a,  22'h64f05}; // a3, a4, a5
8'd195: {o_a3, o_a4, o_a5} = {47'h122b0d454de4,  47'ha688a8c8849,  22'h6221a}; // a3, a4, a5
8'd196: {o_a3, o_a4, o_a5} = {47'h11d8bbfcefdb,  47'ha2c0ff3d4ed,  22'h5f6a8}; // a3, a4, a5
8'd197: {o_a3, o_a4, o_a5} = {47'h118847d280f7,  47'h9f140b5978e,  22'h5cca0}; // a3, a4, a5
8'd198: {o_a3, o_a4, o_a5} = {47'h1139a3a3036f,  47'h9b80ef2de78,  22'h5a3f4}; // a3, a4, a5
8'd199: {o_a3, o_a4, o_a5} = {47'h10ecc2b85bee,  47'h9806d510b31,  22'h57c97}; // a3, a4, a5
8'd200: {o_a3, o_a4, o_a5} = {47'h10a198c5456a,  47'h94a4ef442dd,  22'h5567d}; // a3, a4, a5
8'd201: {o_a3, o_a4, o_a5} = {47'h105819e1705c,  47'h915a77a213c,  22'h5319b}; // a3, a4, a5
8'd202: {o_a3, o_a4, o_a5} = {47'h10103a85cb78,  47'h8e26af4aab1,  22'h50de4}; // a3, a4, a5
8'd203: {o_a3, o_a4, o_a5} = { 47'hfc9ef88f3ce,  47'h8b08de57a3b,  22'h4eb4e}; // a3, a4, a5
8'd204: {o_a3, o_a4, o_a5} = { 47'hf852e1bcaa2,  47'h8800539283f,  22'h4c9cf}; // a3, a4, a5
8'd205: {o_a3, o_a4, o_a5} = { 47'hf41ebc62f31,  47'h850c642e744,  22'h4a95b}; // a3, a4, a5
8'd206: {o_a3, o_a4, o_a5} = { 47'hf001e63dac2,  47'h822c6b853f0,  22'h489eb}; // a3, a4, a5
8'd207: {o_a3, o_a4, o_a5} = { 47'hebfbc215d72,  47'h7f5fcad75ad,  22'h46b73}; // a3, a4, a5
8'd208: {o_a3, o_a4, o_a5} = { 47'he80bb793a3c,  47'h7ca5e90ed8e,  22'h44ded}; // a3, a4, a5
8'd209: {o_a3, o_a4, o_a5} = { 47'he43133120e5,  47'h79fe3285120,  22'h4314e}; // a3, a4, a5
8'd210: {o_a3, o_a4, o_a5} = { 47'he06ba574459,  47'h776818caf02,  22'h4158f}; // a3, a4, a5
8'd211: {o_a3, o_a4, o_a5} = { 47'hdcba83fcc50,  47'h74e31273b2c,  22'h3faa8}; // a3, a4, a5
8'd212: {o_a3, o_a4, o_a5} = { 47'hd91d48260f3,  47'h726e9ae2107,  22'h3e092}; // a3, a4, a5
8'd213: {o_a3, o_a4, o_a5} = { 47'hd5936f7cf5e,  47'h700a3217960,  22'h3c745}; // a3, a4, a5
8'd214: {o_a3, o_a4, o_a5} = { 47'hd21c7b7c5ec,  47'h6db55c86292,  22'h3aeba}; // a3, a4, a5
8'd215: {o_a3, o_a4, o_a5} = { 47'hceb7f16a73b,  47'h6b6fa2e3937,  22'h396ea}; // a3, a4, a5
8'd216: {o_a3, o_a4, o_a5} = { 47'hcb655a372f3,  47'h693891fefca,  22'h37fd0}; // a3, a4, a5
8'd217: {o_a3, o_a4, o_a5} = { 47'hc824425c352,  47'h670fba983c5,  22'h36964}; // a3, a4, a5
8'd218: {o_a3, o_a4, o_a5} = { 47'hc4f439bdea7,  47'h64f4b138ed5,  22'h353a2}; // a3, a4, a5
8'd219: {o_a3, o_a4, o_a5} = { 47'hc1d4d38dbc9,  47'h62e70e0f2c5,  22'h33e83}; // a3, a4, a5
8'd220: {o_a3, o_a4, o_a5} = { 47'hbec5a62d8da,  47'h60e66cc9ee9,  22'h32a01}; // a3, a4, a5
8'd221: {o_a3, o_a4, o_a5} = { 47'hbbc64b1436f,  47'h5ef26c76dcd,  22'h31619}; // a3, a4, a5
8'd222: {o_a3, o_a4, o_a5} = { 47'hb8d65eb3174,  47'h5d0aaf61a0b,  22'h302c3}; // a3, a4, a5
8'd223: {o_a3, o_a4, o_a5} = { 47'hb5f5805ca0c,  47'h5b2edaf4930,  22'h2effc}; // a3, a4, a5
8'd224: {o_a3, o_a4, o_a5} = { 47'hb323522bdc9,  47'h595e979aba7,  22'h2ddbf}; // a3, a4, a5
8'd225: {o_a3, o_a4, o_a5} = { 47'hb05f78ecd95,  47'h579990a30c0,  22'h2cc07}; // a3, a4, a5
8'd226: {o_a3, o_a4, o_a5} = { 47'hada99c05fa2,  47'h55df7424dce,  22'h2bad0}; // a3, a4, a5
8'd227: {o_a3, o_a4, o_a5} = { 47'hab0165621ec,  47'h542ff2e5798,  22'h2aa15}; // a3, a4, a5
8'd228: {o_a3, o_a4, o_a5} = { 47'ha866815b992,  47'h528ac03ed2a,  22'h299d4}; // a3, a4, a5
8'd229: {o_a3, o_a4, o_a5} = { 47'ha5d89ea7eaa,  47'h50ef920735b,  22'h28a07}; // a3, a4, a5
8'd230: {o_a3, o_a4, o_a5} = { 47'ha3576e443e8,  47'h4f5e207a02a,  22'h27aaa}; // a3, a4, a5
8'd231: {o_a3, o_a4, o_a5} = { 47'ha0e2a3629bb,  47'h4dd6262154b,  22'h26bbc}; // a3, a4, a5
8'd232: {o_a3, o_a4, o_a5} = { 47'h9e79f357c4e,  47'h4c575fc093b,  22'h25d37}; // a3, a4, a5
8'd233: {o_a3, o_a4, o_a5} = { 47'h9c1d1589c15,  47'h4ae18c3fe1f,  22'h24f18}; // a3, a4, a5
8'd234: {o_a3, o_a4, o_a5} = { 47'h99cbc35f064,  47'h49746c985eb,  22'h2415d}; // a3, a4, a5
8'd235: {o_a3, o_a4, o_a5} = { 47'h9785b82e3b8,  47'h480fc3c1329,  22'h23402}; // a3, a4, a5
8'd236: {o_a3, o_a4, o_a5} = { 47'h954ab12e945,  47'h46b3569d5d8,  22'h22704}; // a3, a4, a5
8'd237: {o_a3, o_a4, o_a5} = { 47'h931a6d68b72,  47'h455eebea3d9,  22'h21a60}; // a3, a4, a5
8'd238: {o_a3, o_a4, o_a5} = { 47'h90f4ada82df,  47'h44124c2ec6b,  22'h20e14}; // a3, a4, a5
8'd239: {o_a3, o_a4, o_a5} = { 47'h8ed9346d5b0,  47'h42cd41ab63c,  22'h2021c}; // a3, a4, a5
8'd240: {o_a3, o_a4, o_a5} = { 47'h8cc7c5dfeb0,  47'h418f984a792,  22'h1f676}; // a3, a4, a5
8'd241: {o_a3, o_a4, o_a5} = { 47'h8ac027c1c18,  47'h40591d91829,  22'h1eb20}; // a3, a4, a5
8'd242: {o_a3, o_a4, o_a5} = { 47'h88c2216259a,  47'h3f29a092c49,  22'h1e017}; // a3, a4, a5
8'd243: {o_a3, o_a4, o_a5} = { 47'h86cd7b92976,  47'h3e00f1df8c9,  22'h1d558}; // a3, a4, a5
8'd244: {o_a3, o_a4, o_a5} = { 47'h84e20099043,  47'h3cdee37af80,  22'h1cae2}; // a3, a4, a5
8'd245: {o_a3, o_a4, o_a5} = { 47'h82ff7c26744,  47'h3bc348cd3de,  22'h1c0b2}; // a3, a4, a5
8'd246: {o_a3, o_a4, o_a5} = { 47'h8125bb4b0e2,  47'h3aadf697750,  22'h1b6c7}; // a3, a4, a5
8'd247: {o_a3, o_a4, o_a5} = { 47'h7f548c6bb3d,  47'h399ec2e7d12,  22'h1ad1d}; // a3, a4, a5
8'd248: {o_a3, o_a4, o_a5} = { 47'h7d8bbf37c6f,  47'h3895850e527,  22'h1a3b4}; // a3, a4, a5
8'd249: {o_a3, o_a4, o_a5} = { 47'h7bcb249f468,  47'h37921591e32,  22'h19a88}; // a3, a4, a5
8'd250: {o_a3, o_a4, o_a5} = { 47'h7a128ec9417,  47'h36944e25dce,  22'h19199}; // a3, a4, a5
8'd251: {o_a3, o_a4, o_a5} = { 47'h7861d10a9c0,  47'h359c099ff41,  22'h188e5}; // a3, a4, a5
8'd252: {o_a3, o_a4, o_a5} = { 47'h76b8bfdd23c,  47'h34a923ee827,  22'h1806a}; // a3, a4, a5
8'd253: {o_a3, o_a4, o_a5} = { 47'h751730d6f03,  47'h33bb7a0f2f1,  22'h17825}; // a3, a4, a5
8'd254: {o_a3, o_a4, o_a5} = { 47'h737cfaa20c8,  47'h32d2ea05ee6,  22'h17017}; // a3, a4, a5
default:{o_a3, o_a4, o_a5} = { 47'h71e9f4f4680,  47'h31ef52d457b,  22'h1683c}; // a3, a4, a5
    endcase
end

endmodule