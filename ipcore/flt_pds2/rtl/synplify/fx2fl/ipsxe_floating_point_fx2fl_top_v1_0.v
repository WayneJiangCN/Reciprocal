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
// Filename: ipsxe_floating_point_fx2fl_top_v1_0.v
// Function: this module transfers a fixed-point number to the floating-
//           point number
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module ipsxe_floating_point_fx2fl_top_v1_0 #(
    parameter FIXED_INT_BIT = 32, //with sign bit
    parameter FIXED_FRAC_BIT = 0,
    parameter FLOAT_EXP_BIT = 8,
    parameter FLOAT_FRAC_BIT = 24,//include the hidden one
    parameter INT_TYPE = 0,
    parameter LATENCY_CONFIG = 6
)
(
    input i_aclk,
    input i_aclken,
    input i_areset_n,
    input [FIXED_INT_BIT+FIXED_FRAC_BIT-1:0] i_axi4s_a_tdata,
    input i_axi4s_or_abcoperation_tvalid,
    output reg [FLOAT_EXP_BIT+FLOAT_FRAC_BIT-1:0] o_axi4s_result_tdata,
    output o_axi4s_result_tvalid
);

localparam FIXED_DATA_WIDTH = FIXED_INT_BIT + FIXED_FRAC_BIT;
localparam INT_WIDTH = FIXED_DATA_WIDTH > 32 ? 64 : 32;
localparam SHIFT_WIDTH = FIXED_DATA_WIDTH > 32 ? 6 : 5;

localparam COMPENSATE_BIT = INT_WIDTH - FIXED_DATA_WIDTH;
localparam EXP_BIAS = 2 ** (FLOAT_EXP_BIT-1) - 1 - FIXED_FRAC_BIT - COMPENSATE_BIT;

//////////////////// wire & reg ////////////////////
wire fixed_sign;
reg [INT_WIDTH-1:0] fixed_data;
wire [INT_WIDTH-1:0] fixed_data2;
wire [INT_WIDTH-1:0] fixed_data3;

wire zero_judge;

wire [SHIFT_WIDTH-1:0] one_location;
wire [SHIFT_WIDTH-1:0] shift_num;
reg [INT_WIDTH-1:0] shift_data;

wire carry, carry_mid;
wire flt_carry;
reg [FLOAT_FRAC_BIT-1:0] flt_frac;
wire [FLOAT_FRAC_BIT-1:0] flt_frac2;
reg [FLOAT_EXP_BIT-1:0] flt_exp;

wire o_axi4s_result_tvalid_clk1;
wire o_axi4s_result_tvalid_clk2;
wire o_axi4s_result_tvalid_clk3;
wire o_axi4s_result_tvalid_clk4;
wire o_axi4s_result_tvalid_clk5;

wire zero_judge2;
wire [SHIFT_WIDTH-1:0] one_location2;

wire fixed_sign2;
wire fixed_sign3;
wire fixed_sign4;
wire fixed_sign5;
wire fixed_sign6;
//////////////////// find the first 1 ////////////////////


generate
if(INT_TYPE)begin
    assign fixed_sign = 1'b0;

    always @(posedge i_aclk or negedge i_areset_n) begin
        if(!i_areset_n) begin
            fixed_data <= 0;
        end
        else if(i_aclken) begin
            fixed_data <= i_axi4s_a_tdata[FIXED_DATA_WIDTH-1:0];
        end
        else begin
            fixed_data <= fixed_data;
        end
    end

