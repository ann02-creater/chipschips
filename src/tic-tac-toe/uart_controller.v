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
    input  wire       win_flag,
    input  wire [1:0] row,
    input  wire [1:0] col
);

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
        .up_key(up_key),
        .down_key(down_key),
        .left_key(left_key),
        .right_key(right_key),
        .enter_key(enter_key)
    );

    reg [1:0] prev_row, prev_col;
    reg prev_win_flag;
    reg [31:0] status_timer;
    
    localparam STATUS_INTERVAL = 32'd50_000_000;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            prev_row <= 0;
            prev_col <= 0;
            prev_win_flag <= 0;
            tx_send <= 0;
            tx_data <= 0;
            status_timer <= 0;
        end else begin
            tx_send <= 0;

            if ((row != prev_row || col != prev_col || win_flag != prev_win_flag) && !tx_busy) begin
                if (win_flag) begin
                    tx_data <= 8'h57;
                    tx_send <= 1;
                end else begin
                    tx_data <= {4'h3, row} + 8'h30;
                    tx_send <= 1;
                end
                prev_row <= row;
                prev_col <= col;
                prev_win_flag <= win_flag;
                status_timer <= 0;
            end else if (status_timer >= STATUS_INTERVAL && !tx_busy) begin
                tx_data <= {4'h4, col} + 8'h30;
                tx_send <= 1;
                status_timer <= 0;
            end else begin
                status_timer <= status_timer + 1;
            end
        end
    end

endmodule