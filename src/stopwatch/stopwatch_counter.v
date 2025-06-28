`timescale 1ns / 1ps

module stopwatch_counter(
    input wire clk,
    input wire clk_1ms,
    input wire rst_n,
    input wire start_edge,
    input wire reset_edge,
    output reg running,
    output reg [6:0] centiseconds,
    output reg [5:0] seconds,
    output reg [5:0] minutes
);

    reg clk_1ms_prev;
    wire clk_1ms_edge;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_1ms_prev <= 1'b0;
        end else begin
            clk_1ms_prev <= clk_1ms;
        end
    end
    
    assign clk_1ms_edge = clk_1ms & ~clk_1ms_prev;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            running <= 1'b0;
        end else if (reset_edge) begin
            running <= 1'b0;
        end else if (start_edge) begin
            running <= ~running;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            centiseconds <= 7'd0;
            seconds <= 6'd0;
            minutes <= 6'd0;
        end else if (reset_edge) begin
            centiseconds <= 7'd0;
            seconds <= 6'd0;
            minutes <= 6'd0;
        end else if (running && clk_1ms_edge) begin
            if (centiseconds >= 7'd99) begin
                centiseconds <= 7'd0;
                if (seconds >= 6'd59) begin
                    seconds <= 6'd0;
                    if (minutes >= 6'd59) begin
                        minutes <= 6'd0;
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