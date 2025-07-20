module ttt_top (
    input  wire       clk_in,
    input  wire       reset,
    input  wire       rx_in,
    output wire       tx_out,
    output wire       VGA_HS,
    output wire       VGA_VS,
    output wire [3:0] VGA_R,
    output wire [3:0] VGA_G,
    output wire [3:0] VGA_B
);

    // Clock generation
    wire clk25;
    wire locked;
    
    clk_wiz_0 u_clk25 (
        .clk_in(clk_in),
        .reset(reset),
        .clk25(clk25),
        .locked(locked)
    );

    // Internal signals
    wire [7:0] rx_data;
    wire rx_valid;
    wire up, down, left, right, enter;
    wire win_flag;
    wire [1:0] row, col;
    wire [8:0] board_state;
    wire [9:0] x, y;
    wire en;

    // UART RX
    uart_rx u_rx (
        .clk(clk25),
        .reset(reset),
        .rx_in(rx_in),
        .data_out(rx_data),
        .data_valid(rx_valid)
    );

    // Key decoder
    key_decoder u_decoder (
        .clk(clk25),
        .reset(reset),
        .uart_data(rx_data),
        .uart_valid(rx_valid),
        .up_key(up),
        .down_key(down),
        .left_key(left),
        .right_key(right),
        .enter_key(enter)
    );

    // Game controller
    ttt_ctrl u_game (
        .clk(clk25),
        .reset(reset),
        .up(up),
        .down(down),
        .left(left),
        .right(right),
        .enter(enter),
        .win_flag(win_flag),
        .row(row),
        .col(col),
        .board_out(board_state)
    );

    // Status reporter (UART TX)
    uart_controller u_uart_ctrl (
        .clk(clk25),
        .reset(reset),
        .rx_in(rx_in),
        .tx_out(tx_out),
        .up(up),
        .down(down),
        .left(left),
        .right(right),
        .enter(enter),
        .win_flag(win_flag),
        .row(row),
        .col(col)
    );

    // VGA sync
    vga_sync u_sync (
        .clk(clk25),
        .reset(reset),
        .x(x),
        .y(y),
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .en(en)
    );

    // VGA graphics
    vga_graphics u_grp (
        .clk(clk25),
        .reset(reset),
        .x(x),
        .y(y),
        .en(en),
        .sw(board_state),
        .red(VGA_R),
        .green(VGA_G),
        .blue(VGA_B)
    );

endmodule