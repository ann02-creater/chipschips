`timescale 1ns / 1ps
//`default_nettype none

module receiver(
    input clk,
    input rst,
    input RxEn,
    input RxD,
    input RBRF,
    input PRT,
    output [7:0] RBR,
    output reg setRBRF,
    output reg setOE,
    output reg setFE,
    output reg setPE
    );

reg [8:0] RBReg; // recieve buffer
reg [8:0] RSR; // receive shift register
reg [3:0] BitCnt;
reg [2:0] SampleCnt;

reg [2:0] curr_st, nx_st;
localparam IDLE = 3'b000, START_DETECT = 3'b001, SKIP_INT = 3'b010, GET_BIT = 3'b011, STOP_BIT = 3'b100;

reg clr_SampleCnt, inc_SampleCnt, clr_BitCnt, inc_BitCnt;
wire Sample_6, Sample_3, BitCnt_9;
wire detect_falling_edge;
reg shift_RSR, ld_RBR, RxD_delayed;
wire parity;

assign RBR = RBReg[7:0]; // RBReg[8] is parity bit
assign parity = RSR[8] ^ RSR[7] ^ RSR[6] ^ RSR[5] ^ RSR[4] ^ RSR[3] ^ RSR[2] ^ RSR[1] ^ RSR[0];

always @(posedge clk, posedge rst)
	if (rst == 'b1)
		RxD_delayed <= 'b0;
	else if (RxEn == 'b1)
		RxD_delayed <= RxD;

assign detect_falling_edge = (!RxD) & RxD_delayed; // start bit check

always @(posedge clk, posedge rst)
	if (rst == 'b1)
		curr_st <= IDLE;
	else 
		curr_st <= nx_st;

always @(RxD, RxEn, Sample_6, Sample_3, BitCnt_9, curr_st, RBRF, detect_falling_edge, parity, PRT )
	begin
	clr_SampleCnt = 'b0;
    inc_SampleCnt = 'b0;
    clr_BitCnt = 'b0;
    inc_BitCnt = 'b0;
    ld_RBR = 'b0;
    shift_RSR = 'b0;
    setFE = 'b0;
    setOE = 'b0;
    setRBRF = 'b0;
    setPE = 'b0;
	case (curr_st)
		IDLE : 
			begin
			nx_st = IDLE;
			if (detect_falling_edge == 'b1)
				begin
				nx_st = START_DETECT;
				clr_SampleCnt = 'b1;
				clr_BitCnt = 'b1;
				end
			end
		START_DETECT :
			begin
			nx_st = START_DETECT;
			if (RxEn == 'b1)
				begin
				inc_SampleCnt = 'b1;
				if (RxD == 'b1) // NOISE
					nx_st = IDLE;
				else if (Sample_3 == 'b1)
					nx_st = SKIP_INT;
				end
			end
		SKIP_INT :
			begin
			nx_st = SKIP_INT;
			if (RxEn == 'b1)
				begin
				inc_SampleCnt = 'b1;
				if (Sample_3 == 'b1)
					nx_st = GET_BIT;
				end
			end
		GET_BIT :
			begin
			nx_st = GET_BIT;
			if (RxEn == 'b1)
				begin
				inc_BitCnt = 'b1;
				inc_SampleCnt = 'b1;
				if (BitCnt_9 == 'b1)
					begin
					nx_st = STOP_BIT;
					clr_BitCnt = 'b1;
					end
				else
					begin
					shift_RSR = 'b1;
					nx_st = SKIP_INT;
					end
				end
			end
		STOP_BIT :
			begin
			nx_st = STOP_BIT;
			if (RxEn == 'b1)
				begin
				nx_st = IDLE;
				if (RxD == 'b0)
					setFE = 'b1;
				else if  (RBRF == 'b1)
					setOE = 'b1;
				else if (parity != PRT)
					setPE = 'b1;
				else
					begin
					ld_RBR = 'b1;
					setRBRF = 'b1;
					end
				end
			end
		default : nx_st = IDLE;
	endcase
	end

always @(posedge clk, posedge rst)
	if (rst == 'b1)
		begin
		BitCnt <= 'b0;
		SampleCnt <= 'b0;
		end
	else
		begin
		if (clr_BitCnt == 'b1)
			BitCnt <= 'b0;
		else if (inc_BitCnt == 'b1)
			BitCnt <= BitCnt + 1;
			
		if (clr_SampleCnt == 'b1)
			SampleCnt <= 'b0;
		else if (inc_SampleCnt == 'b1)
			SampleCnt <= SampleCnt + 1;
		end
	
assign Sample_3 = (SampleCnt == 'd3)? 'b1 : 'b0;
assign Sample_6 = (SampleCnt == 'd6)? 'b1 : 'b0;
assign BitCnt_9 = (BitCnt == 'd9)? 'b1 : 'b0;

always @(posedge clk, posedge rst)
	if (rst == 'b1)
		begin
		RSR <= 'b0;
		RBReg <= 'b0;
		end
	else
		begin
		if (ld_RBR == 'b1)
			RBReg <= RSR;
		
		if (shift_RSR == 'b1)
			RSR <= {RxD, RSR[8:1]};
		end
		
endmodule
