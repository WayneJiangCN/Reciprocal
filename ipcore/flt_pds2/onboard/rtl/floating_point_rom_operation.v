module floating_point_rom_operation (
    input clk,
    input [3:0] rd_addr,
    output reg [7:0] dout
);

always @(posedge clk) begin: blk_rom_operation
    case(rd_addr)
    4'd0: dout <= 8'h48;
    4'd1: dout <= 8'h65;
    4'd2: dout <= 8'ha3;
    4'd3: dout <= 8'h5c;
    4'd4: dout <= 8'hf2;
    4'd5: dout <= 8'hdd;
    4'd6: dout <= 8'h9b;
    4'd7: dout <= 8'h62;
    4'd8: dout <= 8'hd5;
    4'd9: dout <= 8'h0f;
    default: dout <= 8'h0;
    endcase
end

endmodule