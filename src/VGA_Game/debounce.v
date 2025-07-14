module debounce(
    input clk, 
    input reset, 
    input [4:0] btn, 
    output [4:0] btn_pulse
);
    reg [4:0] prev;
    assign btn_pulse = btn & ~prev;
    always @(posedge clk or posedge reset) begin
        if(reset) prev<=0;
        else prev<=btn;
    end
endmodule
