`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/24 22:05:10
// Design Name: 
// Module Name: watch_1Mz
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


module watch_1Mz(
    input clk, input rstn,
    output a, b, c, d, e, f, g, DP,
    output [7:0] AN 
);

    wire en;
    wire [3:0] Q;
    
    BCD_cnt cnt ( .Q(Q), .TC(), .inc(en), .rstn(rstn), .clk(clk) );
    cnt_100M div ( .clk(clk), .rstn(rstn), .eo_100M(en) );
    Decoder_7Seg seg (.Data(Q), .CA(a), .CB(b), .CC(c), .CD(d), .CE(e), .CF(f), .CG(g), .DP(DP));
    
    assign AN = 8'b1111_1110;
    
  
endmodule
