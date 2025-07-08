module uart_tx(
    input wire clk,
    input wire reset,
    input wire [7:0] switches,
    input wire btn_send,
    output reg tx_data
    //output reg tx_busy
);

    localparam IDLE = 3'd0,
               START = 3'd1,
               DATA = 3'd2,
               PARITY = 3'd3,
               STOP = 3'd4;

    reg [2:0] state;
    reg [2:0] bit_cnt;
    reg [7:0] tx_buffer;
    reg parity_bit;
    reg btn_prev, btn_pulse;

    // Button edge detection
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            btn_prev <= 0;
            btn_pulse <= 0;
        end else begin
            btn_prev <= btn_send;
            btn_pulse <= btn_send & ~btn_prev;
        end
    end

    // UART TX State Machine
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            bit_cnt <= 0;
            tx_buffer <= 0;
            parity_bit <= 0;
            //tx_busy <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (btn_pulse) begin
                        state <= START;
                        tx_buffer <= switches;
                        parity_bit <= ^switches; 
                        bit_cnt <= 0;
                       //tx_busy <= 1;
                    end
                end
                START: begin
                    state <= DATA;
                    bit_cnt <= 0;
                end
                DATA: begin
                    if (bit_cnt == 3'd7) begin
                        state <= PARITY;
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end
                PARITY: begin
                    state <= STOP;
                end
                STOP: begin
                    state <= IDLE;
                    //tx_busy <= 0;
                end
                default: state <= IDLE;
            endcase
        end
    end

    // TX Data Output
    always @(posedge clk, posedge reset) begin
        if (reset)
            tx_data <= 1;
        else begin
            case (state)
                IDLE: tx_data <= 1;
                START: tx_data <= 0;
                DATA: tx_data <= tx_buffer[bit_cnt];
                PARITY: tx_data <= parity_bit;
                STOP: tx_data <= 1;
                default: tx_data <= 1;
            endcase
        end
    end

endmodule