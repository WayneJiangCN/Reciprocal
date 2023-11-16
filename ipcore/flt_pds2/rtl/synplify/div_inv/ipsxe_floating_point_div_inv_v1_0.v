// Inv version with look-up-table
module ipsxe_floating_point_div_inv_v1_0 #(
    parameter DIVIDEND_WIDTH_FLOATING_SRT = 7'd32,
    parameter QUOTIENT_WIDTH_FLOATING_SRT = 7'd32,  // The two line above is just for satisfying the parameter tb offer
    parameter RECIPROCAL_WIDTH_FLOATING_SRT = 7'd32,
    parameter EXPONENT_WIDTH_FLOATING_SRT = 4'd8,
    parameter FRACTION_WIDTH_FLOATING_SRT = 7'd23,
    parameter LATENCY_CONFIG_NEW = 1
)(
    input i_clk,
    input i_aclken,
    input i_areset_n,
    input [RECIPROCAL_WIDTH_FLOATING_SRT-1'b1:0] i_op_in, //opa:denumerator
    input i_tvalid,
    output [RECIPROCAL_WIDTH_FLOATING_SRT-1'b1:0] o_resul,
    // output o_overflow, //high active
    output o_underflow, //high active
    output o_divide_by_zero,
    // output o_invalid_op,
    output o_q_valid
);
    
    wire a_is_denorm;
    wire a_is_inf_or_nan;
    wire a_frac_is_zeros;
    wire exp_is_full_be2;
    // wire [RECIPROCAL_WIDTH_FLOATING_SRT-1'b1:0] op;
    // if the exponent is zero and the mantissa is not zero, then this is a denormalized floating-point number

    assign o_divide_by_zero = a_is_denorm;
    // set denormalized numbers to zeros

    wire sign_reci;
    wire [EXPONENT_WIDTH_FLOATING_SRT-1:0] exp_reci;
    wire [FRACTION_WIDTH_FLOATING_SRT-1:0] frac_reci;

    assign sign_reci = i_op_in[RECIPROCAL_WIDTH_FLOATING_SRT-1];
    assign exp_reci = i_op_in[RECIPROCAL_WIDTH_FLOATING_SRT -2:RECIPROCAL_WIDTH_FLOATING_SRT - EXPONENT_WIDTH_FLOATING_SRT - 1];
    assign frac_reci = i_op_in[FRACTION_WIDTH_FLOATING_SRT-1:0];

    assign exp_is_full_be2 = &i_op_in[RECIPROCAL_WIDTH_FLOATING_SRT-2 -:EXPONENT_WIDTH_FLOATING_SRT-2];

    assign a_is_denorm = (exp_reci==0);
    assign a_is_inf_or_nan = (exp_is_full_be2 & (&exp_reci[1:0]));
    assign a_frac_is_zeros = (|frac_reci);
    assign o_underflow = (exp_is_full_be2 & (exp_reci[0] ^ exp_reci[1]));


    wire [FRACTION_WIDTH_FLOATING_SRT-1'b1:0] frac_result_reci_out;
    reg [FRACTION_WIDTH_FLOATING_SRT-1'b1:0] frac_result;

    reg [EXPONENT_WIDTH_FLOATING_SRT-1:0] exp_result;
    // assign exp_result = a_is_denorm ? {(EXPONENT_WIDTH_FLOATING_SRT){1'b1}}: a_is_inf_or_nan ? (a_frac_is_zeros? ({(EXPONENT_WIDTH_FLOATING_SRT){1'b1}}):({(EXPONENT_WIDTH_FLOATING_SRT){1'b0}})):(~exp_reci-2'd2);
    
    always @(*)   begin
        if(a_is_denorm) begin
            exp_result = {(EXPONENT_WIDTH_FLOATING_SRT){1'b1}};
        end
        else if(a_is_inf_or_nan)    begin
            if(a_frac_is_zeros) begin
                exp_result = {(EXPONENT_WIDTH_FLOATING_SRT){1'b1}};
            end
            else    begin
                exp_result = {(EXPONENT_WIDTH_FLOATING_SRT){1'b0}};
            end
        end
        else if(o_underflow)    begin
            exp_result = {(EXPONENT_WIDTH_FLOATING_SRT){1'b0}};
        end
        else if(~a_frac_is_zeros)   begin
            exp_result = (~exp_reci-1'd1);
        end
        else begin
            exp_result = (~exp_reci-2'd2);
        end
    end

    always @(*)   begin
        if(a_is_denorm) begin
            frac_result = {(FRACTION_WIDTH_FLOATING_SRT){1'b1}};
        end
        else if(a_is_inf_or_nan)    begin
            if(a_frac_is_zeros) begin
                frac_result = {(FRACTION_WIDTH_FLOATING_SRT){1'b1}};
            end
            else    begin
                frac_result = {(FRACTION_WIDTH_FLOATING_SRT){1'b0}};
            end
        end
        else if(o_underflow)    begin
            frac_result = {(FRACTION_WIDTH_FLOATING_SRT){1'b0}};
        end
        else if(~a_frac_is_zeros)   begin
            frac_result = {(FRACTION_WIDTH_FLOATING_SRT){1'b0}};
        end
        else begin
            frac_result = frac_result_reci_out;
        end
    end

    assign o_resul = {sign_reci, exp_result, frac_result};

    assign o_q_valid = i_tvalid;
    reci
    #(
        .FLT_WIDTH  (FRACTION_WIDTH_FLOATING_SRT)
    )
    u_reci(
    	.clk      (i_clk    ),
        .rst_n    (i_areset_n),
        .i_X      (frac_reci),
        .o_result (frac_result_reci_out)
    );
    
endmodule
