`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/23 10:35:55
// Design Name: 
// Module Name: cnt_100M
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


module cnt_100M(
    input clk, rstn,
    output eo_100M, eo_10M, eo_1M , eo_100K, eo_10K, eo_1K , eo_100, eo_10
);

    wire tc0, tc1, tc2, tc3, tc4, tc5, tc6, tc7;
    wire [3:0] Q100M;

    BCD_cnt u0 ( .TC(tc0), .inc(1'b1), .rstn(rstn), .clk(clk) );
    BCD_cnt u1 ( .TC(tc1), .inc(tc0), .rstn(rstn), .clk(clk) );
    BCD_cnt u2 ( .TC(tc2), .inc(tc1), .rstn(rstn), .clk(clk) );
    BCD_cnt u3 ( .TC(tc3), .inc(tc2), .rstn(rstn), .clk(clk) );
    BCD_cnt u4 ( .TC(tc4), .inc(tc3), .rstn(rstn), .clk(clk) );
    BCD_cnt u5 ( .TC(tc5), .inc(tc4), .rstn(rstn), .clk(clk) );
    BCD_cnt u6 ( .TC(tc6), .inc(tc5), .rstn(rstn), .clk(clk) );
    BCD_cnt u7 ( .Q(Q100M), .TC(tc7), .inc(tc6), .rstn(rstn), .clk(clk) );
    
    assign eo_100M  = tc7;
    assign eo_10M   = tc6;
    assign eo_1M    = tc5;
    assign eo_100K  = tc4;
    assign eo_10K   = tc3;
    assign eo_1K    = tc2;
    assign eo_100   = tc1;
    assign eo_10    = tc0;

endmodule
