module ipsxe_floating_point_rom_addr_counter (
    input clk,
    input rst_n,
    output reg tvalid,
    output reg [3:0] rom_addr_cnt
);

always @(posedge clk) begin: blk_rom_addr_cnt
    if (!rst_n) begin
        tvalid <= 1'b0;
        rom_addr_cnt <= 4'b0;
    end
    else
        if (rom_addr_cnt == 4'd4) begin
            tvalid <= 1'b0;
            rom_addr_cnt <= 4'd4;
        end
        else begin
            tvalid <= 1'b1;
            rom_addr_cnt <= rom_addr_cnt + 1;
        end
end

endmodule