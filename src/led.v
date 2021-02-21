/********************************************************
* Title    : LED Controller
* Date     : 2021/02/13
* Design   : kingyo
********************************************************/
module led (
    input   wire    i_clk,
    input   wire    i_res_n,
    input   wire    i_uart_tx,
    input   wire    i_fifo_full,
    input   wire    i_timestamp_en,
    input   wire    i_timestamp_res,
    output  wire    o_led_r,
    output  wire    o_led_g,
    output  wire    o_led_b
    );

    reg     r_fifo_full_latch;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_fifo_full_latch <= 1'b0;
        end else begin
            if (i_fifo_full) begin
                r_fifo_full_latch <= 1'b1;
            end
        end
    end

    reg     r_mode_led;
    reg     r_flash_busy;
    reg     [24:0]  r_flash_cnt;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_mode_led <= i_timestamp_en;
        end else begin
            if (i_timestamp_res) begin
                r_flash_busy <= 1'b1;
                r_flash_cnt <= 25'd0;
            end

            if (r_flash_busy) begin
                r_flash_cnt <= r_flash_cnt + 25'd1;
                r_mode_led <= r_flash_cnt[21];
                if (&r_flash_cnt) begin
                    r_flash_busy <= 1'b0;
                end
            end else begin
                r_mode_led <= i_timestamp_en;
            end
        end
    end


    assign o_led_r = ~r_fifo_full_latch;
    assign o_led_g = i_uart_tx;
    assign o_led_b = ~r_mode_led;
    
endmodule
