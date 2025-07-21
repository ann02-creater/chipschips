module ttt_ctrl (
    input  wire        clk,
    input  wire        reset,
    input  wire        up,
    input  wire        down,
    input  wire        left,
    input  wire        right,
    input  wire        enter,
    input  wire        space,
    output reg         win_flag,
    output reg [3:0]   current_cell,
    output reg [8:0]   cell_select_flag,
    output reg [17:0]  board_out  // VGA 연결용 (2비트 x 9개 셀)
);

    localparam
        S_CURSOR_MOVE = 2'd0,
        S_INPUT_READY = 2'd1,
        S_PLACE_PIECE = 2'd2,
        S_DISPLAY_WIN = 2'd3;

    // 플레이어 정의: 01 = X (Player 1), 10 = O (Player 2)
    localparam
        PLAYER_X = 2'b01,
        PLAYER_O = 2'b10;

    reg [1:0] state, next_state;
    reg [17:0] game_board;
    reg [1:0] current_player;
    integer i;

    wire space_valid = space && (game_board[current_cell*2+1:current_cell*2] == 2'b00);
    wire enter_valid = enter;

    // 게임 보드를 VGA 출력에 직접 연결
    always @(*) begin
        board_out = game_board;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S_CURSOR_MOVE;
            current_cell <= 4'd0;
            cell_select_flag <= 9'b000000001;
            win_flag <= 1'b0;
            current_player <= PLAYER_X;
            game_board <= 18'b0;
        end else begin
            state <= next_state;
            win_flag <= 1'b0;
            case (state)
                S_CURSOR_MOVE: begin
                    // WASD 키로 0~8번 셀 이동
                    if (up && current_cell >= 3) begin
                        current_cell <= current_cell - 3;
                        cell_select_flag <= cell_select_flag >> 3;
                    end
                    if (down && current_cell <= 5) begin
                        current_cell <= current_cell + 3;
                        cell_select_flag <= cell_select_flag << 3;
                    end
                    if (left && (current_cell % 3) != 0) begin
                        current_cell <= current_cell - 1;
                        cell_select_flag <= cell_select_flag >> 1;
                    end
                    if (right && (current_cell % 3) != 2) begin
                        current_cell <= current_cell + 1;
                        cell_select_flag <= cell_select_flag << 1;
                    end
                end
                S_INPUT_READY: begin
                    // 입력 준비 상태 - 엔터 대기
                end
                S_PLACE_PIECE: begin
                    // 말 놓기
                    game_board[current_cell*2+1:current_cell*2] <= current_player;
                    current_player <= (current_player == PLAYER_X) ? PLAYER_O : PLAYER_X;
                    
                    // 승리 조건 검사
                    case (current_cell)
                        // Row 0
                        0, 1, 2: begin
                            if (game_board[1:0] == current_player && 
                                game_board[3:2] == current_player && 
                                game_board[5:4] == current_player)
                                win_flag <= 1'b1;
                        end
                        // Row 1  
                        3, 4, 5: begin
                            if (game_board[7:6] == current_player && 
                                game_board[9:8] == current_player && 
                                game_board[11:10] == current_player)
                                win_flag <= 1'b1;
                        end
                        // Row 2
                        6, 7, 8: begin
                            if (game_board[13:12] == current_player && 
                                game_board[15:14] == current_player && 
                                game_board[17:16] == current_player)
                                win_flag <= 1'b1;
                        end
                    endcase
                    
                    // Column checks
                    case (current_cell % 3)
                        0: begin // Left column
                            if (game_board[1:0] == current_player && 
                                game_board[7:6] == current_player && 
                                game_board[13:12] == current_player)
                                win_flag <= 1'b1;
                        end
                        1: begin // Middle column
                            if (game_board[3:2] == current_player && 
                                game_board[9:8] == current_player && 
                                game_board[15:14] == current_player)
                                win_flag <= 1'b1;
                        end
                        2: begin // Right column
                            if (game_board[5:4] == current_player && 
                                game_board[11:10] == current_player && 
                                game_board[17:16] == current_player)
                                win_flag <= 1'b1;
                        end
                    endcase
                    
                    // Diagonal checks
                    if (current_cell == 0 || current_cell == 4 || current_cell == 8) begin
                        if (game_board[1:0] == current_player && 
                            game_board[9:8] == current_player && 
                            game_board[17:16] == current_player)
                            win_flag <= 1'b1;
                    end
                    
                    if (current_cell == 2 || current_cell == 4 || current_cell == 6) begin
                        if (game_board[5:4] == current_player && 
                            game_board[9:8] == current_player && 
                            game_board[13:12] == current_player)
                            win_flag <= 1'b1;
                    end
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
            S_CURSOR_MOVE:
                next_state = space_valid ? S_INPUT_READY : S_CURSOR_MOVE;
            S_INPUT_READY:
                next_state = enter_valid ? S_PLACE_PIECE : S_INPUT_READY;
            S_PLACE_PIECE:
                next_state = win_flag ? S_DISPLAY_WIN : S_CURSOR_MOVE;
            S_DISPLAY_WIN:
                next_state = S_DISPLAY_WIN;
            default:
                next_state = S_CURSOR_MOVE;
        endcase
    end

endmodule