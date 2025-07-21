module baud_rate_gen(
    input wire clk,
    input wire reset,
    output reg baud_tick
);

// 25MHz / 9600 = 2604 클록 주기
localparam BAUD_COUNT = 2604;
reg [11:0] counter;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter <= 0;
        baud_tick <= 0;
    end else begin
        if (counter == BAUD_COUNT - 1) begin
            counter <= 0;
            baud_tick <= 1;
        end else begin
            counter <= counter + 1;
            baud_tick <= 0;
        end
    end
end

endmodule

module baud_rate_gen_rx(
    input wire clk,
    input wire reset,
    output reg baud_tick
);

// RX용 16x 오버샘플링: 25MHz / (9600 * 16) = 163 클록 주기
localparam BAUD_COUNT = 163;
reg [7:0] counter;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter <= 0;
        baud_tick <= 0;
    end else begin
        if (counter == BAUD_COUNT - 1) begin
            counter <= 0;
            baud_tick <= 1;
        end else begin
            counter <= counter + 1;
            baud_tick <= 0;
        end
    end
end

endmodule