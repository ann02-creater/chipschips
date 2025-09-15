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

always @(*) begin
    case(Din)
        4'b0000: {a,b,c,d,e,f,g,dp} = 8'b00000011;
        4'b0001: {a,b,c,d,e,f,g,dp} = 8'b10011111;
        4'b0010: {a,b,c,d,e,f,g,dp} = 8'b00100101;
        4'b0011: {a,b,c,d,e,f,g,dp} = 8'b00001101;
        4'b0100: {a,b,c,d,e,f,g,dp} = 8'b10011001;
        4'b0101: {a,b,c,d,e,f,g,dp} = 8'b01001001;
        4'b0110: {a,b,c,d,e,f,g,dp} = 8'b01000001;
        4'b0111: {a,b,c,d,e,f,g,dp} = 8'b00011111;
        4'b1000: {a,b,c,d,e,f,g,dp} = 8'b00000001;
        4'b1001: {a,b,c,d,e,f,g,dp} = 8'b00001001;
        4'b1010: {a,b,c,d,e,f,g,dp} = 8'b00010001;
        4'b1011: {a,b,c,d,e,f,g,dp} = 8'b11000001;
        4'b1100: {a,b,c,d,e,f,g,dp} = 8'b01100011;
        4'b1101: {a,b,c,d,e,f,g,dp} = 8'b10000101;
        4'b1110: {a,b,c,d,e,f,g,dp} = 8'b01100001;
        4'b1111: {a,b,c,d,e,f,g,dp} = 8'b01110001;
        default: {a,b,c,d,e,f,g,dp} = 8'b11111111;
    endcase
end

endmodule