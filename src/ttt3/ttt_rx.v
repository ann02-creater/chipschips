module uart_rx (
    input  wire       clk,
    input  wire       reset,
    input  wire       rx_serial,
    output reg  [7:0] data,
    output reg        valid
);
    parameter CLK_FREQ = 100_000_000;
    parameter BAUD     = 9600;
    localparam BAUD_DIV = CLK_FREQ / BAUD;

    reg [15:0] baud_cnt;
    reg [3:0]  bit_idx;
    reg [7:0]  shift_reg;
    reg        rx_d1, rx_d2;
    reg        sampling;

    always @(posedge clk) begin
        rx_d1 <= rx_serial;
        rx_d2 <= rx_d1;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            baud_cnt  <= 0;
            bit_idx   <= 0;
            shift_reg <= 0;
            data      <= 0;
            valid     <= 0;
            sampling  <= 0;
        end else begin
            valid <= 0;
            if (!sampling) begin
                if (rx_d2 == 1'b0) begin
                    sampling <= 1;
                    baud_cnt <= BAUD_DIV/2;
                    bit_idx  <= 0;
                end
            end else begin
                if (baud_cnt == BAUD_DIV-1) begin
                    baud_cnt <= 0;
                    if (bit_idx < 8) begin
                        shift_reg[bit_idx] <= rx_d2;
                        bit_idx <= bit_idx + 1;
                    end else begin
                        data     <= shift_reg;
                        valid    <= 1;
                        sampling <= 0;
                    end
                end else begin
                    baud_cnt <= baud_cnt + 1;
                end
            end
        end
    end
endmodule