end
else begin
    assign fixed_sign = i_axi4s_a_tdata[FIXED_DATA_WIDTH-1];

    always @(posedge i_aclk or negedge i_areset_n) begin
        if(!i_areset_n) begin
            fixed_data <= 0;
        end
        else if(i_aclken) begin
            if(fixed_sign)begin
                fixed_data <= { ~i_axi4s_a_tdata[FIXED_DATA_WIDTH-1:0]+1, {(COMPENSATE_BIT){1'b0}} };
            end
            else begin
                fixed_data <= { i_axi4s_a_tdata[FIXED_DATA_WIDTH-1:0], {(COMPENSATE_BIT){1'b0}} };
            end
        end
        else begin
            fixed_data <= fixed_data;
        end
    end
end
endgenerate

    ipsxe_floating_point_register_v1_0 #(INT_WIDTH) u_reg_fixed_data2(
        i_aclk,
        i_aclken,
        i_areset_n,
        fixed_data,
        fixed_data2
    );

    ipsxe_floating_point_register_v1_0 #(INT_WIDTH) u_reg_fixed_data3(
        i_aclk,
        i_aclken,
        i_areset_n,
        fixed_data2,
        fixed_data3
    );

ipsxe_floating_point_find_one_loc_v1_0 #(
    .WIDTH(INT_WIDTH),
    .LOC_BITS(SHIFT_WIDTH)
) u1_ipsxe_floating_point_find_one_loc_v1_0 (
    .i_clk(i_aclk),
    .i_aclken(i_aclken),
    .i_rst_n(i_areset_n),
    .i_data(fixed_data),
    .one_location(one_location),
    .zero_judge(zero_judge)
);

    ipsxe_floating_point_register_v1_0 #(1) u_reg_zero_judge(
        i_aclk,
        i_aclken,
        i_areset_n,
        zero_judge,
        zero_judge2
    );

    ipsxe_floating_point_register_v1_0 #(SHIFT_WIDTH) u_reg_one_location(
        i_aclk,
        i_aclken,
        i_areset_n,
        one_location,
        one_location2
    );
//////////////////// decode mantissa and exp ////////////////////
    assign shift_num = INT_WIDTH - one_location - 1; //shift the 1st to the sign bit

    // always @(*) begin
    //     shift_data = fixed_data << shift_num;
    // end

    always @(posedge i_aclk or negedge i_areset_n) begin
        if(!i_areset_n) begin
            shift_data <= 0;
        end
        else if(i_aclken) begin
            shift_data <= fixed_data3 << shift_num;
        end
        else begin
            shift_data <= shift_data;
        end
    end

generate
if(FIXED_DATA_WIDTH > FLOAT_FRAC_BIT)begin
    ipsxe_floating_point_round_v6_v1_0 #( //round to even
        .FLOAT_FRAC_BIT(INT_WIDTH-FLOAT_FRAC_BIT)
    ) u_round (
        .data_in(shift_data[INT_WIDTH-FLOAT_FRAC_BIT-1:0]),
        .carry(carry),
        .carry_mid(carry_mid)
    );

    assign flt_carry = carry | (carry_mid & shift_data[INT_WIDTH-FLOAT_FRAC_BIT]);

    always @(*) begin
        flt_frac = shift_data[INT_WIDTH-2 -: FLOAT_FRAC_BIT-1] + flt_carry;
    end

    //always @(posedge i_aclk or negedge i_areset_n) begin
    //    if(!i_areset_n) begin
    //        flt_frac <= 0;
    //    end
    //    else if(i_aclken) begin
    //        flt_frac <= shift_data[INT_WIDTH-2 -: FLOAT_FRAC_BIT-1] + flt_carry;
    //    end
    //end

    always @(posedge i_aclk or negedge i_areset_n) begin
        if(!i_areset_n) begin
            flt_exp <= 0;
        end
        else if(i_aclken) begin
            if(zero_judge2)begin
                flt_exp <= 0;
            end
            else begin
                flt_exp <= one_location2 + EXP_BIAS + flt_frac[FLOAT_FRAC_BIT-1];
            end
        end
        else begin
            flt_exp <= flt_exp;
        end
    end

    // assign flt_exp = zero_judge ? 0 : one_location + EXP_BIAS + flt_frac[FLOAT_FRAC_BIT-1];
