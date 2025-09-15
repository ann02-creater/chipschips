`timescale 1ns / 1ps

module mux_4to1_3bit(
    input [2:0] A,
    input [2:0] B,
    input [2:0] C,
    input [2:0] D,
    input [1:0] sel,
    output reg [2:0] Y
);

always @(*) begin
    case(sel)
        2'b00: Y = A;
        2'b01: Y = B;
        2'b10: Y = C;
        2'b11: Y = D;
        default: Y = 3'b000;
    endcase
end

endmodule