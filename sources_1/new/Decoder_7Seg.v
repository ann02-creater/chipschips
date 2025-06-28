`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/24 22:12:23
// Design Name: 
// Module Name: Decoder_7Seg
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



module Decoder_7Seg(
    output wire CA, CB, CC, CD, CE, CF, CG,
    input wire [3:0] Data
);  

    reg [6:0] C7;

    always @(*) begin
        case(Data)
            4'h0:C7 = 7'b000_0001; 
            4'h1:C7 = 7'b100_1111;
            4'h2:C7 = 7'b001_0010; 
            4'h3:C7 = 7'b000_0110; 
            4'h4:C7 = 7'b100_1100; 
            4'h5:C7 = 7'b010_0100; 
            4'h6:C7 = 7'b010_0000; 
            4'h7:C7 = 7'b000_1111;
            4'h8:C7 = 7'b000_0000; 
            4'h9:C7 = 7'b000_0100; 
            4'ha:C7 = 7'b000_1000; 
            4'hb:C7 = 7'b110_0000; 
            4'hc:C7 = 7'b011_0001; 
            4'hd:C7 = 7'b100_0010; 
            4'he:C7 = 7'b011_0000; 
            4'hf:C7 = 7'b011_1000; 
            default: C7 = 7'b000_0000; // 0
        endcase
    end
    
    assign {CA, CB, CC, CD, CE, CF, CG} = C7;
    assign DP = 1'b1;
    
endmodule
