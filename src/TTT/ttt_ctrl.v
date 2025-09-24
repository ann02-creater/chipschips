module ttt_ctrl (
    input  wire        clk,
    input  wire        reset,
    input  wire        up,
    input  wire        down,
    input  wire        left,
    input  wire        right,
    input  wire        enter,
    input  wire        space,
    output reg  [1:0]  win_flag,         // 00=none, 01=P1, 10=P2, 11=draw
    output reg  [3:0]  current_cell,
    output reg  [8:0]  cell_select_flag,
    output reg  [17:0] board_out,        // 2 bits¡¿9 cells
    output reg         current_player    // 0=P1, 1=P2
);

    localparam S_MOVE  = 3'd0;
    localparam S_WAIT  = 3'd1;
    localparam S_PLACE = 3'd2;
    localparam S_CHECK = 3'd3;
    localparam S_WIN   = 3'd4;

    localparam PLAYER_1 = 2'b01;
    localparam PLAYER_2 = 2'b10;
    localparam EMPTY    = 2'b00;

    localparam BOARD_SIZE    = 3;
    localparam MIN_UP_CELL   = 3;
    localparam MAX_DOWN_CELL = 5;

    reg [2:0]  state;
    reg [17:0] board_state;

    // sync & edge detect
    reg up_s1, up_s2, up_d;
    reg down_s1, down_s2, down_d;
    reg left_s1, left_s2, left_d;
    reg right_s1, right_s2, right_d;
    reg enter_s1, enter_s2, enter_d;
    reg space_s1, space_s2, space_d;

    wire up_edge    = up_s2    & ~up_d;
    wire down_edge  = down_s2  & ~down_d;
    wire left_edge  = left_s2  & ~left_d;
    wire right_edge = right_s2 & ~right_d;
    wire enter_edge = enter_s2 & ~enter_d;
    wire space_edge = space_s2 & ~space_d;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            up_s1 <= 0; up_s2 <= 0; up_d <= 0;
            down_s1 <= 0; down_s2 <= 0; down_d <= 0;
            left_s1 <= 0; left_s2 <= 0; left_d <= 0;
            right_s1 <= 0; right_s2 <= 0; right_d <= 0;
            enter_s1 <= 0; enter_s2 <= 0; enter_d <= 0;
            space_s1 <= 0; space_s2 <= 0; space_d <= 0;
        end else begin
            up_s1    <= up;     up_s2    <= up_s1;    up_d    <= up_s2;
            down_s1  <= down;   down_s2  <= down_s1;  down_d  <= down_s2;
            left_s1  <= left;   left_s2  <= left_s1;  left_d  <= left_s2;
            right_s1 <= right;  right_s2 <= right_s1; right_d <= right_s2;
            enter_s1 <= enter;  enter_s2 <= enter_s1; enter_d <= enter_s2;
            space_s1 <= space;  space_s2 <= space_s1; space_d <= space_s2;
        end
    end

    // cursor moves
    wire [3:0] next_up    = (current_cell >= MIN_UP_CELL)   ? current_cell - BOARD_SIZE : current_cell;
    wire [3:0] next_down  = (current_cell <= MAX_DOWN_CELL) ? current_cell + BOARD_SIZE : current_cell;
    wire [3:0] next_left  = (current_cell % BOARD_SIZE != 0) ? current_cell - 1         : current_cell;
    wire [3:0] next_right = (current_cell % BOARD_SIZE != 2) ? current_cell + 1         : current_cell;

    // empty?
    reg current_cell_empty;
    always @(*) begin
        case (current_cell)
            4'd0: current_cell_empty = (board_state[1:0]    == EMPTY);
            4'd1: current_cell_empty = (board_state[3:2]    == EMPTY);
            4'd2: current_cell_empty = (board_state[5:4]    == EMPTY);
            4'd3: current_cell_empty = (board_state[7:6]    == EMPTY);
            4'd4: current_cell_empty = (board_state[9:8]    == EMPTY);
            4'd5: current_cell_empty = (board_state[11:10]  == EMPTY);
            4'd6: current_cell_empty = (board_state[13:12]  == EMPTY);
            4'd7: current_cell_empty = (board_state[15:14]  == EMPTY);
            4'd8: current_cell_empty = (board_state[17:16]  == EMPTY);
            default: current_cell_empty = 1'b0;
        endcase
    end

    // win detect
    wire [1:0] pv = current_player ? PLAYER_2 : PLAYER_1;
    wire win0 = (board_state[1:0]   == pv && board_state[3:2]   == pv && board_state[5:4]   == pv);
    wire win1 = (board_state[7:6]   == pv && board_state[9:8]   == pv && board_state[11:10]== pv);
    wire win2 = (board_state[13:12] == pv && board_state[15:14] == pv && board_state[17:16]== pv);
    wire win3 = (board_state[1:0]   == pv && board_state[7:6]   == pv && board_state[13:12]== pv);
    wire win4 = (board_state[3:2]   == pv && board_state[9:8]   == pv && board_state[15:14]== pv);
    wire win5 = (board_state[5:4]   == pv && board_state[11:10]== pv && board_state[17:16]== pv);
    wire win6 = (board_state[1:0]   == pv && board_state[9:8]   == pv && board_state[17:16]== pv);
    wire win7 = (board_state[5:4]   == pv && board_state[9:8]   == pv && board_state[13:12]== pv);
    wire win_detected = win0||win1||win2||win3||win4||win5||win6||win7;

    // full board?
    wire board_full =
        board_state[1:0]   != EMPTY &&
        board_state[3:2]   != EMPTY &&
        board_state[5:4]   != EMPTY &&
        board_state[7:6]   != EMPTY &&
        board_state[9:8]   != EMPTY &&
        board_state[11:10] != EMPTY &&
        board_state[13:12] != EMPTY &&
        board_state[15:14] != EMPTY &&
        board_state[17:16] != EMPTY;

    // FSM
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state            <= S_MOVE;
            current_cell     <= 4'd0;
            cell_select_flag <= 9'b000000001;
            board_state      <= 18'b0;
            win_flag         <= 2'b00;
            current_player   <= 1'b0;
        end else begin
            case (state)
                S_MOVE: begin
                    if (win_flag == 2'b00) begin
                        if      (up_edge    && current_cell >= MIN_UP_CELL)   begin current_cell <= next_up;    cell_select_flag <= cell_select_flag >> 3; end
                        else if (down_edge  && current_cell <= MAX_DOWN_CELL) begin current_cell <= next_down;  cell_select_flag <= cell_select_flag << 3; end
                        else if (left_edge  && current_cell % 3 != 0)         begin current_cell <= next_left;  cell_select_flag <= cell_select_flag >> 1; end
                        else if (right_edge && current_cell % 3 != 2)         begin current_cell <= next_right; cell_select_flag <= cell_select_flag << 1; end
                        if (space_edge && current_cell_empty) state <= S_WAIT;
                    end
                end

                S_WAIT: begin
                    if      (enter_edge) state <= S_PLACE;
                    else if (space_edge) state <= S_MOVE;
                end

                S_PLACE: begin
                    case (current_cell)
                        4'd0: board_state[1:0]   <= pv;
                        4'd1: board_state[3:2]   <= pv;
                        4'd2: board_state[5:4]   <= pv;
                        4'd3: board_state[7:6]   <= pv;
                        4'd4: board_state[9:8]   <= pv;
                        4'd5: board_state[11:10] <= pv;
                        4'd6: board_state[13:12] <= pv;
                        4'd7: board_state[15:14] <= pv;
                        4'd8: board_state[17:16] <= pv;
                    endcase
                    state <= S_CHECK;
                end

                S_CHECK: begin
                    if      (win_detected)            begin win_flag <= pv;       state <= S_WIN; end
                    else if (board_full && !win_detected) begin win_flag <= 2'b11;    state <= S_WIN; end
                    else                              begin current_player <= ~current_player; state <= S_MOVE; end
                end

                S_WIN: begin end
                default: state <= S_MOVE;
            endcase
        end
    end

    always @(*) board_out = board_state;
endmodule
