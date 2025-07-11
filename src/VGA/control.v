module control(
    input clk, input reset,
    input [4:0] btn_pulse,
    output reg [8:0] board,
    output reg [3:0] cursor,
    output reg [1:0] winner,
    output reg [2:0] state
);
    localparam IDLE=0, PLAY=1, GAME_OVER=2;

    localparam MAX_CURSOR = 8;//마지막 커서 위치 (8, 총 9칸)
    localparam ROW_SIZE   = 3;//한 줄에 칸 개수 (3)
    localparam COL_WRAP   = 6;//위아래 wrap용 (3x3 → 6)


    reg [1:0] player;

    always @(posedge clk or posedge reset) begin
        if(reset) begin 
            board <= 0; cursor <= 0; player <= 1; winner <= 0; state <= IDLE; 
        end else case(state)
            IDLE: 
                if(btn_pulse[4]) state <= PLAY;

            PLAY: begin
                if(btn_pulse[0]) // UP
                    cursor <= (cursor < COL_WRAP) ? cursor + ROW_SIZE : cursor - COL_WRAP;
                if(btn_pulse[1]) // DOWN
                    cursor <= (cursor >= ROW_SIZE) ? cursor - ROW_SIZE : cursor + COL_WRAP;
                if(btn_pulse[2]) // LEFT
                    cursor <= (cursor == 0) ? MAX_CURSOR : cursor - 1;
                if(btn_pulse[3]) // RIGHT
                    cursor <= (cursor == MAX_CURSOR) ? 0 : cursor + 1;

                if(btn_pulse[4] && board[cursor]==0) begin
                    board[cursor] <= player;
                    player <= (player==1) ? 2 : 1;
                    if(check_winner(board)) begin
                        winner <= player;
                        state <= GAME_OVER;
                    end
                end
            end
            GAME_OVER: if(btn_pulse[4]) begin 
                board<=0; cursor<=0; 
                player<=1; winner<=0; 
                state<=IDLE; 
            end
        endcase
    end
    function check_winner;
        input [8:0] b;
        check_winner=
          ((b[0]==b[1]&&b[1]==b[2]&&b[0]!=0)||
           (b[3]==b[4]&&b[4]==b[5]&&b[3]!=0)||
           (b[6]==b[7]&&b[7]==b[8]&&b[6]!=0)||
           (b[0]==b[3]&&b[3]==b[6]&&b[0]!=0)||
           (b[1]==b[4]&&b[4]==b[7]&&b[1]!=0)||
           (b[2]==b[5]&&b[5]==b[8]&&b[2]!=0)||
           (b[0]==b[4]&&b[4]==b[8]&&b[0]!=0)||
           (b[2]==b[4]&&b[4]==b[6]&&b[2]!=0));
    endfunction
endmodule