/********************************************************
* Title    : UART Tx 
* Date     : 2021/02/13
* Design   : kingyo
********************************************************/
module uart_tx (
    input   wire            i_clk,      // 24MHz
    input   wire            i_res_n,
    input   wire            i_wen,
    input   wire    [7:0]   i_data,
    output  wire            o_full,
    output  wire            o_tx
);

    // Tx FIFO
    wire            w_fifo_full;
    wire    [7:0]   w_fifo_rdata;
    wire            w_fifo_emp;
    reg             r_fifo_ren;
    fifo tx_fifo (
        .i_clk ( i_clk ),
        .i_res_n ( i_res_n ),
        .i_wen ( i_wen & ~w_fifo_full ),
        .i_data ( i_data[7:0] ),
        .o_full ( w_fifo_full ),
        .i_ren ( r_fifo_ren & ~w_fifo_emp ),
        .o_data ( w_fifo_rdata[7:0] ),
        .o_empty ( w_fifo_emp )
    );
    assign o_full = w_fifo_full;

    // Baud rate generator
    reg     [4:0]   r_baud_cnt;
    reg             r_tx_busy;
    wire            w_baud_pls = (r_baud_cnt == 5'd23); // 1Mbps @24MHz
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_baud_cnt <= 5'd0;
        end else begin
            if (~r_tx_busy) begin
                r_baud_cnt <= 5'd0;
            end else if (w_baud_pls) begin
                r_baud_cnt <= 5'd0;
            end else begin
                r_baud_cnt <= r_baud_cnt + 5'd1;
            end
        end
    end

    // Tx bit counter
    reg     [3:0]   r_bit_cnt;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_bit_cnt <= 4'd0;
            r_tx_busy <= 1'b0;
            r_fifo_ren <= 1'b0;
        end else begin
            if (~r_tx_busy) begin
                if (~w_fifo_emp) begin
                    r_bit_cnt <= 4'd0;
                    r_tx_busy <= 1'b1;
                    r_fifo_ren <= 1'b1;
                end
            end else begin
                r_fifo_ren <= 1'b0;
                if (w_baud_pls) begin
                    r_bit_cnt <= r_bit_cnt + 4'd1;
                    if (r_bit_cnt == 4'd10) begin
                        r_tx_busy <= 1'b0;
                    end
                end
            end
        end
    end

    // Send UART bit
    reg             r_uart_tx;
    reg     [9:0]   r_tx_shift; // {STOP, DATA[7:0], START}
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_uart_tx <= 1'b1;
            r_tx_shift <= 10'd0;
        end else if (~r_tx_busy) begin
            r_uart_tx <= 1'b1;
            r_tx_shift <= 10'd0;
        end else if (w_baud_pls) begin
            if (r_tx_shift == 10'd0) begin
                r_uart_tx <= 1'b1;
                r_tx_shift <= {1'b1, w_fifo_rdata[7:0], 1'b0};
            end else begin
                r_uart_tx <= r_tx_shift[0];
                r_tx_shift <= {1'b0, r_tx_shift[9:1]};
            end
        end
    end

    assign o_tx = r_uart_tx;

endmodule
