`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/09 00:41:46
// Design Name: 
// Module Name: Debounce
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


module Debounced_TFF(
        input clk, en, rstn, BTN,
        output debTFF
    );
    
    wire Q0;
    
    diff U0 ( .clk(clk), .en(en), .D(BTN), .rstn(rstn), .Q(Q0) );
    diff U1 ( .clk(clk), .en(en), .D(Q0),  .rstn(rstn), .Q(debTFF)  );
//    tff  U2 ( .clk(clk), .en(en), .T(~Q1&Q0),  .rstn(rstn), .Q(debTFF) ); 
    
    
endmodule
