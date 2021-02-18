/********************************************************
* Title    : Glitch filter
* Date     : 2021/02/18
* Design   : kingyo
* Note     :
* If set FILTER_NUM = 5, the output value will be 
* updated if the same value continues for more than 5 times.
********************************************************/
module glitch_filter #(
    parameter       FILTER_NUM = 5,
    parameter       FILTER_BIT = 3,
    parameter       INIT_STATE = 1'b1
    ) (
    input   wire    i_clk,
    input   wire    i_res_n,
    input   wire    i_d,
    output  reg     o_q
    );

    // Synchronizer
    reg     [1:0]   r_sync_ff;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_sync_ff <= {2{INIT_STATE}};
        end else begin
            r_sync_ff <= {r_sync_ff[0], i_d};
        end
    end

    // Glitch filter
    reg     [FILTER_BIT-1:0]    r_high_cnt;
    reg     [FILTER_BIT-1:0]    r_low_cnt;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_high_cnt <= {FILTER_BIT{1'b0}};
            r_low_cnt <= {FILTER_BIT{1'b0}};
            o_q <= INIT_STATE;
        end else begin
            if (r_sync_ff[1]) begin
                r_low_cnt <= {FILTER_BIT{1'b0}};
                if (r_high_cnt == FILTER_NUM-1) begin
                    o_q <= 1'b1;
                end else begin
                    r_high_cnt <= r_high_cnt + 1'd1;
                end
            end else begin
                r_high_cnt <= {FILTER_BIT{1'b0}};
                if (r_low_cnt == FILTER_NUM-1) begin
                    o_q <= 1'b0;
                end else begin
                    r_low_cnt <= r_low_cnt + 1'd1;
                end
            end
        end
    end

endmodule
