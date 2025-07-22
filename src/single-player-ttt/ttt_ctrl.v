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
    output reg [8:0]   board_out
);

    // State definitions
    localparam S_MOVE  = 2'b00;
    localparam S_WAIT  = 2'b01;
    localparam S_PLACE = 2'b10;

    reg [1:0] state;
    reg [8:0] board_state;
    
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
    wire [3:0] next_cell_up    = (current_cell >= 3) ? current_cell - 3 : current_cell;
    wire [3:0] next_cell_down  = (current_cell <= 5) ? current_cell + 3 : current_cell;
    wire [3:0] next_cell_left  = (current_cell % 3 != 0) ? current_cell - 1 : current_cell;
    wire [3:0] next_cell_right = (current_cell % 3 != 2) ? current_cell + 1 : current_cell;

    // Main state machine
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S_MOVE;
            current_cell <= 4'b0;
            cell_select_flag <= 9'b000000001;
            board_state <= 9'b0;
            win_flag <= 1'b0;
        end else begin
            case (state)
                S_MOVE: begin
                    // Handle movement
                    if (up_edge && current_cell >= 3) begin
                        current_cell <= next_cell_up;
                        cell_select_flag <= cell_select_flag >> 3;
                    end else if (down_edge && current_cell <= 5) begin
                        current_cell <= next_cell_down;
                        cell_select_flag <= cell_select_flag << 3;
                    end else if (left_edge && current_cell % 3 != 0) begin
                        current_cell <= next_cell_left;
                        cell_select_flag <= cell_select_flag >> 1;
                    end else if (right_edge && current_cell % 3 != 2) begin
                        current_cell <= next_cell_right;
                        cell_select_flag <= cell_select_flag << 1;
                    end
                    
                    // Check for space press on empty cell
                    if (space_edge && !board_state[current_cell]) begin
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
                    // Place piece and return to move state
                    board_state[current_cell] <= 1'b1;
                    state <= S_MOVE;
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