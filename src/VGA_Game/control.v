module control(
    input clk, 
    input reset,
    input [4:0] btn_pulse,
    output reg [8:0] board,
    output reg [3:0] cursor,
    output reg [1:0] winner,
    output reg [1:0] state
);
    localparam IDLE=0, PLAY=1, GAME_OVER=2;

    localparam MAX_CURSOR = 8;
    localparam ROW_SIZE   = 3;
    localparam COL_WRAP   = 6;


    reg [1:0] player;

    always @(posedge clk or posedge reset) begin
        if(reset) begin 
            board <= 0; 
            cursor <= 0; 
            player <= 1; 
            winner <= 0; 
            state <= IDLE; 
        end 
        else case(state)
            IDLE: 
                if(btn_pulse[4]) state <= PLAY;

            PLAY: begin
                if(btn_pulse[0]) // UP
                    cursor <= (cursor < ROW_SIZE) ? cursor + COL_WRAP : cursor - ROW_SIZE;
                if(btn_pulse[1]) // DOWN
                    cursor <= (cursor >= COL_WRAP) ? cursor - COL_WRAP : cursor + ROW_SIZE;
                if(btn_pulse[2]) // LEFT
                    cursor <= (cursor == 0) ? MAX_CURSOR : cursor - 1;
                if(btn_pulse[3]) // RIGHT
                    cursor <= (cursor == MAX_CURSOR) ? 0 : cursor + 1;

                if(btn_pulse[4] && board[cursor]==0) begin
                    board[cursor] <= player;
                    
                    if(check_winner(board, player)) begin
                        winner <= player;
                        state <= GAME_OVER;
                    end
                    player <= (player==1) ? 2 : 1;
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
        input [1:0] p;
        check_winner=
          ((b[0]==p&&b[1]==p&&b[2]==p)||
           (b[3]==p&&b[4]==p&&b[5]==p)||
           (b[6]==p&&b[7]==p&&b[8]==p)||
           (b[0]==p&&b[3]==p&&b[6]==p)||
           (b[1]==p&&b[4]==p&&b[7]==p)||
           (b[2]==p&&b[5]==p&&b[8]==p)||
           (b[0]==p&&b[4]==p&&b[8]==p)||
           (b[2]==p&&b[4]==p&&b[6]==p));
    endfunction
endmodule
