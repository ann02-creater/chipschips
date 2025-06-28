`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/09 01:08:35
// Design Name: 
// Module Name: tb_Debounce
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


module top_Debounce(
    input CLK100MHZ, reset, BTNC,
    output LED
);
    
    
    Debounced_TFF DUT ( 
        .clk(CLK100MHZ), .en(eo_10M), 
        .rstn(reset), .BTN(BTNC), .debTFF(LED) 
    );
        
    cnt_100M DIV (
        .clk(CLK100MHZ), .rstn(reset),
        .eo_100M(en), .eo_10M(eo_10M), .eo_100K(eo_100K), 
        .eo_10K(eo_10K), .eo_1K(eo_1K), .eo_100(eo_100) 
    );
    
    
    
endmodule
