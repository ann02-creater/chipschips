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

    // Clock generation (moved to vga_top)

    // Internal signals  
    wire up, down, left, right, enter, space;
    wire win_flag;
    wire [3:0] current_cell;
    wire [8:0] cell_select_flag;
    wire [8:0] board_state;
    wire clk25;

    // Clock generation for game logic (25MHz)
    clk_wiz_0 u_clk25 (
        .clk_in(clk_in),
        .reset(reset),
        .clk25(clk25),
        .locked()
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
        .space(space),
        .win_flag(win_flag),
        .current_cell(current_cell),
        .cell_select_flag(cell_select_flag),
        .board_out(board_state)
    );

    // UART Controller with integrated key decoder
    uart_controller u_uart_ctrl (
        .clk(clk_in),  // Use 100MHz clock for UART
        .reset(reset),
        .rx_in(rx_in),
        .tx_out(tx_out),
        .up(up),
        .down(down),
        .left(left),
        .right(right),
        .enter(enter),
        .space(space),
        .win_flag(win_flag),
        .current_cell(current_cell),
        .cell_select_flag(cell_select_flag)
    );


    // VGA display system (integrated)
    vga_top u_vga (
        .clk25(clk25),
        .reset(reset),
        .sw(board_state),
        .cell_select_flag(cell_select_flag),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B)
    );

endmodule