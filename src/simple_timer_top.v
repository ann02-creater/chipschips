`timescale 1ns / 1ps

module simple_timer_top(
    input wire clk,         // 100MHz system clock
    input wire reset,       // Active-high reset
    output wire [6:0] seg,  // 7-segment display segments
    output wire [7:0] AN    // Anode control - only one digit active
);

    // Internal signals
    wire tc_1sec;           // 1 second pulse from clock divider
    wire [3:0] seconds;     // Single digit second counter (0-9)
    wire tc_seconds;        // Terminal count for seconds counter

    // Clock divider: 100MHz -> 1Hz (1 second)
    clock_divider_1sec U_CLK_DIV (
        .clk(clk),
        .reset(reset),
        .en(1'b1),          // Always enabled
        .tc_1sec(tc_1sec)
    );

    // Single BCD counter for seconds (0-9)
    counter_bcd U_SECONDS (
        .clk(clk),
        .reset(reset),
        .en(tc_1sec),       // Count when 1 second passes
        .Q(seconds),
        .TC(tc_seconds)     // TC when reaching 9
    );

    // 7-segment decoder for displaying the seconds
    ssdecoder U_DECODER (
        .data(seconds),
        .seg(seg)
    );

    // Only activate the rightmost digit (AN[0])
    // All other digits are turned off
    assign AN = 8'b11111110;  // Only AN[0] is active (low)

endmodule