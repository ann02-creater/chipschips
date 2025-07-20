module uart_tx(
    input wire clk,
    input wire reset,
    input wire [7:0] tx_data_out_in,
    input wire tx_start, // 전송 시작 신호
    output reg tx_data_out_out,
    output reg tx_busy
    
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
    reg tx_start_reg; // 전송 시작 신호의 이전 상태
    reg tx_start_pulse; // 0~1로 바뀔때의 신호
   
    always @(posedge clk, posedge reset) begin // 상승엣지에서의 신호를 정확히 감지
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
            tx_data_out <= 1'b1;
            tx_busy <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    tx_data_out_out <= 1'b1;
                    tx_busy <= 1'b0; // 전송 중 아님
                    if (tx_start_pulse) begin
                        state <= START;
                        tx_buffer <= tx_data_outt_in;
                        parity_bit <= ^tx_data_outt_in; 
                        bit_cnt <= 3'd0;
                        tx_busy <= 1'b1; // 전송중
                    end
                end
                START: begin
                    tx_data_out <= 1'b0;
                    state <= DATA;
                    bit_cnt <= 3'd0;
                end
                DATA: begin
                    tx_data_out <= tx_buffer[bit_cnt];
                    if (bit_cnt == 3'd7) begin
                        state <= PARITY;
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end
                PARITY: begin
                    tx_data_out <= parity_bit;
                    state <= STOP;
                end
                STOP: begin
                    tx_data_out <= 1'b1; 
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end



endmodule