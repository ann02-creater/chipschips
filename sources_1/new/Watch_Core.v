`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/07 11:14:03
// Design Name: 
// Module Name: WatchCore
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Watch_Core(
    input clk, en, rstn, inc,
    output [3:0] Q0, Q1, Q2, Q3, Q4, Q5
);

wire tc0, tc1, tc2, tc3, tc4, tc5;

BCD_cnt         U0 ( .inc(inc), .rstn(rstn), .clk(en), .TC(tc0), .Q(Q0)); // 0.1 sec
BCD_cnt         U1 ( .inc(tc0), .rstn(rstn), .clk(en), .TC(tc1), .Q(Q1) ); // 1 sec

Binary_Mod6_Cnt U2 ( .inc(tc1), .rstn(rstn), .clk(en), .TC(tc2), .Q(Q2) ); // 10 sec -> by 60 sec
BCD_cnt         U3 ( .inc(tc2), .rstn(rstn), .clk(en), .TC(tc3), .Q(Q3) ); // 1 min  -> by 60 min

Binary_Mod6_Cnt U4 ( .inc(tc3), .rstn(rstn), .clk(en), .TC(tc4), .Q(Q4) ); // 1h 
BCD_cnt         U5 ( .inc(tc4), .rstn(rstn), .clk(en), .TC(tc5), .Q(Q5) ); // 10 min -> by 60 min

endmodule
