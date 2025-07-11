module sseg_display(
    input wire clk, input wire reset,
    input wire [7:0] data_in,// winner=1이면 1 표시, winner=2면 2 표시
    output reg [6:0] seg_out,
    output reg [3:0] seg_sel
);
    reg [1:0] digit_select;
    reg [19:0] refresh_counter;
    reg [3:0] hex_digit;
    always @(posedge clk or posedge reset) begin
        if(reset) refresh_counter <=0;
        else if(refresh_counter == 20'd100000) refresh_counter <=0;
        else refresh_counter <= refresh_counter+1;
    end

    always @(posedge clk or posedge reset) begin
        if(reset) digit_select<=0;
        else if(refresh_counter==0) 
        digit_select<=digit_select+1;
    end
    always @(*) begin
        case(digit_select)
            2'b00: begin 
            seg_sel=4'b1110; 
            hex_digit=data_in[3:0]; 
            end
            default: begin 
            seg_sel=4'b1111; 
            hex_digit=4'h0; 
            end
        endcase
    end
    // 7-segment display encoding
    always @(*) begin
        case(hex_digit)
            4'h0: seg_out=7'b1000000; 
            4'h1: seg_out=7'b1111001;//player 1 win
            4'h2: seg_out=7'b0100100; //player 2 win
            default: seg_out=7'b1111111;
        endcase
    end
endmodule