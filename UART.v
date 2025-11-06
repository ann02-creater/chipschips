`define TBRE status_flags[7] // status: TBR Empty
`define RBRF status_flags[6] // RBR Full
`define FE status_flags[5] // Frame Error
`define OE status_flags[4] // Overrun Error
`define PE status_flags[3] // Parity Error
`define TC status_flags[2] // transmit complete
`define status_unused status_flags[1:0] // unused status bits

`define TIE control_flags[7] // control: interrup enable
`define RIE control_flags[6] // control: interrup enable
`define PRT control_flags[5] // control: parity control (0:even, 1: odd)


module UART(
    input clk,
    input rst,
    input read,
    input write,
    input [1:0] addr,
    input RxD,
    input IACK,
    input [7:0] datain,
    output reg [7:0] dataout,
    output TxD,
    output reg IRQ
    );
	 
wire RxEn, TxEn;
wire setRBRF,  setOE, setFE, setTBRE, setTC, setPE;
reg write_TBR, read_RBR, ld_control, read_status, scale_high_ld, scale_low_ld;
wire [7:0] RBR;

localparam ADDR_CTRL_STAT = 2'b00, ADDR_DATA_BUF = 2'b01, ADDR_SCALE_LSB = 2'b10, ADDR_SCALE_MSB = 2'b11;

reg [7:0] status_flags, control_flags;
wire transmit_int, receive_int;
reg RxD_d, RxD_dd;

clkgen CLK (
    .clk(clk), 
    .rst(rst), 
    .scale_high_ld(scale_high_ld), 
    .scale_low_ld(scale_low_ld), 
    .scale_val(datain), 
    .RxEn(RxEn), 
    .TxEn(TxEn)
    );
	 
receiver RX (
    .clk(clk), 
    .rst(rst), 
    .RxEn(RxEn), 
    .RxD(RxD_dd), 
    .RBRF(`RBRF), 
    .PRT(`PRT), 
    .RBR(RBR), 
    .setRBRF(setRBRF), 
    .setOE(setOE), 
    .setFE(setFE), 
    .setPE(setPE)
    );
	 
transmit TX (
    .clk(clk), 
    .rst(rst), 
    .TxEn(TxEn), 
    .TBRE(`TBRE), 
    .PRT(`PRT), 
    .ld_tbr(write_TBR), 
    .datain(datain), 
    .setTBRE(setTBRE), 
    .setTC(setTC), 
    .TxD(TxD)
    );
	 
always @(posedge clk, posedge rst)
	if (rst == 'b1)
		begin
		RxD_d <= 'b1;
		RxD_dd <= 'b1;
		end
	else if (RxEn == 'b1)
		begin
		RxD_d <= RxD;
		RxD_dd <= RxD_d;
		end
	
always @(addr, read, write)
	begin
	scale_low_ld = 'b0; 
    scale_high_ld = 'b0;
    write_TBR = 'b0;
    ld_control = 'b0;
    read_RBR = 'b0;
    read_status = 'b0;
	if (write == 'b1)
		case (addr)
			ADDR_CTRL_STAT : ld_control = 'b1;
			ADDR_DATA_BUF : write_TBR = 'b1;
			ADDR_SCALE_LSB : scale_low_ld = 'b1;
			ADDR_SCALE_MSB : scale_high_ld = 'b1;
			default : ;
		endcase
		
	if (read == 'b1)
		case (addr)
			ADDR_CTRL_STAT : read_status = 'b1;
			ADDR_DATA_BUF : read_RBR = 'b1;
			default : ;
		endcase
	end
	
always @(posedge clk, posedge rst)
	if (rst == 'b1)
		dataout <= 'bz;
	else if (read_RBR == 'b1)
		dataout <= RBR;
	else if (read_status == 'b1)
		dataout <= status_flags;

always @(posedge clk, posedge rst)
	if (rst)
		control_flags <= 'b0;
	else if (ld_control == 'b1)
		control_flags <= datain;
		
always @(posedge clk, posedge rst)
	if (rst == 'b1)
		begin
		`TBRE = 'b1; // TBRE
        `RBRF = 'b0; // RBRF
		`FE = 'b0; // FE
		`OE = 'b0; // OE
		`PE = 'b0; // PE
        `TC = 'b0; // TC
		`status_unused = 2'b00; // status_unused
		end
	else
		begin
		if (setTBRE == 'b1)
			`TBRE = 'b1;
		else if (write_TBR == 'b1)
			`TBRE = 'b0;
		
		if (setRBRF == 'b1)
			`RBRF = 'b1;
		else if (read_RBR == 'b1)
			`RBRF  = 'b0;
			
		if (setFE == 'b1)
            `FE = 'b1;
         else if (read_status == 'b1)
            `FE = 'b0;
			
		if (setOE == 'b1)
            `OE = 'b1;
        else if (read_status == 'b1)
            `OE = 'b0;
			
		if (setPE == 'b1)
            `PE = 'b1;
        else if (read_status == 'b1)
            `PE = 'b0;
		
		if (setTC == 'b1)
            `TC  = 'b1;
      else if (read_status == 'b1)
            `TC = 'b0;			
		end
		
assign transmit_int = `TIE & `TBRE; // TIE and TBRE
assign receive_int = `RIE & `RBRF; // RIE and RBRF

 
always @(posedge clk, posedge rst)
	if (rst)
		IRQ <= 'b0;
	else if ((IACK == 'b1) && (IRQ == 'b1))
		IRQ <= 'b0;
	else if ((transmit_int == 'b1) || (receive_int == 'b1))
		IRQ <= 'b1;

endmodule

