module conv33_scale_input #(
    parameter SCALE_WIDTH = 24
)(
    input  wire                  clk,
    input  wire                  rst,

    // 加载接口
    input  wire                  load_en,
    input  wire [SCALE_WIDTH-1:0] load_data,

    // 读取控制
    input  wire                  read_en,

    // 输出接口
    output reg  [SCALE_WIDTH-1:0] scale,      // 缩放系数输出
    output reg                   valid,       // 输出有效
    output reg                   scale_load   // 缩放系数加载完成（1拍脉冲）
);

    reg [SCALE_WIDTH-1:0] buffer;

    // 偏置加载过程
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            buffer     <= 0;
            scale_load <= 0;
        end else if (load_en) begin
            buffer     <= load_data;
            scale_load <= 1;  // 一拍脉冲，通知加载完成
        end else begin
            scale_load <= 0;
        end
    end

    // 缩放系数读取输出
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            scale <= 0;
            valid <= 0;
        end else if (read_en) begin
            scale <= buffer;
            valid <= 1;
        end else begin
            valid <= 0;
        end
    end

endmodule
