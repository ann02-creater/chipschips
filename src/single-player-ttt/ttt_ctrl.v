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
        S_PLACE_PIECE = 2'd2;

    // 단일 플레이어 정의: 01 = Circle (Player 1만 사용)
    localparam
        PLAYER_CIRCLE = 2'b01,
        EMPTY = 2'b00;

    reg [1:0] state, next_state;
    reg [17:0] game_board;
    integer i;

    reg [1:0] current_cell_data;
    
    // 현재 셀 데이터 추출
    always @(*) begin
        case (current_cell)
            4'd0: current_cell_data = game_board[1:0];
            4'd1: current_cell_data = game_board[3:2];
            4'd2: current_cell_data = game_board[5:4];
            4'd3: current_cell_data = game_board[7:6];
            4'd4: current_cell_data = game_board[9:8];
            4'd5: current_cell_data = game_board[11:10];
            4'd6: current_cell_data = game_board[13:12];
            4'd7: current_cell_data = game_board[15:14];
            4'd8: current_cell_data = game_board[17:16];
            default: current_cell_data = 2'b00;
        endcase
    end
    
    wire space_valid = space && (current_cell_data == 2'b00);
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
                    case (current_cell)
                        4'd0: game_board[1:0] <= PLAYER_CIRCLE;
                        4'd1: game_board[3:2] <= PLAYER_CIRCLE;
                        4'd2: game_board[5:4] <= PLAYER_CIRCLE;
                        4'd3: game_board[7:6] <= PLAYER_CIRCLE;
                        4'd4: game_board[9:8] <= PLAYER_CIRCLE;
                        4'd5: game_board[11:10] <= PLAYER_CIRCLE;
                        4'd6: game_board[13:12] <= PLAYER_CIRCLE;
                        4'd7: game_board[15:14] <= PLAYER_CIRCLE;
                        4'd8: game_board[17:16] <= PLAYER_CIRCLE;
                    endcase
                    
                    // 단순히 원 배치만 하고 승리 조건 제거 (circle_image.coe만 표시)
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
                next_state = S_CURSOR_MOVE;
            default:
                next_state = S_CURSOR_MOVE;
        endcase
    end

endmodule