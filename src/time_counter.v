/********************************************************
* Title    : Time counter (resolution 1us)
* Date     : 2021/02/21
* Design   : kingyo
********************************************************/
module time_counter (
    input   wire    i_clk,      // 24MHz
    input   wire    i_res_n,
    input   wire    i_cnt_res,
    input   wire    i_cnt_en,
    output  reg     [31:0]  o_cnt_val
);

    // 1us enable signal
    reg     [4:0]   r_1us_cnt;
    wire            w_1us_enable = (r_1us_cnt == 5'd23);
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_1us_cnt <= 5'd0;
        end else begin
            if (w_1us_enable | ~i_cnt_en) begin
                r_1us_cnt <= 5'd0;
            end else begin
                r_1us_cnt <= r_1us_cnt + 5'd1;
            end
        end
    end

    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            o_cnt_val <= 32'd0;
        end else begin
            if (i_cnt_res) begin
                o_cnt_val <= 32'd0;
            end else begin
                if (w_1us_enable & ~&o_cnt_val) begin
                    o_cnt_val <= o_cnt_val + 32'd1;
                end
            end
        end
    end

endmodule
