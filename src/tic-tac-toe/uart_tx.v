module uart_tx (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] data_in,
    input  wire       send,
    output reg        tx_out,
    output reg        busy
);

    localparam 
        IDLE  = 3'd0,
        START = 3'd1,
        DATA  = 3'd2,
        STOP  = 3'd3;

    reg [2:0] state;
    reg [2:0] bit_cnt;
    reg [7:0] tx_buffer;
    reg send_prev, send_pulse;

    // Button edge detection
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            send_prev  <= 0;
            send_pulse <= 0;
        end else begin
            send_prev  <= send;
            send_pulse <= send & ~send_prev;
        end
    end

    // UART TX State Machine
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state     <= IDLE;
            bit_cnt   <= 0;
            tx_buffer <= 0;
            busy      <= 0;
        end else begin
            case (state)
                IDLE: begin
                    busy <= 0;
                    if (send_pulse) begin
                        state     <= START;
                        tx_buffer <= data_in;
                        bit_cnt   <= 0;
                        busy      <= 1;
                    end
                end
                
                START: begin
                    state   <= DATA;
                    bit_cnt <= 0;
                end
                
                DATA: begin
                    if (bit_cnt == 3'd7) begin
                        state <= STOP;
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end
                
                STOP: begin
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end

    // TX Data Output
    always @(posedge clk, posedge reset) begin
        if (reset)
            tx_out <= 1;
        else begin
            case (state)
                IDLE:  tx_out <= 1;
                START: tx_out <= 0;
                DATA:  tx_out <= tx_buffer[bit_cnt];
                STOP:  tx_out <= 1;
                default: tx_out <= 1;
            endcase
        end
    end

endmodule