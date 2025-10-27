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
        if (reset) begin
            ff1 <= 1'b0;
            sync_x <= 1'b0;
        end else begin
     ff1 <= x;
        sync_x <= ff1;
        end
    end
endmodule

module datapath(
    input clk, reset,
    input ld, inc,
    output eq6, eq7, eq11, eq,
    output reg [2:0] dice1, dice2
);
reg [3:0] point;
wire [3:0] sum;

assign sum = dice1 + dice2;
assign eq6 = (sum == 4'd6);
assign eq7 = (sum == 4'd7);
assign eq11 = (sum == 4'd11);
assign eq = (sum == point);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        dice1 <= 3'd1;
        dice2 <= 3'd1;
        point <= 4'd0;
    end else if (inc) begin
        if (dice1 == 3'd6) begin
            dice1 <= 3'd1;
            if (dice2 == 3'd6) begin
                dice2 <= 3'd1;
            end else begin
                dice2 <= dice2 + 3'd1;
            end
        end else begin
            dice1 <= dice1 + 3'd1;
        end
    end 
    if (ld) begin
        point <= sum;
    end
end
   
endmodule

module controller(
    input clk, reset,
    input sync_x,
    input eq6, eq7, eq11, eq,
    output reg ld, inc,
    output reg win, lose
);
localparam  S0 = 3'd0,
            S1 = 3'd1,
            S2 = 3'd2,
            S3 = 3'd3,
            S4 = 3'd4,
            S5 = 3'd5;

reg [2:0] current_state, next_state;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state <= S0;
    end else begin
        current_state <= next_state;
    end
end

always @(*) begin
    next_state = current_state;



    case (current_state)
        S0: begin
            if (sync_x) begin
                next_state = S1;
            end
        end
        S1: begin
            if (eq7 || eq11) begin
                next_state = S2;
            end else if (eq6) begin
                next_state = S3;
            end else begin
                next_state = S4;
            end
        end
        S2: begin
                next_state = S0;
            end
        
        S3: begin
                next_state = S0;
            end
        S4: begin
        if(sync_x) begin
            next_state = S5;
          end
        end
        S5: begin
            if (eq) begin
                next_state = S2;
            end else if (eq6 || eq7) begin
                next_state = S3;
            end else begin
                next_state = S4;
            end
        end
        default: begin
            next_state = S0;
        end
    endcase
end

always @(*) begin
    ld = 1'b0;
    inc = 1'b0;
    win = 1'b0;
    lose = 1'b0;

    case (current_state)
        S0: begin
            inc = 1'b1;
        end
        S1: begin
            if(!(eq7 || eq11 || eq6))
            ld = 1'b1;
        end
        S2: begin
            win = 1'b1;
        end
        S3: begin
            lose = 1'b1;
        end
        S4: begin
            inc = 1'b1;
        end
        S5: begin
           
        end
    endcase
end
endmodule



    // controller implementation here
/*data path 와 controller 로 나누기
datapath에서 controller로 가는 신호는 eq6(sum == 6),eq7(sum == 7),eq11(sum == 11), eq(sum==point) 4개이다.
controller에서 inc=1 이면 datapath에서 dice1,dice2를 100Mhz 속도로 +1씩 증가시키고
사용자가 x입력을 하면 controller에서 inc=0으로 만들고 datapath에 ld 신호를 준다.
controller에서 ld=1 이면 datapath에서 dice1,dice2 값을 고정한 후 저장(point = sum)하고 sum=dice1+dice2를 계산한다.
만약 sum이 7 or 11 이면 Win=1, sum이 6이면 Lose=1 으로 하고 다시 inc=1로 만들어 dice1,dice2를 +1씩 증가시키도록 한다.
그리고 sum =6 or 7이면 lose, 아니면 point와  sum이 같으면 Win=1, 아니면 inc=1로 만들어 dice1,dice2를 +1씩 증가시키도록 한다.
추가적으로 사용자신호는 비동기신호이고, 내부시스템과 동기화가 되어있지 않는 상태이다. 그래서 synchronizer를 만들어서 내부시스템과 동기화 시켜준다.
이 모듈은 flipflop 2개로 구성되어있다. */

