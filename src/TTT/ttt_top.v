module ttt_top (
    input  wire       clk_in,
    input  wire       reset_n,  // Active-low reset (CPU_RESETN button)
    input  wire       rx_in,
    output wire       tx_out,
    output wire       VGA_HS,
    output wire       VGA_VS,
    output wire [3:0] VGA_R,
    output wire [3:0] VGA_G,
    output wire [3:0] VGA_B,
    output wire [1:0] FLAG
);

    // Internal reset signal (active-high)
    wire reset = ~reset_n;

    // Internal signals  
    wire up, down, left, right, enter, space;
    wire [1:0] win_flag;
    wire [3:0] current_cell;
    wire [8:0] cell_select_flag;
    wire [17:0] board_state;  // Changed from 9-bit to 18-bit
    wire current_player;      // New signal for current player
    wire clk25;

    // UART Echo Test를 위한 신호
    wire [7:0] rx_data;
    wire rx_data_valid;
    wire tx_busy;

    // Direct UART RX instance for echo test
    uart_rx u_echo_rx (
        .clk(clk_in),
        .reset(reset),
        .rx_in(rx_in),
        .data_out(rx_data),
        .data_valid(rx_data_valid)
    );

    // UART TX for echo back
    uart_tx u_echo_tx (
        .clk(clk_in),
        .reset(reset),
        .data_in(rx_data),
        .data_valid(rx_data_valid),
        .tx_out(tx_out),
        .tx_busy(tx_busy)
    );

    // LED indicators
    reg rx_led;
    reg [23:0] led_counter;

    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            rx_led <= 1'b0;
            led_counter <= 24'd0;
        end else begin
            if (rx_data_valid) begin
                rx_led <= 1'b1;
                led_counter <= 24'd10000000; // 100ms
            end else if (led_counter > 0) begin
                led_counter <= led_counter - 1;
            end else begin
                rx_led <= 1'b0;
            end
        end
    end

    assign FLAG[0] = rx_led;  // RX 데이터 수신 표시
    assign FLAG[1] = up | down | left | right | enter | space;  // 키 입력 표시 

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
        .board_out(board_state),
        .current_player(current_player)  // New connection
    );

    // UART Controller with integrated key decoder
    uart_controller u_uart_ctrl (
        .clk(clk_in),  // Use 100MHz clock for UART
        .reset(reset),
        .rx_in(rx_in),
        .up(up),
        .down(down),
        .left(left),
        .right(right),
        .enter(enter),
        .space(space)
    );


    // VGA display system (integrated)
    vga_top u_vga (
        .clk25(clk25),
        .reset(reset),
        .sw(board_state),  // Now 18-bit
        .cell_select_flag(cell_select_flag),
        .win_flag         (win_flag),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B)
    );

endmodule