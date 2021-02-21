/********************************************************
* Title    : I2C Decoder
* Date     : 2021/02/13
* Design   : kingyo
********************************************************/
module i2c_decoder (
    input   wire            i_clk,
    input   wire            i_res_n,

    // I2C Signal
    input   wire            i_i2c_scl,
    input   wire            i_i2c_sda,

    // Time stamp
    input   wire    [31:0]  i_timestamp,
    input   wire            i_timestamp_en,
    input   wire            i_timestamp_res,
    output  reg             o_cnt_en,

    // OUTPUT
    output  wire            o_wen,
    output  wire    [7:0]   o_wdata
    );

    // Get Hex String
    function [7:0] getHexStr (input [3:0] in);
        begin
            case (in)
                4'h0: getHexStr = 8'h30;
                4'h1: getHexStr = 8'h31;
                4'h2: getHexStr = 8'h32;
                4'h3: getHexStr = 8'h33;
                4'h4: getHexStr = 8'h34;
                4'h5: getHexStr = 8'h35;
                4'h6: getHexStr = 8'h36;
                4'h7: getHexStr = 8'h37;
                4'h8: getHexStr = 8'h38;
                4'h9: getHexStr = 8'h39;
                4'hA: getHexStr = 8'h41;
                4'hB: getHexStr = 8'h42;
                4'hC: getHexStr = 8'h43;
                4'hD: getHexStr = 8'h44;
                4'hE: getHexStr = 8'h45;
                4'hF: getHexStr = 8'h46;
            endcase
        end
    endfunction

    // I2C Signal Synchronizer & Glitch filte
    wire            w_fltd_scl;
    wire            w_fltd_sda;
    glitch_filter gf_scl (
        .i_clk ( i_clk ),
        .i_res_n ( i_res_n ),
        .i_d ( i_i2c_scl ),
        .o_q ( w_fltd_scl )
    );
    glitch_filter gf_sda (
        .i_clk ( i_clk ),
        .i_res_n ( i_res_n ),
        .i_d ( i_i2c_sda ),
        .o_q ( w_fltd_sda )
    );

    // Edge detector
    reg     [1:0]   r_scl_ff;
    reg     [1:0]   r_sda_ff;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_scl_ff <= 2'b11;
            r_sda_ff <= 2'b11;
        end else begin
            r_scl_ff <= {r_scl_ff[0], w_fltd_scl};
            r_sda_ff <= {r_sda_ff[0], w_fltd_sda};
        end
    end

    // Detect start bit (SDA negedge & SCL high)
    wire    w_i2c_start = (r_sda_ff == 2'b10) && r_scl_ff[1];

    // Detect stop bit (SDA posedge & SCL high)
    wire    w_i2c_stop = (r_sda_ff == 2'b01) && r_scl_ff[1];

    // Detect SCL negedge
    wire    w_i2c_scl_negedge = (r_scl_ff == 2'b10);

    // I2C Decode
    reg             r_fifo_wen;
    reg     [7:0]   r_wdata;
    reg     [3:0]   r_i2c_state;
    reg             r_i2c_start_busy;
    reg             r_i2c_stop_busy;
    reg             r_i2c_data_ack_busy;
    reg             r_i2c_first_st_flg;
    reg     [3:0]   r_i2c_rx_bit_cnt;
    reg     [8:0]   r_i2c_rx_byte;  // Data[7:0] + ACK
    reg             r_det_stopbit;
    reg     [31:0]  r_timestamp_ff;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_fifo_wen <= 1'b0;
            r_wdata <= 8'd0;
            r_i2c_state <= 4'd0;
            r_i2c_start_busy <= 1'b0;
            r_i2c_stop_busy <= 1'b0;
            r_i2c_data_ack_busy <= 1'b0;
            r_i2c_first_st_flg <= 1'b0;
            r_i2c_rx_bit_cnt <= 4'd0;
            r_i2c_rx_byte <= 9'd0;
            r_det_stopbit <= 1'b1;
            r_timestamp_ff <= 32'd0;
            o_cnt_en <= 1'b0;
        end else begin
            // Timestamp Counter Disable
            if (i_timestamp_res) begin
                o_cnt_en <= 1'b0;

            // START Bit
            end else if (r_i2c_start_busy) begin
                r_i2c_state <= r_i2c_state + 4'd1;
                r_det_stopbit <= 1'b0;
                o_cnt_en <= 1'b1;

                if (i_timestamp_en) begin
                    case (r_i2c_state)
                        0: begin
                            r_timestamp_ff <= i_timestamp;
                            r_wdata <= getHexStr(i_timestamp[31:28]);
                            r_fifo_wen <= 1'b1;
                        end
                        1:  r_wdata <= getHexStr(r_timestamp_ff[27:24]);
                        2:  r_wdata <= getHexStr(r_timestamp_ff[23:20]);
                        3:  r_wdata <= getHexStr(r_timestamp_ff[19:16]);
                        4:  r_wdata <= getHexStr(r_timestamp_ff[15:12]);
                        5:  r_wdata <= getHexStr(r_timestamp_ff[11: 8]);
                        6:  r_wdata <= getHexStr(r_timestamp_ff[ 7: 4]);
                        7:  r_wdata <= getHexStr(r_timestamp_ff[ 3: 0]);
                        8:  r_wdata <= 8'h20;   // SP
                        9:  r_wdata <= 8'h53;   // S
                        10: begin
                            r_wdata <= 8'h20;   // SP
                            r_i2c_start_busy <= 1'b0;
                        end
                    endcase
                end else begin
                    case (r_i2c_state)
                        0: begin
                            r_wdata <= 8'h53;   // S
                            r_fifo_wen <= 1'b1;
                        end
                        1: begin
                            r_wdata <= 8'h20;   // SP
                            r_i2c_start_busy <= 1'b0;
                        end
                    endcase
                end

            // STOP Bit
            end else if (r_i2c_stop_busy) begin
                r_i2c_state <= r_i2c_state + 4'd1;
                case (r_i2c_state)
                    0: begin
                        r_wdata <= 8'h50;   // P
                        r_fifo_wen <= 1'b1;
                    end
                    1: r_wdata <= 8'h0d;    // CR
                    2: begin
                        r_wdata <= 8'h0a;   // LC
                        r_i2c_stop_busy <= 1'b0;
                    end
                endcase

            // DATA and ACK Flag
            end else if (r_i2c_data_ack_busy) begin
                r_i2c_state <= r_i2c_state + 4'd1;
                case (r_i2c_state)
                    0: begin
                        r_wdata <= getHexStr(r_i2c_rx_byte[8:5]);
                        r_fifo_wen <= 1'b1;
                    end
                    1: r_wdata <= getHexStr(r_i2c_rx_byte[4:1]);
                    2: r_wdata <= 8'h20;    // SP
                    3: r_wdata <= r_i2c_rx_byte[0] ? 8'h4e : 8'h41; // ACK or NAK
                    4: begin
                        r_wdata <= 8'h20;   // SP
                        r_i2c_data_ack_busy <= 1'b0;
                        r_i2c_rx_bit_cnt <= 4'd0;
                    end
                endcase

            // Catch START Bit
            end else if (w_i2c_start) begin
                r_i2c_state <= 4'd0;
                r_i2c_start_busy <= 1'b1;
                r_i2c_first_st_flg <= 1'b1;
                r_i2c_rx_bit_cnt <= 4'd0;

            // Catch STOP Bit
            end else if (w_i2c_stop) begin
                r_i2c_state <= 4'd0;
                r_i2c_stop_busy <= 1'b1;
                r_det_stopbit <= 1'b1;

            // Catch SCL negedge
            end else if (w_i2c_scl_negedge) begin
                r_i2c_state <= 4'd0;
                if (r_i2c_first_st_flg) begin
                    r_i2c_first_st_flg <= 1'b0;
                end else begin
                    r_i2c_rx_bit_cnt <= r_i2c_rx_bit_cnt + 4'd1;
                    r_i2c_rx_byte <= {r_i2c_rx_byte[7:0], r_sda_ff[1]};
                    if (r_i2c_rx_bit_cnt == 4'd8) begin
                        r_i2c_rx_bit_cnt <= 4'd0;
                        r_i2c_data_ack_busy <= 1'b1;
                    end
                end

            // None
            end else begin
                r_fifo_wen <= 1'b0;
            end
        end
    end

    assign o_wdata = r_wdata;
    assign o_wen = r_fifo_wen;

endmodule
