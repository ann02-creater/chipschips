module uart_controller (
    input  wire       clk,
    input  wire       reset,
    input  wire       rx_in,
    output wire       tx_out,
    output wire       up,
    output wire       down,
    output wire       left,
    output wire       right,
    output wire       enter,
    output wire       space,
    input  wire       win_flag,
    input  wire [3:0] current_cell,
    input  wire [8:0] cell_select_flag
);

    // ASCII character codes
    localparam KEY_W = 8'h57;      // 'W' for win
    localparam KEY_C = 8'h43;      // 'C' for cursor
    localparam KEY_0 = 8'h30;      // '0' - base for digit conversion

    wire [7:0] rx_data;
    wire rx_valid;
    wire tx_busy;
    reg [7:0] tx_data;
    reg tx_send;

    uart_rx u_rx (
        .clk(clk),
        .reset(reset),
        .rx_in(rx_in),
        .data_out(rx_data),
        .data_valid(rx_valid)
    );

    uart_tx u_tx (
        .clk(clk),
        .reset(reset),
        .data_in(tx_data),
        .send(tx_send),
        .tx_out(tx_out),
        .busy(tx_busy)
    );

    key_decoder u_decoder (
        .clk(clk),
        .reset(reset),
        .uart_data(rx_data),
        .uart_valid(rx_valid),
        .up_key(up),
        .down_key(down),
        .left_key(left),
        .right_key(right),
        .enter_key(enter),
        .space_key(space)
    );

    reg [3:0] prev_current_cell;
    reg [8:0] prev_cell_select_flag;
    reg prev_win_flag;
    reg [31:0] status_timer;
    
    localparam STATUS_INTERVAL = 32'd50_000_000;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            prev_current_cell <= 0;
            prev_cell_select_flag <= 9'b000000001;
            prev_win_flag <= 0;
            tx_send <= 0;
            tx_data <= 0;
            status_timer <= 0;
        end else begin
            tx_send <= 0;

            if ((current_cell != prev_current_cell || cell_select_flag != prev_cell_select_flag || win_flag != prev_win_flag) && !tx_busy) begin
                if (win_flag) begin
                    tx_data <= KEY_W;  // 'W' for win
                    tx_send <= 1;
                end else begin
                    tx_data <= current_cell + KEY_0;  // Send current cell position
                    tx_send <= 1;
                end
                prev_current_cell <= current_cell;
                prev_cell_select_flag <= cell_select_flag;
                prev_win_flag <= win_flag;
                status_timer <= 0;
            end else if (status_timer >= STATUS_INTERVAL && !tx_busy) begin
                tx_data <= KEY_C;  // 'C' for cursor position status
                tx_send <= 1;
                status_timer <= 0;
            end else begin
                status_timer <= status_timer + 1;
            end
        end
    end

endmodule