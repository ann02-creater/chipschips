module controller(
    input clk, reset,
    input sync_x,
    input eq6, eq7, eq11, eq,
    output reg ld, inc,
    output reg win, lose
);
localparam  S0 = 3'd0,
            S1 = 3'd1,
            S2 = 3'd2,
            S3 = 3'd3,
            S4 = 3'd4,
            S5 = 3'd5;

reg [2:0] current_state, next_state;

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        current_state <= S0;
    end else begin
        current_state <= next_state;
    end
end

always @(*) begin
    next_state = current_state;



    case (current_state)
        S0: begin
            if (sync_x) begin
                next_state = S1;
            end
        end
        S1: begin
            if (eq7 || eq11) begin
                next_state = S2;
            end else if (eq6) begin
                next_state = S3;
            end else begin
                next_state = S4;
            end
        end
        S2: begin
            if(!sync_x) begin
                next_state = S0;
            end
            end
        
        S3: begin
            if(!sync_x) begin
                next_state = S0;
            end
            end
        S4: begin
        if(sync_x) begin
            next_state = S5;
          end
        end
        S5: begin
            if (eq) begin
                next_state = S2;
            end else if (eq6 || eq7) begin
                next_state = S3;
            end else begin
                next_state = S4;
            end
        end
        default: begin
            next_state = S0;
        end
    endcase
end

always @(*) begin
    ld = 1'b0;
    inc = 1'b0;
    win = 1'b0;
    lose = 1'b0;

    case (current_state)
        S0: begin
            inc = 1'b1;
        end
        S1: begin
            if(!(eq7 || eq11 || eq6))
            ld = 1'b1;
        end
        S2: begin
            win = 1'b1;
        end
        S3: begin
            lose = 1'b1;
        end
        S4: begin
            inc = 1'b1;
        end
        S5: begin
           
        end
    endcase
end
endmodule