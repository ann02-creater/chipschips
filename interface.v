`timescale 1ns / 1ps

`define TE status[7]
`define RF status[6]
`define FE status[5]
`define OVE status[4]
`define PE status[3]

module interface(
    input clk,
    input rst,
    input [15:0] baud_div_val,
	/* interface with external IO */
    input newdata_ext,
    input [7:0] din_ext, // extin->interface
    output reg [7:0] dout_ext, // interface -> extout
    output reg newoutput_ext,
	/* interface with UART */ 
    output reg uart_read,
    output reg uart_write,
    output reg uart_IACK,
    input uart_IRQ,
    output reg [1:0] uart_addr,
    input [7:0] din_from_uart, // UART->interface
    output [7:0] dout_to_uart, // interface->UART
    output reg error
    );
	 
reg [7:0] status; // status = { TE, RF, RE, OVE, PE, 3'b000 }
reg write_data_to_uart, new_input_arrived, set_error;
reg read_data, read_status, read_data_delayed_command, read_status_delayed_command;
reg [7:0] ctrl_data, data_buf;

reg [2:0] curr_st, nx_st;
localparam INIT = 3'b000, INIT_2 = 3'b001, INIT_3 = 3'b010, READY = 3'b011, 
			  CHECK_STATUS = 3'b100, CHECK_2 = 3'b101, CHECK_3 = 3'b110, CHECK_4 = 3'b111;

	 
always @(posedge clk, posedge rst)
	if (rst == 'b1)
		curr_st <= INIT;
	else
		curr_st <= nx_st;

assign dout_to_uart = ((curr_st == INIT) || (curr_st == INIT_2) || (curr_st == INIT_3))? ctrl_data : data_buf;

always @(curr_st,uart_IRQ, new_input_arrived, status)
	begin
	uart_write = 'b0;
    uart_read = 'b0;
    uart_IACK = 'b0;
    uart_addr = 2'b00;
    write_data_to_uart = 'b0;
    read_data = 'b0;
    read_status = 'b0;
    ctrl_data = 'b0;
    set_error = 'b0;
	case (curr_st)
		INIT :
			begin
			uart_write = 'b1;
			uart_addr = 2'b00;
			ctrl_data = 8'b01100000; // Receive interrupt enable (control flags)
			nx_st = INIT_2;
			end
		INIT_2 :
			begin
			uart_write = 'b1;
			uart_addr = 2'b10;
			ctrl_data = baud_div_val[7:0]; // load scale LSB
			nx_st = INIT_3;
			end
		INIT_3 :
			begin
			uart_write = 'b1;
			uart_addr = 2'b11;
			ctrl_data = baud_div_val[15:8]; // load scale MSB
			nx_st = READY;
			end
		READY :
			begin
			nx_st = READY;
			if (uart_IRQ == 'b1)
				nx_st = CHECK_STATUS;
			else if (new_input_arrived == 'b1)
				begin
				write_data_to_uart = 'b1;
				uart_write = 'b1;
				uart_addr = 2'b01;
				end
			end
		CHECK_STATUS : // read status register and check status
			begin
			uart_read = 'b1;
			uart_addr = 2'b00;
			read_status = 'b1;
			nx_st = CHECK_2;
			end
      // Delay State : 1 clock period delay 
      // to synch read operation of status flags from UART
		CHECK_2 : nx_st = CHECK_3;
		CHECK_3 :
			begin
			nx_st = CHECK_4;
			uart_IACK = 'b1;
			if (`RF == 'b1) // data ready in RBR
				begin
				uart_read = 'b1;
				uart_addr = 2'b01;
				read_data = 'b1;
				end
			else if ((`TE == 'b1) && (new_input_arrived == 'b1)) // no data in TBR & data for transmit is ready
				begin
				write_data_to_uart = 'b1;
				uart_write = 'b1;
				uart_addr = 2'b01;
				end
			
			//if ((`PE == 'b1) || (`OVE == 'b1) || (`FE == 'b1)) // error detect
			//	set_error <= 'b1;
			end
		CHECK_4 :
			if (uart_IRQ == 'b0)
				begin
				uart_IACK = 'b0;
				nx_st = READY;
				end
			else
				nx_st = CHECK_4;
		default : nx_st = READY;
	endcase
	end

always @(posedge clk)
	begin
	read_status_delayed_command <= read_status;
    read_data_delayed_command <= read_data;
	end
	
always @(posedge clk, posedge rst)
	if (rst == 'b1)
		status <= 'b0;
	else if (read_status_delayed_command == 'b1)
		status <= din_from_uart;

always @(posedge clk, posedge rst)
	if (rst == 'b1)
		begin
		dout_ext <= 'b0;
		newoutput_ext <= 'b0;
		end
	else if (read_data_delayed_command == 'b1)
		begin
		dout_ext <= din_from_uart;
		newoutput_ext <= 'b1;
		end
	else
		newoutput_ext <= 'b0;
		
always @(posedge clk, posedge rst)
	if (rst)
		begin
		data_buf <= 'b0;
		new_input_arrived <= 'b0;
		end
	else if (newdata_ext == 'b1)
		begin
		data_buf <= din_ext;
		new_input_arrived <= 'b1;
		end
	else if (write_data_to_uart == 'b1)
		new_input_arrived <= 'b0;
		
always @(posedge clk, posedge rst)
	if (rst == 'b1)
		error <= 'b0;
	else if (set_error == 'b1)
		error <= 'b1;

endmodule
