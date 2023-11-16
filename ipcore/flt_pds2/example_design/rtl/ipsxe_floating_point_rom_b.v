module ipsxe_floating_point_rom_b #(
    parameter EXP_WIDTH = 8,
    parameter MAN_WIDTH = 23
) (
    input clk,
    input [3:0] rd_addr,
    output reg [(1+EXP_WIDTH+MAN_WIDTH)-1:0] dout
);

always @(posedge clk) begin: blk_rom_b
    case(rd_addr)
    4'd0: dout <= {1'b0, 1'b1, {(EXP_WIDTH-3){1'b0}}, 1'b1, 1'b0, {MAN_WIDTH{1'b0}}}; // 32'h41000000; // 8;
    4'd1: dout <= {1'b0, {EXP_WIDTH{1'b1}}, {MAN_WIDTH{1'b0}}}; // +inf
    4'd2: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    4'd3: dout <= 0;
    default: dout <= 0;
    endcase
end

endmodule