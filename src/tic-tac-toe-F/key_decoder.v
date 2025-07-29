module key_decoder (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] uart_data,
    input  wire       uart_valid,
    output reg        up_key,
    output reg        down_key,
    output reg        left_key,
    output reg        right_key,
    output reg        enter_key,
    output reg        space_key
);

    // ASCII key definitions
    localparam 
        KEY_W      = 8'h77,  // 'w' - up
        KEY_S      = 8'h73,  // 's' - down  
        KEY_A      = 8'h61,  // 'a' - left
        KEY_D      = 8'h64,  // 'd' - right
        KEY_SPACE  = 8'h20,  // space
        KEY_ENTER  = 8'h0D;  // enter

    // Key hold duration and cooldown parameters
    localparam KEY_HOLD_CYCLES = 16'd1000;     // ~10us at 100MHz
    localparam KEY_COOLDOWN_CYCLES = 20'd500000; // ~5ms cooldown

    // Single cycle pulse generation
    reg uart_valid_d;
    wire uart_valid_pulse;
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            uart_valid_d <= 1'b0;
        else
            uart_valid_d <= uart_valid;
    end
    
    assign uart_valid_pulse = uart_valid & ~uart_valid_d;

    // Key hold counters
    reg [15:0] up_hold_cnt, down_hold_cnt, left_hold_cnt, right_hold_cnt;
    reg [15:0] enter_hold_cnt, space_hold_cnt;
    
    // Cooldown counters
    reg [19:0] up_cooldown, down_cooldown, left_cooldown, right_cooldown;
    reg [19:0] enter_cooldown, space_cooldown;
    
    // Last detected key
    reg [7:0] last_key;

    // Key detection with extended pulses and debouncing
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            up_key    <= 1'b0;
            down_key  <= 1'b0;
            left_key  <= 1'b0;
            right_key <= 1'b0;
            enter_key <= 1'b0;
            space_key <= 1'b0;
            
            up_hold_cnt    <= 16'd0;
            down_hold_cnt  <= 16'd0;
            left_hold_cnt  <= 16'd0;
            right_hold_cnt <= 16'd0;
            enter_hold_cnt <= 16'd0;
            space_hold_cnt <= 16'd0;
            
            up_cooldown    <= 20'd0;
            down_cooldown  <= 20'd0;
            left_cooldown  <= 20'd0;
            right_cooldown <= 20'd0;
            enter_cooldown <= 20'd0;
            space_cooldown <= 20'd0;
            
            last_key <= 8'd0;
        end else begin
            // Decrement cooldown counters
            if (up_cooldown > 0)    up_cooldown    <= up_cooldown - 1;
            if (down_cooldown > 0)  down_cooldown  <= down_cooldown - 1;
            if (left_cooldown > 0)  left_cooldown  <= left_cooldown - 1;
            if (right_cooldown > 0) right_cooldown <= right_cooldown - 1;
            if (enter_cooldown > 0) enter_cooldown <= enter_cooldown - 1;
            if (space_cooldown > 0) space_cooldown <= space_cooldown - 1;
            
            // Handle key detection
            if (uart_valid_pulse) begin
                last_key <= uart_data;
                
                case (uart_data)
                    KEY_W: if (up_cooldown == 0) begin
                        up_hold_cnt <= KEY_HOLD_CYCLES;
                        up_cooldown <= KEY_COOLDOWN_CYCLES;
                    end
                    
                    KEY_S: if (down_cooldown == 0) begin
                        down_hold_cnt <= KEY_HOLD_CYCLES;
                        down_cooldown <= KEY_COOLDOWN_CYCLES;
                    end
                    
                    KEY_A: if (left_cooldown == 0) begin
                        left_hold_cnt <= KEY_HOLD_CYCLES;
                        left_cooldown <= KEY_COOLDOWN_CYCLES;
                    end
                    
                    KEY_D: if (right_cooldown == 0) begin
                        right_hold_cnt <= KEY_HOLD_CYCLES;
                        right_cooldown <= KEY_COOLDOWN_CYCLES;
                    end
                    
                    KEY_SPACE: if (space_cooldown == 0) begin
                        space_hold_cnt <= KEY_HOLD_CYCLES;
                        space_cooldown <= KEY_COOLDOWN_CYCLES;
                    end
                    
                    KEY_ENTER: if (enter_cooldown == 0) begin
                        enter_hold_cnt <= KEY_HOLD_CYCLES;
                        enter_cooldown <= KEY_COOLDOWN_CYCLES;
                    end
                    
                    default: ; // Do nothing
                endcase
            end
            
            // Manage hold counters and output signals
            if (up_hold_cnt > 0) begin
                up_hold_cnt <= up_hold_cnt - 1;
                up_key <= 1'b1;
            end else begin
                up_key <= 1'b0;
            end
            
            if (down_hold_cnt > 0) begin
                down_hold_cnt <= down_hold_cnt - 1;
                down_key <= 1'b1;
            end else begin
                down_key <= 1'b0;
            end
            
            if (left_hold_cnt > 0) begin
                left_hold_cnt <= left_hold_cnt - 1;
                left_key <= 1'b1;
            end else begin
                left_key <= 1'b0;
            end
            
            if (right_hold_cnt > 0) begin
                right_hold_cnt <= right_hold_cnt - 1;
                right_key <= 1'b1;
            end else begin
                right_key <= 1'b0;
            end
            
            if (enter_hold_cnt > 0) begin
                enter_hold_cnt <= enter_hold_cnt - 1;
                enter_key <= 1'b1;
            end else begin
                enter_key <= 1'b0;
            end
            
            if (space_hold_cnt > 0) begin
                space_hold_cnt <= space_hold_cnt - 1;
                space_key <= 1'b1;
            end else begin
                space_key <= 1'b0;
            end
        end
    end

endmodule