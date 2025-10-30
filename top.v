module top (
    input x,
    input clk, reset,
    output win, lose,
    output [2:0] dice1, dice2
);
synchronizer uut( 
    .x(x),
    .clk(clk),
    .reset(reset),
    .sync_x(sync_x)
);
wire sync_x;
wire ld, inc;
wire eq6, eq7, eq11, eq;

datapath uut1(
    .clk(clk),
    .reset(reset),
    .ld(ld),
    .inc(inc),
    .eq6(eq6),
    .eq7(eq7),
    .eq11(eq11),
    .eq(eq),
    .dice1(dice1),
    .dice2(dice2)
);
controller uut2(
    .clk(clk),
    .reset(reset),
    .sync_x(sync_x),
    .eq6(eq6),
    .eq7(eq7),
    .eq11(eq11),
    .eq(eq),
    .ld(ld),
    .inc(inc),
    .win(win),
    .lose(lose)
);

endmodule

module synchronizer (
    input x,
    input clk,
    input reset,
    output reg sync_x
);
    reg ff1;
    always @(posedge clk) begin
        if (!reset) begin
            ff1 <= 1'b0;
            sync_x <= 1'b0;
        end else begin
     ff1 <= x;
        sync_x <= ff1;
        end
    end
endmodule



/*data path 와 controller 로 나누기
datapath에서 controller로 가는 신호는 eq6(sum == 6),eq7(sum == 7),eq11(sum == 11), eq(sum==point) 4개이다.
controller에서 inc=1 이면 datapath에서 dice1,dice2를 100Mhz 속도로 +1씩 증가시키고
사용자가 x입력을 하면 controller에서 inc=0으로 만들고 datapath에 ld 신호를 준다.
controller에서 ld=1 이면 datapath에서 dice1,dice2 값을 고정한 후 저장(point = sum)하고 sum=dice1+dice2를 계산한다.
만약 sum이 7 or 11 이면 Win=1, sum이 6이면 Lose=1 으로 하고 다시 inc=1로 만들어 dice1,dice2를 +1씩 증가시키도록 한다.
그리고 sum =6 or 7이면 lose, 아니면 point와  sum이 같으면 Win=1, 아니면 inc=1로 만들어 dice1,dice2를 +1씩 증가시키도록 한다.
추가적으로 사용자신호는 비동기신호이고, 내부시스템과 동기화가 되어있지 않는 상태이다. 그래서 synchronizer를 만들어서 내부시스템과 동기화 시켜준다.
이 모듈은 flipflop 2개로 구성되어있다. */

