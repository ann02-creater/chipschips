`timescale 1ns / 1ps


module top_TLC(
        input CLK100MHZ, reset, BTNC,
        output [2:0] LED16, 
        output [2:0] LED17,
        output ledA, ledB
    );
    
    wire [1:0] fwy, hwy;
    wire eo_10M, eo_100K;
    wire x;
    assign ledA = x;
    assign ledB = eo_100M;
        
    Debounced_TFF U1 ( 
        .clk(CLK100MHZ), .en(eo_10M), 
        .rstn(reset), .BTN(BTNC), .debTFF(x) 
    ); 
    
    sig_controller U2 (
        .hwy(hwy), .fwy(fwy), 
        .x(x), .clk(CLK100MHZ), .rst(reset), .en(eo_100M)
    );
    
    Color_LED_Driver U3 (
        .state(hwy), .LED(LED16)
    );
    
    Color_LED_Driver U4 (
        .state(fwy), .LED(LED17)
    );
    
    cnt_100M DIV (
        .clk(CLK100MHZ), .rstn(reset),
        .eo_100M(eo_100M), .eo_10M(eo_10M), .eo_100K(eo_100K), 
        .eo_10K(eo_10K), .eo_1K(eo_1K), .eo_100(eo_100) 
    );
    

endmodule
