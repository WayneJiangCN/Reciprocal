module ipsxe_floating_point_rom_golden_result #(
    parameter EXP_WIDTH = 8,
    parameter MAN_WIDTH = 23,
    parameter OP_SEL = 0
) (
    input clk,
    input [3:0] rd_addr,
    output reg [(1+EXP_WIDTH+MAN_WIDTH)-1:0] dout
);

generate
if (OP_SEL == 0) begin
always @(posedge clk) begin: blk_rom_golden_result_0
    case(rd_addr)
    4'd0: dout <= {1'b0, 1'b1, {(EXP_WIDTH-2){1'b0}}, 1'b1, {(MAN_WIDTH){1'b0}}}; // 32'h40800000; // 4;
    4'd1: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    4'd2: dout <= {1'b0, {EXP_WIDTH{1'b1}}, {MAN_WIDTH{1'b0}}}; // +inf
    4'd3: dout <= 0;
    default: dout <= 0;
    endcase
end
end
else if (OP_SEL == 1) begin
always @(posedge clk) begin: blk_rom_golden_result_1
    case(rd_addr)
    4'd0: dout <= {1'b0, 1'b1, {(EXP_WIDTH-2){1'b0}}, 1'b1, {(MAN_WIDTH){1'b0}}}; // 32'h40800000; // 4;
    4'd1: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // 4 + NaN = NaN
    4'd2: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN + +inf = NaN
    4'd3: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN + 0 = NaN
    default: dout <= 0;
    endcase
end
end
else if (OP_SEL == 2) begin
always @(posedge clk) begin: blk_rom_golden_result_2
    case(rd_addr)
    4'd0: dout <= {1'b0, 1'b1, {(EXP_WIDTH-3){1'b0}}, 1'b1, 1'b0, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // 32'h41400000; // 12;
    4'd1: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    4'd2: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    4'd3: dout <= 0;
    default: dout <= 0;
    endcase
end
end
else if (OP_SEL == 3) begin
always @(posedge clk) begin: blk_rom_golden_result_3
    case(rd_addr)
    4'd0: dout <= 0;
    4'd1: dout <= 1;
    4'd2: dout <= 1;
    4'd3: dout <= 0;
    default: dout <= 0;
    endcase
end
end
else if (OP_SEL == 4) begin
always @(posedge clk) begin: blk_rom_golden_result_4
    case(rd_addr)
    4'd0: dout <= {1'b0, 1'b0, {(EXP_WIDTH-2){1'b1}}, 1'b0, {MAN_WIDTH{1'b0}}}; // 0.5
    4'd1: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    4'd2: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    4'd3: dout <= 0;
    default: dout <= 0;
    endcase
