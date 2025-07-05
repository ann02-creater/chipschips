module counter1 #(
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

module counter2 #(
    parameter MaxCount = 9,
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

//각 자리마다 둘 중 알맞은 모듈이 적용되고, TC값이 다음 자릿수의 en값이 됨. 즉, U1.en = TC0, U2.en = TC1...