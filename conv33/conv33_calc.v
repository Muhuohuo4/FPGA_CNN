module conv33_calc #(
    parameter DATA_WIDTH = 8,
    parameter MUL_WIDTH  = 16,
    parameter BIAS_WIDTH = 16,
    parameter OUT_WIDTH  = 32
)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   conv33_en,

    // 输入数据
    input  wire signed [DATA_WIDTH-1:0]  data_0_0,
    input  wire signed [DATA_WIDTH-1:0]  data_0_1,
    input  wire signed [DATA_WIDTH-1:0]  data_0_2,
    input  wire signed [DATA_WIDTH-1:0]  data_1_0,
    input  wire signed [DATA_WIDTH-1:0]  data_1_1,
    input  wire signed [DATA_WIDTH-1:0]  data_1_2,
    input  wire signed [DATA_WIDTH-1:0]  data_2_0,
    input  wire signed [DATA_WIDTH-1:0]  data_2_1,
    input  wire signed [DATA_WIDTH-1:0]  data_2_2,

    // 卷积权重
    input  wire signed [DATA_WIDTH-1:0]  weight_0,
    input  wire signed [DATA_WIDTH-1:0]  weight_1,
    input  wire signed [DATA_WIDTH-1:0]  weight_2,
    input  wire signed [DATA_WIDTH-1:0]  weight_3,
    input  wire signed [DATA_WIDTH-1:0]  weight_4,
    input  wire signed [DATA_WIDTH-1:0]  weight_5,
    input  wire signed [DATA_WIDTH-1:0]  weight_6,
    input  wire signed [DATA_WIDTH-1:0]  weight_7,
    input  wire signed [DATA_WIDTH-1:0]  weight_8,

    // 偏置 
    input  wire signed [BIAS_WIDTH-1:0] bias,

    // 输出结果
    output reg  signed [OUT_WIDTH-1:0] result,
    output reg                         valid,
    
    output wire signed [MUL_WIDTH-1:0] mul_0,
    output wire signed [MUL_WIDTH-1:0] mul_1,
    output wire signed [MUL_WIDTH-1:0] mul_2,
    output wire signed [MUL_WIDTH-1:0] mul_3,
    output wire signed [MUL_WIDTH-1:0] mul_4,
    output wire signed [MUL_WIDTH-1:0] mul_5,
    output wire signed [MUL_WIDTH-1:0] mul_6,
    output wire signed [MUL_WIDTH-1:0] mul_7,
    output wire signed [MUL_WIDTH-1:0] mul_8,
    output wire signed [MUL_WIDTH:0]   sum0,
    output wire signed [MUL_WIDTH:0]   sum1, 
    output wire signed [MUL_WIDTH:0]   sum2,
    output wire signed [MUL_WIDTH:0]   sum3,
    output wire signed [MUL_WIDTH+1:0] sum4,
    output wire signed [MUL_WIDTH+1:0] sum5
);

    // 中间乘法结果
    wire signed [MUL_WIDTH-1:0] mul [0:8];

    assign mul[0] = data_0_0 * weight_0;
    assign mul[1] = data_0_1 * weight_1;
    assign mul[2] = data_0_2 * weight_2;
    assign mul[3] = data_1_0 * weight_3;
    assign mul[4] = data_1_1 * weight_4;
    assign mul[5] = data_1_2 * weight_5;
    assign mul[6] = data_2_0 * weight_6;
    assign mul[7] = data_2_1 * weight_7;
    assign mul[8] = data_2_2 * weight_8;

    // 分级加法树（后期模块化）
    wire signed [MUL_WIDTH:0] sum_0 = mul[0] + mul[1];
    wire signed [MUL_WIDTH:0] sum_1 = mul[2] + mul[3];
    wire signed [MUL_WIDTH:0] sum_2 = mul[4] + mul[5];
    wire signed [MUL_WIDTH:0] sum_3 = mul[6] + mul[7];
    wire signed [MUL_WIDTH+1:0] sum_4 = sum_0 + sum_1;  // 0~3
    wire signed [MUL_WIDTH+1:0] sum_5 = sum_2 + sum_3;  // 4~7
    wire signed [OUT_WIDTH-1:0] conv_sum = sum_4 + sum_5 + mul[8];  // 0~8;
    
    wire signed [OUT_WIDTH-1:0] conv_sum_24_8 = conv_sum <<< 8;
    wire signed [OUT_WIDTH-1:0] bias_ext = {{16{bias[15]}}, bias};

    // 同步输出
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result <= 0;
            valid  <= 0;
        end else if (conv33_en) begin
            result <= conv_sum_24_8 + bias_ext;
            valid  <= 1;
        end else begin
            valid <= 0;
        end
    end

    assign mul_0 = mul[0];
    assign mul_1 = mul[1];
    assign mul_2 = mul[2];
    assign mul_3 = mul[3];
    assign mul_4 = mul[4];
    assign mul_5 = mul[5];
    assign mul_6 = mul[6];
    assign mul_7 = mul[7];
    assign mul_8 = mul[8];
    assign sum0= sum_0;
    assign sum1= sum_1; 
    assign sum2= sum_2;
    assign sum3= sum_3;
    assign sum4= sum_4;
    assign sum5= sum_5;

endmodule
