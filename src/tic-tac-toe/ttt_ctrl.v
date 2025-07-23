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
    output reg [17:0]  board_out,     // Changed from 9-bit to 18-bit
    output reg         current_player  // 0 = player 1 (circle), 1 = player 2 (X)
);

    // State definitions
    localparam S_MOVE  = 2'b00;
    localparam S_WAIT  = 2'b01;
    localparam S_PLACE = 2'b10;
    localparam S_WIN   = 2'b11;  // New state for game won
    
    // Cell bit position definitions for board_state
    localparam CELL_0 = 1;   // board_state[1:0]   - Top left
    localparam CELL_1 = 3;   // board_state[3:2]   - Top center
    localparam CELL_2 = 5;   // board_state[5:4]   - Top right
    localparam CELL_3 = 7;   // board_state[7:6]   - Middle left
    localparam CELL_4 = 9;   // board_state[9:8]   - Middle center
    localparam CELL_5 = 11;  // board_state[11:10] - Middle right
    localparam CELL_6 = 13;  // board_state[13:12] - Bottom left
    localparam CELL_7 = 15;  // board_state[15:14] - Bottom center
    localparam CELL_8 = 17;  // board_state[17:16] - Bottom right
    
    // Player definitions
    localparam PLAYER_1 = 2'b01;  // Player 1 (green circle)
    localparam PLAYER_2 = 2'b10;  // Player 2 (red X)
    localparam EMPTY    = 2'b00;  // Empty cell
    
    // Board dimensions
    localparam BOARD_SIZE = 3;    // 3x3 grid
    localparam TOTAL_CELLS = 9;   // Total number of cells
    
    // Cell movement boundaries
    localparam MIN_UP_CELL = 3;   // Minimum cell index to move up
    localparam MAX_DOWN_CELL = 5; // Maximum cell index to move down

    reg [1:0] state;
    reg [17:0] board_state;  // 18-bit: 2 bits per cell (00=empty, 01=player1, 10=player2)
    
    // Clock domain synchronization (100MHz to 25MHz)
    // First stage synchronizers
    reg up_sync1, down_sync1, left_sync1, right_sync1;
    reg enter_sync1, space_sync1;
    
    // Second stage synchronizers
    reg up_sync2, down_sync2, left_sync2, right_sync2;
    reg enter_sync2, space_sync2;
    
    // Synchronization logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            up_sync1    <= 1'b0;
            down_sync1  <= 1'b0;
            left_sync1  <= 1'b0;
            right_sync1 <= 1'b0;
            enter_sync1 <= 1'b0;
            space_sync1 <= 1'b0;
            
            up_sync2    <= 1'b0;
            down_sync2  <= 1'b0;
            left_sync2  <= 1'b0;
            right_sync2 <= 1'b0;
            enter_sync2 <= 1'b0;
            space_sync2 <= 1'b0;
        end else begin
            // First stage
            up_sync1    <= up;
            down_sync1  <= down;
            left_sync1  <= left;
            right_sync1 <= right;
            enter_sync1 <= enter;
            space_sync1 <= space;
            
            // Second stage
            up_sync2    <= up_sync1;
            down_sync2  <= down_sync1;
            left_sync2  <= left_sync1;
            right_sync2 <= right_sync1;
            enter_sync2 <= enter_sync1;
            space_sync2 <= space_sync1;
        end
    end
    
    // Edge detection for synchronized keys
    reg up_d, down_d, left_d, right_d, space_d, enter_d;
    wire up_edge    = up_sync2 & ~up_d;
    wire down_edge  = down_sync2 & ~down_d;
    wire left_edge  = left_sync2 & ~left_d;
    wire right_edge = right_sync2 & ~right_d;
    wire space_edge = space_sync2 & ~space_d;
    wire enter_edge = enter_sync2 & ~enter_d;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            up_d    <= 1'b0;
            down_d  <= 1'b0;
            left_d  <= 1'b0;
            right_d <= 1'b0;
            space_d <= 1'b0;
            enter_d <= 1'b0;
        end else begin
            up_d    <= up_sync2;
            down_d  <= down_sync2;
            left_d  <= left_sync2;
            right_d <= right_sync2;
            space_d <= space_sync2;
            enter_d <= enter_sync2;
        end
    end

    // Cell movement logic
    wire [3:0] next_cell_up    = (current_cell >= MIN_UP_CELL) ? current_cell - BOARD_SIZE : current_cell;
    wire [3:0] next_cell_down  = (current_cell <= MAX_DOWN_CELL) ? current_cell + BOARD_SIZE : current_cell;
    wire [3:0] next_cell_left  = (current_cell % BOARD_SIZE != 0) ? current_cell - 1 : current_cell;
    wire [3:0] next_cell_right = (current_cell % BOARD_SIZE != 2) ? current_cell + 1 : current_cell;

    // Check if cell is empty (2 bits per cell) - with explicit return type
    function reg is_cell_empty;
        input [17:0] board;
        input [3:0] cell;
        reg [1:0] cell_value;
        begin
            // Use case statement to avoid dynamic shift
            case (cell)
                4'd0: cell_value = board[CELL_0:CELL_0-1];
                4'd1: cell_value = board[CELL_1:CELL_1-1];
                4'd2: cell_value = board[CELL_2:CELL_2-1];
                4'd3: cell_value = board[CELL_3:CELL_3-1];
                4'd4: cell_value = board[CELL_4:CELL_4-1];
                4'd5: cell_value = board[CELL_5:CELL_5-1];
                4'd6: cell_value = board[CELL_6:CELL_6-1];
                4'd7: cell_value = board[CELL_7:CELL_7-1];
                4'd8: cell_value = board[CELL_8:CELL_8-1];
                default: cell_value = 2'b00;
            endcase
            is_cell_empty = (cell_value == EMPTY);
        end
    endfunction

    // Get cell value (2 bits per cell) - with explicit return type
    function [1:0] get_cell_value;
        input [17:0] board;
        input [3:0] cell;
        begin
            // Use case statement to avoid dynamic shift
            case (cell)
                4'd0: get_cell_value = board[CELL_0:CELL_0-1];
                4'd1: get_cell_value = board[CELL_1:CELL_1-1];
                4'd2: get_cell_value = board[CELL_2:CELL_2-1];
                4'd3: get_cell_value = board[CELL_3:CELL_3-1];
                4'd4: get_cell_value = board[CELL_4:CELL_4-1];
                4'd5: get_cell_value = board[CELL_5:CELL_5-1];
                4'd6: get_cell_value = board[CELL_6:CELL_6-1];
                4'd7: get_cell_value = board[CELL_7:CELL_7-1];
                4'd8: get_cell_value = board[CELL_8:CELL_8-1];
                default: get_cell_value = 2'b00;
            endcase
        end
    endfunction

    // Check win condition - with explicit return type
    function reg check_win;
        input [17:0] board;
        input player;  // 0 = player1, 1 = player2
        reg [1:0] player_val;
        begin
            player_val = player ? PLAYER_2 : PLAYER_1;
            
            // Check rows
            check_win = ((get_cell_value(board, 0) == player_val) && 
                        (get_cell_value(board, 1) == player_val) && 
                        (get_cell_value(board, 2) == player_val)) ||
                       ((get_cell_value(board, 3) == player_val) && 
                        (get_cell_value(board, 4) == player_val) && 
                        (get_cell_value(board, 5) == player_val)) ||
                       ((get_cell_value(board, 6) == player_val) && 
                        (get_cell_value(board, 7) == player_val) && 
                        (get_cell_value(board, 8) == player_val)) ||
            // Check columns
                       ((get_cell_value(board, 0) == player_val) && 
                        (get_cell_value(board, 3) == player_val) && 
                        (get_cell_value(board, 6) == player_val)) ||
                       ((get_cell_value(board, 1) == player_val) && 
                        (get_cell_value(board, 4) == player_val) && 
                        (get_cell_value(board, 7) == player_val)) ||
                       ((get_cell_value(board, 2) == player_val) && 
                        (get_cell_value(board, 5) == player_val) && 
                        (get_cell_value(board, 8) == player_val)) ||
            // Check diagonals
                       ((get_cell_value(board, 0) == player_val) && 
                        (get_cell_value(board, 4) == player_val) && 
                        (get_cell_value(board, 8) == player_val)) ||
                       ((get_cell_value(board, 2) == player_val) && 
                        (get_cell_value(board, 4) == player_val) && 
                        (get_cell_value(board, 6) == player_val));
        end
    endfunction

    // Main state machine
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S_MOVE;
            current_cell <= 4'b0;
            cell_select_flag <= 9'b000000001;
            board_state <= 18'b0;
            win_flag <= 1'b0;
            current_player <= 1'b0;  // Start with player 1
        end else begin
            case (state)
                S_MOVE: begin
                    // Handle movement
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
                    
                    // Check for space press on empty cell
                    if (space_edge && is_cell_empty(board_state, current_cell)) begin
                        state <= S_WAIT;
                    end
                end
                
                S_WAIT: begin
                    // Wait for enter
                    if (enter_edge) begin
                        state <= S_PLACE;
                    end
                    // Allow cancellation by pressing space again
                    else if (space_edge) begin
                        state <= S_MOVE;
                    end
                end
                
                S_PLACE: begin
                    // Place piece based on current player using case statement
                    case (current_cell)
                        4'd0: begin
                            if (current_player == 1'b0)
                                board_state[CELL_0:CELL_0-1] <= PLAYER_1;
                            else
                                board_state[CELL_0:CELL_0-1] <= PLAYER_2;
                        end
                        4'd1: begin
                            if (current_player == 1'b0)
                                board_state[CELL_1:CELL_1-1] <= PLAYER_1;
                            else
                                board_state[CELL_1:CELL_1-1] <= PLAYER_2;
                        end
                        4'd2: begin
                            if (current_player == 1'b0)
                                board_state[CELL_2:CELL_2-1] <= PLAYER_1;
                            else
                                board_state[CELL_2:CELL_2-1] <= PLAYER_2;
                        end
                        4'd3: begin
                            if (current_player == 1'b0)
                                board_state[CELL_3:CELL_3-1] <= PLAYER_1;
                            else
                                board_state[CELL_3:CELL_3-1] <= PLAYER_2;
                        end
                        4'd4: begin
                            if (current_player == 1'b0)
                                board_state[CELL_4:CELL_4-1] <= PLAYER_1;
                            else
                                board_state[CELL_4:CELL_4-1] <= PLAYER_2;
                        end
                        4'd5: begin
                            if (current_player == 1'b0)
                                board_state[CELL_5:CELL_5-1] <= PLAYER_1;
                            else
                                board_state[CELL_5:CELL_5-1] <= PLAYER_2;
                        end
                        4'd6: begin
                            if (current_player == 1'b0)
                                board_state[CELL_6:CELL_6-1] <= PLAYER_1;
                            else
                                board_state[CELL_6:CELL_6-1] <= PLAYER_2;
                        end
                        4'd7: begin
                            if (current_player == 1'b0)
                                board_state[CELL_7:CELL_7-1] <= PLAYER_1;
                            else
                                board_state[CELL_7:CELL_7-1] <= PLAYER_2;
                        end
                        4'd8: begin
                            if (current_player == 1'b0)
                                board_state[CELL_8:CELL_8-1] <= PLAYER_1;
                            else
                                board_state[CELL_8:CELL_8-1] <= PLAYER_2;
                        end
                    endcase
                    
                    // Check for win
                    if (check_win(board_state, current_player)) begin
                        win_flag <= 1'b1;
                        state <= S_WIN;
                    end else begin
                        // Switch player and continue
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

    // Output assignment
    always @(*) begin
        board_out = board_state;
    end

endmodule