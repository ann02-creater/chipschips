`timescale 1ns / 1ps

module UART_top(
    input clk,
    input rst,
    input [7:0] datain_ext,
    output [7:0] dataout_ext,
    input new_in,
    output new_out,
    output error,
    input RxD,
    output TxD
    );
	 
wire new_key, IRQ, IACK, write, read, shift_ss;
wire [1:0] addr;
wire [7:0] datain, dataout, data_ss, data_key;

assign data_key[7:4] = 4'b0000;
assign data_ss[7:4] = 4'b0000;

UART CORE (
    .clk(clk),
    .rst(rst),
    .read(read),
    .write(write),
    .addr(addr),
    .RxD(RxD),  
    .IACK(IACK),
    .datain(datain),
    .dataout(dataout),
    .TxD(TxD),
    .IRQ(IRQ)
    );
	 
interface UP (
    .clk(clk), 
    .rst(rst), 
   // .baud_div_val(16'b0000_0010_1000_1011), // Found by dividing 50MHz by 9600 and 8
										  // Baud Rate dividor, set now for a rate of 9600.
    .baud_div_val(16'b0000_0101_0001_0110), //100MHZ / 9600 / 8
    .newdata_ext(new_in), 
    .din_ext(datain_ext), 
    .dout_ext(dataout_ext), 
    .newoutput_ext(new_out), 
    .uart_read(read), 
    .uart_write(write), 
    .uart_IACK(IACK), 
    .uart_IRQ(IRQ), 
    .uart_addr(addr), 
    .din_from_uart(dataout), 
    .dout_to_uart(datain), 
    .error(error)
    );



endmodule
