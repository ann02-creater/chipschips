`timescale 1ns / 1ps

module clock_divider_1sec(
    input wire clk,         // 100MHz input clock
    input wire reset,
    input wire en,
    output wire tc_1sec     // Terminal count - pulses every 1 second
);

    // 8 TC signals for chaining BCD counters
    // 100MHz / 10^8 = 1Hz (1 second)
    wire [7:0] TC;

    // Chain of 8 BCD counters to divide by 10^8
    counter_bcd U0 (.clk(clk), .reset(reset), .en(en),     .Q(), .TC(TC[0]));
    counter_bcd U1 (.clk(clk), .reset(reset), .en(TC[0]),  .Q(), .TC(TC[1]));
    counter_bcd U2 (.clk(clk), .reset(reset), .en(TC[1]),  .Q(), .TC(TC[2]));
    counter_bcd U3 (.clk(clk), .reset(reset), .en(TC[2]),  .Q(), .TC(TC[3]));
    counter_bcd U4 (.clk(clk), .reset(reset), .en(TC[3]),  .Q(), .TC(TC[4]));
    counter_bcd U5 (.clk(clk), .reset(reset), .en(TC[4]),  .Q(), .TC(TC[5]));
    counter_bcd U6 (.clk(clk), .reset(reset), .en(TC[5]),  .Q(), .TC(TC[6]));
    counter_bcd U7 (.clk(clk), .reset(reset), .en(TC[6]),  .Q(), .TC(TC[7]));

    // Final TC output - pulses once per second
    assign tc_1sec = TC[7];

endmodule