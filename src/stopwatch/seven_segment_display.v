`timescale 1ns / 1ps

module seven_segment_display(
    input wire clock,
    input wire clock_refresh,
    input wire reset_n,
    input wire [4:0] hours,
    input wire [5:0] minutes,
    input wire [5:0] seconds,
    input wire [6:0] centiseconds,
    output reg [6:0] seg,
    output reg [7:0] an
);

    reg [2:0] digit_select;
    reg clock_refresh_prev;
    wire clock_refresh_edge;
    
    reg [3:0] hours_tens;
    reg [3:0] hours_ones;
    reg [3:0] minutes_tens;
    reg [3:0] minutes_ones;
    reg [3:0] seconds_tens;
    reg [3:0] seconds_ones;
    reg [3:0] centiseconds_tens;
    reg [3:0] centiseconds_ones;
    
    reg [3:0] current_bcd;
    reg [6:0] seg_pattern;
    
    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            clock_refresh_prev <= 1'b0;
        end else begin
            clock_refresh_prev <= clock_refresh;
        end
    end
    
    assign clock_refresh_edge = clock_refresh & ~clock_refresh_prev;
    
    always @(*) begin
        hours_tens = hours / 10;
        hours_ones = hours % 10;
        minutes_tens = minutes / 10;
        minutes_ones = minutes % 10;
        seconds_tens = seconds / 10;
        seconds_ones = seconds % 10;
        centiseconds_tens = centiseconds / 10;
        centiseconds_ones = centiseconds % 10;
    end
    
    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            digit_select <= 3'd0;
        end else if (clock_refresh_edge) begin
            digit_select <= digit_select + 1;
        end
    end
    
    always @(*) begin
        case (digit_select)
            3'd0: current_bcd = centiseconds_ones;
            3'd1: current_bcd = centiseconds_tens;
            3'd2: current_bcd = seconds_ones;
            3'd3: current_bcd = seconds_tens;
            3'd4: current_bcd = minutes_ones;
            3'd5: current_bcd = minutes_tens;
            3'd6: current_bcd = hours_ones;
            3'd7: current_bcd = hours_tens;
            default: current_bcd = 4'h0;
        endcase
    end
    
    always @(*) begin
        case (current_bcd)
            4'h0: seg_pattern = 7'b1000000;
            4'h1: seg_pattern = 7'b1111001;
            4'h2: seg_pattern = 7'b0100100;
            4'h3: seg_pattern = 7'b0110000;
            4'h4: seg_pattern = 7'b0011001;
            4'h5: seg_pattern = 7'b0010010;
            4'h6: seg_pattern = 7'b0000010;
            4'h7: seg_pattern = 7'b1111000;
            4'h8: seg_pattern = 7'b0000000;
            4'h9: seg_pattern = 7'b0010000;
            4'hA: seg_pattern = 7'b0001000;
            4'hB: seg_pattern = 7'b0000011;
            4'hC: seg_pattern = 7'b1000110;
            4'hD: seg_pattern = 7'b0100001;
            4'hE: seg_pattern = 7'b0000110;
            4'hF: seg_pattern = 7'b1111111;
            default: seg_pattern = 7'b1111111;
        endcase
    end
    
    always @(*) begin
        an = 8'b11111111;
        an[digit_select] = 1'b0;
    end
    
    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            seg <= 7'b1111111;
        end else begin
            seg <= seg_pattern;
        end
    end

endmodule