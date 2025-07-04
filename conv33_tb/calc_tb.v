`timescale 1ns / 1ps

module conv33_calc_tb;

    reg clk = 0;
    reg rst = 1;
    reg conv33_en = 0;

    reg signed [7:0] data_0_0 = 0, data_0_1 = 0, data_0_2 = 0;
    reg signed [7:0] data_1_0 = 0, data_1_1 = 0, data_1_2 = 0;
    reg signed [7:0] data_2_0 = 0, data_2_1 = 0, data_2_2 = 0;

    reg signed [7:0] weight_0 = 0, weight_1 = 0, weight_2 = 0;
    reg signed [7:0] weight_3 = 0, weight_4 = 0, weight_5 = 0;
    reg signed [7:0] weight_6 = 0, weight_7 = 0, weight_8 = 0;

    reg signed [15:0] bias = 0;

    wire signed [31:0] result;
    wire valid;

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
        .valid(valid)
    );

    always #5 clk = ~clk;

    initial begin
        #10 rst = 0;

        // 赋初值
        data_0_0 = 1; data_0_1 = 2; data_0_2 = 3;
        data_1_0 = 4; data_1_1 = 5; data_1_2 = 6;
        data_2_0 = 7; data_2_1 = 8; data_2_2 = 9;

        weight_0 = 1; weight_1 = 1; weight_2 = 1;
        weight_3 = 1; weight_4 = 1; weight_5 = 1;
        weight_6 = 1; weight_7 = 1; weight_8 = 1;

        bias = 0;

        #10 conv33_en = 1;
        #10 conv33_en = 0;

        #50;

        // 改变输入测试负数
        data_0_0 = -1; data_0_1 = -1; data_0_2 = -1;
        data_1_0 = -1; data_1_1 = -1; data_1_2 = -1;
        data_2_0 = -1; data_2_1 = -1; data_2_2 = -1;

        #10 conv33_en = 1;
        #10 conv33_en = 0;

        #50;

        $stop;
    end

endmodule
