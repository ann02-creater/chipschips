`timescale 1ns / 1ps

module stopwatch_top(
    input wire CLK100MHZ,
    input wire [15:0] SW,
    output wire [6:0] SEG,
    output wire [7:0] AN
);

    wire rst_n;
    assign rst_n = 1'b1;
    
    wire clk_1ms;
    wire clk_refresh;
    
    wire running;
    wire [6:0] centiseconds;
    wire [5:0] seconds;
    wire [5:0] minutes;
    wire [4:0] hours;
    
    clock_divider u_clock_divider (
        .clk_100mhz(CLK100MHZ),
        .rst_n(rst_n),
        .clk_1ms(clk_1ms),
        .clk_refresh(clk_refresh)
    );
    
    
    stopwatch_counter u_stopwatch_counter (
        .clk(CLK100MHZ),
        .clk_1ms(clk_1ms),
        .rst_n(rst_n),
        .start_edge(SW[0]),
        .reset_edge(SW[1]),
        .running(running),
        .centiseconds(centiseconds),
        .seconds(seconds),
        .minutes(minutes),
        .hours(hours)
    );
    
    seven_segment_display u_seven_segment_display (
        .clk(CLK100MHZ),
        .clk_refresh(clk_refresh),
        .rst_n(rst_n),
        .hours(hours),
        .minutes(minutes),
        .seconds(seconds),
        .centiseconds(centiseconds),
        .seg(SEG),
        .an(AN)
    );

endmodule