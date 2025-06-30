`timescale 1ns / 1ps

module stopwatch_tb();

    reg CLK100MHZ;
    reg [15:0] SW;
    wire [6:0] SEG;
    wire [7:0] AN;
    
    integer i, j;
    reg [31:0] timer;
    
    wire clk_1ms = dut.clk_1ms;
    wire clk_refresh = dut.clk_refresh;
    wire running = dut.running;
    wire [6:0] centiseconds = dut.centiseconds;
    wire [5:0] seconds = dut.seconds;
    wire [5:0] minutes = dut.minutes;
    wire [4:0] hours = dut.hours;
    
    stopwatch_top dut (
        .CLK100MHZ(CLK100MHZ),
        .SW(SW),
        .SEG(SEG),
        .AN(AN)
    );
    
    initial begin
        CLK100MHZ = 0;
        forever #5 CLK100MHZ = ~CLK100MHZ;
    end
    
    initial begin
        SW = 16'h0000;
        timer = 0;
        
        #1000000;
        
        #10000000;
        SW[1] = 1;
        #15000000;
        SW[1] = 0;
        #10000000;
        
        #10000000;
        SW[0] = 1;
        #15000000;
        SW[0] = 0;
        #10000000;
        
        for (i = 0; i < 5; i = i + 1) begin
            @(posedge clk_1ms);
        end
        
        #10000000;
        SW[0] = 1;
        #15000000;
        SW[0] = 0;
        #10000000;
        
        timer = centiseconds;
        #10000000;
        
        #10000000;
        SW[0] = 1;
        #15000000;
        SW[0] = 0;
        #50000000;
        
        SW[0] = 1;
        #15000000;
        SW[0] = 0;
        #50000000;
        
        SW[0] = 1;
        #15000000;
        SW[0] = 0;
        #50000000;
        
        SW[1] = 1;
        #15000000;
        SW[1] = 0;
        #10000000;
        
        #100000;
        $finish;
    end

endmodule