`timescale 1ns / 1ps

module simple_timer_top(
    input wire clk,        
    input wire reset,       
    output wire [6:0] seg,  
    output wire [7:0] AN   
);

    assign AN = 8'b11111110; 
    wire tc_1s;           
    wire [3:0] seconds;     
    wire tc_seconds;       

 
    clock_divider U0 (
        .clk(clk),
        .reset(reset),
        .en(1'b1),          
        .tc_1sec(tc_1s)
    );


    counter_bcd U1 (
        .clk(clk),
        .reset(reset),
        .en(tc_1s),       
        .Q(seconds),
        .TC(tc_seconds)     
    );

   
    ssdecoder U_DECODER (
        .data(seconds),
        .seg(seg)
    );


endmodule