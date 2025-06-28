`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/30 22:17:53
// Design Name: 
// Module Name: cnt3
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


module cnt3(
    input en, rstn, clk,
    output TC,
    output reg [2:0]Q
);
    
wire fin;

always @(posedge clk or negedge rstn) begin
    if(!rstn) Q <= 3'd0;
    else if (en)
        if (fin) Q <= 3'd0;
        else Q <= Q + 1;
end
    
assign fin = (Q == 3'd7);
assign TC = fin & en;
    
    
endmodule
