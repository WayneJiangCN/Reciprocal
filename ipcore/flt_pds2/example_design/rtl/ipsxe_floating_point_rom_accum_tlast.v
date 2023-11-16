module ipsxe_floating_point_rom_accum_tlast (
    input clk,
    input [3:0] rd_addr,
    output reg dout
);

always @(posedge clk) begin: blk_rom_accum_tlast
    case(rd_addr)
    4'd0: dout <= 1'b0;
    4'd1: dout <= 1'b0;
    4'd2: dout <= 1'b0;
    4'd3: dout <= 1'b0;
    4'd4: dout <= 1'b0;
    4'd5: dout <= 1'b0;
    4'd6: dout <= 1'b0;
    4'd7: dout <= 1'b1;
    4'd8: dout <= 1'b0;
    4'd9: dout <= 1'b1;
    default: dout <= 1'b0;
    endcase
end

endmodule