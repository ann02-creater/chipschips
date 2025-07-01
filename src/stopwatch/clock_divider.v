`timescale 1ns / 1ps

module clock_divider(
    input wire clk,
    input wire reset,
    input wire en,
    output wire tc_1ms,
    output wire tc_refresh
);

    wire [4:0] TC_1ms;
    wire [3:0] TC_refresh;
    
    // 1ms 생성용 BCD 카운터 체인 (100,000 = 10^5)
    counter_bcd U0_1ms (.clk(clk), .reset(reset), .en(en), .Q(), .TC(TC_1ms[0]));
    counter_bcd U1_1ms (.clk(clk), .reset(reset), .en(TC_1ms[0]), .Q(), .TC(TC_1ms[1]));
    counter_bcd U2_1ms (.clk(clk), .reset(reset), .en(TC_1ms[1]), .Q(), .TC(TC_1ms[2]));
    counter_bcd U3_1ms (.clk(clk), .reset(reset), .en(TC_1ms[2]), .Q(), .TC(TC_1ms[3]));
    counter_bcd U4_1ms (.clk(clk), .reset(reset), .en(TC_1ms[3]), .Q(), .TC(TC_1ms[4]));
    counter_bcd U5_1ms (.clk(clk), .reset(reset), .en(TC_1ms[4]), .Q(), .TC(tc_1ms));
    
    // refresh 생성용 BCD 카운터 체인 (12,500 = 1.25 * 10^4)
    counter_bcd U0_ref (.clk(clk), .reset(reset), .en(en), .Q(), .TC(TC_refresh[0]));
    counter_bcd U1_ref (.clk(clk), .reset(reset), .en(TC_refresh[0]), .Q(), .TC(TC_refresh[1]));
    counter_bcd U2_ref (.clk(clk), .reset(reset), .en(TC_refresh[1]), .Q(), .TC(TC_refresh[2]));
    counter_bcd U3_ref (.clk(clk), .reset(reset), .en(TC_refresh[2]), .Q(), .TC(TC_refresh[3]));
    counter_bcd U4_ref (.clk(clk), .reset(reset), .en(TC_refresh[3]), .Q(), .TC(tc_refresh));
    
endmodule