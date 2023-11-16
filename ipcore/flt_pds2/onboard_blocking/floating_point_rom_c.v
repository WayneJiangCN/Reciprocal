module floating_point_rom_c (
    input clk,
    input [4:0] rd_addr,
    output reg [31:0] dout
);

always @(posedge clk) begin: blk_rom_c
    case(rd_addr)
    5'd0: dout <= 32'he2f7_84c5;
    5'd1: dout <= 32'hd513_d2aa;
    5'd2: dout <= 32'h72af_f7e5;
    5'd3: dout <= 32'hbbd2_7277;
    5'd4: dout <= 32'h8932_d612;
    5'd5: dout <= 32'h47ec_db8f;
    5'd6: dout <= 32'h7930_69f2;
    5'd7: dout <= 32'h0;
    5'd8: dout <= {1'b0, {8{1'b1}}, {23{1'b0}}}; // +inf
    5'd9: dout <= {1'b0, {8{1'b1}}, 1'b1, {(23-1){1'b0}}}; // NaN
    5'd10: dout <= 32'he2f7_84c5;
    5'd11: dout <= 32'hd513_d2aa;
    5'd12: dout <= 32'h72af_f7e5;
    5'd13: dout <= 32'hbbd2_7277;
    5'd14: dout <= 32'h8932_d612;
    5'd15: dout <= 32'h47ec_db8f;
    5'd16: dout <= 32'h7930_69f2;
    5'd17: dout <= 32'h0;
    5'd18: dout <= {1'b0, {8{1'b1}}, {23{1'b0}}}; // +inf
    5'd19: dout <= {1'b0, {8{1'b1}}, 1'b1, {(23-1){1'b0}}}; // NaN
    default: dout <= 32'he776_96ce;
    endcase
end

endmodule