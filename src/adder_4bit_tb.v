`timescale 1ns/1ps
`include "adder_4bit.v"

module adder_4bit_tb;
    reg in_c;
    reg [3:0] in_a, in_b;
    wire out_c;
    wire [3:0] out_s;

    adder_4bit a(.in_c(in_c), .in_a(in_a), .in_b(in_b), .out_c(out_c), .out_s(out_s));

    initial begin
        $dumpfile("adder_4bit_tb.vcd");
        $dumpvars(0, adder_4bit_tb);
    end

    initial begin
        in_c = 1'b0;
        in_a = 4'd5;
        in_b = 4'd7; // out_s == 12

        #10;
        in_c = 1'b1;
        in_a = 4'd3; // out_s == 11

        #10;
        in_b = 4'd1; // out_s == 5

        #50;
        $finish;
    end
    
endmodule