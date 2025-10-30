module datapath(
    input clk, reset,
    input ld, inc,
    output eq6, eq7, eq11, eq,
    output reg [2:0] dice1, dice2
);
    reg [3:0] point;
    wire [3:0] sum;

    assign sum = dice1 + dice2;
    assign eq6 = (sum == 4'd6);
    assign eq7 = (sum == 4'd7);
    assign eq11 = (sum == 4'd11);
    assign eq = (sum == point);

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
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
   
endmodule