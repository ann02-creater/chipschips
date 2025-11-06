`timescale 1ns / 1ps
//`default_nettype none

module clkgen(
    input clk,
    input rst,
    input scale_high_ld,
    input scale_low_ld,
    input [7:0] scale_val,
    output RxEn,
    output TxEn
    );
	 
reg [15:0] scale_cnt_rx;
reg [2:0] scale_cnt_tx;
reg [15:0] scale_terminal_val;
wire rx_fin, tx_fin;

always @(posedge clk, posedge rst)
	if (rst == 'b1)
		scale_terminal_val <= 16'b0000000000000001;
	else if (scale_high_ld == 'b1)
		scale_terminal_val[15:8] <= scale_val; // scale_terminal_val[15:8] = scale_terminal_high
	else if (scale_low_ld == 'b1)
		scale_terminal_val[7:0] <= scale_val; // scale_terminal_val[7:0] = scale_terminal_low

always @(posedge clk, posedge rst)
	if (rst == 'b1)
		scale_cnt_rx <= 'b0;
	else
		begin
		scale_cnt_rx <= scale_cnt_rx + 1;
		if (rx_fin == 'b1)
			scale_cnt_rx <= 'b0;
		end
		
assign rx_fin = (scale_cnt_rx == scale_terminal_val)? 'b1 : 'b0;

always @(posedge clk, posedge rst)
	if (rst == 'b1)
		scale_cnt_tx <= 'b0;
	else if (rx_fin == 'b1)
		begin
		scale_cnt_tx <=  scale_cnt_tx + 1;
		if (tx_fin == 'b1)
		
			scale_cnt_tx <= 'b0;
		end

assign tx_fin = (scale_cnt_tx == 3'b111)? 'b1 : 'b0;

assign TxEn = tx_fin & rx_fin;
assign RxEn = rx_fin;
		

endmodule
