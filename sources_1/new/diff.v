`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/08 22:45:15
// Design Name: 
// Module Name: Diff
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


module diff(output reg Q, input D, input en, input clk, input rstn );

// 동기 reset 이라 가정
always @( posedge clk )
    if (!rstn)
        Q <= 0;
    else if (en)
        Q <= D;

endmodule
