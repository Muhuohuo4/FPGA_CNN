module conv33_output_ctrl (
    input wire clk,
    input wire rst,

    input wire in_valid,          // 来自计算模块
    input wire buffer_ready,      // 保留接口

    output reg read_en,           // 控制 buffer 输出
    output reg output_valid       // 通知外部模块数据有效
);

    // 一拍延迟逻辑
    reg in_valid_d;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            in_valid_d    <= 0;
            read_en       <= 0;
            output_valid  <= 0;
        end else begin
            in_valid_d    <= in_valid;
            read_en       <= in_valid_d;
            output_valid  <= in_valid_d;
        end
    end

endmodule
