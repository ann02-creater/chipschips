module ttt_ctrl (
    input  wire        clk,
    input  wire        reset,
    input  wire        up,
    input  wire        down,
    input  wire        left,
    input  wire        right,
    input  wire        enter,
    output reg         win_flag,
    output reg [1:0]   row,
    output reg [1:0]   col,
    output reg [8:0]   board_out  // VGA 연결용 추가
);

    localparam
        S_CURSOR      = 2'd0,
        S_PLACE_O     = 2'd1,
        S_DISPLAY_WIN = 2'd2;

    reg [1:0] state, next_state;
    reg [1:0] board [0:2][0:2];
    integer i, j;

    wire en_valid = enter && (board[row][col] == 2'b00);

    // board 배열을 VGA용 1차원 배열로 변환
    always @(*) begin
        board_out[0] = (board[0][0] != 2'b00);
        board_out[1] = (board[0][1] != 2'b00);
        board_out[2] = (board[0][2] != 2'b00);
        board_out[3] = (board[1][0] != 2'b00);
        board_out[4] = (board[1][1] != 2'b00);
        board_out[5] = (board[1][2] != 2'b00);
        board_out[6] = (board[2][0] != 2'b00);
        board_out[7] = (board[2][1] != 2'b00);
        board_out[8] = (board[2][2] != 2'b00);
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state    <= S_CURSOR;
            row      <= 2'd0;
            col      <= 2'd0;
            win_flag <= 1'b0;
            for (i = 0; i < 3; i = i + 1)
                for (j = 0; j < 3; j = j + 1)
                    board[i][j] <= 2'b00;
        end else begin
            state    <= next_state;
            win_flag <= 1'b0;
            case (state)
                S_CURSOR: begin
                    if (up    && row > 0) row <= row - 1;
                    if (down  && row < 2) row <= row + 1;
                    if (left  && col > 0) col <= col - 1;
                    if (right && col < 2) col <= col + 1;
                end
                S_PLACE_O: begin
                    board[row][col] <= 2'b10;
                    if (board[row][0] == 2'b10 &&
                        board[row][1] == 2'b10 &&
                        board[row][2] == 2'b10)
                        win_flag <= 1'b1;
                    else if (board[0][col] == 2'b10 &&
                             board[1][col] == 2'b10 &&
                             board[2][col] == 2'b10)
                        win_flag <= 1'b1;
                    else if (row == col &&
                             board[0][0] == 2'b10 &&
                             board[1][1] == 2'b10 &&
                             board[2][2] == 2'b10)
                        win_flag <= 1'b1;
                    else if (row + col == 2 &&
                             board[0][2] == 2'b10 &&
                             board[1][1] == 2'b10 &&
                             board[2][0] == 2'b10)
                        win_flag <= 1'b1;
                end
                S_DISPLAY_WIN: begin
                end
                default: begin
                end
            endcase
        end
    end

    always @(*) begin
        case (state)
            S_CURSOR:
                next_state = en_valid ? S_PLACE_O : S_CURSOR;
            S_PLACE_O:
                next_state = win_flag ? S_DISPLAY_WIN : S_CURSOR;
            S_DISPLAY_WIN:
                next_state = S_DISPLAY_WIN;
            default:
                next_state = S_CURSOR;
        endcase
    end

endmodule