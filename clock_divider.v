`timescale 1ns / 1ps

module clock_divider(
    input wire clk,
    input wire reset,
    input wire en,
    output wire tc_1sec
);


    wire [7:0] TC;

    counter_bcd u0 (.clk(clk), .reset(reset), .en(en),     .Q(), .TC(TC[0]));
    counter_bcd u1 (.clk(clk), .reset(reset), .en(TC[0]),  .Q(), .TC(TC[1]));
    counter_bcd u2 (.clk(clk), .reset(reset), .en(TC[1]),  .Q(), .TC(TC[2]));
    counter_bcd u3 (.clk(clk), .reset(reset), .en(TC[2]),  .Q(), .TC(TC[3]));
    counter_bcd u4 (.clk(clk), .reset(reset), .en(TC[3]),  .Q(), .TC(TC[4]));
    counter_bcd u5 (.clk(clk), .reset(reset), .en(TC[4]),  .Q(), .TC(TC[5]));
    counter_bcd u6 (.clk(clk), .reset(reset), .en(TC[5]),  .Q(), .TC(TC[6]));
    counter_bcd u7 (.clk(clk), .reset(reset), .en(TC[6]),  .Q(), .TC(TC[7]));

    assign tc_1sec = TC[7];

endmodule