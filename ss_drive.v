module ss_drive(
    input clk,
    input rst,
    input [3:0] data7, data6, data5, data4, data3, data2, data1, data0,
    input [7:0] mask,
    output ssA, ssB, ssC, ssD, ssE, ssF, ssG, ssDP,
    output reg AN7, AN6, AN5, AN4, AN3, AN2, AN1, AN0
);

reg [2:0] sel;
reg [3:0] data;
reg [15:0] cnt;

always @(posedge clk) begin
    if(rst) begin
        cnt <= 0;
        sel <= 0;
    end else if (cnt < 20000) begin
        cnt <= cnt + 1;
    end else begin
        cnt <= 0;
        sel <= sel + 1;
    end
end

always @(*) begin
    case(sel)
        3'b000: begin data = data0; {AN7,AN6,AN5,AN4,AN3,AN2,AN1,AN0} = {7'b1111111, ~mask[0]}; end
        3'b001: begin data = data1; {AN7,AN6,AN5,AN4,AN3,AN2,AN1,AN0} = {6'b111111, ~mask[1], 1'b1}; end
        3'b010: begin data = data2; {AN7,AN6,AN5,AN4,AN3,AN2,AN1,AN0} = {5'b11111, ~mask[2], 2'b11}; end
        3'b011: begin data = data3; {AN7,AN6,AN5,AN4,AN3,AN2,AN1,AN0} = {4'b1111, ~mask[3], 3'b111}; end
        3'b100: begin data = data4; {AN7,AN6,AN5,AN4,AN3,AN2,AN1,AN0} = {3'b111, ~mask[4], 4'b1111}; end
        3'b101: begin data = data5; {AN7,AN6,AN5,AN4,AN3,AN2,AN1,AN0} = {2'b11, ~mask[5], 5'b11111}; end
        3'b110: begin data = data6; {AN7,AN6,AN5,AN4,AN3,AN2,AN1,AN0} = {1'b1, ~mask[6], 6'b111111}; end
        3'b111: begin data = data7; {AN7,AN6,AN5,AN4,AN3,AN2,AN1,AN0} = {~mask[7], 7'b1111111}; end
    endcase
end

ss_decoder decoder(
    .Din(data),
    .a(ssA), .b(ssB), .c(ssC), .d(ssD),
    .e(ssE), .f(ssF), .g(ssG), .dp(ssDP)
);

endmodule