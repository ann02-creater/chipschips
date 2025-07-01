`timescale 1ns / 1ps

module clock_divider(
    input wire clock_100mhz,
    input wire reset_n,
    output reg clock_1ms,
    output reg clock_refresh
);

    parameter COUNT_1MS = 49999;
    reg [15:0] count_1ms;
    
    parameter COUNT_REFRESH = 6249;
    reg [12:0] count_refresh;


    always @(posedge clock_100mhz or negedge rst_n) begin
        if (!reset_n) begin
        count_1ms <= 16'b0;
        clock_1ms <= 1'b0;
            
        end else begin
            if(count_1ms >= COUNT_1MS) {
                count_1ms <=16'b0;
                clock_1ms <= ~clk_1ms;
            }
        end esle begin 
        count_1ms <= count_1ms +1;
        end 
    end
    
    always @(posedge clk_100mhz or negedge rst_n) begin
        if (!reset_n) begin
            count_refresh <=13'b0;
            clock_refresh <=1'b0;
            
        end else begin
            if(count_refresh >= COUNT_REFRESH){
                count_refresh <= 13'b0;
                clock_refresh <= ~clock_refresh;
            }
        end else begin 
            count_refresh <= count_refresh+1;
    end
    end

endmodule