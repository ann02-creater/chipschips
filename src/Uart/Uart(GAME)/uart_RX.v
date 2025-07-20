module uart_rx(
    input  wire       clk,
    input  wire       reset,
    input  wire       rx_data,
    output reg  [7:0] rx_ascii_reg,
    output reg        parity_error
    output reg        rx_data_valid // 10개의 값 중 하나만 눌렀을 때 작동함
);

    localparam IDLE   = 3'd0,
               START  = 3'd1,
               DATA   = 3'd2,
               PARITY = 3'd3,
               STOP   = 3'd4;

    reg [2:0] state;
    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state         <= IDLE;
            bit_cnt       <= 3'd0;
            shift_reg     <= 8'd0;
            rx_ascii_reg  <= 8'd0;
            parity_error  <= 1'b0;
            rx_data_valid <= 1'b0;
        end
        else begin

            rx_data_valid <= 1'b0;

            case (state)
                IDLE: begin
                    if (rx_data == 1'b0)
                        state <= START;
                end
                START: begin
                    state   <= DATA;
                    bit_cnt <= 3'd0;
                end
                DATA: begin
                    shift_reg[bit_cnt] <= rx_data;
                    if (bit_cnt == 3'd7)
                        state <= PARITY;
                    else
                        bit_cnt <= bit_cnt + 1;
                end
                PARITY: begin
                    parity_error <= (rx_data != (^shift_reg));
                    state        <= STOP;
                end
                STOP: begin
                    rx_data_valid <= 1'b1;
                    rx_ascii_reg <= shift_reg;
                    state        <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule