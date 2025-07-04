module counter #(
    parameter MaxCount = 6,
              DataWidth = 4
)(
    input wire clk,
    input wire reset,
    input wire en,
    output reg [DataWidth-1:0] Q,
    output wire TC
);

    assign TC = (Q == MaxCount) & en;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Q <= 0;
        end else if (en) begin
            if (TC)
                Q <= 0;
            else
                Q <= Q + 1;
        end
    end

endmodule

module counter_bcd(
    input wire clk,
    input wire reset,
    input wire en,
    output reg [3:0] Q,
    output wire TC
);

    assign TC = (Q == 4'd9) & en;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Q <= 4'd0;
        end else if (en) begin
            if (TC)
                Q <= 4'd0;
            else
                Q <= Q + 1;
        end
    end

endmodule

module counter_mod6(
    input wire clk,
    input wire reset,
    input wire en,
    output reg [2:0] Q,
    output wire TC
);

    assign TC = (Q == 3'd5) & en;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Q <= 3'd0;
        end else if (en) begin
            if (TC)
                Q <= 3'd0;
            else
                Q <= Q + 1;
        end
    end

endmodule