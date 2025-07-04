module stop_watch_top(
    input  wire clk, reset,
    input  wire [3:0] ADDR,
    input  wire pause, store, load,                 
    output wire [6:0] SEG,
    output reg [7:0] AN
);

    // declaration
    wire cnt_en;
    wire write, select;
    wire tc_cnt, tc_led;
    wire [31:0] watch_data, mem_data, mux_data;


    // module interconnection
    debounce U_DEBOUNCE (
        .clk(clk),
        .reset(reset),
        .btn(pause),
        .cnt_en(cnt_en)
    );

    control U_CTRL (
        .clk(clk),
        .reset(reset),
        .en(cnt_en),
        .store(store),
        .load(load),
        .write(write),
        .select(select)
    );
    
    clock_divider U_CLKDIV (
        .clk(clk),
        .reset(reset),
        .en(cnt_en),
        .tc_cnt(tc_cnt),
        .tc_led(tc_led)
    );
    
    // TODO
    watch_counter U_WATCH (
        .clk(clk),
        .reset(reset),
        .tc_cnt(tc_cnt),
        .data(watch_data) // 32-bit
    );
    
    blk_mem_gen_0 U_MEM (
      .clka(clk),       // input wire clka
      .rsta(reset),     // input wire rsta
      .ena(1'b1),       // input wire ena
      .wea(write),      // input wire [0 : 0] wea
      .addra(ADDR),     // input wire [3 : 0] addra
      .dina(watch_data),    // input wire [31 : 0] dina
      .douta(mem_data),     // output wire [31 : 0] douta
      .rsta_busy()      // ignore
    );
    
    // TODO
    mux_32bit U_MUX (
        .a(watch_data),
        .b(mem_data),
        .sel(select),
        .y(mux_data)
    );
    
    // TODO
    sseg_control U_SSEG (
        .clk(clk),
        .reset(reset),
        .data(mux_data), // 32-bit
        .tc_led(tc_led),
        .seg(SEG), // 7-bit
        .AN(AN) // 8-bit
    );
    
endmodule
