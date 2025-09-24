////////////////////////////////////////////////////////////////////////////////
//
// UART RX module - Reference-based implementation
// Adapted for Nexys A7 tic-tac-toe project
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module uart_rx(
    input  wire       clk,
    input  wire       reset,
    input  wire       rx_in,
    output reg  [7:0] data_out,
    output reg        data_valid
);

parameter [23:0] CLOCKS_PER_BAUD = 24'd10417; // 100MHz / 9600

// Local parameters for states
localparam [3:0] BIT0 = 4'h0;
localparam [3:0] BIT1 = 4'h1;
localparam [3:0] BIT2 = 4'h2;
localparam [3:0] BIT3 = 4'h3;
localparam [3:0] BIT4 = 4'h4;
localparam [3:0] BIT5 = 4'h5;
localparam [3:0] BIT6 = 4'h6;
localparam [3:0] BIT7 = 4'h7;
localparam [3:0] STOP = 4'h8;
localparam [3:0] IDLE = 4'hf;

wire    [23:0]    half_baud;
reg    [3:0]    state;

assign    half_baud = { 1'b0, CLOCKS_PER_BAUD[23:1] } - 24'h1;
reg    [23:0]    baud_counter;
reg        zero_baud_counter;

// Register input to avoid metastability
reg    q_uart, qq_uart, ck_uart;
always @(posedge clk)
begin
    if (reset) begin
        q_uart  <= 1'b1;
        qq_uart <= 1'b1;
        ck_uart <= 1'b1;
    end else begin
        q_uart <= rx_in;
        qq_uart <= q_uart;
        ck_uart <= qq_uart;
    end
end

// Track clocks since last change
reg    [23:0]    chg_counter;
always @(posedge clk)
    if (reset)
        chg_counter <= 24'h00;
    else if (qq_uart != ck_uart)
        chg_counter <= 24'h00;
    else
        chg_counter <= chg_counter + 1;

// Check if we are in middle of start bit
reg    half_baud_time;
always @(posedge clk)
    if (reset)
        half_baud_time <= 1'b0;
    else
        half_baud_time <= (~ck_uart)&&(chg_counter >= half_baud);


// Baud counter (only runs when not in IDLE state)
always @(posedge clk)
    if (reset) begin
        baud_counter <= 24'h00;
        zero_baud_counter <= 1'b0;
    end else if (state != IDLE) begin
        if (zero_baud_counter)
            baud_counter <= CLOCKS_PER_BAUD - 24'h01;
        else
            baud_counter <= baud_counter - 24'h01;

        zero_baud_counter <= (baud_counter == 24'h01);
    end else begin
        baud_counter <= CLOCKS_PER_BAUD - 24'h01;
        zero_baud_counter <= 1'b0;
    end

// Main state machine
always @(posedge clk)
begin
    if (reset) begin
        state <= IDLE;
    end else begin
        if (state == IDLE)
        begin
            state <= IDLE;
            if ((~ck_uart)&&(half_baud_time))
                state <= BIT0;
        end else if (zero_baud_counter)
        begin
            if (state < STOP)
                state <= state + 1;
            else
                state <= IDLE;
        end
    end
end

// Data bit capture logic
reg    [7:0]    data_reg;
always @(posedge clk)
    if (reset)
        data_reg <= 8'h00;
    else if (zero_baud_counter)
        data_reg <= { ck_uart, data_reg[7:1] };

// Output data logic
always @(posedge clk)
    if (reset) begin
        data_valid <= 1'b0;
        data_out <= 8'h00;
    end else if ((zero_baud_counter)&&(state == STOP)) begin
        data_valid <= 1'b1;
        data_out <= data_reg;
    end else begin
        data_valid <= 1'b0;
    end

endmodule