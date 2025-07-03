module counter_bcd(
    input wire clk, reset, en,
    output reg [3:0] Q,
    output wire TC
    );
    
    always @(posedge clk, negedge reset) begin
        if(!reset)  Q <= 0;
        else if(en) Q <= TC ? 0 : Q+1;
    end
    
    assign TC = (Q == 4'd9);
    
endmodule
