/********************************************************
* Title    : Toggle register
* Date     : 2021/02/21
* Design   : kingyo
********************************************************/
module toggle_reg (
    input   wire    i_clk,
    input   wire    i_res_n,
    input   wire    i_init_val,
    input   wire    i_pls,
    output  reg     o_sig
);

    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            o_sig <= i_init_val;
        end else if (i_pls) begin
            o_sig <= ~o_sig;
        end
    end

endmodule
