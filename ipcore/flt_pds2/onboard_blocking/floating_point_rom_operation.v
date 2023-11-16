module floating_point_rom_operation (
    input clk,
    input [4:0] rd_addr,
    output reg [7:0] dout
);

always @(posedge clk) begin: blk_rom_operation
    case(rd_addr)
    5'd0: dout <= 8'h48;
    5'd1: dout <= 8'h65;
    5'd2: dout <= 8'ha3;
    5'd3: dout <= 8'h5c;
    5'd4: dout <= 8'hf2;
    5'd5: dout <= 8'hdd;
    5'd6: dout <= 8'h9b;
    5'd7: dout <= 8'h62;
    5'd8: dout <= 8'hd5;
    5'd9: dout <= 8'h0f;
    5'd10: dout <= 8'h48;
    5'd11: dout <= 8'h65;
    5'd12: dout <= 8'ha3;
    5'd13: dout <= 8'h5c;
    5'd14: dout <= 8'hf2;
    5'd15: dout <= 8'hdd;
    5'd16: dout <= 8'h9b;
    5'd17: dout <= 8'h62;
    5'd18: dout <= 8'hd5;
    5'd19: dout <= 8'h0f;
    default: dout <= 8'h0;
    endcase
end

endmodule