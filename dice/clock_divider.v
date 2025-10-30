`timescale 1ns / 1ps

module clock_divider(
    input wire clk,
    input wire reset,
    input wire en,
    output wire tc_1sec
);

    reg [16:0] counter;
    reg clk_out;

    // 100MHz / 50,000 = 2kHz toggle rate → 1kHz output frequency
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            counter <= 0;
            clk_out <= 0;
        end else if (en) begin
            if (counter >= 50000 - 1) begin
                counter <= 0;
                clk_out <= ~clk_out;
            end else begin
                counter <= counter + 1;
            end
        end
    end

    assign tc_1sec = clk_out;

endmodule
