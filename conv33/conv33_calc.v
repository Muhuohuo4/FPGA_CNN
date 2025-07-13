module conv33_calc #(
    parameter DATA_WIDTH = 8,
    parameter MUL_WIDTH  = 16,
    parameter OUT_WIDTH  = 32
)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   start,
    output wire                   done,  
    output reg                    valid_out,
    input  wire                   ready_in,

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
    // 输出结果
    output reg  signed [OUT_WIDTH-1:0]   result
);
    // 中间乘法结果
    wire signed [MUL_WIDTH-1:0] mul [0:8];
    wire signed [MUL_WIDTH-1:0] mul_0 = data_0_0 * weight_0;
    wire signed [MUL_WIDTH-1:0] mul_1 = data_0_1 * weight_1;
    wire signed [MUL_WIDTH-1:0] mul_2 = data_0_2 * weight_2;
    wire signed [MUL_WIDTH-1:0] mul_3 = data_1_0 * weight_3;
    wire signed [MUL_WIDTH-1:0] mul_4 = data_1_1 * weight_4;
    wire signed [MUL_WIDTH-1:0] mul_5 = data_1_2 * weight_5;
    wire signed [MUL_WIDTH-1:0] mul_6 = data_2_0 * weight_6;
    wire signed [MUL_WIDTH-1:0] mul_7 = data_2_1 * weight_7;
    wire signed [MUL_WIDTH-1:0] mul_8 = data_2_2 * weight_8;

    // 分级加法树
    wire signed [MUL_WIDTH:0]   sum_0    = mul_0 + mul_1;
    wire signed [MUL_WIDTH:0]   sum_1    = mul_2 + mul_3;
    wire signed [MUL_WIDTH:0]   sum_2    = mul_4 + mul_5;
    wire signed [MUL_WIDTH:0]   sum_3    = mul_6 + mul_7;
    wire signed [MUL_WIDTH+1:0] sum_4    = sum_0 + sum_1;  // 0~3
    wire signed [MUL_WIDTH+1:0] sum_5    = sum_2 + sum_3;  // 4~7
    wire signed [OUT_WIDTH-1:0] conv_sum = sum_4 + sum_5 + mul_8;  // 0~8;

    // 同步输出
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result    <= 0;
            valid_out <= 0;
        end else if (start) begin
            result    <= conv_sum;
            valid_out <= 1;
        end else begin
            valid_out <= 0;
        end
    end
    assign done = valid_out && ready_in;

endmodule
