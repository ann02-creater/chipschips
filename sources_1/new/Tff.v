`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/09 02:06:47
// Design Name: 
// Module Name: Tff
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
    
module tff (
    output reg Q,                   // 플립플롭 출력
    input en, clk, rstn, T          // T 입력 (토글 신호)
);

// 동기 리셋을 갖는 T 플립플롭의 동작
always @(posedge clk or negedge rstn) begin
    if (!rstn)          // 동기 리셋: clk의 상승 엣지에서 rstn이 0일 때 리셋
        Q <= 1;         // 리셋 시 출력 Q를 0으로 설정
    else if (en)        // Enable 신호가 활성화된 경우
        if (T)          // T 입력이 1일 때
            Q <= ~Q;    // 출력 Q 토글
end

endmodule
