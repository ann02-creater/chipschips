`timescale 1ns / 1ps

module clock_divider(
    input wire clk_100mhz,
    input wire rst_n,
    output reg clk_1ms,
    output reg clk_refresh
);

    reg [15:0] counter_1ms;
    parameter COUNT_1MS = 16'd49999;
    
    reg [12:0] counter_refresh;
    parameter COUNT_REFRESH = 13'd6249;
    
    always @(posedge clk_100mhz or negedge rst_n) begin
        if (!rst_n) begin
            counter_1ms <= 16'd0;
            clk_1ms <= 1'b0;
        end else begin
            if (counter_1ms >= COUNT_1MS) begin
                counter_1ms <= 16'd0;
                clk_1ms <= ~clk_1ms;
            end else begin
                counter_1ms <= counter_1ms + 1;
            end
        end
    end
    
    always @(posedge clk_100mhz or negedge rst_n) begin
        if (!rst_n) begin
            counter_refresh <= 13'd0;
            clk_refresh <= 1'b0;
        end else begin
            if (counter_refresh >= COUNT_REFRESH) begin
                counter_refresh <= 13'd0;
                clk_refresh <= ~clk_refresh;
            end else begin
                counter_refresh <= counter_refresh + 1;
            end
        end
    end

endmodule