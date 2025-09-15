`timescale 1ns / 1ps

module ss_decoder(
    input [3:0] Din,
    output reg a,
    output reg b,
    output reg c,
    output reg d,
    output reg e,
    output reg f,
    output reg g,
    output reg dp
);

always @(Din)
case(Din)
    4'b0000 : begin//0
                a = 0;
                b = 0;
                c = 0;
                d = 0;
                e = 0;
                f = 0;
                g = 1;
                dp = 1;
            end
    4'b0001 : begin//1
                a = 1;
                b = 0;
                c = 0;
                d = 1;
                e = 1;
                f = 1;
                g = 1;
                dp = 1;
            end
    4'b0010 : begin//2
                a = 0;
                b = 0;
                c = 1;
                d = 0;
                e = 0;
                f = 1;
                g = 0;
                dp = 1;
            end
    4'b0011 : begin//3
                a = 0;
                b = 0;
                c = 0;
                d = 0;
                e = 1;
                f = 1;
                g = 0;
                dp = 1;
            end
    4'b0100 : begin//4
                a = 1;
                b = 0;
                c = 0;
                d = 1;
                e = 1;
                f = 0;
                g = 0;
                dp = 1;
            end
    4'b0101 : begin//5
                a = 0;
                b = 1;
                c = 0;
                d = 0;
                e = 1;
                f = 0;
                g = 0;
                dp = 1;
            end
    4'b0110 : begin//6
                a = 0;
                b = 1;
                c = 0;
                d = 0;
                e = 0;
                f = 0;
                g = 0;
                dp = 1;
            end
    4'b0111 : begin//7
                a = 0;
                b = 0;
                c = 0;
                d = 1;
                e = 1;
                f = 1;
                g = 1;
                dp = 1;
            end
    4'b1000 : begin//8
                a = 0;
                b = 0;
                c = 0;
                d = 0;
                e = 0;
                f = 0;
                g = 0;
                dp = 1;
            end
    4'b1001 : begin//9
                a = 0;
                b = 0;
                c = 0;
                d = 0;
                e = 1;
                f = 0;
                g = 0;
                dp = 1;
            end
    4'b1010 : begin//a
                a = 0;
                b = 0;
                c = 0;
                d = 1;
                e = 0;
                f = 0;
                g = 0;
                dp = 1;
            end
    4'b1011 : begin//b
                a = 1;
                b = 1;
                c = 0;
                d = 0;
                e = 0;
                f = 0;
                g = 0;
                dp = 1;
            end
    4'b1100 : begin//c
                a = 0;
                b = 1;
                c = 1;
                d = 0;
                e = 0;
                f = 0;
                g = 1;
                dp = 1;
            end
    4'b1101 : begin//d
                a = 1;
                b = 0;
                c = 0;
                d = 0;
                e = 0;
                f = 1;
                g = 0;
                dp = 1;
            end
    4'b1110 : begin//e
                a = 0;
                b = 1;
                c = 1;
                d = 0;
                e = 0;
                f = 0;
                g = 0;
                dp = 1;
            end
    4'b1111 : begin//f
                a = 0;
                b = 1;
                c = 1;
                d = 1;
                e = 0;
                f = 0;
                g = 0;
                dp = 1;
            end
    default : begin
                a = 1;
                b = 1;
                c = 1;
                d = 1;
                e = 1;
                f = 1;
                g = 1;
                dp = 1;
            end
endcase

endmodule