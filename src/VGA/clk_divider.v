module clk_divider #(parameter DIV=4)(input clk, input reset, output reg clk_out);

localparam CNT_MAX = DIV/2 -1;
reg [$clog2(DIV)-1:0] cnt;


always @(posedge clk or posedge reset) begin
    if(reset) begin 
        cnt<=0; clk_out<=0; 
    end
    else if(cnt==CNT_MAX) begin 
        cnt<=0; clk_out<=~clk_out; 
    end
    else cnt<=cnt+1;
    end
   
    endmodule

module debounce(input clk, input reset, input [4:0] btn, output [4:0] btn_pulse);
    reg [4:0] prev;
    assign btn_pulse = btn & ~prev;
    always @(posedge clk or posedge reset) begin
        if(reset) prev<=0;
        else prev<=btn;
    end
endmodule