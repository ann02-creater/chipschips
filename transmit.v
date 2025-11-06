`timescale 1ns / 1ps
//`default_nettype none

module transmit(
    input clk,
    input rst,
	 input TxEn,
    input TBRE,
    input PRT,
    input ld_tbr,
    input [7:0] datain,
    output reg setTBRE,
    output reg setTC,
    output TxD
    );
	 
reg [3:0] BitCnt;
reg [7:0] TBR;
reg [10:0] TSR;
reg inc_BitCnt, clr_BitCnt;
wire BitCnt_fin;
reg shift_tsr, ld_tsr, parity;
reg [1:0] curr_st, nx_st;

localparam IDLE = 2'b00, SENDING = 2'b01, LAST = 2'b10;
	 
assign TxD = TSR[0];
	 
always @(posedge clk, posedge rst)
	if (rst == 'b1)
		TSR <= 11'b11111111111;
	else if (ld_tsr == 'b1)
		TSR <= {parity, TBR, 2'b01};
	else if (shift_tsr == 'b1)
		TSR <= {1'b1, TSR[10:1]};

always @(posedge clk, posedge rst)
	if (rst == 'b1)
		begin
		parity <= 'b0;
		TBR <= 8'b11111111;
		end
	else if ((ld_tbr == 'b1) && (TBRE == 'b1))	
		begin
		TBR <= datain;
		parity <= datain[0] ^ datain[1] ^ datain[2] ^ datain[3] ^ datain[4] ^ datain[5] ^ datain[6] ^ datain[7] ^ PRT;
		end
		
always @(posedge clk, posedge rst)
	if (rst == 'b1)
		curr_st <= IDLE;
	else
		curr_st <= nx_st;

always @(*)
	begin
   ld_tsr <= 'b0;
   clr_BitCnt <= 'b0;
   setTBRE <= 'b0;
   shift_tsr <= 'b0;
   setTC <= 'b0;
   inc_BitCnt <= 'b0;
	case (curr_st)
		IDLE :
			begin
			if (TBRE == 'b0)
				begin
				nx_st <= SENDING;
				ld_tsr <= 'b1;
				clr_BitCnt <= 'b1;
				setTBRE <= 'b1;
				end
			else
				nx_st <= IDLE;
			end
		SENDING :
			begin
			nx_st <= SENDING;
			if(TxEn == 'b1)
				begin
				shift_tsr <= 'b1;
				if (BitCnt_fin == 'b1)
					nx_st <= LAST;
				else 
					inc_BitCnt <= 'b1;
				end
			end
		LAST :
			begin
			nx_st <= IDLE;
			setTC <= 'b1;
			end
		default : nx_st <= IDLE;
	endcase
	end
				
always @(posedge clk, posedge rst)
	if (rst == 'b1)
		BitCnt <= 'b0;
	else if (clr_BitCnt == 'b1)
		BitCnt <= 'b0;
	else if (inc_BitCnt == 'b1)
		BitCnt <= BitCnt + 1;

assign BitCnt_fin = (BitCnt == 'd11)? 'b1 : 'b0;
			
endmodule
