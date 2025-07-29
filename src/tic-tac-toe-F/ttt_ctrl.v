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
    output reg [17:0]  board_out,
    output reg         current_player  // 0 = player 1 (circle), 1 = player 2 (X)
);

    localparam S_MOVE  = 2'b00;
    localparam S_WAIT  = 2'b01;
    localparam S_PLACE = 2'b10;
    localparam S_WIN   = 2'b11;

    localparam PLAYER_1 = 2'b01;
    localparam PLAYER_2 = 2'b10;
    localparam EMPTY    = 2'b00;

    localparam BOARD_SIZE = 3;
    localparam MIN_UP_CELL = 3;
    localparam MAX_DOWN_CELL = 5;

    reg [1:0] state;
    reg [17:0] board_state;

    reg up_sync1, down_sync1, left_sync1, right_sync1;
    reg enter_sync1, space_sync1;
    reg up_sync2, down_sync2, left_sync2, right_sync2;
    reg enter_sync2, space_sync2;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            up_sync1 <= 0; down_sync1 <= 0; left_sync1 <= 0; right_sync1 <= 0;
            enter_sync1 <= 0; space_sync1 <= 0;
            up_sync2 <= 0; down_sync2 <= 0; left_sync2 <= 0; right_sync2 <= 0;
            enter_sync2 <= 0; space_sync2 <= 0;
        end else begin
            up_sync1 <= up; down_sync1 <= down; left_sync1 <= left; right_sync1 <= right;
            enter_sync1 <= enter; space_sync1 <= space;
            up_sync2 <= up_sync1; down_sync2 <= down_sync1;
            left_sync2 <= left_sync1; right_sync2 <= right_sync1;
            enter_sync2 <= enter_sync1; space_sync2 <= space_sync1;
        end
    end

    reg up_d, down_d, left_d, right_d, space_d, enter_d;
    wire up_edge    = up_sync2 & ~up_d;
    wire down_edge  = down_sync2 & ~down_d;
    wire left_edge  = left_sync2 & ~left_d;
    wire right_edge = right_sync2 & ~right_d;
    wire space_edge = space_sync2 & ~space_d;
    wire enter_edge = enter_sync2 & ~enter_d;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            up_d <= 0; down_d <= 0; left_d <= 0; right_d <= 0; space_d <= 0; enter_d <= 0;
        end else begin
            up_d <= up_sync2; down_d <= down_sync2; left_d <= left_sync2;
            right_d <= right_sync2; space_d <= space_sync2; enter_d <= enter_sync2;
        end
    end

    wire [3:0] next_cell_up    = (current_cell >= MIN_UP_CELL) ? current_cell - BOARD_SIZE : current_cell;
    wire [3:0] next_cell_down  = (current_cell <= MAX_DOWN_CELL) ? current_cell + BOARD_SIZE : current_cell;
    wire [3:0] next_cell_left  = (current_cell % BOARD_SIZE != 0) ? current_cell - 1 : current_cell;
    wire [3:0] next_cell_right = (current_cell % BOARD_SIZE != 2) ? current_cell + 1 : current_cell;

    reg current_cell_empty;
    always @(*) begin
        case (current_cell)
            4'd0: current_cell_empty = (board_state[1:0] == EMPTY);
            4'd1: current_cell_empty = (board_state[3:2] == EMPTY);
            4'd2: current_cell_empty = (board_state[5:4] == EMPTY);
            4'd3: current_cell_empty = (board_state[7:6] == EMPTY);
            4'd4: current_cell_empty = (board_state[9:8] == EMPTY);
            4'd5: current_cell_empty = (board_state[11:10] == EMPTY);
            4'd6: current_cell_empty = (board_state[13:12] == EMPTY);
            4'd7: current_cell_empty = (board_state[15:14] == EMPTY);
            4'd8: current_cell_empty = (board_state[17:16] == EMPTY);
            default: current_cell_empty = 1'b0;
        endcase
    end

    reg win_detected;
    reg [1:0] player_val;
    always @(*) begin
        player_val = current_player ? PLAYER_2 : PLAYER_1;
        win_detected =
            ((board_state[1:0] == player_val) && (board_state[3:2] == player_val) && (board_state[5:4] == player_val)) ||
            ((board_state[7:6] == player_val) && (board_state[9:8] == player_val) && (board_state[11:10] == player_val)) ||
            ((board_state[13:12] == player_val) && (board_state[15:14] == player_val) && (board_state[17:16] == player_val)) ||
            ((board_state[1:0] == player_val) && (board_state[7:6] == player_val) && (board_state[13:12] == player_val)) ||
            ((board_state[3:2] == player_val) && (board_state[9:8] == player_val) && (board_state[15:14] == player_val)) ||
            ((board_state[5:4] == player_val) && (board_state[11:10] == player_val) && (board_state[17:16] == player_val)) ||
            ((board_state[1:0] == player_val) && (board_state[9:8] == player_val) && (board_state[17:16] == player_val)) ||
            ((board_state[5:4] == player_val) && (board_state[9:8] == player_val) && (board_state[13:12] == player_val));
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S_MOVE;
            current_cell <= 4'b0;
            cell_select_flag <= 9'b000000001;
            board_state <= 18'b0;
            win_flag <= 1'b0;
            current_player <= 1'b0;
        end else begin
            case (state)
                S_MOVE: begin
                    if (up_edge && current_cell >= MIN_UP_CELL) begin
                        current_cell <= next_cell_up;
                        cell_select_flag <= cell_select_flag >> BOARD_SIZE;
                    end else if (down_edge && current_cell <= MAX_DOWN_CELL) begin
                        current_cell <= next_cell_down;
                        cell_select_flag <= cell_select_flag << BOARD_SIZE;
                    end else if (left_edge && current_cell % BOARD_SIZE != 0) begin
                        current_cell <= next_cell_left;
                        cell_select_flag <= cell_select_flag >> 1;
                    end else if (right_edge && current_cell % BOARD_SIZE != 2) begin
                        current_cell <= next_cell_right;
                        cell_select_flag <= cell_select_flag << 1;
                    end
                    if (space_edge && current_cell_empty)
                        state <= S_WAIT;
                end
                S_WAIT: begin
                    if (enter_edge) state <= S_PLACE;
                    else if (space_edge) state <= S_MOVE;
                end
                S_PLACE: begin
                    case (current_cell)
                        4'd0: board_state[1:0]   <= current_player ? PLAYER_2 : PLAYER_1;
                        4'd1: board_state[3:2]   <= current_player ? PLAYER_2 : PLAYER_1;
                        4'd2: board_state[5:4]   <= current_player ? PLAYER_2 : PLAYER_1;
                        4'd3: board_state[7:6]   <= current_player ? PLAYER_2 : PLAYER_1;
                        4'd4: board_state[9:8]   <= current_player ? PLAYER_2 : PLAYER_1;
                        4'd5: board_state[11:10] <= current_player ? PLAYER_2 : PLAYER_1;
                        4'd6: board_state[13:12] <= current_player ? PLAYER_2 : PLAYER_1;
                        4'd7: board_state[15:14] <= current_player ? PLAYER_2 : PLAYER_1;
                        4'd8: board_state[17:16] <= current_player ? PLAYER_2 : PLAYER_1;
                    endcase
                    if (win_detected) begin
                        win_flag <= 1'b1;
                        state <= S_WIN;
                    end else begin
                        // Switch player and return to move state
                        current_player <= ~current_player;
                        state <= S_MOVE;
                    end
                end
                
                S_WIN: begin
                    // Game is won, stay in this state until reset
                    // No input is processed
                end
                
                default: state <= S_MOVE;
            endcase
        end
    end

    always @(*) begin
        board_out = board_state;
    end

endmodule