end
else begin
    always @(*) begin
        flt_frac = {shift_data[INT_WIDTH-1 -: FIXED_DATA_WIDTH],{(FLOAT_FRAC_BIT-FIXED_DATA_WIDTH){1'b0}}};
    end

    always @(posedge i_aclk or negedge i_areset_n) begin
        if(!i_areset_n) begin
            flt_exp <= 0;
        end
        else if(i_aclken) begin
            if(zero_judge2)begin
                flt_exp <= 0;
            end
            else begin
                flt_exp <= one_location2 + EXP_BIAS;
            end
        end
        else begin
            flt_exp <= flt_exp;
        end
    end
    // assign flt_exp = zero_judge ? 0 : one_location + EXP_BIAS;
end
endgenerate

    ipsxe_floating_point_register_v1_0 #(FLOAT_FRAC_BIT) u_reg_flt_frac(
        i_aclk,
        i_aclken,
        i_areset_n,
        flt_frac,
        flt_frac2
    );

//////////////////// encode output data ////////////////////
    always @(posedge i_aclk or negedge i_areset_n) begin
        if(!i_areset_n) begin
            o_axi4s_result_tdata <= 0;
        end
        else if(i_aclken) begin
            o_axi4s_result_tdata <= {fixed_sign6, flt_exp, flt_frac2[FLOAT_FRAC_BIT-2:0]};
        end
        else begin
            o_axi4s_result_tdata <= o_axi4s_result_tdata;
        end
    end

    ipsxe_floating_point_register_v1_0 #(1) u_reg_fixed_sign(
        i_aclk,
        i_aclken,
        i_areset_n,
        fixed_sign,
        fixed_sign2
    );

    ipsxe_floating_point_register_v1_0 #(1) u_reg_fixed_sign2(
        i_aclk,
        i_aclken,
        i_areset_n,
        fixed_sign2,
        fixed_sign3
    );

    ipsxe_floating_point_register_v1_0 #(1) u_reg_fixed_sign3(
        i_aclk,
        i_aclken,
        i_areset_n,
        fixed_sign3,
        fixed_sign4
    );

    ipsxe_floating_point_register_v1_0 #(1) u_reg_fixed_sign4(
        i_aclk,
        i_aclken,
        i_areset_n,
        fixed_sign4,
        fixed_sign5
    );
    
    ipsxe_floating_point_register_v1_0 #(1) u_reg_fixed_sign5(
        i_aclk,
        i_aclken,
        i_areset_n,
        fixed_sign5,
        fixed_sign6
    );
    //always @(*) begin
    //    o_axi4s_result_tdata = {fixed_sign, flt_exp, flt_frac[FLOAT_FRAC_BIT-2:0]};
    //end

    ipsxe_floating_point_register_v1_0 #(1) u_reg_m_axis_result_tvalid1(
        i_aclk,
        i_aclken,
        i_areset_n,
        i_axi4s_or_abcoperation_tvalid,
        o_axi4s_result_tvalid_clk1
    );

    ipsxe_floating_point_register_v1_0 #(1) u_reg_m_axis_result_tvalid2(
        i_aclk,
        i_aclken,
        i_areset_n,
        o_axi4s_result_tvalid_clk1,
        o_axi4s_result_tvalid_clk2
    );

    ipsxe_floating_point_register_v1_0 #(1) u_reg_m_axis_result_tvalid3(
        i_aclk,
        i_aclken,
        i_areset_n,
        o_axi4s_result_tvalid_clk2,
        o_axi4s_result_tvalid_clk3
    );

    ipsxe_floating_point_register_v1_0 #(1) u_reg_m_axis_result_tvalid4(
        i_aclk,
        i_aclken,
        i_areset_n,
        o_axi4s_result_tvalid_clk3,
        o_axi4s_result_tvalid_clk4
    );

    ipsxe_floating_point_register_v1_0 #(1) u_reg_m_axis_result_tvalid5(
        i_aclk,
        i_aclken,
        i_areset_n,
        o_axi4s_result_tvalid_clk4,
        o_axi4s_result_tvalid_clk5
    );

    ipsxe_floating_point_register_v1_0 #(1) u_reg_m_axis_result_tvalid6(
        i_aclk,
        i_aclken,
        i_areset_n,
        o_axi4s_result_tvalid_clk5,
        o_axi4s_result_tvalid
    );
endmodule