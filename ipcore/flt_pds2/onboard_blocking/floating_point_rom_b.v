module floating_point_rom_b (
    input clk,
    input [4:0] rd_addr,
    output reg [31:0] dout
);

always @(posedge clk) begin: blk_rom_b
    case(rd_addr)
    5'd0: dout <= 32'h00f3_e301;
    5'd1: dout <= 32'h06d7_cd0d;
    5'd2: dout <= 32'h3b23_f176;
    5'd3: dout <= 32'h1e8d_cd3d;
    5'd4: dout <= 32'h76d4_57ed;
    5'd5: dout <= 32'h462d_f78c;
    5'd6: dout <= 32'h7cfd_e9f9;
    5'd7: dout <= {1'b0, {8{1'b1}}, 1'b1, {(23-1){1'b0}}}; // NaN
    5'd8: dout <= 32'h0;
    5'd9: dout <= {1'b0, {8{1'b1}}, {23{1'b0}}}; // +inf
    5'd10: dout <= 32'h00f3_e301;
    5'd11: dout <= 32'h06d7_cd0d;
    5'd12: dout <= 32'h3b23_f176;
    5'd13: dout <= 32'h1e8d_cd3d;
    5'd14: dout <= 32'h76d4_57ed;
    5'd15: dout <= 32'h462d_f78c;
    5'd16: dout <= 32'h7cfd_e9f9;
    5'd17: dout <= {1'b0, {8{1'b1}}, 1'b1, {(23-1){1'b0}}}; // NaN
    5'd18: dout <= 32'h0;
    5'd19: dout <= {1'b0, {8{1'b1}}, {23{1'b0}}}; // +inf
    default: dout <= 32'he337_24c6;
    endcase
end

endmodule