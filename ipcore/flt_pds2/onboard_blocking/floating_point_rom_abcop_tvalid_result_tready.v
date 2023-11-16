module floating_point_rom_abcop_tvalid_result_tready (
    input clk,
    input [4:0] rd_addr,
    output reg [4:0] dout
);

always @(posedge clk) begin: blk_rom_abcop_tvalid_result_tready
    case(rd_addr)
    5'd0 : dout <= 5'b01011;
    5'd1 : dout <= 5'b10101;
    5'd2 : dout <= 5'b01101;
    5'd3 : dout <= 5'b10011;
    5'd4 : dout <= 5'b11001;
    5'd5 : dout <= 5'b00110;
    5'd6 : dout <= 5'b00100;
    5'd7 : dout <= 5'b00010;
    5'd8 : dout <= 5'b10110;
    5'd9 : dout <= 5'b01100;
    5'd10: dout <= 5'b01011;
    5'd11: dout <= 5'b10101;
    5'd12: dout <= 5'b00011;
    5'd13: dout <= 5'b10001;
    5'd14: dout <= 5'b11001;
    5'd15: dout <= 5'b00100;
    5'd16: dout <= 5'b00000;
    5'd17: dout <= 5'b01000;
    5'd18: dout <= 5'b10010;
    5'd19: dout <= 5'b01000;
    default: dout <= 5'b00001;
    endcase
end

endmodule