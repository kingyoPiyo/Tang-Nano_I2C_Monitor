/********************************************************
* Title    : FIFO
* Date     : 2021/02/07
* Design   : kingyo
********************************************************/
module fifo #(
    parameter       DATA_WIDTH = 8,     // 8 bit
    parameter       DATA_DEPTH = 11     // 2048 word
    ) (
    input   wire    i_clk,
    input   wire    i_res_n,

    // Write Port
    input   wire    i_wen,
    input   wire    [DATA_WIDTH-1:0]    i_data,
    output  wire    o_full,

    // Read Port
    input   wire    i_ren,
    output  wire    [DATA_WIDTH-1:0]    o_data,
    output  wire    o_empty
    );

    reg     [DATA_WIDTH-1:0]    r_mem[0:2**DATA_DEPTH-1];
    reg     [DATA_WIDTH-1:0]    r_rdata;
    reg     [DATA_DEPTH-1:0]    r_waddr;
    reg     [DATA_DEPTH-1:0]    r_raddr;

    // Write
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_waddr <= {DATA_DEPTH{1'b0}};
        end else begin
            if (i_wen & ~o_full) begin
                r_waddr <= r_waddr + 1'd1;
                r_mem[r_waddr] <= i_data;
            end
        end
    end

    // Read
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_raddr <= {DATA_DEPTH{1'b0}};
            r_rdata <= {DATA_WIDTH{1'b0}};
        end else begin
            if (i_ren & ~o_empty) begin
                r_raddr <= r_raddr + 1'd1;
                r_rdata <= r_mem[r_raddr];
            end
        end
    end
    assign o_data = r_rdata;

    // Empty
    assign o_empty = (r_raddr == r_waddr);

    // Full
    assign o_full = (r_raddr == r_waddr + 1'd1);

endmodule
