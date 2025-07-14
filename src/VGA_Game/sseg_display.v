module sseg_display(
    input wire clk, reset,
    input wire [1:0] winner, // 0: no winner, 1: P1 wins, 2: P2 wins
    output reg [6:0] seg_out,
    output reg [3:0] seg_sel
);
    reg [1:0] digit_select;
    reg [19:0] refresh_counter;
    reg [3:0] hex_digit;

    always @(posedge clk or posedge reset) begin
        if(reset) {
        refresh_counter <=0;
        }
        else if(refresh_counter == 20'd100000) {
        refresh_counter <=0;
        }
        else refresh_counter <= refresh_counter+1;
    end

    always @(posedge clk or posedge reset) begin
        if(reset) {
        digit_select<=0;
            }
        else if(refresh_counter==0){ 
        digit_select<=digit_select+1;
        }
    end
    always @(*) begin
        case(digit_select)
            2'b00: begin 
                seg_sel=4'b1110; 
                hex_digit = winner[1:0];
            end
            default: begin 
                seg_sel=4'b1111; 
                hex_digit=4'hF; 
            end
        endcase
    end

    // 7-segment display encoding
    always @(*) begin
        case(hex_digit)
            4'h1: seg_out=7'b1111001; // Display '1' for Player 1 win
            4'h2: seg_out=7'b0100100; // Display '2' for Player 2 win
            default: seg_out=7'b1111111; // Off
        endcase
    end
endmodule
