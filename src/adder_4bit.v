module adder_4bit (
    input in_c,
    input [3:0] in_a, in_b,
    output out_c,
    output [3:0] out_s
);
    assign {out_c, out_s} = in_a + in_b + in_c;
endmodule