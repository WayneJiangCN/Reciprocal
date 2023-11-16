//????RAM??????ROM
module n_rom #(
    parameter ADDR_TOTAL = 8,
    parameter ADDR_WIDTH = 3,
    parameter OUTPUT_BIT_WIDTH = 6
)
(
    input rd_en, 
    input [ADDR_WIDTH-1:0] rd_addr, 
    output [OUTPUT_BIT_WIDTH-1:0] dout
);

(*rom_style = "block" *) reg [OUTPUT_BIT_WIDTH-1:0] rom_ndata;

assign dout = rom_ndata;

always @(*) begin
    if (rd_en)
        case(rd_addr)
            0: rom_ndata =  6'h3c;
            1: rom_ndata =  6'h2f;
            2: rom_ndata =  6'h26;
            3: rom_ndata =  6'h20;
            4: rom_ndata =  6'h1b;
            5: rom_ndata =  6'h17;
            6: rom_ndata =  6'h14;
            7: rom_ndata =  6'h11;
            default: rom_ndata = 6'h0;
        endcase
end



endmodule

