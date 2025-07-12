module conv33_output #(
    parameter OUT_WIDTH = 32
)(
    input  wire clk,
    input  wire rst,

    // 来自计算模块
    input  wire                 in_valid,
    input  wire [OUT_WIDTH-1:0] in_data,

    // 输出给外部模块
    output wire                 out_valid,
    output wire [OUT_WIDTH-1:0] out_data
);

    // 中间信号：buffer 和 ctrl 之间
    wire read_en;
    wire output_valid;

    // 输出缓存
    conv33_output_buffer #(
        .OUT_WIDTH(OUT_WIDTH)
    ) u_output_buffer (
        .clk(clk),
        .rst(rst),
        .in_valid(in_valid),
        .in_data (in_data),
        .read_en(read_en),
        .out_valid(out_valid),
        .out_data(out_data)
    );

    // 输出控制器
    conv33_output_ctrl u_output_ctrl (
        .clk(clk),
        .rst(rst),
        .in_valid(in_valid),
        .read_en(read_en),
        .output_valid(output_valid) // 预留对外通知使用（可选）
    );

endmodule
