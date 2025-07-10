module mux_32bit (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire sel,
    output wire [31:0] y
);

    assign y = sel ? b : a;
//y: display에 a: 실시간 스톱워치 시간 or b: 저장된 시간 기록 중 어떤 것을 띄울지 선택
endmodule

module ssdecoder(
    input wire [3:0] data,
    output reg [6:0] seg
);
    always @(*) begin
        case (data)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            default: seg = 7'b1111111;
        endcase
    end

endmodule

module sseg_control(
    input wire clk,
    input wire reset,
    input wire [31:0] data,//4-bit data 총 8개
    input wire tc_led,
    output wire [6:0] seg,
    output reg [7:0] AN
);

    reg [2:0] digit_select;//현재 표시할 digit을 선택
    reg [3:0] digit_data;//digit_select한 4-bit data를 ssdecoder에 전달
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            digit_select <= 3'd0;
        end else if (tc_led) begin
            digit_select <= digit_select + 1;
        end
    end
    
    always @(*) begin
        case (digit_select)//현재 표시할 digit 순서(0~7)에 따라 display에 표시됨
            3'd0: begin AN = 8'b11111110; digit_data = data[3:0]; end//LSB부터 켜짐
            3'd1: begin AN = 8'b11111101; digit_data = data[7:4]; end
            3'd2: begin AN = 8'b11111011; digit_data = data[11:8]; end
            3'd3: begin AN = 8'b11110111; digit_data = data[15:12]; end
            3'd4: begin AN = 8'b11101111; digit_data = data[19:16]; end
            3'd5: begin AN = 8'b11011111; digit_data = data[23:20]; end
            3'd6: begin AN = 8'b10111111; digit_data = data[27:24]; end
            3'd7: begin AN = 8'b01111111; digit_data = data[31:28]; end
        endcase
    end
    
    ssdecoder U_DECODER (
        .data(digit_data),
        .seg(seg)
    );

endmodule
