// Simple UART Transmitter for echo test
module uart_tx (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] data_in,
    input  wire       data_valid,
    output reg        tx_out,
    output reg        tx_busy
);

    // Same baud rate as uart_rx
    parameter [13:0] CLOCKS_PER_BIT = 14'd868; // 100MHz / 115200

    // State machine
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0]  state = IDLE;
    reg [13:0] baud_counter = 0;
    reg [2:0]  bit_index = 0;
    reg [7:0]  data_buffer = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx_out <= 1'b1;  // Idle high
            tx_busy <= 1'b0;
            state <= IDLE;
            baud_counter <= 0;
            bit_index <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx_out <= 1'b1;  // Keep high when idle
                    tx_busy <= 1'b0;
                    baud_counter <= 0;
                    bit_index <= 0;

                    if (data_valid) begin
                        data_buffer <= data_in;
                        tx_busy <= 1'b1;
                        state <= START;
                    end
                end

                START: begin
                    tx_out <= 1'b0;  // Start bit

                    if (baud_counter < CLOCKS_PER_BIT - 1) begin
                        baud_counter <= baud_counter + 1;
                    end else begin
                        baud_counter <= 0;
                        state <= DATA;
                    end
                end

                DATA: begin
                    tx_out <= data_buffer[bit_index];

                    if (baud_counter < CLOCKS_PER_BIT - 1) begin
                        baud_counter <= baud_counter + 1;
                    end else begin
                        baud_counter <= 0;

                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 0;
                            state <= STOP;
                        end
                    end
                end

                STOP: begin
                    tx_out <= 1'b1;  // Stop bit

                    if (baud_counter < CLOCKS_PER_BIT - 1) begin
                        baud_counter <= baud_counter + 1;
                    end else begin
                        baud_counter <= 0;
                        tx_busy <= 1'b0;
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule