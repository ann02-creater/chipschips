`timescale 1ns / 1ps

module stopwatch_tb();

    reg CLK100MHZ;
    reg BTNC;
    reg BTNU;
    wire [6:0] SEG;
    wire [7:0] AN;
    
    integer i, j;
    reg [31:0] timer;
    
    wire clk_1ms = dut.clk_1ms;
    wire clk_refresh = dut.clk_refresh;
    wire btnc_edge = dut.btnc_edge;
    wire btnu_edge = dut.btnu_edge;
    wire running = dut.running;
    wire [6:0] centiseconds = dut.centiseconds;
    wire [5:0] seconds = dut.seconds;
    wire [5:0] minutes = dut.minutes;
    
    stopwatch_top dut (
        .CLK100MHZ(CLK100MHZ),
        .BTNC(BTNC),
        .BTNU(BTNU),
        .SEG(SEG),
        .AN(AN)
    );
    
    initial begin
        CLK100MHZ = 0;
        forever #5 CLK100MHZ = ~CLK100MHZ;
    end
    
    initial begin
        BTNC = 0;
        BTNU = 0;
        timer = 0;
        
        #1000000;
        
        #10000000;
        BTNU = 1;
        #15000000;
        BTNU = 0;
        #10000000;
        
        #10000000;
        BTNC = 1;
        #15000000;
        BTNC = 0;
        #10000000;
        
        for (i = 0; i < 5; i = i + 1) begin
            @(posedge clk_1ms);
        end
        
        #10000000;
        BTNC = 1;
        #15000000;
        BTNC = 0;
        #10000000;
        
        timer = centiseconds;
        #10000000;
        
        #10000000;
        BTNC = 1;
        #15000000;
        BTNC = 0;
        #50000000;
        
        BTNC = 1;
        #15000000;
        BTNC = 0;
        #50000000;
        
        BTNC = 1;
        #15000000;
        BTNC = 0;
        #50000000;
        
        BTNU = 1;
        #15000000;
        BTNU = 0;
        #10000000;
        
        #100000;
        $finish;
    end

endmodule