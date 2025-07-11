module tic_tac_toe_top(
    input wire clk,
    input wire reset,
    input wire [4:0] btn,
    input wire sw0,
    output wire HS, VS,
    output wire [3:0] VGA_R, VGA_G, VGA_B,
    output wire [6:0] SEG,
    output wire [3:0] AN
);
    wire clk_25MHz;
    wire [4:0] btn_pulse;
    wire [8:0] board;
    wire [3:0] cursor;
    wire [1:0] winner;
    wire [2:0] state;
    wire video_on;
    wire [9:0] x, y;

    clk_divider u_div(.clk(clk), .reset(sw0), .clk_out(clk_25MHz));
    debounce u_db(.clk(clk), .reset(sw0), .btn(btn), .btn_pulse(btn_pulse));
    control u_fsm(.clk(clk), .reset(sw0), .btn_pulse(btn_pulse), .board(board), .cursor(cursor), .winner(winner), .state(state));
    scan_gen u_vga(.clk(clk_25MHz), .reset(sw0), .HS(HS), .VS(VS), .video_on(video_on), .x(x), .y(y));
    renderer u_render(.x(x), .y(y), .video_on(video_on), .board(board), .cursor(cursor), .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B));
    sseg_display u_seg7(.clk(clk), .reset(sw0), .data_in({6'b0,winner}), .seg_out(SEG), .seg_sel(AN));
endmodule