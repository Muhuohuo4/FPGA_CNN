module conv11_weight_input #(
    parameter DATA_WIDTH = 8
)(
    input  wire                   clk,
    input  wire                   rst,

    // 串行加载权重数据
    input  wire                   load_en,
    input  wire [DATA_WIDTH-1:0]  load_data,

    // 输出控制
    input  wire                   read_en,

    // 输出权重
    output reg  [DATA_WIDTH-1:0]  weight_0,
    output reg                    weight_load,  // 加载完成标志
    output reg                    valid         // 输出权重有效标志
);

    reg [DATA_WIDTH-1:0] buffer;
    reg loaded;

    // 权重加载（串行，只有一个权重）
    always @(posedge clk) begin
        if (rst) begin
            buffer      <= 0;
            loaded      <= 0;
            weight_load <= 0;
        end else if (load_en && !loaded) begin
            buffer      <= load_data;
            loaded      <= 1;
            weight_load <= 1;
        end else begin
            weight_load <= 0;  // 默认拉低（1拍脉冲）
        end
    end

    // 输出权重
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            weight_0 <= 0;
            valid    <= 0;
        end else if (read_en) begin
            weight_0 <= buffer;
            valid    <= 1;
        end else begin
            valid <= 0;
        end
    end

endmodule
