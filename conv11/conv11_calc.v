module conv11_calc #(
    parameter DATA_WIDTH = 8,
    parameter MUL_WIDTH  = 16,
    parameter BIAS_WIDTH = 32,
    parameter OUT_WIDTH  = 32
)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   conv11_en,
    // 输入数据
    input  wire signed [DATA_WIDTH-1:0]  data_0_0,
    // 卷积权重
    input  wire signed [DATA_WIDTH-1:0]  weight_0,
    // 偏置
    input  wire signed [BIAS_WIDTH-1:0]  bias,
    // 缩放系数
    input  wire signed [BIAS_WIDTH-1:0]  scale,
    // 输出结果
    output reg  signed [DATA_WIDTH-1:0]  result,
    output reg                           valid
);
    wire signed [MUL_WIDTH-1:0] mul = data_0_0 * weight_0;
    wire signed [OUT_WIDTH-1:0] result_bias = mul + bias;
    wire signed [OUT_WIDTH-1:0] result_scale = result_bias * scale;
    wire signed [DATA_WIDTH-1:0] result_8 = result_scale[23:16];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result <= 0;
            valid  <= 0;
        end else if (conv11_en) begin
            result <= result_8[DATA_WIDTH-1] ? 0 : result_8;
            valid  <= 1;
        end else begin
            valid <= 0;
        end
    end

endmodule
