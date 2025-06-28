`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/14 09:38:10
// Design Name: 
// Module Name: sig_controller
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

// state assignment definition
`define S0      2'b00
`define S1      2'b01
`define S2      2'b11
`define S3      2'b10

module sig_controller(
    hwy, fwy, 
    x, clk, rst, en
);

    output reg [1:0] hwy, fwy;
    input wire x, clk, rst, en;

    reg[1:0] current_state, next_state;
    
    always @(posedge clk or negedge rst)
        if(!rst) current_state <= `S0;
        else if(en) current_state <= next_state;
        
    always @(current_state or x) case (current_state)
        `S0: if(x) next_state = `S1; else next_state = `S0;
        `S1: next_state = `S2;
        `S2: if(x) next_state = `S3; else next_state = `S2;
        `S3 : next_state = `S0;
    endcase 
        
    always @(current_state or x) begin
        case(current_state)
            `S0: begin
                hwy = `GREEN;
                fwy = `RED;
            end
            
            `S1: begin
                hwy = `YELLOW;
                fwy = `RED;
            end
            
            `S2: begin
                hwy = `RED;
                fwy = `GREEN;
            end

            `S3: begin
                hwy = `RED;
                fwy = `YELLOW;
            end
                        
        endcase
    end
        
    
endmodule
