`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:11:35 12/08/2014
// Design Name:   UART_example
// Module Name:   D:/Workspace/DSD/14.12.08 UART/UART_ver1/tb_UART.v
// Project Name:  UART_ver1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: UART_example
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_UART;

	// Inputs
	reg clk;
	reg rst;
	reg RxD;
	reg [7:0] test_TxD;
    reg new_in;

	// Outputs
	
	wire error;
    wire TxD;
    wire new_out;
	// Instantiate the Unit Under Test (UUT)
UART_top a1 (
        .clk(clk), 
        .rst(rst), 
        .datain_ext(test_TxD), 
        .dataout_ext(), 
        .new_in(new_in), 
        .new_out(new_out), 
        .error(error), 
        .RxD(RxD), 
        .TxD(TxD)
        );


    always #1 clk = ~ clk;

    
    
	initial begin
		// Initialize Inputs

		clk = 0;
		rst = 1;
		RxD = 1;
		test_TxD = 0;
		new_in = 1'b0;


		// Wait 100 ns for global reset to finish
		#100 rst = 0;
		#100 test_TxD = 'd31; new_in = 1'b1;
		#100 new_in = 1'b0;
		
		#2000 test_TxD = 'd65; new_in = 1'b1;
        #100 new_in = 1'b0;

		#50000 
		
      
		// Add stimulus here
        
	end
      
endmodule

