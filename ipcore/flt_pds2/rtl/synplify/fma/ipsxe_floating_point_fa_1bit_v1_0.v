module ipsxe_floating_point_fa_1bit_v1_0
(
    input   i_a,
    input   i_b,
    input   i_c,
    output  o_c,
    output  o_s

);


	assign o_s = i_a ^ i_b ^ i_c;
	assign o_c = (i_a & i_b) | (i_a & i_c) | (i_b & i_c);

endmodule
