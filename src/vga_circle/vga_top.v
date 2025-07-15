module vga_top (
    input  wire       clk,
    input  wire       reset,
    input  wire [0:0] switches,
    output wire       VGA_HS,
    output wire       VGA_VS,
    output wire [3:0] VGA_R,
    output wire [3:0] VGA_G,
    output wire [3:0] VGA_B
);

    wire clk25;
    clk25 u_clk25 (
        .clk   (clk),
        .reset (reset),
        .clk25 (clk25)
    );

    wire [9:0] x;
    wire [9:0] y;
    wire       en;
    vga_sync u_sync (
        .clk      (clk25),
        .reset    (reset),
        .x        (x),
        .y        (y),
        .hsync    (VGA_HS),
        .vsync    (VGA_VS),
        .en       (en)
    );

    // BRAM signals
    wire [18:0] rom_addr;
    wire [11:0] rom_data;

    // Graphics and Image color signals
    wire [3:0] graphics_r, graphics_g, graphics_b;
    wire [3:0] image_r, image_g, image_b;

    // Calculate BRAM address from x, y coordinates
    assign rom_addr = (en) ? (y * 640) + x : 0;

    // Instantiate the Block Memory Generator IP (replace blk_mem_gen_0 if the name is different)
    blk_mem_gen_0 u_image_rom (
        .clka  (clk25),
        .addra (rom_addr),
        .douta (rom_data)
    );

    // Instantiate the procedural graphics generator
    vga_graphics u_grp (
        .x(x), .y(y), .en(en), .sw(switches[0]),
        .red(graphics_r), .green(graphics_g), .blue(graphics_b)
    );

    // Split 12-bit BRAM data into R, G, B
    assign image_r = rom_data[11:8];
    assign image_g = rom_data[7:4];
    assign image_b = rom_data[3:0];

    // MUX to select between image from BRAM or procedural graphics
    assign VGA_R = switches[0] ? image_r : graphics_r;
    assign VGA_G = switches[0] ? image_g : graphics_g;
    assign VGA_B = switches[0] ? image_b : graphics_b;

endmodule

