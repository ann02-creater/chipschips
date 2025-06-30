`timescale 1ns / 1ps

module clock_divider(
    input wire clock_100mhz,
    input wire reset_n,
    output reg clock_1ms,
    output reg clock_refresh
);

    parameter COUNT_1MS = 16'd49999;
    reg [15:0] counter_1ms;
    
    parameter COUNT_REFRESH = 13'd6249;
    reg [12:0] counter_refresh;

    always @(posedge clock_100mhz or negedge reset_n) begin
        if (!reset_n) begin
            counter_1ms <= 16'd0;
            clock_1ms <= 1'b0;
        end else begin
            if (counter_1ms >= COUNT_1MS) begin
                counter_1ms <= 16'd0;
                clock_1ms <= ~clock_1ms;
            end else begin
                counter_1ms <= counter_1ms + 1;
            end
        end
    end
    
    always @(posedge clock_100mhz or negedge reset_n) begin
        if (!reset_n) begin
            counter_refresh <= 13'd0;
            clock_refresh <= 1'b0;
        end else begin
            if (counter_refresh >= COUNT_REFRESH) begin
                counter_refresh <= 13'd0;
                clock_refresh <= ~clock_refresh;
            end else begin
                counter_refresh <= counter_refresh + 1;
            end
        end
    end

endmodule