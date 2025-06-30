`timescale 1ns / 1ps

module stopwatch_top(
    input wire CLK100MHZ,
    input wire [15:0] SW,
    output wire [6:0] SEG,
    output wire [7:0] AN
);

    wire reset_n;
    assign reset_n = 1'b1;
    
    wire clock_1ms;
    wire clock_refresh;
    
    wire running;
    wire [6:0] centiseconds;
    wire [5:0] seconds;
    wire [5:0] minutes;
    wire [4:0] hours;
    
    clock_divider u_clock_divider (
        .clock_100mhz(CLK100MHZ),
        .reset_n(reset_n),
        .clock_1ms(clock_1ms),
        .clock_refresh(clock_refresh)
    );
    
    
    stopwatch_counter u_stopwatch_counter (
        .clock(CLK100MHZ),
        .clock_1ms(clock_1ms),
        .reset_n(reset_n),
        .start_edge(SW[0]),
        .reset_edge(SW[1]),
        .running(running),
        .centiseconds(centiseconds),
        .seconds(seconds),
        .minutes(minutes),
        .hours(hours)
    );
    
    seven_segment_display u_seven_segment_display (
        .clock(CLK100MHZ),
        .clock_refresh(clock_refresh),
        .reset_n(reset_n),
        .hours(hours),
        .minutes(minutes),
        .seconds(seconds),
        .centiseconds(centiseconds),
        .seg(SEG),
        .an(AN)
    );

endmodule