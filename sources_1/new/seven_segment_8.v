`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/30 10:01:30
// Design Name: 
// Module Name: seven_segment_8
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


module seven_segment_8_drv(
        input clk, reset,
        input [3:0] D0, D1, D2, D3, D4, D5, D6, D7,
        output a, b, c, d, e, f, g,// AN,
        output [7:0]AN
    );
    
    wire [3:0] Y;
    wire [2:0] sel;
    
    mux81 SEG_U0 ( .D0(D0), .D1(D1), .D2(D2), .D3(D3), .D4(D4), .D5(D5), .D6(D6), .D7(D7), .sel(sel), .Y(Y));
    cnt3 SEG_U1 (.clk(clk), .reset(reset), .Q(sel));
    seven_segment_decoder SEG_U2 (.a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g), .data(Y));
    
    decoder SEG_U3 (.Q(sel), .enable(AN));
    cnt_100M SEG_U4 (.clk(clk), .rstn(!reset), .eo_100M(), .eo_100K(en_cnt3), .eo_1K() );
    
endmodule
