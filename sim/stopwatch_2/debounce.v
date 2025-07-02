module debounce(
    input wire clk, reset, btn,
    output reg toggle
    );
    reg Q0, Q1;
    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            Q0 <= 0;
            Q1 <= 0;
            toggle <= 0;
        end else begin
            Q0 <= btn;
            Q1 <= Q0;
            toggle <= Q0 & ~Q1 ? ~toggle : toggle;
        end
    end
    
endmodule
