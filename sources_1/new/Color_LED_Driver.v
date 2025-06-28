`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/14 09:52:30
// Design Name: 
// Module Name: Color_LED_Driver
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

// traffic lignt definition
`define YELLOW  2'd0
`define RED     2'd1
`define GREEN   2'd2


module Color_LED_Driver(
    input [1:0]state,
    output reg [2:0] LED // RGB
);

    always @(state) begin
        case(state)
            `RED:       LED = 3'b001; // R
            `GREEN:     LED = 3'b010; // G
            default:    LED = 3'b011; // Y 
        endcase
    end
    
endmodule
