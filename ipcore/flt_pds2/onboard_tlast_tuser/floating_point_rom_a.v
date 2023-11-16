module floating_point_rom_a #(
    parameter EXP_WIDTH = 8,
    parameter MAN_WIDTH = 23
) (
    input clk,
    input [3:0] rd_addr,
    output reg [(1+EXP_WIDTH+MAN_WIDTH)-1:0] dout
);

generate
if (EXP_WIDTH == 8) begin
always @(posedge clk) begin: blk_rom_a_single
    case(rd_addr)
    4'd0: dout <= 32'h1215_3524;
    4'd1: dout <= 32'hc089_5e81;
    4'd2: dout <= 32'h8484_d609;
    4'd3: dout <= 32'hb1f0_5663;
    4'd4: dout <= 32'h06b9_7b0d;
    4'd5: dout <= 32'h46df_998d;
    4'd6: dout <= 32'hb2c2_8465;
    4'd7: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    4'd8: dout <= {1'b0, {EXP_WIDTH{1'b1}}, {MAN_WIDTH{1'b0}}}; // +inf
    4'd9: dout <= 32'h0;
    default: dout <= 32'h8937_5212;
    endcase
end
end
else begin
always @(posedge clk) begin: blk_rom_a_double
    case(rd_addr)
    4'd0: dout <= 64'h8484_d609_1215_3524;
    4'd1: dout <= 64'hc089_5e81_b1f0_5663;
    4'd2: dout <= 64'h8484_d609_8937_5212;
    4'd3: dout <= 64'hb2c2_8465_b1f0_5663;
    4'd4: dout <= 64'hc089_5e81_06b9_7b0d;
    4'd5: dout <= 64'h46df_998d_06b9_7b0d;
    4'd6: dout <= 64'hb2c2_8465_46df_998d;
    4'd7: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    4'd8: dout <= {1'b0, {EXP_WIDTH{1'b1}}, {MAN_WIDTH{1'b0}}}; // +inf
    4'd9: dout <= 64'h0;
    default: dout <= 64'h8937_5212_8937_5212;
    endcase
end
end
endgenerate

endmodule