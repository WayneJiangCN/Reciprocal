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
// Filename: ipsxe_floating_point_axi_buffer_4io_v1_0.v
// Function: The module is used as FIFO for 4 data streams, performing
//     in Blocking Mode. Please set the depth of FIFO as the desired
//     specification.
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_axi_buffer_4io_v1_0 #(
    parameter TLAST_TUSER_TDATA_A_WIDTH = 32,
    parameter TLAST_TUSER_TDATA_B_WIDTH = 1,
    parameter TLAST_TUSER_TDATA_C_WIDTH = 1,
    parameter TLAST_TUSER_TDATA_OPERATION_WIDTH = 1
)(
    input                              i_aclk,
    input                              i_areset_n,
    //Input Stream
    input      [TLAST_TUSER_TDATA_A_WIDTH-1:0]     i_a_tlast_tuser_tdata, //input data
    output reg [TLAST_TUSER_TDATA_A_WIDTH-1:0]     o_a_tlast_tuser_tdata, //output data
    input                              i_a_tvalid, //input data valid
    output reg                         o_a_tready, //to master, fifo is ready for new data
    input      [TLAST_TUSER_TDATA_B_WIDTH-1:0]     i_b_tlast_tuser_tdata, //input data
    output reg [TLAST_TUSER_TDATA_B_WIDTH-1:0]     o_b_tlast_tuser_tdata, //output data
    input                              i_b_tvalid, //input data valid
    output reg                         o_b_tready, //to master, fifo is ready for new data
    input      [TLAST_TUSER_TDATA_C_WIDTH-1:0]     i_c_tlast_tuser_tdata, //input data
    output reg [TLAST_TUSER_TDATA_C_WIDTH-1:0]     o_c_tlast_tuser_tdata, //output data
    input                              i_c_tvalid, //input data valid
    output reg                         o_c_tready, //to master, fifo is ready for new data
    input      [TLAST_TUSER_TDATA_OPERATION_WIDTH-1:0]     i_operation_tlast_tuser_tdata, //input data
    output reg [TLAST_TUSER_TDATA_OPERATION_WIDTH-1:0]     o_operation_tlast_tuser_tdata, //output data
    input                              i_operation_tvalid, //input data valid
    output reg                         o_operation_tready, //to master, fifo is ready for new data
    //Output Stream
    input                              i_tready, //to fifo, slave is ready for new data
    output reg                         o_tvalid //output data valid
);

// **********************************************************
//             Parameters
// **********************************************************
    // Set the depth as the desired specification
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
    wire [TLAST_TUSER_TDATA_A_WIDTH-1:0]      o_a_tlast_tuser_tdata_mem;
    wire                        wr_en_b;
    wire                        rd_en_b;
    reg  [ADDR_WIDTH-1:0]       cnt_b;
    reg  [ADDR_WIDTH-1:0]       wr_addr_b;
    reg  [ADDR_WIDTH-1:0]       rd_addr_b;
    wire [TLAST_TUSER_TDATA_B_WIDTH-1:0]      o_b_tlast_tuser_tdata_mem;
    wire                        wr_en_c;
    wire                        rd_en_c;
    reg  [ADDR_WIDTH-1:0]       cnt_c;
    reg  [ADDR_WIDTH-1:0]       wr_addr_c;
    reg  [ADDR_WIDTH-1:0]       rd_addr_c;
    wire [TLAST_TUSER_TDATA_C_WIDTH-1:0]      o_c_tlast_tuser_tdata_mem;
    wire                        wr_en_operation;
    wire                        rd_en_operation;
    reg  [ADDR_WIDTH-1:0]       cnt_operation;
    reg  [ADDR_WIDTH-1:0]       wr_addr_operation;
    reg  [ADDR_WIDTH-1:0]       rd_addr_operation;
    wire [TLAST_TUSER_TDATA_OPERATION_WIDTH-1:0]      o_operation_tlast_tuser_tdata_mem;
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
        .i_aclk            (i_aclk),
        .i_d               (i_a_tlast_tuser_tdata),
        .i_wa              (wr_addr_a),
        .i_we              (wr_en_a),
        .i_ra              (rd_addr_a),
        .i_re              (rd_en_a),
        .o_q               (o_a_tlast_tuser_tdata_mem)
    );

    always @(posedge i_aclk or negedge i_areset_n) begin: blk_o_a_tlast_tuser_tdata
        if(!i_areset_n) begin
            o_a_tlast_tuser_tdata <= 0;
        end
        else if(valid_out) begin
            o_a_tlast_tuser_tdata <= cnt_a != 0 ? o_a_tlast_tuser_tdata_mem : i_a_tlast_tuser_tdata;
        end
    end

