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
    
    // Player definitions
    localparam PLAYER_1 = 2'b01;  // Player 1 (green circle)
    localparam PLAYER_2 = 2'b10;  // Player 2 (red X)
    localparam EMPTY    = 2'b00;  // Empty cell
    
    // Board dimensions
    localparam BOARD_SIZE = 3;    // 3x3 grid
    
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

    // Check if current cell is empty
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

    // Check win condition for current player
    reg win_detected;
    reg [1:0] player_val;
    
    always @(*) begin
        player_val = current_player ? PLAYER_2 : PLAYER_1;
        
        // Check all win conditions
        win_detected = 
            // Rows
            ((board_state[1:0] == player_val) && (board_state[3:2] == player_val) && (board_state[5:4] == player_val)) ||
            ((board_state[7:6] == player_val) && (board_state[9:8] == player_val) && (board_state[11:10] == player_val)) ||
            ((board_state[13:12] == player_val) && (board_state[15:14] == player_val) && (board_state[17:16] == player_val)) ||
            // Columns
            ((board_state[1:0] == player_val) && (board_state[7:6] == player_val) && (board_state[13:12] == player_val)) ||
            ((board_state[3:2] == player_val) && (board_state[9:8] == player_val) && (board_state[15:14] == player_val)) ||
            ((board_state[5:4] == player_val) && (board_state[11:10] == player_val) && (board_state[17:16] == player_val)) ||
            // Diagonals
            ((board_state[1:0] == player_val) && (board_state[9:8] == player_val) && (board_state[17:16] == player_val)) ||
            ((board_state[5:4] == player_val) && (board_state[9:8] == player_val) && (board_state[13:12] == player_val));
    end

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
                    if (space_edge && current_cell_empty) begin
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
                                board_state[1:0] <= PLAYER_1;
                            else
                                board_state[1:0] <= PLAYER_2;
                        end
                        4'd1: begin
                            if (current_player == 1'b0)
                                board_state[3:2] <= PLAYER_1;
                            else
                                board_state[3:2] <= PLAYER_2;
                        end
                        4'd2: begin
                            if (current_player == 1'b0)
                                board_state[5:4] <= PLAYER_1;
                            else
                                board_state[5:4] <= PLAYER_2;
                        end
                        4'd3: begin
                            if (current_player == 1'b0)
                                board_state[7:6] <= PLAYER_1;
                            else
                                board_state[7:6] <= PLAYER_2;
                        end
                        4'd4: begin
                            if (current_player == 1'b0)
                                board_state[9:8] <= PLAYER_1;
                            else
                                board_state[9:8] <= PLAYER_2;
                        end
                        4'd5: begin
                            if (current_player == 1'b0)
                                board_state[11:10] <= PLAYER_1;
                            else
                                board_state[11:10] <= PLAYER_2;
                        end
                        4'd6: begin
                            if (current_player == 1'b0)
                                board_state[13:12] <= PLAYER_1;
                            else
                                board_state[13:12] <= PLAYER_2;
                        end
                        4'd7: begin
                            if (current_player == 1'b0)
                                board_state[15:14] <= PLAYER_1;
                            else
                                board_state[15:14] <= PLAYER_2;
                        end
                        4'd8: begin
                            if (current_player == 1'b0)
                                board_state[17:16] <= PLAYER_1;
                            else
                                board_state[17:16] <= PLAYER_2;
                        end
                    endcase
                    
                    // Move to move state first to allow win check to see updated board
                    state <= S_MOVE;
                end
                
                S_WIN: begin
                    // Game is won, stay in this state until reset
                    // No input is processed
                end
                
                default: state <= S_MOVE;
            endcase
            
            // Check for win after placing piece (separate from state machine)
            if (state == S_MOVE && win_detected) begin
                win_flag <= 1'b1;
                state <= S_WIN;
            end
        end
    end

    // Output assignment
    always @(*) begin
        board_out = board_state;
    end

endmodule