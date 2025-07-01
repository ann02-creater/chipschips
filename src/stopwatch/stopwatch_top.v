`timescale 1ns / 1ps

module stop_watch_top(
    input wire clk,
    input wire reset, 
    input wire btn,
    output reg [6:0] SEG,
    output reg [7:0] AN
);

    wire toggle;
    wire [2:0] sel;
    wire tc_100Hz, tc_1MHz;
    
    // 카운터 출력들
    wire [3:0] Q0, Q1, Q2, Q4, Q6, Q7;
    wire [2:0] Q3, Q5;
    wire tc0, tc1, tc2, tc3, tc4, tc5, tc6, tc7;
    
    // 7-segment 디코딩용
    reg [3:0] data;
    reg [6:0] sseg;
    
    // 디바운스 모듈
    debounce U_DEBOUNCE (.clk(clk), .reset(reset), .btn(btn), .toggle(toggle));
    
    // 클럭 분주기 
    clock_divider U_Clkdivider (.clk(clk), .reset(reset), .en(toggle), .tc_100Hz(tc_100Hz), .tc_1MHz(tc_1MHz));
    
    // 10ms BCD counter (Q0 = 0-9)
    counter_bcd U0 (.clk(clk), .reset(reset), .en(tc_100Hz), .Q(Q0), .tc(tc0));
    
    // 100ms BCD counter
    counter_bcd U1 (.clk(clk), .reset(reset), .en(tc0), .Q(Q1), .tc(tc1));
    
    // 1s BCD counter
    counter_bcd U2 (.clk(clk), .reset(reset), .en(tc1), .Q(Q2), .tc(tc2));
    
    // 10s mod6 counter
    counter_mod6 U3 (.clk(clk), .reset(reset), .en(tc2), .Q(Q3), .tc(tc3));
    
    // 1min BCD counter
    counter_bcd U4 (.clk(clk), .reset(reset), .en(tc3), .Q(Q4), .tc(tc4));
    
    // 10min mod6 counter
    counter_mod6 U5 (.clk(clk), .reset(reset), .en(tc4), .Q(Q5), .tc(tc5));
    
    // 1hour BCD counter
    counter_bcd U6 (.clk(clk), .reset(reset), .en(tc5), .Q(Q6), .tc(tc6));
    
    // 10hour BCD counter
    counter_bcd U7 (.clk(clk), .reset(reset), .en(tc6), .Q(Q7), .tc(tc7));
    
    // 3bit 카운터 (7-segment 선택용)
    counter_3bit U_CNT3 (.clk(clk), .reset(reset), .en(tc_1MHz), .Q(sel));
    
    // 7-segment 디코더
    sseg_decoder U_DECODER (.data(data), .sseg(sseg));
    
    // 멀티플렉서
    always @(*) begin
        case(sel)
            3'd0: begin
                AN = 8'b11111110;
                data = Q0; 
            end
            3'd1: begin
                AN = 8'b11111101;
                data = Q1; 
            end
            3'd2: begin
                AN = 8'b11111011;
                data = Q2;
            end
            3'd3: begin
                AN = 8'b11110111;
                data = {1'b0, Q3}; // 3비트를 4비트로 확장
            end
            3'd4: begin
                AN = 8'b11101111;
                data = Q4;
            end
            3'd5: begin
                AN = 8'b11011111;
                data = {1'b0, Q5}; // 3비트를 4비트로 확장
            end
            3'd6: begin
                AN = 8'b10111111;
                data = Q6;
            end
            3'd7: begin
                AN = 8'b01111111;
                data = Q7;
            end
            default: begin
                AN = 8'b11111111;
                data = 4'b0000;
            end
        endcase
        
        SEG = sseg;
    end

endmodule