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
    output reg Q,                   // �ø��÷� ���
    input en, clk, rstn, T          // T �Է� (��� ��ȣ)
);

// ���� ������ ���� T �ø��÷��� ����
always @(posedge clk or negedge rstn) begin
    if (!rstn)          // ���� ����: clk�� ��� �������� rstn�� 0�� �� ����
        Q <= 1;         // ���� �� ��� Q�� 0���� ����
    else if (en)        // Enable ��ȣ�� Ȱ��ȭ�� ���
        if (T)          // T �Է��� 1�� ��
            Q <= ~Q;    // ��� Q ���
end

endmodule