// **********************************************************
//             Stream B
// **********************************************************
    assign wr_en_b = i_b_tvalid & o_b_tready & (!valid_out | cnt_b != 0);

    always @(posedge i_aclk or negedge i_areset_n) begin: blk_wr_addr_b
        if(!i_areset_n) begin
            wr_addr_b <= 0;
        end
        else if(wr_en_b) begin
            wr_addr_b <= (wr_addr_b < MEM_DEPTH-1) ? wr_addr_b+1 : 0;
        end
    end

    assign rd_en_b = valid_out & cnt_b != 0;

    always @(posedge i_aclk or negedge i_areset_n) begin: blk_rd_addr_b
        if(!i_areset_n) begin
            rd_addr_b <= 0;
        end
        else if(rd_en_b) begin
            rd_addr_b <= (rd_addr_b < MEM_DEPTH-1) ? rd_addr_b+1 : 0;
        end
    end

    always @(posedge i_aclk or negedge i_areset_n) begin: blk_o_b_tready
        if(!i_areset_n) begin
            cnt_b <= 0;
            o_b_tready <= 0;
        end
        else begin
            case ({wr_en_b, rd_en_b})
                2'b00: begin
                    cnt_b <= cnt_b;
                    o_b_tready <= valid_out | (cnt_b < MEM_DEPTH);
                end
                2'b01: begin
                    cnt_b <= cnt_b - 1;
                    o_b_tready <= 1;
                end
                2'b10: begin
                    cnt_b <= cnt_b + 1;//(cnt_b < MEM_DEPTH) ? cnt_b+1 : cnt_b;
                    o_b_tready <= cnt_b < MEM_DEPTH-1;
                end
                default: begin // 2'b11
                    cnt_b <= cnt_b;
                    o_b_tready <= valid_out | (cnt_b < MEM_DEPTH);
                end
            endcase
        end
    end

    ipsxe_floating_point_sram_dualports_v1_0 #(
        .MEM_WIDTH      (TLAST_TUSER_TDATA_B_WIDTH),
        .MEM_DEPTH      (MEM_DEPTH),
        .ADDR_WIDTH     (ADDR_WIDTH)
    ) u_fifo_b (
        .i_aclk            (i_aclk),
        .i_d               (i_b_tlast_tuser_tdata),
        .i_wa              (wr_addr_b),
        .i_we              (wr_en_b),
        .i_ra              (rd_addr_b),
        .i_re              (rd_en_b),
        .o_q               (o_b_tlast_tuser_tdata_mem)
    );

    always @(posedge i_aclk or negedge i_areset_n) begin: blk_o_b_tlast_tuser_tdata
        if(!i_areset_n) begin
            o_b_tlast_tuser_tdata <= 0;
        end
        else if(valid_out) begin
            o_b_tlast_tuser_tdata <= cnt_b != 0 ? o_b_tlast_tuser_tdata_mem : i_b_tlast_tuser_tdata;
        end
    end

// **********************************************************
//             Stream C
// **********************************************************
    assign wr_en_c = i_c_tvalid & o_c_tready & (!valid_out | cnt_c != 0);

    always @(posedge i_aclk or negedge i_areset_n) begin: blk_wr_addr_c
        if(!i_areset_n) begin
            wr_addr_c <= 0;
        end
        else if(wr_en_c) begin
            wr_addr_c <= (wr_addr_c < MEM_DEPTH-1) ? wr_addr_c+1 : 0;
        end
    end

    assign rd_en_c = valid_out & cnt_c != 0;

    always @(posedge i_aclk or negedge i_areset_n) begin: blk_rd_addr_c
        if(!i_areset_n) begin
            rd_addr_c <= 0;
        end
        else if(rd_en_c) begin
            rd_addr_c <= (rd_addr_c < MEM_DEPTH-1) ? rd_addr_c+1 : 0;
        end
    end

    always @(posedge i_aclk or negedge i_areset_n) begin: blk_o_c_tready
        if(!i_areset_n) begin
            cnt_c <= 0;
            o_c_tready <= 0;
        end
        else begin
            case ({wr_en_c, rd_en_c})
                2'b00: begin
                    cnt_c <= cnt_c;
                    o_c_tready <= valid_out | (cnt_c < MEM_DEPTH);
                end
                2'b01: begin
                    cnt_c <= cnt_c - 1;
                    o_c_tready <= 1;
                end
                2'b10: begin
                    cnt_c <= cnt_c + 1;//(cnt_c < MEM_DEPTH) ? cnt_c+1 : cnt_c;
                    o_c_tready <= cnt_c < MEM_DEPTH-1;
                end
                default: begin // 2'b11
                    cnt_c <= cnt_c;
                    o_c_tready <= valid_out | (cnt_c < MEM_DEPTH);
                end
            endcase
        end
    end

    ipsxe_floating_point_sram_dualports_v1_0 #(
        .MEM_WIDTH      (TLAST_TUSER_TDATA_C_WIDTH),
        .MEM_DEPTH      (MEM_DEPTH),
        .ADDR_WIDTH     (ADDR_WIDTH)
    ) u_fifo_c (
        .i_aclk            (i_aclk),
        .i_d               (i_c_tlast_tuser_tdata),
        .i_wa              (wr_addr_c),
        .i_we              (wr_en_c),
        .i_ra              (rd_addr_c),
        .i_re              (rd_en_c),
        .o_q               (o_c_tlast_tuser_tdata_mem)
    );

    always @(posedge i_aclk or negedge i_areset_n) begin: blk_o_c_tlast_tuser_tdata
        if(!i_areset_n) begin
            o_c_tlast_tuser_tdata <= 0;
        end
        else if(valid_out) begin
            o_c_tlast_tuser_tdata <= cnt_c != 0 ? o_c_tlast_tuser_tdata_mem : i_c_tlast_tuser_tdata;
        end
    end

