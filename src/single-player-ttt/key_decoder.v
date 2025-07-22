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

    // Simple key detection with single-cycle pulses
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            up_key    <= 1'b0;
            down_key  <= 1'b0;
            left_key  <= 1'b0;
            right_key <= 1'b0;
            enter_key <= 1'b0;
            space_key <= 1'b0;
        end else begin
            // Clear all keys by default
            up_key    <= 1'b0;
            down_key  <= 1'b0;
            left_key  <= 1'b0;
            right_key <= 1'b0;
            enter_key <= 1'b0;
            space_key <= 1'b0;
            
            // Set key on valid pulse
            if (uart_valid_pulse) begin
                case (uart_data)
                    KEY_W:     up_key    <= 1'b1;
                    KEY_S:     down_key  <= 1'b1;
                    KEY_A:     left_key  <= 1'b1;
                    KEY_D:     right_key <= 1'b1;
                    KEY_SPACE: space_key <= 1'b1;
                    KEY_ENTER: enter_key <= 1'b1;
                    default:   ; // Do nothing
                endcase
            end
        end
    end

endmodule