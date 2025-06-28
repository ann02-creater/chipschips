`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/30 10:03:31
// Design Name: 
// Module Name: top_7Seg_demo
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


module top_7Seg_demo(
        input CLK100MHZ, reset, BTNC,
        output a, b, c, d, e, f, g, //DP,
        output [7:0] AN
    );
    
    
    wire [3:0] D0, D1, D2, D3, D4, D5, D6, D7;
    wire eo_10M, eo_100K;
    wire stop_signal;
    
    
    seven_segment_8_drv U0 (
        .clk(CLK100MHZ), .reset(reset), .en(eo_100K), //eo_100K ∞Ì¡§
        .D0(D0),.D1(D1),.D2(D2),.D3(D3),.D4(D4),.D5(D5),.D6(D6),.D7(D7), 
        .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g), .AN(AN)
    );
    
    
    Watch_Core WATCH (
        .clk(CLK100MHZ), .en(eo_10M), .rstn(reset), .inc(stop_signal),
        .Q0(D0), .Q1(D1), .Q2(D2), .Q3(D3), .Q4(D4), .Q5(D5) 
    );
    
        
    Debounced_TFF DUT ( 
        .clk(CLK100MHZ), .en(eo_10M), 
        .rstn(reset), .BTN(BTNC), .debTFF(stop_signal) 
    ); 
    
    
    cnt_100M DIV (
        .clk(CLK100MHZ), .rstn(reset),
        .eo_100M(eo_100M), .eo_10M(eo_10M), .eo_100K(eo_100K), 
        .eo_10K(eo_10K), .eo_1K(eo_1K), .eo_100(eo_100) 
    );
    

    assign D6 = 0;
    assign D7 = 0;
    

endmodule
