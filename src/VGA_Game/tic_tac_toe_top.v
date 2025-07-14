module tic_tac_toe_top(
    input wire clk,
    input wire reset,
    input wire up, down, left, right, check,
    output wire HS, VS,
    output wire [3:0] VGA_R, VGA_G, VGA_B,
    output wire [6:0] seg_out,
    output wire [3:0] seg_sel
);
    wire clk_25MHz;
    wire [4:0] btn_pulse;
    wire [8:0] board;
    wire [3:0] cursor;
    wire [1:0] winner;
    wire [1:0] state;
    wire en;
    wire [9:0] x, y;

    clk25_chain u_div(
     .clk(clk),
     .reset(reset), 
     .clk25(clk_25MHz)
     );

    debounce u_db(
        .clk(clk), 
        .reset(reset), 
        .btn({check, right, left, down, up}), 
        .btn_pulse(btn_pulse)
        );

    control u_fsm(
        .clk(clk), 
        .reset(reset), 
        .btn_pulse(btn_pulse), 
        .board(board), 
        .cursor(cursor), 
        .winner(winner), 
        .state(state)
        );

    vga_sync u_vga(
        .clk(clk_25MHz), 
        .reset(reset), 
        .hsync(HS), 
        .vsync(VS), 
        .en(en), 
        .x(x), 
        .y(y)
        );
    renderer u_render(
        .x(x), 
        .y(y), 
        .en(en), 
        .board(board), 
        .cursor(cursor), 
        .VGA_R(VGA_R), 
        .VGA_G(VGA_G), 
        .VGA_B(VGA_B)
        );

    sseg_display u_seg7(
        .clk(clk), 
        .reset(reset), 
        .winner(winner), 
        .seg_out(seg_out), 
        .seg_sel(seg_sel)
        );
endmodule