end
end
else if (OP_SEL == 5) begin
always @(posedge clk) begin: blk_rom_golden_result_5
    case(rd_addr)
    4'd0: dout <= 32'h425a6481; // e ^ 4
    4'd1: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    4'd2: dout <= {1'b0, {EXP_WIDTH{1'b1}}, {MAN_WIDTH{1'b0}}}; // +inf
    4'd3: dout <= {1'b0, 1'b0, {(EXP_WIDTH-1){1'b1}}, {MAN_WIDTH{1'b0}}}; // 1
    default: dout <= 0;
    endcase
end
end
else if (OP_SEL == 6) begin
always @(posedge clk) begin: blk_rom_golden_result_6
    case(rd_addr)
    4'd0: dout <= 32'h4e810000; // 32'h40800000 -> (fixed)1082130432
    4'd1: dout <= 32'h4eff8000; // NaN(7fc00000) -> fixed 2143289344
    4'd2: dout <= 32'h4eff0000; // +inf(7f800000) -> fixed 2139095040
    4'd3: dout <= 0;
    default: dout <= 0;
    endcase
end
end
else if (OP_SEL == 7) begin
always @(posedge clk) begin: blk_rom_golden_result_7
    case(rd_addr)
    4'd0: dout <= 4;
    4'd1: dout <= {1'b1, {(EXP_WIDTH+MAN_WIDTH){1'b0}}}; // most negative number
    4'd2: dout <= {1'b0, {(EXP_WIDTH+MAN_WIDTH){1'b1}}}; // most positive number
    4'd3: dout <= 0;
    default: dout <= 0;
    endcase
end
end
else if (OP_SEL == 8) begin
always @(posedge clk) begin: blk_rom_golden_result_8
    case(rd_addr)
    4'd0: dout <= {1'b0, 1'b1, {(EXP_WIDTH-2){1'b0}}, 1'b1, {(MAN_WIDTH){1'b0}}}; // 32'h40800000; // 4;
    4'd1: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    4'd2: dout <= {1'b0, {EXP_WIDTH{1'b1}}, {MAN_WIDTH{1'b0}}}; // +inf
    4'd3: dout <= 0;
    default: dout <= 0;
    endcase
end
end
else if (OP_SEL == 9) begin
always @(posedge clk) begin: blk_rom_golden_result_9
    case(rd_addr)
    4'd0: dout <= {1'b0, 1'b1, {(EXP_WIDTH-4){1'b0}}, 1'b1, 2'b0, 2'b0, 2'b1, {(MAN_WIDTH-4){1'b0}}}; // 4*8+6=38;
    4'd1: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    4'd2: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    4'd3: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    default: dout <= 0;
    endcase
end
end
else if (OP_SEL == 10) begin
always @(posedge clk) begin: blk_rom_golden_result_10
    case(rd_addr)
    4'd0: dout <= 32'h3fb17218; // ln 4
    4'd1: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    4'd2: dout <= {1'b0, {EXP_WIDTH{1'b1}}, {MAN_WIDTH{1'b0}}}; // +inf
    4'd3: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    default: dout <= 0;
    endcase
end
end
else if (OP_SEL == 11) begin
always @(posedge clk) begin: blk_rom_golden_result_11
    case(rd_addr)
    4'd0: dout <= {1'b0, 1'b1, {(EXP_WIDTH-4){1'b0}}, 1'b1, 2'b0, {MAN_WIDTH{1'b0}}}; // 4*8=32;
    4'd1: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    4'd2: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    4'd3: dout <= 0;
    default: dout <= 0;
    endcase
end
end
else if (OP_SEL == 12) begin
always @(posedge clk) begin: blk_rom_golden_result_12
    case(rd_addr)
    4'd0: dout <= {1'b0, 1'b0, {(EXP_WIDTH-3){1'b1}}, 1'b0, 1'b1, {MAN_WIDTH{1'b0}}}; // 1/4=0.25;
    4'd1: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    4'd2: dout <= 0;
    4'd3: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    default: dout <= 0;
    endcase
end
end
else if (OP_SEL == 13) begin
always @(posedge clk) begin: blk_rom_golden_result_13
    case(rd_addr)
    4'd0: dout <= {1'b0, 1'b0, {(EXP_WIDTH-2){1'b1}}, 1'b0, {MAN_WIDTH{1'b0}}}; // 0.5
    4'd1: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    4'd2: dout <= 0;
    4'd3: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    default: dout <= 0;
    endcase
end
end
else if (OP_SEL == 14) begin
always @(posedge clk) begin: blk_rom_golden_result_14
    case(rd_addr)
    4'd0: dout <= {1'b0, 1'b1, {(EXP_WIDTH-1){1'b0}}, {MAN_WIDTH{1'b0}}}; // 2
    4'd1: dout <= {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {(MAN_WIDTH-1){1'b0}}}; // NaN
    4'd2: dout <= {1'b0, {EXP_WIDTH{1'b1}}, {MAN_WIDTH{1'b0}}}; // +inf
    4'd3: dout <= 0;
    default: dout <= 0;
    endcase
end
end

endgenerate

endmodule