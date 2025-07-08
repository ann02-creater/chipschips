module seg7_display(
    input wire clk,
    input wire reset,
    input wire [7:0] data_in,
    output reg [6:0] seg_out,
    output reg [3:0] seg_sel
);

reg [1:0] digit_select;
reg [19:0] refresh_counter;
reg [3:0] hex_digit;


always @(posedge clk, posedge reset) begin
    if(reset)
        refresh_counter <= 0;
    else if(refresh_counter == 20'd100000)
        refresh_counter <= 0;
    else
        refresh_counter <= refresh_counter + 1;
end


always @(posedge clk, posedge reset) begin
    if(reset)
        digit_select <= 0;
    else if(refresh_counter == 0)
        digit_select <= digit_select + 1;
end


always @(*) begin
    case(digit_select)
        2'b00: begin
            seg_sel = 4'b1110;  
            hex_digit = data_in[3:0];
        end
        2'b01: begin
            seg_sel = 4'b1101;  
            hex_digit = data_in[7:4];
        end
        default: begin
            seg_sel = 4'b1111; 
            hex_digit = 4'h0;
        end
    endcase
end

always @(*) begin
    case(hex_digit)
        4'h0: seg_out = 7'b1000000;  
        4'h1: seg_out = 7'b1111001;  
        4'h2: seg_out = 7'b0100100;  
        4'h3: seg_out = 7'b0110000;  
        4'h4: seg_out = 7'b0011001;  
        4'h5: seg_out = 7'b0010010; 
        4'h6: seg_out = 7'b0000010;  
        4'h7: seg_out = 7'b1111000; 
        4'h8: seg_out = 7'b0000000;  
        4'h9: seg_out = 7'b0010000;  
        4'hA: seg_out = 7'b0001000;  
        4'hB: seg_out = 7'b0000011;  
        4'hC: seg_out = 7'b1000110;  
        4'hD: seg_out = 7'b0100001;  
        4'hE: seg_out = 7'b0000110;  
        4'hF: seg_out = 7'b0001110;  
        default: seg_out = 7'b1111111;  
    endcase
end

endmodule