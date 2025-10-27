always @(posedge clk or posedge reset) begin
    if (reset) begin
        dice1 <= 3'd1;
        dice2 <= 3'd1;
        point <= 4'd0;
    end else begin  
        if (inc) begin
            if (dice1 == 3'd6) begin
                dice1 <= 3'd1;
                if (dice2 == 3'd6) begin  
                    dice2 <= 3'd1;
                end else begin
                    dice2 <= dice2 + 3'd1;
                end
            end else begin
                dice1 <= dice1 + 3'd1;
            end
        end 
        if (ld) begin
            point <= sum;
        end
    end
end