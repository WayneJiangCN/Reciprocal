//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
//
// Library:
// Filename: ipsxe_floating_point_axi_buffer_1io_v1_0.v
// Function: The module is used as FIFO for 1 data stream, performing
//     in Blocking Mode. Please set the depth of FIFO as the desired
//     specification.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_axi_buffer_1io_v1_0 #(
    parameter TLAST_TUSER_TDATA_A_WIDTH     = 32 //data bus width
)(
    input                              i_aclk,
    input                              i_areset_n,

    //Input Stream
    input      [TLAST_TUSER_TDATA_A_WIDTH-1:0]     i_a_tlast_tuser_tdata, //input data
    input                              i_a_tvalid, //input data valid
    output reg                         o_a_tready, //to master, fifo is ready for new data

    //Output Stream
    input                              i_tready, //to fifo, slave is ready for new data
    output reg                         o_tvalid, //output data valid
    output reg [TLAST_TUSER_TDATA_A_WIDTH-1:0]     o_a_tlast_tuser_tdata //output data
);

// **********************************************************
//             Parameters
// **********************************************************
    localparam MEM_DEPTH     = 8; //maximum MEM_DEPTH = 2 ^ ADDR_WIDTH
    localparam ADDR_WIDTH    = 8; //recommended maximum

// **********************************************************
//             Global wires
// **********************************************************
    wire                        data_valid;
    wire                        valid_out;

    wire                        wr_en_a;
    wire                        rd_en_a;
    reg  [ADDR_WIDTH-1:0]       cnt_a;
    reg  [ADDR_WIDTH-1:0]       wr_addr_a;
    reg  [ADDR_WIDTH-1:0]       rd_addr_a;
    wire [TLAST_TUSER_TDATA_A_WIDTH-1:0]      m_a_tlast_tuser_tdata_mem;

// **********************************************************
//             Stream A
// **********************************************************
    assign wr_en_a = i_a_tvalid & o_a_tready & (!valid_out | cnt_a != 0);

    always @(posedge i_aclk or negedge i_areset_n) begin: blk_wr_addr_a
        if(!i_areset_n) begin
            wr_addr_a <= 0;
        end
        else if(wr_en_a) begin
            wr_addr_a <= (wr_addr_a < MEM_DEPTH-1) ? wr_addr_a+1 : 0;
        end
    end

    assign rd_en_a = valid_out & cnt_a != 0;

    always @(posedge i_aclk or negedge i_areset_n) begin: blk_rd_addr_a
        if(!i_areset_n) begin
            rd_addr_a <= 0;
        end
        else if(rd_en_a) begin
            rd_addr_a <= (rd_addr_a < MEM_DEPTH-1) ? rd_addr_a+1 : 0;
        end
    end

    always @(posedge i_aclk or negedge i_areset_n) begin: blk_o_a_tready
        if(!i_areset_n) begin
            cnt_a <= 0;
            o_a_tready <= 0;
        end
        else begin
            case ({wr_en_a, rd_en_a})
                2'b00: begin
                    cnt_a <= cnt_a;
                    o_a_tready <= valid_out | (cnt_a < MEM_DEPTH);
                end
                2'b01: begin
                    cnt_a <= cnt_a - 1;
                    o_a_tready <= 1;
                end
                2'b10: begin
                    cnt_a <= cnt_a + 1;//(cnt_a < MEM_DEPTH) ? cnt_a+1 : cnt_a;
                    o_a_tready <= cnt_a < MEM_DEPTH-1;
                end
                default: begin // 2'b11
                    cnt_a <= cnt_a;
                    o_a_tready <= valid_out | (cnt_a < MEM_DEPTH);
                end
            endcase
        end
    end

    ipsxe_floating_point_sram_dualports_v1_0 #(
        .MEM_WIDTH      (TLAST_TUSER_TDATA_A_WIDTH),
        .MEM_DEPTH      (MEM_DEPTH),
        .ADDR_WIDTH     (ADDR_WIDTH)
    ) u_fifo_a (
        .i_aclk           (i_aclk),
        .i_d              (i_a_tlast_tuser_tdata),
        .i_wa             (wr_addr_a),
        .i_we             (wr_en_a),
        .i_ra             (rd_addr_a),
        .i_re             (rd_en_a),
        .o_q              (m_a_tlast_tuser_tdata_mem)
    );


// **********************************************************
//             Output Stream
// **********************************************************
    assign data_valid = (cnt_a != 0 | i_a_tvalid);
    assign valid_out = i_tready ? data_valid : data_valid & !o_tvalid;

    always @(posedge i_aclk or negedge i_areset_n) begin: blk_o_tvalid
        if(!i_areset_n) begin
            o_tvalid <= 0;
        end
        else begin
            if(i_tready)
                o_tvalid <= valid_out;
            else if(valid_out)
                o_tvalid <= 1;
        end
    end

    always @(posedge i_aclk or negedge i_areset_n) begin: blk_o_a_tlast_tuser_tdata
        if(!i_areset_n) begin
            o_a_tlast_tuser_tdata <= 0;
        end
        else if(valid_out) begin
            o_a_tlast_tuser_tdata <= cnt_a != 0 ? m_a_tlast_tuser_tdata_mem : i_a_tlast_tuser_tdata;
        end
    end

endmodule