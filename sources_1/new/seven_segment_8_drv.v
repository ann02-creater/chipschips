`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/30 10:01:30
// Design Name: 
// Module Name: seven_segment_8
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


module seven_segment_8_drv(
        input clk, reset, en,
        input wire [3:0] D0, D1, D2, D3, D4, D5, D6, D7,// DP,
        output reg a, b, c, d, e, f, g,
        output [7:0] AN
    );
    
    wire [3:0] Y;
    wire [2:0] sel;    
    
    mux81 Seg_U0 ( 
        .D0(D0), .D1(D1), .D2(D2), .D3(D3), .D4(D4),
        .D5(D5), .D6(D6), .D7(D7), .sel(sel), .D(Y)
    );
    cnt3 Seg_U1 ( .clk(clk), .en(en), .rstn(reset), .Q(sel) );
    decoder Seg_U3 ( .sel(sel), .enable(AN) );
    
    always @(*) begin
        case(Y)
            4'h0: { a, b, c, d, e, f, g } = 7'b000_0001; // 0
            4'h1: { a, b, c, d, e, f, g } = 7'b100_1111; // 1
            4'h2: { a, b, c, d, e, f, g } = 7'b001_0010; // 2
            4'h3: { a, b, c, d, e, f, g } = 7'b000_0110; // 3
            4'h4: { a, b, c, d, e, f, g } = 7'b100_1100; // 4
            4'h5: { a, b, c, d, e, f, g } = 7'b010_0100; // 5
            4'h6: { a, b, c, d, e, f, g } = 7'b010_0000; // 6
            4'h7: { a, b, c, d, e, f, g } = 7'b000_1111; // 7
            4'h8: { a, b, c, d, e, f, g } = 7'b000_0000; // 8
            4'h9: { a, b, c, d, e, f, g } = 7'b000_0100; // 9
            4'ha: { a, b, c, d, e, f, g } = 7'b000_1000; // a
            4'hb: { a, b, c, d, e, f, g } = 7'b110_0000; // b
            4'hc: { a, b, c, d, e, f, g } = 7'b011_0001; // c
            4'hd: { a, b, c, d, e, f, g } = 7'b100_0010; // d
            4'he: { a, b, c, d, e, f, g } = 7'b011_0000; // e
            default: { a, b, c, d, e, f, g } = 7'b011_1000; // f 
        endcase
    end
        
endmodule
