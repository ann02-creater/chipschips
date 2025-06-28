`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/23 10:33:35
// Design Name: 
// Module Name: BCD_cnt
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


module BCD_cnt(
    input inc, rstn, clk, 
    output TC,
    output reg [3:0] Q 
);
           
//wire fin;
               
always @(posedge clk or negedge rstn) begin
   if(!rstn) Q <= 4'd0; // synchronous reset
   else if (inc) begin
      if (TC) Q<=4'd0;
      else Q <= Q + 1;
   end
end

assign TC = ( Q == 4'd9 && inc) ? 1 : 0;
//assign fin = (Q == 4'd9 )?1:0;
//assign TC = fin & inc;

endmodule
