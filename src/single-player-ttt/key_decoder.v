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

    localparam 
        KEY_W      = 8'h77,  // 'w' - up
        KEY_S      = 8'h73,  // 's' - down  
        KEY_A      = 8'h61,  // 'a' - left
        KEY_D      = 8'h64,  // 'd' - right
        KEY_SPACE  = 8'h20,  // space - enter
        KEY_ENTER  = 8'h0D;  // enter - enter

    // Key index parameters
    localparam 
        UP_IDX     = 0,
        DOWN_IDX   = 1,
        LEFT_IDX   = 2,
        RIGHT_IDX  = 3,
        ENTER_IDX  = 4,
        SPACE_IDX  = 5;

    reg [15:0] key_hold_counter [5:0];
    reg [5:0] key_pressed;
    
    localparam KEY_HOLD_TIME = 16'd5000;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            up_key <= 0;
            down_key <= 0;
            left_key <= 0;
            right_key <= 0;
            enter_key <= 0;
            space_key <= 0;
            key_pressed <= 6'b0;
            key_hold_counter[UP_IDX] <= 0;
            key_hold_counter[DOWN_IDX] <= 0;
            key_hold_counter[LEFT_IDX] <= 0;
            key_hold_counter[RIGHT_IDX] <= 0;
            key_hold_counter[ENTER_IDX] <= 0;
            key_hold_counter[SPACE_IDX] <= 0;
        end else begin
            if (uart_valid) begin
                case (uart_data)
                    KEY_W: begin
                        key_pressed[UP_IDX] <= 1;
                        key_hold_counter[UP_IDX] <= KEY_HOLD_TIME;
                    end
                    KEY_S: begin
                        key_pressed[DOWN_IDX] <= 1;
                        key_hold_counter[DOWN_IDX] <= KEY_HOLD_TIME;
                    end
                    KEY_A: begin
                        key_pressed[LEFT_IDX] <= 1;
                        key_hold_counter[LEFT_IDX] <= KEY_HOLD_TIME;
                    end
                    KEY_D: begin
                        key_pressed[RIGHT_IDX] <= 1;
                        key_hold_counter[RIGHT_IDX] <= KEY_HOLD_TIME;
                    end
                    KEY_SPACE: begin
                        key_pressed[SPACE_IDX] <= 1;
                        key_hold_counter[SPACE_IDX] <= KEY_HOLD_TIME;
                    end
                    KEY_ENTER: begin
                        key_pressed[ENTER_IDX] <= 1;
                        key_hold_counter[ENTER_IDX] <= KEY_HOLD_TIME;
                    end
                endcase
            end

            if (key_hold_counter[UP_IDX] > 0) begin
                key_hold_counter[UP_IDX] <= key_hold_counter[UP_IDX] - 1;
                up_key <= 1;
            end else begin
                key_pressed[UP_IDX] <= 0;
                up_key <= 0;
            end

            if (key_hold_counter[DOWN_IDX] > 0) begin
                key_hold_counter[DOWN_IDX] <= key_hold_counter[DOWN_IDX] - 1;
                down_key <= 1;
            end else begin
                key_pressed[DOWN_IDX] <= 0;
                down_key <= 0;
            end

            if (key_hold_counter[LEFT_IDX] > 0) begin
                key_hold_counter[LEFT_IDX] <= key_hold_counter[LEFT_IDX] - 1;
                left_key <= 1;
            end else begin
                key_pressed[LEFT_IDX] <= 0;
                left_key <= 0;
            end

            if (key_hold_counter[RIGHT_IDX] > 0) begin
                key_hold_counter[RIGHT_IDX] <= key_hold_counter[RIGHT_IDX] - 1;
                right_key <= 1;
            end else begin
                key_pressed[RIGHT_IDX] <= 0;
                right_key <= 0;
            end

            if (key_hold_counter[ENTER_IDX] > 0) begin
                key_hold_counter[ENTER_IDX] <= key_hold_counter[ENTER_IDX] - 1;
                enter_key <= 1;
            end else begin
                key_pressed[ENTER_IDX] <= 0;
                enter_key <= 0;
            end

            if (key_hold_counter[SPACE_IDX] > 0) begin
                key_hold_counter[SPACE_IDX] <= key_hold_counter[SPACE_IDX] - 1;
                space_key <= 1;
            end else begin
                key_pressed[SPACE_IDX] <= 0;
                space_key <= 0;
            end
        end
    end

endmodule