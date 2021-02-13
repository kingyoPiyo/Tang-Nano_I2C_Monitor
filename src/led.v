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

    assign o_led_r = ~r_fifo_full_latch;
    assign o_led_g = i_uart_tx;
    assign o_led_b = 1'b1;
    
endmodule
