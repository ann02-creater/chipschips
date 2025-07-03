module stop_watch_top(
    input wire clk, reset, btn,
    output wire [7:0] SEG, AN
    );
    wire toggle;
    wire [2:0] sel;
    
    debounce U_DEBOUNCE (clk, reset, btn, toggle);
    clock_divider U_Clkdivider (clk, reset, toggle, tc_100Hz, tc_1MHz); // 100Hz --> 10ms
    
    // 10ms bcd counter  Q0 = 0
    // counter_bcd(clk, reset, tc_100Hz, Q0, tc0);
    // 100ms bcd counter
    // counter_bcd(clk, reset, tc0, Q1, tc1);
    // 1s bcd counter
    // counter_bcd(clk, reset, tc1, Q2, tc2);
    // 10s mod6 counter
    // counter_mod6 (clk, reset, tc2, Q3, tc3);
    // 1min bcd counter
    // 10min mod6 counter
    // 1hour bcd counter
    // 10hour bcd counter
    
//    counter_3bit U_CNT3 (clk, reset, tc_1MHz, sel);
//    selector U_SEL (sel, Q0 ~ Q7, AN, SEG);
    
//    sseg_decoder (data, sseg);
//    always@(sel) begin
//        case(sel)
//            3'd0: begin
//                    AN = 8'b11111110;
//                    data = Q0; 
//                  end
//            3'd1: begin
//                    AN = 8'b11111101;
//                    data = Q1; 
//                  end
//           ... 
//        endcase
//    end
    
    
    
    
    
    
    
    
endmodule
