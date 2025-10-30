module ssdecoder(
    input [2:0] dice_value,
    output reg [6:0] seg
);
    always @(*) begin
        case (dice_value)
            3'd1: seg = 7'b1111001; // 1
            3'd2: seg = 7'b0100100; // 2
            3'd3: seg = 7'b0110000; // 3
            3'd4: seg = 7'b0011001; // 4
            3'd5: seg = 7'b0010010; // 5
            3'd6: seg = 7'b0000010; // 6
            default: seg = 7'b1111111; // blank
        endcase
    end
endmodule
