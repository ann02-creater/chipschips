module stop_watch_top(
    input wire clk, reset, btn,                      
    output reg [6:0] SEG,
    output reg [7:0] AN
);
    
    wire toggle;
    reg [2:0] sel;
    wire tc_100Hz, tc_1MHz;
    
    clock_divider U_CLKDIV( clk, reset, en, tc_100Hz, tc_1MHz);

always @(posedge clk or posedge reset) begin
if(reset) begin 
sel <=3'd0;
end else if(tc_100Hz) begin
sel <= sel+1;
end 
end     
   
    wire [3:0] Q0, Q1, Q2, Q4, Q6, Q7;
    wire [2:0] Q3, Q5;
    wire tc0, tc1, tc2, tc3, tc4, tc5, tc6, tc7;
    
   
    reg [3:0] data;
    wire [6:0] sseg;
    
    debounce U_DEBOUNCE (clk, reset, btn, toggle);

    counter_bcd(clk, reset, tc_100Hz, Q0, tc0);
    counter_bcd(clk, reset, tc0, Q1, tc1);
    counter_bcd(clk, reset, tc1, Q2, tc2);
    counter_mod6 (clk, reset, tc2, Q3, tc3);
    counter_bcd(clk, reset, tc3, Q4, tc4);
    counter_mod6 (clk, reset, tc4, Q5, tc5);
    counter_bcd(clk, reset, tc5, Q6, tc6);
    counter_bcd(clk, reset, tc6, Q7, tc7);
   
    
endmodule
