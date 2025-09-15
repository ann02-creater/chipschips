module mux_4to1_3bit(
    input [2:0] in_a,
    input [2:0] in_b,
    input [2:0] in_c,
    input [2:0] in_d,
    input [1:0] sel,
    output reg [2:0] out
);

always @(*) begin
    case(sel)
        2'b00: out = in_a;
        2'b01: out = in_b;
        2'b10: out = in_c;
        2'b11: out = in_d;
    endcase
end

endmodule

