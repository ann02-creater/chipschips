module watch_counter (
    input  wire clk,
    input  wire reset,
    input  wire tc_cnt,         
    output wire [31:0] data       
);

    
    wire [3:0] Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7;

    
    wire tc0, tc1, tc2, tc3, tc4, tc5, tc6, tc7;

    //counter.v에서 정의한 counter1, counter2 모듈들을 8개의 instance로 연결함.
    //각 자릿수가 연쇄적으로 연결되어 있는 실제 스톱워치 시간 표현 모듈.
    counter2 #(.MaxCount(9), .DataWidth(4)) U_CNT0 (
        .clk(clk),
        .reset(reset),
        .en(tc_cnt),
        .Q(Q0),
        .TC(tc0)
    );

   
    counter2 #(.MaxCount(9), .DataWidth(4)) U_CNT1 (
        .clk(clk),
        .reset(reset),
        .en(tc0),
        .Q(Q1),
        .TC(tc1)
    );

    
    counter2 #(.MaxCount(9), .DataWidth(4)) U_CNT2 (
        .clk(clk),
        .reset(reset),
        .en(tc1),
        .Q(Q2),
        .TC(tc2)
    );

   
    counter1 #(.MaxCount(5), .DataWidth(4)) U_CNT3 (
        .clk(clk),
        .reset(reset),
        .en(tc2),
        .Q(Q3),
        .TC(tc3)
    );

    
    counter2 #(.MaxCount(9), .DataWidth(4)) U_CNT4 (
        .clk(clk),
        .reset(reset),
        .en(tc3),
        .Q(Q4),
        .TC(tc4)
    );

    
    counter1 #(.MaxCount(5), .DataWidth(4)) U_CNT5 (
        .clk(clk),
        .reset(reset),
        .en(tc4),
        .Q(Q5),
        .TC(tc5)
    );

    
    counter2 #(.MaxCount(9), .DataWidth(4)) U_CNT6 (
        .clk(clk),
        .reset(reset),
        .en(tc5),
        .Q(Q6),
        .TC(tc6)
    );

   
    counter2 #(.MaxCount(9), .DataWidth(4)) U_CNT7 (
        .clk(clk),
        .reset(reset),
        .en(tc6),
        .Q(Q7),
        .TC(tc7)   
    );

    
    assign data = {Q7, Q6, Q5, Q4, Q3, Q2, Q1, Q0};

endmodule