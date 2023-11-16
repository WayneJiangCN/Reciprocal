module floating_point_rom_c #(
    parameter EXP_WIDTH = 8,
    parameter MAN_WIDTH = 23
) (
    input clk,
    input [3:0] rd_addr,
    output reg [(1+EXP_WIDTH+MAN_WIDTH)-1:0] dout
);

generate
if (EXP_WIDTH == 8) begin
always @(posedge clk) begin: blk_rom_c_single
    case(rd_addr)
    4'd0: dout <= 32'he2f7_84c5;
    4'd1: dout <= 32'hd513_d2aa;
    4'd2: dout <= 32'h72af_f7e5;
    4'd3: dout <= 32'hbbd2_7277;
    4'd4: dout <= 32'h8932_d612;
    4'd5: dout <= 32'h47ec_db8f;
    4'd6: dout <= 32'h7930_69f2;
    4'd7: dout <= 32'h0;
    4'd8: dout <= {1'b0, {EXP_WIDTH{1'b1}}, {MAN_WIDTH{1'b0}}}; // +inf
    4'd9: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    default: dout <= 32'he776_96ce;
    endcase
end
end
else begin
always @(posedge clk) begin: blk_rom_c_double
    case(rd_addr)
    4'd0: dout <= 64'hbbd2_7277_e2f7_84c5;
    4'd1: dout <= 64'hd513_d2aa_7930_69f2;
    4'd2: dout <= 64'h72af_f7e5_e2f7_84c5;
    4'd3: dout <= 64'hd513_d2aa_bbd2_7277;
    4'd4: dout <= 64'h72af_f7e5_8932_d612;
    4'd5: dout <= 64'h47ec_db8f_e776_96ce;
    4'd6: dout <= 64'h7930_69f2_8932_d612;
    4'd7: dout <= 64'h0;
    4'd8: dout <= {1'b0, {EXP_WIDTH{1'b1}}, {MAN_WIDTH{1'b0}}}; // +inf
    4'd9: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    default: dout <= 64'he776_96ce_47ec_db8f;
    endcase
end
end
endgenerate

endmodule