module conv11_input #(
    parameter DATA_WIDTH = 8
)(
    input  wire                 clk,
    input  wire                 rst,
    input  wire                 start,
    output wire                 done,           // 输出完成信号
    // 来自滑窗的数据输入
    input  wire                 valid_in,
    output wire                 ready_out,

    input  wire [DATA_WIDTH-1:0] in_0_0,
    input  wire [DATA_WIDTH-1:0] in_0_1,
    input  wire [DATA_WIDTH-1:0] in_0_2,
    input  wire [DATA_WIDTH-1:0] in_1_0,
    input  wire [DATA_WIDTH-1:0] in_1_1,
    input  wire [DATA_WIDTH-1:0] in_1_2,
    input  wire [DATA_WIDTH-1:0] in_2_0,
    input  wire [DATA_WIDTH-1:0] in_2_1,
    input  wire [DATA_WIDTH-1:0] in_2_2,

    // 输出给卷积计算模块
    output wire [DATA_WIDTH-1:0] out_0_0,
    output wire [DATA_WIDTH-1:0] out_0_1,
    output wire [DATA_WIDTH-1:0] out_0_2,
    output wire [DATA_WIDTH-1:0] out_1_0,
    output wire [DATA_WIDTH-1:0] out_1_1,
    output wire [DATA_WIDTH-1:0] out_1_2,
    output wire [DATA_WIDTH-1:0] out_2_0,
    output wire [DATA_WIDTH-1:0] out_2_1,
    output wire [DATA_WIDTH-1:0] out_2_2
);

    // 数据缓存模块实例化
    conv33_input_buffer u_input_buffer (
        .clk            (clk),
        .rst            (rst),
        .start          (start),
        .valid_in       (valid_in),
        .ready_out      (ready_out),
        .in_0_0         (in_0_0), 
        .in_0_1         (in_0_1), 
        .in_0_2         (in_0_2),
        .in_1_0         (in_1_0), 
        .in_1_1         (in_1_1), 
        .in_1_2         (in_1_2),
        .in_2_0         (in_2_0), 
        .in_2_1         (in_2_1), 
        .in_2_2         (in_2_2),
        .out_0_0        (out_0_0), 
        .out_0_1        (out_0_1), 
        .out_0_2        (out_0_2),
        .out_1_0        (out_1_0),
        .out_1_1        (out_1_1),
        .out_1_2        (out_1_2),
        .out_2_0        (out_2_0), 
        .out_2_1        (out_2_1), 
        .out_2_2        (out_2_2)
    );

    // 控制模块实例化
    conv33_input_ctrl u_input_ctrl (
        .clk            (clk),
        .rst            (rst),
        .start          (start),
        .done           (done),           // 输出完成信号
        .valid_in       (valid_in),
        .ready_out      (ready_out)
    );

endmodule
