module uart_rx (
    input  wire       clk,
    input  wire       reset,
    input  wire       rx_in,
    output reg  [7:0] data_out,
    output reg        data_valid
);

    localparam 
        IDLE  = 3'd0,
        START = 3'd1,
        DATA  = 3'd2,
        STOP  = 3'd3;

    localparam CLK_FREQ = 25_000_000;
    localparam BAUD_RATE = 9600;
    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE / 16;

    reg [2:0] state;
    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;
    reg [15:0] baud_counter;
    reg baud_tick;

    // Baud rate generator
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            baud_counter <= 0;
            baud_tick <= 0;
        end else begin
            if (baud_counter >= BAUD_DIV - 1) begin
                baud_counter <= 0;
                baud_tick <= 1;
            end else begin
                baud_counter <= baud_counter + 1;
                baud_tick <= 0;
            end
        end
    end

    // UART RX state machine
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state      <= IDLE;
            bit_cnt    <= 3'd0;
            shift_reg  <= 8'd0;
            data_out   <= 8'd0;
            data_valid <= 1'b0;
        end
        else begin
            data_valid <= 1'b0;
            
            if (baud_tick) begin
                case (state)
                    IDLE: begin
                        if (rx_in == 1'b0)
                            state <= START;
                    end
                    
                    START: begin
                        state   <= DATA;
                        bit_cnt <= 3'd0;
                    end
                    
                    DATA: begin
                        shift_reg[bit_cnt] <= rx_in;
                        if (bit_cnt == 3'd7)
                            state <= STOP;
                        else
                            bit_cnt <= bit_cnt + 1;
                    end
                    
                    STOP: begin
                        data_out   <= shift_reg;
                        data_valid <= 1'b1;
                        state      <= IDLE;
                    end
                    
                    default: state <= IDLE;
                endcase
            end
        end
    end

endmodule