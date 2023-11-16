module floating_point_rom_b #(
    parameter EXP_WIDTH = 8,
    parameter MAN_WIDTH = 23
) (
    input clk,
    input [3:0] rd_addr,
    output reg [(1+EXP_WIDTH+MAN_WIDTH)-1:0] dout
);

generate
if (EXP_WIDTH == 8) begin
always @(posedge clk) begin: blk_rom_b_single
    case(rd_addr)
    4'd0: dout <= 32'h00f3_e301;
    4'd1: dout <= 32'h06d7_cd0d;
    4'd2: dout <= 32'h3b23_f176;
    4'd3: dout <= 32'h1e8d_cd3d;
    4'd4: dout <= 32'h76d4_57ed;
    4'd5: dout <= 32'h462d_f78c;
    4'd6: dout <= 32'h7cfd_e9f9;
    4'd7: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    4'd8: dout <= 32'h0;
    4'd9: dout <= {1'b0, {EXP_WIDTH{1'b1}}, {MAN_WIDTH{1'b0}}}; // +inf
    default: dout <= 32'he337_24c6;
    endcase
end
end
else begin
always @(posedge clk) begin: blk_rom_b_double
    case(rd_addr)
    4'd0: dout <= 64'h3b23_f176_00f3_e301;
    4'd1: dout <= 64'h06d7_cd0d_7cfd_e9f9;
    4'd2: dout <= 64'he337_24c6_3b23_f176;
    4'd3: dout <= 64'h1e8d_cd3d_76d4_57ed;
    4'd4: dout <= 64'h76d4_57ed_06d7_cd0d;
    4'd5: dout <= 64'h462d_f78c_00f3_e301;
    4'd6: dout <= 64'h462d_f78c_7cfd_e9f9;
    4'd7: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    4'd8: dout <= 64'h0;
    4'd9: dout <= {1'b0, {EXP_WIDTH{1'b1}}, {MAN_WIDTH{1'b0}}}; // +inf
    default: dout <= 64'he337_24c6_e337_24c6;
    endcase
end
end
endgenerate

endmodule