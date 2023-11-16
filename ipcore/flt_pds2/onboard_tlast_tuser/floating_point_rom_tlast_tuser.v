module floating_point_rom_tlast_tuser (
    input clk,
    input [3:0] rd_addr,
    output reg [7:0] dout
);

always @(posedge clk) begin: blk_rom_tlast_tuser
    case(rd_addr)
    4'd0: dout <= 8'h90;
    4'd1: dout <= 8'h81;
    4'd2: dout <= 8'h72;
    4'd3: dout <= 8'h63;
    4'd4: dout <= 8'h54;
    4'd5: dout <= 8'h45;
    4'd6: dout <= 8'h36;
    4'd7: dout <= 8'h27;
    4'd8: dout <= 8'h18;
    4'd9: dout <= 8'h09;
    default: dout <= 8'h00;
    endcase
end

endmodule