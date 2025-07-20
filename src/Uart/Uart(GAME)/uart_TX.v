module uart_tx(
    input wire clk,
    input wire reset,
    input wire [7:0] tx_data_in,
    output reg tx_data_out,
    output reg tx_busy
    
);

    localparam IDLE = 3'd0,
               START = 3'd1,
               DATA = 3'd2,
               PARITY = 3'd3,
               STOP = 3'd4;

    reg [2:0] state;
    reg [2:0] bit_cnt;//현재 송신중인 bit위치 추적용. 몇번째 switch인지 확인함.
    reg [7:0] tx_buffer;//tx_buffer[bt_cnt]로 1-bit짜리 switch 8개의 값을 하나로 묶어둔 것.
    reg parity_bit;
    reg tx_start_reg;
    reg tx_start_pulse;
   
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            tx_start_reg <= 1'b0;
            tx_start_pulse <= 1'b0;
        end else begin
            tx_start_reg <= tx_start;
        tx_start_pulse <= ~tx_start_reg & tx_start;
        end
    end

    // UART TX State Machine
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            bit_cnt <= 3'd0;
            tx_buffer <= 8'd0;
            parity_bit <= 1b'0;
            tx_data <= 1'b1;
            tx_busy <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    tx_data_out <= 1'b1;
                    tx_busy <= 1'b0; // 전송 중 아님


                    if (tx_start_pulse) begin
                        state <= START;
                        tx_buffer <= tx_datat_in;
                        parity_bit <= ^tx_datat_in; 
                        bit_cnt <= 3'd0;
                        tx_busy <= 1'b1;
                    end
                end
                START: begin
                    tx_data <= 1'b0;
                    state <= DATA;
                    bit_cnt <= 3'd0;
                end
                DATA: begin
                    tx_data <= tx_buffer[bit_cnt];
                    if (bit_cnt == 3'd7) begin
                        state <= PARITY;
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end
                PARITY: begin
                    tx_data <= parity_bit;
                    state <= STOP;
                end
                STOP: begin
                    tx_data <= 1'b1; 
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule