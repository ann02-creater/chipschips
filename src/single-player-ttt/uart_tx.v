////////////////////////////////////////////////////////////////////////////////
//
// UART TX module - Reference-based implementation
// Adapted for Nexys A7 tic-tac-toe project
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

`define	TXUL_BIT_ZERO	4'h0
`define	TXUL_BIT_ONE	4'h1
`define	TXUL_BIT_TWO	4'h2
`define	TXUL_BIT_THREE	4'h3
`define	TXUL_BIT_FOUR	4'h4
`define	TXUL_BIT_FIVE	4'h5
`define	TXUL_BIT_SIX	4'h6
`define	TXUL_BIT_SEVEN	4'h7
`define	TXUL_STOP	4'h8
`define	TXUL_IDLE	4'hf

module uart_tx(
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] data_in,
    input  wire       send,
    output reg        tx_out,
    output wire       busy
);

parameter [23:0] CLOCKS_PER_BAUD = 24'd10417; // 100MHz / 9600

reg	[23:0]	baud_counter;
reg	[3:0]	state;
reg	[7:0]	lcl_data;
reg		r_busy, zero_baud_counter;

initial	r_busy = 1'b1;
initial	state  = `TXUL_IDLE;
initial tx_out = 1'b1;

always @(posedge clk)
begin
    if (reset) begin
        r_busy <= 1'b1;
        state <= `TXUL_IDLE;
        tx_out <= 1'b1;
    end else begin
        if (!zero_baud_counter)
            r_busy <= 1'b1;
        else if (state == `TXUL_IDLE)
        begin
            r_busy <= 1'b0;
            tx_out <= 1'b1;  // IDLE 상태에서 high
            if ((send)&&(!r_busy))
            begin
                r_busy <= 1'b1;
                state <= `TXUL_BIT_ZERO;
            end
        end else begin
            r_busy <= 1'b1;
            if (state <= `TXUL_STOP)
                state <= state + 1;
            else
                state <= `TXUL_IDLE;
                
            // UART 데이터 출력 로직을 여기로 이동
            if (zero_baud_counter)
            begin
                if (state == `TXUL_BIT_ZERO)
                    tx_out <= 1'b0;  // Start bit
                else if (state == `TXUL_STOP)
                    tx_out <= 1'b1;  // Stop bit
                else
                    tx_out <= lcl_data[0];  // Data bits
            end
        end 
    end
end

assign	busy = r_busy;

// Working copy of data register
always @(posedge clk)
    if (reset)
        lcl_data <= 8'hff;
    else if ((send)&&(!busy))
        lcl_data <= data_in;
    else if (zero_baud_counter)
        lcl_data <= { 1'b1, lcl_data[7:1] };

// Baud counter
always @(posedge clk)
    if (reset)
        baud_counter <= 24'h00;
    else if (zero_baud_counter)
        baud_counter <= CLOCKS_PER_BAUD - 24'h01;
    else
        baud_counter <= baud_counter - 24'h01;

always @(posedge clk)
    if (reset)
        zero_baud_counter <= 1'b0;
    else
        zero_baud_counter <= (baud_counter == 24'h01);

// 중복된 tx_out 할당 블록 제거

endmodule