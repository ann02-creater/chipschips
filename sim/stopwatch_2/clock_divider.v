module clock_divider(
    input wire clk, reset, en,
    output wire tc_100hz, tc_1MHz
    );
    // 100MHz -> 100 Hz
    
    wire [4:0] TC;
    
    counter_bcd U0 (.clk(clk), .reset(reset), .en(en  ),  .Q(), .TC(TC[0]));
    counter_bcd U1 (.clk(clk), .reset(reset), .en(TC[0]), .Q(), .TC(TC[1]));
    counter_bcd U2 (.clk(clk), .reset(reset), .en(TC[1]), .Q(), .TC(TC[2]));
    counter_bcd U3 (.clk(clk), .reset(reset), .en(TC[2]), .Q(), .TC(TC[3]));
    counter_bcd U4 (.clk(clk), .reset(reset), .en(TC[3]), .Q(), .TC(TC[4]));
    counter_bcd U5 (.clk(clk), .reset(reset), .en(TC[4]), .Q(), .TC(tc_100hz));
    
    assign tc_1MHz = TC[1];
    
endmodule
