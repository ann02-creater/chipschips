module clock_divider(
    input wire clk,
    input wire reset,
    input wire en,
    output wire tc_cnt,
    output wire tc_led
);

    wire [4:0] TC_1ms;
    wire [3:0] TC_refresh;
    
  //TC_1ms
    counter1 U0_1ms (.clk(clk), .reset(reset), .en(en), .Q(), .TC(TC_1ms[0]));
    counter1 U1_1ms (.clk(clk), .reset(reset), .en(TC_1ms[0]), .Q(), .TC(TC_1ms[1]));
    counter1 U2_1ms (.clk(clk), .reset(reset), .en(TC_1ms[1]), .Q(), .TC(TC_1ms[2]));
    counter1 U3_1ms (.clk(clk), .reset(reset), .en(TC_1ms[2]), .Q(), .TC(TC_1ms[3]));
    counter1 U4_1ms (.clk(clk), .reset(reset), .en(TC_1ms[3]), .Q(), .TC(TC_1ms[4]));
    counter1 U5_1ms (.clk(clk), .reset(reset), .en(TC_1ms[4]), .Q(), .TC(tc_cnt));// 여기서 tc_cnt =1이 되면서 1ms 신호 완성 됨.(10^6주기마다 tc_cnt=1.)
    
//Tc_refresh
    counter1 U0_ref (.clk(clk), .reset(reset), .en(1'b1), .Q(), .TC(TC_refresh[0]));
    counter1 U1_ref (.clk(clk), .reset(reset), .en(TC_refresh[0]), .Q(), .TC(TC_refresh[1]));
    counter1 U2_ref (.clk(clk), .reset(reset), .en(TC_refresh[1]), .Q(), .TC(TC_refresh[2]));
    counter1 U3_ref (.clk(clk), .reset(reset), .en(TC_refresh[2]), .Q(), .TC(TC_refresh[3]));
    counter1 U4_ref (.clk(clk), .reset(reset), .en(TC_refresh[3]), .Q(), .TC(tc_led));//tc_cnt랑 병렬적으로 동작. 10^4주기마다 digit_sel같은 신호를 켜서 한자리씩 켰다끔. tc_cnt보다 훨씬 빠름.
    
endmodule