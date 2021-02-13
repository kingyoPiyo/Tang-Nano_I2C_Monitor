/********************************************************
* Title    : Tang-Nano I2C Monitor
* Date     : 2021/02/13
* Design   : kingyo
********************************************************/
module i2c_moni_top (
    // CLK
    input   wire    mco,    // 24MHz

    // Button
    input   wire    btn_a,  // Reset (Low Active)
    input   wire    btn_b,  // Not Use

    // Onboard LED (Low Active)
    output  wire    led_r,
    output  wire    led_g,
    output  wire    led_b,
    
    // I2C Input
    input   wire    i2c_scl,
    input   wire    i2c_sda,

    // UART I/F
    output  wire    uart_tx,
    input   wire    uart_rx // Not Use
    );

    wire            w_res_n;
    wire    [7:0]   w_uart_data;
    wire            w_uart_wen;
    wire            w_fifo_full;

    //==========================
    // Reset
    //==========================
    sync_reset sync_reset (
        .i_clk ( mco ),
        .i_res_n ( btn_a ),
        .o_res_n ( w_res_n )
    );

    //==========================
    // I2C Decoder
    //==========================
    i2c_decoder i2c_dec (
        .i_clk ( mco ),
        .i_res_n ( w_res_n ),
        .i_i2c_scl ( i2c_scl ),
        .i_i2c_sda ( i2c_sda ),
        .o_wen ( w_uart_wen ),
        .o_wdata ( w_uart_data[7:0] )
    );

    //==========================
    // UART Tx (Include FIFO)
    //==========================
    uart_tx uart_tx_inst (
        .i_clk ( mco ),
        .i_res_n ( w_res_n ),
        .i_wen ( w_uart_wen ),
        .i_data ( w_uart_data[7:0] ),
        .o_full ( w_fifo_full ),
        .o_tx ( uart_tx )
    );

    //==========================
    // LED Controller
    //==========================
    led led_cnt (
        .i_clk ( mco ),
        .i_res_n ( w_res_n ),
        .i_uart_tx ( uart_tx ),
        .i_fifo_full ( w_fifo_full ),
        .o_led_r ( led_r ),
        .o_led_g ( led_g ),
        .o_led_b ( led_b )
    );

endmodule
