module uart_top(
    input wire clk,
    input wire reset,
    input wire [7:0] switches,
    input wire btn_send,
    input wire rx_in,
    output wire tx_out,
    output wire [6:0] seg_out,
    output wire [3:0] seg_sel
);

wire uart_clk;
wire [7:0] rx_ascii_data;


baudrate_gen baud_gen(
    .clk(clk),
    .reset(reset),
    .clk1(uart_clk)
);

uart_rx rx_module(
    .clk(uart_clk),
    .reset(reset),
    .rx_data(rx_in),
    .rx_ascii_reg(rx_ascii_data),
    .parity_error()
);

uart_tx tx_module(
    .clk(uart_clk),
    .reset(reset),
    .switches(switches),
    .btn_send(btn_send),
    .tx_data(tx_out)
);

seg7_display display(
    .clk(clk),
    .reset(reset),
    .data_in(rx_ascii_data),
    .seg_out(seg_out),
    .seg_sel(seg_sel)
);

endmodule