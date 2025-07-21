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
    output reg [8:0]   board_out  // VGA 연결용 (9비트, 각 셀 on/off)
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
    reg [8:0] game_board;  // 9비트로 변경 (각 셀 on/off)
    integer i;

    // 현재 셀이 비어있는지 확인 (단순화)
    wire space_valid = space && !game_board[current_cell];
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
            game_board <= 9'b0;
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
                    // 원 배치 (해당 셀 비트를 1로 설정)
                    game_board[current_cell] <= 1'b1;
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