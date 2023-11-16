module floating_point_rom_a (
    input clk,
    input [4:0] rd_addr,
    output reg [31:0] dout
);

always @(posedge clk) begin: blk_rom_a
    case(rd_addr)
    5'd0: dout <= 32'h1215_3524;
    5'd1: dout <= 32'hc089_5e81;
    5'd2: dout <= 32'h8484_d609;
    5'd3: dout <= 32'hb1f0_5663;
    5'd4: dout <= 32'h06b9_7b0d;
    5'd5: dout <= 32'h46df_998d;
    5'd6: dout <= 32'hb2c2_8465;
    5'd7: dout <= {1'b0, {8{1'b1}}, 1'b1, {(23-1){1'b0}}}; // NaN
    5'd8: dout <= {1'b0, {8{1'b1}}, {23{1'b0}}}; // +inf
    5'd9: dout <= 32'h0;
    5'd10: dout <= 32'h1215_3524;
    5'd11: dout <= 32'hc089_5e81;
    5'd12: dout <= 32'h8484_d609;
    5'd13: dout <= 32'hb1f0_5663;
    5'd14: dout <= 32'h06b9_7b0d;
    5'd15: dout <= 32'h46df_998d;
    5'd16: dout <= 32'hb2c2_8465;
    5'd17: dout <= {1'b0, {8{1'b1}}, 1'b1, {(23-1){1'b0}}}; // NaN
    5'd18: dout <= {1'b0, {8{1'b1}}, {23{1'b0}}}; // +inf
    5'd19: dout <= 32'h0;
    default: dout <= 32'h8937_5212;
    endcase
end

endmodule