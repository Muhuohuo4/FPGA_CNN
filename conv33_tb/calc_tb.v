`timescale 1ns / 1ps

module conv33_calc_tb;

    // ��������
    localparam MUL_WIDTH = 16;
    localparam OUT_WIDTH = 32;
    // ʱ�Ӹ�λ���ź�
    reg clk = 0;
    reg rst = 1;
    reg conv33_en = 0;

    // �������ݺ�Ȩ��
    reg signed [7:0] data_0_0, data_0_1, data_0_2;
    reg signed [7:0] data_1_0, data_1_1, data_1_2;
    reg signed [7:0] data_2_0, data_2_1, data_2_2;

    reg signed [7:0] weight_0, weight_1, weight_2;
    reg signed [7:0] weight_3, weight_4, weight_5;
    reg signed [7:0] weight_6, weight_7, weight_8;

    reg signed [OUT_WIDTH-1:0] bias = 0; // 偏置

    // ����ź�???
    wire signed [31:0] result;
    wire valid;

    // �����۲���м�˷�����˿�???
    wire signed [MUL_WIDTH-1:0] mul_0;
    wire signed [MUL_WIDTH-1:0] mul_1;
    wire signed [MUL_WIDTH-1:0] mul_2;
    wire signed [MUL_WIDTH-1:0] mul_3;
    wire signed [MUL_WIDTH-1:0] mul_4;
    wire signed [MUL_WIDTH-1:0] mul_5;
    wire signed [MUL_WIDTH-1:0] mul_6;
    wire signed [MUL_WIDTH-1:0] mul_7;
    wire signed [MUL_WIDTH-1:0] mul_8;
    wire signed [MUL_WIDTH:0] sum0;
    wire signed [MUL_WIDTH:0] sum1;
    wire signed [MUL_WIDTH:0] sum2;
    wire signed [MUL_WIDTH:0] sum3;
    wire signed [MUL_WIDTH+1:0] sum4;
    wire signed [MUL_WIDTH+1:0] sum5;
    wire signed [OUT_WIDTH-1:0] convsum;
    // ʵ��������ģ��
    conv33_calc uut (
        .clk(clk),
        .rst(rst),
        .conv33_en(conv33_en),

        .data_0_0(data_0_0), .data_0_1(data_0_1), .data_0_2(data_0_2),
        .data_1_0(data_1_0), .data_1_1(data_1_1), .data_1_2(data_1_2),
        .data_2_0(data_2_0), .data_2_1(data_2_1), .data_2_2(data_2_2),

        .weight_0(weight_0), .weight_1(weight_1), .weight_2(weight_2),
        .weight_3(weight_3), .weight_4(weight_4), .weight_5(weight_5),
        .weight_6(weight_6), .weight_7(weight_7), .weight_8(weight_8),

        .bias(bias),

        .result(result),
        .valid(valid),

        .mul_0(mul_0),
        .mul_1(mul_1),
        .mul_2(mul_2),
        .mul_3(mul_3),
        .mul_4(mul_4),
        .mul_5(mul_5),
        .mul_6(mul_6),
        .mul_7(mul_7),
        .mul_8(mul_8),
        .sum0(sum0),
        .sum1(sum1),
        .sum2(sum2),
        .sum3(sum3),
        .sum4(sum4),
        .sum5(sum5),
        .convsum(convsum)
    );

    // ʱ������
    always #5 clk = ~clk;

    initial begin
        // ��λ
        rst = 1;
        #20 rst = 0;

        // ��ʼ����������
        data_0_0 = 8'b00000001; // 1
        data_0_1 = 8'b00000010; // 2
        data_0_2 = 8'b00000011; // 3
        
        data_1_0 = 8'b00000100; // 4
        data_1_1 = 8'b00000101; // 5
        data_1_2 = 8'b00000110; // 6
        
        data_2_0 = 8'b00000111; // 7
        data_2_1 = 8'b00001000; // 8
        data_2_2 = 8'b00001001; // 9
        
        weight_0 = 8'b00000001; // 1
        weight_1 = 8'b00000001; // 1
        weight_2 = 8'b00000001; // 1
        
        weight_3 = 8'b00000001; // 1
        weight_4 = 8'b00000001; // 1
        weight_5 = 8'b00000001; // 1
        
        weight_6 = 8'b00000001; // 1
        weight_7 = 8'b00000001; // 1
        weight_8 = 8'b00000001; // 1


        bias = 1;

        // ʹ�ܼ���
        #10 conv33_en = 1;
        #100 conv33_en = 0;


        $stop;
    end

endmodule
