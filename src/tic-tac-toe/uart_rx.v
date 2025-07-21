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

    reg [2:0] state;
    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;
    wire baud_tick;

    // Baud rate generator instance for RX (16x oversampling)
    baud_rate_gen_rx u_baud_gen_rx (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick)
    );

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