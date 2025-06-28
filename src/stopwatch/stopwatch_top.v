`timescale 1ns / 1ps

module stopwatch_top(
    input wire CLK100MHZ,
    input wire BTNC,
    input wire BTNU,
    output wire [6:0] SEG,
    output wire [7:0] AN
);

    wire rst_n;
    assign rst_n = 1'b1;
    
    wire clk_1ms;
    wire clk_refresh;
    
    wire btnc_clean;
    wire btnu_clean;
    wire btnc_edge;
    wire btnu_edge;
    
    wire running;
    wire [6:0] centiseconds;
    wire [5:0] seconds;
    wire [5:0] minutes;
    
    clock_divider u_clock_divider (
        .clk_100mhz(CLK100MHZ),
        .rst_n(rst_n),
        .clk_1ms(clk_1ms),
        .clk_refresh(clk_refresh)
    );
    
    button_debouncer u_btnc_debouncer (
        .clk(CLK100MHZ),
        .clk_1ms(clk_1ms),
        .rst_n(rst_n),
        .btn_in(BTNC),
        .btn_out(btnc_clean),
        .btn_edge(btnc_edge)
    );
    
    button_debouncer u_btnu_debouncer (
        .clk(CLK100MHZ),
        .clk_1ms(clk_1ms),
        .rst_n(rst_n),
        .btn_in(BTNU),
        .btn_out(btnu_clean),
        .btn_edge(btnu_edge)
    );
    
    stopwatch_counter u_stopwatch_counter (
        .clk(CLK100MHZ),
        .clk_1ms(clk_1ms),
        .rst_n(rst_n),
        .start_edge(btnc_edge),
        .reset_edge(btnu_edge),
        .running(running),
        .centiseconds(centiseconds),
        .seconds(seconds),
        .minutes(minutes)
    );
    
    seven_segment_display u_seven_segment_display (
        .clk(CLK100MHZ),
        .clk_refresh(clk_refresh),
        .rst_n(rst_n),
        .minutes(minutes),
        .seconds(seconds),
        .centiseconds(centiseconds),
        .seg(SEG),
        .an(AN)
    );

endmodule