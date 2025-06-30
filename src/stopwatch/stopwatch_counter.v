`timescale 1ns / 1ps

module stopwatch_counter(
    input wire clock,
    input wire clock_1ms,
    input wire reset_n,
    input wire start_edge,
    input wire reset_edge,
    output reg running,
    output reg [6:0] centiseconds,
    output reg [5:0] seconds,
    output reg [5:0] minutes,
    output reg [4:0] hours
);

    reg clock_1ms_prev;
    wire clock_1ms_edge;
    
    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            clock_1ms_prev <= 1'b0;
        end else begin
            clock_1ms_prev <= clock_1ms;
        end
    end
    
    assign clock_1ms_edge = clock_1ms & ~clock_1ms_prev;
    
    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            running <= 1'b0;
        end else if (reset_edge) begin
            running <= 1'b0;
        end else if (start_edge) begin
            running <= ~running;
        end
    end
    
    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            centiseconds <= 7'd0;
            seconds <= 6'd0;
            minutes <= 6'd0;
            hours <= 5'd0;
        end else if (reset_edge) begin
            centiseconds <= 7'd0;
            seconds <= 6'd0;
            minutes <= 6'd0;
            hours <= 5'd0;
        end else if (running && clock_1ms_edge) begin
            if (centiseconds >= 7'd99) begin
                centiseconds <= 7'd0;
                if (seconds >= 6'd59) begin
                    seconds <= 6'd0;
                    if (minutes >= 6'd59) begin
                        minutes <= 6'd0;
                        if (hours >= 5'd23) begin
                            hours <= 5'd0;
                        end else begin
                            hours <= hours + 1;
                        end
                    end else begin
                        minutes <= minutes + 1;
                    end
                end else begin
                    seconds <= seconds + 1;
                end
            end else begin
                centiseconds <= centiseconds + 1;
            end
        end
    end

endmodule