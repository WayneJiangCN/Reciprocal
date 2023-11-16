module ipsxe_floating_point_rom_operation (
    input clk,
    input [3:0] rd_addr,
    output reg [7:0] dout
);

always @(posedge clk) begin: blk_rom_operation
    case(rd_addr)
    4'd0: dout <= {2'b0, 3'b001, 2'b0, 1'b0};
    4'd1: dout <= {2'b0, 3'b001, 2'b0, 1'b0};
    4'd2: dout <= {2'b0, 3'b001, 2'b0, 1'b0};
    4'd3: dout <= {2'b0, 3'b001, 2'b0, 1'b0};
    default: dout <= {2'b0, 3'b001, 2'b0, 1'b0};
    endcase
end

endmodule