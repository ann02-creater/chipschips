module stop_watch_top(
    input wire clk, reset, btn;
                      
    output reg [6:0] SEG, [7:0] AN);
    
    wire toggle;
    wire [2:0] sel;
    wire tc_100Hz, tc_1MHz;
    
   
    wire [3:0] Q0, Q1, Q2, Q4, Q6, Q7;
    wire [2:0] Q3, Q5;
    wire tc0, tc1, tc2, tc3, tc4, tc5, tc6, tc7;
    
   
    reg [3:0] data;
    reg [6:0] sseg;
    
    // 디바운스 모듈
    debounce U_DEBOUNCE (clk, reset, btn, toggle);

    //10ms bcd counter  Q0 = 0
    counter_bcd(clk, reset, tc_100Hz, Q0, tc0);
    //100ms bcd counter
    counter_bcd(clk, reset, tc0, Q1, tc1);
    // 1s bcd counter
    counter_bcd(clk, reset, tc1, Q2, tc2);
    // 10s mod6 counter
    counter_mod6 (clk, reset, tc2, Q3, tc3);
    // 1min bcd counter
    counter_bcd(clk, reset, tc3, Q4, tc4);
    // 10min mod6 counter
    counter_mod6 (clk, reset, tc4, Q5, tc5);
    // 1hour bcd counter
    counter_bcd(clk, reset, tc5, Q6, tc6);
    // 10hour bcd counter
    counter_bcd(clk, reset, tc6, Q7, tc7);
    
    // 7-segment 디코더
    sseg_decoder U_DECODER (data, .sseg);
    
    always @(*) begin
        case(sel)
            3'd0: begin
                AN   = 8'b11111110;
                data = Q0;
            end
            3'd1: begin
                AN   = 8'b11111101;
                data = Q1;
            end
            3'd2: begin
                AN   = 8'b11111011;
                data = Q2;
            end
            3'd3: begin
                AN   = 8'b11110111;
                data = {1'b0, Q3};
            end
            3'd4: begin
                AN   = 8'b11101111;
                data = Q4;
            end
            3'd5: begin
                AN   = 8'b11011111;
                data = {1'b0, Q5};
            end
            3'd6: begin
                AN   = 8'b10111111;
                data = Q6;
            end
            3'd7: begin
                AN   = 8'b01111111;
                data = Q7;
            end
            default: begin
                AN   = 8'b11111111;
                data = 4'b0000;
            end
        endcase
        SEG = sseg;
    end
    
endmodule
