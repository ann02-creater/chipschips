module vga_top (
    input  wire       clk25,
    input  wire       reset,
    input  wire [17:0] sw,
    input  wire [8:0] cell_select_flag,
    output wire       VGA_HS,
    output wire       VGA_VS,
    output wire [3:0] VGA_R,
    output wire [3:0] VGA_G,
    output wire [3:0] VGA_B
);

    // Internal signals
    wire [9:0] x, y;
    wire en;
    
    // VGA sync generator
    vga_sync u_vga_sync (
        .clk(clk25),
        .reset(reset),
        .x(x),
        .y(y),
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .en(en)
    );
    
    // VGA graphics generator
    vga_graphics u_vga_graphics (
        .clk(clk25),
        .reset(reset),
        .x(x),
        .y(y),
        .en(en),
        .sw(sw),
        .cell_select_flag(cell_select_flag),
        .red(VGA_R),
        .green(VGA_G),
        .blue(VGA_B)
    );

endmodule