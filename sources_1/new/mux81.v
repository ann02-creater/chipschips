`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/30 10:45:17
// Design Name: 
// Module Name: mux81
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


module mux81(
    input [3:0] D0, D1, D2, D3, D4, D5, D6, D7,
    input [3:0] sel,
    output reg [3:0] D
);

always @(*)
    case (sel)
        3'b000: D = D0;
        3'b001: D = D1;
        3'b010: D = D2;
        3'b011: D = D3;
        3'b100: D = D4;
        3'b101: D = D5;
        3'b110: D = D6;
        default: D = D7;
    endcase

endmodule
