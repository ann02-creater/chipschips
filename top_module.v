module top_module(
    input clk,
    input rst,
    input [15:0] sw,
    output [6:0] seg,
    output dp,
    output [7:0] AN
);

wire [2:0] mux_out;
wire [3:0] decoder_in;

mux_4to1_3bit mux_inst(
    .in_a(sw[15:13]),
    .in_b(sw[12:10]),
    .in_c(sw[9:7]),
    .in_d(sw[6:4]),
    .sel(sw[1:0]),
    .out(mux_out)
);

assign decoder_in = {1'b0, mux_out};

ss_drive ss_drive_inst(
    .clk(clk),
    .rst(rst),
    .data7(4'b0000), .data6(4'b0000), .data5(4'b0000), .data4(4'b0000),
    .data3(4'b0000), .data2(4'b0000), .data1(4'b0000), .data0(decoder_in),
    .mask(8'b00000001),
    .ssA(seg[0]), .ssB(seg[1]), .ssC(seg[2]), .ssD(seg[3]),
    .ssE(seg[4]), .ssF(seg[5]), .ssG(seg[6]), .ssDP(dp),
    .AN7(AN[7]), .AN6(AN[6]), .AN5(AN[5]), .AN4(AN[4]),
    .AN3(AN[3]), .AN2(AN[2]), .AN1(AN[1]), .AN0(AN[0])
);

endmodule