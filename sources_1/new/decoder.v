`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/30 09:40:39
// Design Name: 
// Module Name: decoder
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


module decoder( // 3:8 active low decoder
    input [2:0] sel,
    output reg [7:0] enable
);
    
    
    always @(*) begin
        case (sel)
            3'b000: enable = ~8'b0000_0001;
            3'b001: enable = ~8'b0000_0010;
            3'b010: enable = ~8'b0000_0100;
            3'b011: enable = ~8'b0000_1000;
            3'b100: enable = ~8'b0001_0000;
            3'b101: enable = ~8'b0010_0000;
            3'b110: enable = ~8'b0100_0000;
            default: enable = ~8'b1000_0000;
        endcase
    end
    
endmodule