// **********************************************************
//             Stream OPERATION
// **********************************************************
    assign wr_en_operation = i_operation_tvalid & o_operation_tready & (!valid_out | cnt_operation != 0);

    always @(posedge i_aclk or negedge i_areset_n) begin: blk_wr_addr_operation
        if(!i_areset_n) begin
            wr_addr_operation <= 0;
        end
        else if(wr_en_operation) begin
            wr_addr_operation <= (wr_addr_operation < MEM_DEPTH-1) ? wr_addr_operation+1 : 0;
        end
    end

    assign rd_en_operation = valid_out & cnt_operation != 0;

    always @(posedge i_aclk or negedge i_areset_n) begin: blk_rd_addr_operation
        if(!i_areset_n) begin
            rd_addr_operation <= 0;
        end
        else if(rd_en_operation) begin
            rd_addr_operation <= (rd_addr_operation < MEM_DEPTH-1) ? rd_addr_operation+1 : 0;
        end
    end

    always @(posedge i_aclk or negedge i_areset_n) begin: blk_o_operation_tready
        if(!i_areset_n) begin
            cnt_operation <= 0;
            o_operation_tready <= 0;
        end
        else begin
            case ({wr_en_operation, rd_en_operation})
                2'b00: begin
                    cnt_operation <= cnt_operation;
                    o_operation_tready <= valid_out | (cnt_operation < MEM_DEPTH);
                end
                2'b01: begin
                    cnt_operation <= cnt_operation - 1;
                    o_operation_tready <= 1;
                end
                2'b10: begin
                    cnt_operation <= cnt_operation + 1;//(cnt_operation < MEM_DEPTH) ? cnt_operation+1 : cnt_operation;
                    o_operation_tready <= cnt_operation < MEM_DEPTH-1;
                end
                default: begin // 2'b11
                    cnt_operation <= cnt_operation;
                    o_operation_tready <= valid_out | (cnt_operation < MEM_DEPTH);
                end
            endcase
        end
    end

    ipsxe_floating_point_sram_dualports_v1_0 #(
        .MEM_WIDTH      (TLAST_TUSER_TDATA_OPERATION_WIDTH),
        .MEM_DEPTH      (MEM_DEPTH),
        .ADDR_WIDTH     (ADDR_WIDTH)
    ) u_fifo_operation (
        .i_aclk            (i_aclk),
        .i_d               (i_operation_tlast_tuser_tdata),
        .i_wa              (wr_addr_operation),
        .i_we              (wr_en_operation),
        .i_ra              (rd_addr_operation),
        .i_re              (rd_en_operation),
        .o_q               (o_operation_tlast_tuser_tdata_mem)
    );

    always @(posedge i_aclk or negedge i_areset_n) begin: blk_o_operation_tlast_tuser_tdata
        if(!i_areset_n) begin
            o_operation_tlast_tuser_tdata <= 0;
        end
        else if(valid_out) begin
            o_operation_tlast_tuser_tdata <= cnt_operation != 0 ? o_operation_tlast_tuser_tdata_mem : i_operation_tlast_tuser_tdata;
        end
    end

// **********************************************************
//             Output Stream
// **********************************************************
    assign data_valid = (cnt_a != 0 | i_a_tvalid) & (cnt_b != 0 | i_b_tvalid) & (cnt_c != 0 | i_c_tvalid) & (cnt_operation != 0 | i_operation_tvalid);

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

endmodule