/********************************************************
* Title    : Button long or short judge
* Date     : 2021/02/21
* Design   : kingyo
********************************************************/
module btn_input #(
    parameter       SHORT_MS = 30,
    parameter       LONG_MS = 1000
    ) (
    input   wire    i_clk,      // 24MHz
    input   wire    i_res_n,    // Reset
    input   wire    i_btn,      // Button input
    output  reg     o_sig1,     // Short press
    output  reg     o_sig2      // Long press
);

    // input synchronizer
    reg     [1:0]   r_input_ff;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_input_ff <= 2'b11;
        end else begin
            r_input_ff <= {r_input_ff[0], i_btn};
        end
    end

    // 1ms enable pulse
    reg     [14:0]  r_1ms_cnt;
    wire            w_1ms_enable = (r_1ms_cnt == 15'd23999);
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_1ms_cnt <= 15'd0;
        end else begin
            if (w_1ms_enable) begin
                r_1ms_cnt <= 15'd0;
            end else begin
                r_1ms_cnt <= r_1ms_cnt + 15'd1;
            end
        end
    end

    // Judge
    reg     [9:0]   r_btn_press_ms;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_btn_press_ms <= 10'd0;
            o_sig1 <= 1'b0;
            o_sig2 <= 1'b0;
        end else begin
            if (w_1ms_enable) begin
                if (r_input_ff[1]) begin
                    // Pressed
                    if (~&r_btn_press_ms) begin
                        r_btn_press_ms <= r_btn_press_ms + 10'd1;
                    end
                    if (r_btn_press_ms == LONG_MS-1) begin
                        o_sig2 <= 1'b1;
                    end
                end else begin
                    // Released
                    r_btn_press_ms <= 10'd0;
                    if (r_btn_press_ms >= SHORT_MS-1 && r_btn_press_ms < LONG_MS-1) begin
                        o_sig1 <= 1'b1;
                    end
                end
            end else begin
                o_sig1 <= 1'b0;
                o_sig2 <= 1'b0;
            end
        end
    end

endmodule
