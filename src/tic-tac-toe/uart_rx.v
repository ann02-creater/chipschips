////////////////////////////////////////////////////////////////////////////////
//
// UART RX module - Reference-based implementation
// Adapted for Nexys A7 tic-tac-toe project
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

`define	RXUL_BIT_ZERO		4'h0
`define	RXUL_BIT_ONE		4'h1
`define	RXUL_BIT_TWO		4'h2
`define	RXUL_BIT_THREE		4'h3
`define	RXUL_BIT_FOUR		4'h4
`define	RXUL_BIT_FIVE		4'h5
`define	RXUL_BIT_SIX		4'h6
`define	RXUL_BIT_SEVEN		4'h7
`define	RXUL_STOP		4'h8
`define	RXUL_IDLE		4'hf

module uart_rx(
    input  wire       clk,
    input  wire       reset,
    input  wire       rx_in,
    output reg  [7:0] data_out,
    output reg        data_valid
);

parameter [23:0] CLOCKS_PER_BAUD = 24'd10417; // 100MHz / 9600

wire	[23:0]	half_baud;
reg	[3:0]	state;

assign	half_baud = { 1'b0, CLOCKS_PER_BAUD[23:1] } - 24'h1;
reg	[23:0]	baud_counter;
reg		zero_baud_counter;

// Register input to avoid metastability
reg	q_uart, qq_uart, ck_uart;
initial	q_uart  = 1'b0;
initial	qq_uart = 1'b0;
initial	ck_uart = 1'b0;
always @(posedge clk)
begin
    q_uart <= rx_in;
    qq_uart <= q_uart;
    ck_uart <= qq_uart;
end

// Track clocks since last change
reg	[23:0]	chg_counter;
initial	chg_counter = 24'h00;
always @(posedge clk)
    if (qq_uart != ck_uart)
        chg_counter <= 24'h00;
    else
        chg_counter <= chg_counter + 1;

// Check if we are in middle of start bit
reg	half_baud_time;
initial	half_baud_time = 0;
always @(posedge clk)
    half_baud_time <= (~ck_uart)&&(chg_counter >= half_baud);

initial	state = `RXUL_IDLE;
initial	data_valid = 1'b0;
initial	data_out = 8'h00;
initial	baud_counter = 24'h00;
initial	zero_baud_counter = 1'b0;

// Baud counter (only runs when not in IDLE state)
always @(posedge clk)
    if (reset) begin
        baud_counter <= 24'h00;
        zero_baud_counter <= 1'b0;
    end else if (state != `RXUL_IDLE) begin
        if (zero_baud_counter)
            baud_counter <= CLOCKS_PER_BAUD - 24'h01;
        else
            baud_counter <= baud_counter - 24'h01;
            
        zero_baud_counter <= (baud_counter == 24'h01);
    end else begin
        // IDLE 상태에서는 보드레이트 카운터 정지
        baud_counter <= CLOCKS_PER_BAUD - 24'h01;
        zero_baud_counter <= 1'b0;
    end

// Main state machine
always @(posedge clk)
begin
    if (reset) begin
        state <= `RXUL_IDLE;
    end else begin
        if (state == `RXUL_IDLE)
        begin
            state <= `RXUL_IDLE;
            if ((~ck_uart)&&(half_baud_time))
                state <= `RXUL_BIT_ZERO;
        end else if (zero_baud_counter)
        begin
            if (state < `RXUL_STOP)
                state <= state + 1;
            else
                state <= `RXUL_IDLE;
        end
    end
end

// Data bit capture logic
reg	[7:0]	data_reg;
always @(posedge clk)
    if (zero_baud_counter)
        data_reg <= { ck_uart, data_reg[7:1] };

// Output data logic
always @(posedge clk)
    if (reset) begin
        data_valid <= 1'b0;
        data_out <= 8'h00;
    end else if ((zero_baud_counter)&&(state == `RXUL_STOP)) begin
        data_valid <= 1'b1;
        data_out <= data_reg;
    end else begin
        data_valid <= 1'b0;
    end

endmodule