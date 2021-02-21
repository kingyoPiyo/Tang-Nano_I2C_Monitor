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
    input   wire    btn_b,  // Mode

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
    wire            w_btn_b_short;
    wire            w_btn_b_long;
    wire            w_timestamp_en;
    wire            w_counter_en;
    wire    [31:0]  w_counter_val;

    //==========================
    // Reset
    //==========================
    sync_reset sync_reset (
        .i_clk ( mco ),
        .i_res_n ( btn_a ),
        .o_res_n ( w_res_n )
    );

    //==========================
    // Button Input
    //==========================
    btn_input btn_input (
        .i_clk ( mco ),
        .i_res_n ( w_res_n ),
        .i_btn ( ~btn_b ),
        .o_sig1 ( w_btn_b_short ),
        .o_sig2 ( w_btn_b_long )
    );

    //==========================
    // Toggle timestamp enable
    //==========================
    toggle_reg toggle_reg(
        .i_clk ( mco ),
        .i_res_n ( w_res_n ),
        .i_init_val ( 1'b0 ),
        .i_pls ( w_btn_b_short ),
        .o_sig ( w_timestamp_en )
    );

    //==========================
    // Time stamp counter
    // Resolution : 1us
    //==========================
    time_counter time_counter (
        .i_clk ( mco ),
        .i_res_n ( w_res_n ),
        .i_cnt_res ( w_btn_b_long ),
        .i_cnt_en ( w_counter_en ),
        .o_cnt_val ( w_counter_val )
    );

    //==========================
    // I2C Decoder
    //==========================
    i2c_decoder i2c_dec (
        .i_clk ( mco ),
        .i_res_n ( w_res_n ),
        .i_i2c_scl ( i2c_scl ),
        .i_i2c_sda ( i2c_sda ),
        .i_timestamp ( w_counter_val ),
        .i_timestamp_en ( w_timestamp_en ),
        .i_timestamp_res ( w_btn_b_long ),
        .o_cnt_en ( w_counter_en ),
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
    led led_ctrl (
        .i_clk ( mco ),
        .i_res_n ( w_res_n ),
        .i_uart_tx ( uart_tx ),
        .i_fifo_full ( w_fifo_full ),
        .i_timestamp_en ( w_timestamp_en ),
        .i_timestamp_res ( w_btn_b_long ),
        .o_led_r ( led_r ),
        .o_led_g ( led_g ),
        .o_led_b ( led_b )
    );

endmodule
