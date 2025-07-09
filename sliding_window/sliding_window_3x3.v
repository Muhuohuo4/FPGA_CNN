module sliding_window_3x3 (
    input  wire        clk,
    input  wire        rst,
    input  wire        en,              // 输入使能，每拍一个像素
    input  wire [7:0]  pixel_in,        // 输入像素流
    output reg  [7:0]  window [0:8],    // 输出 3x3 窗口：左上到右下
    output reg         valid            // 输出有效标志
);

    parameter IMG_WIDTH = 128;

    // === 行缓冲器 ===
    reg [7:0] line_buf_0 [0:IMG_WIDTH-1];  // 行 n-2
    reg [7:0] line_buf_1 [0:IMG_WIDTH-1];  // 行 n-1

    reg [13:0] col_cnt;  // 当前列位置（0~127）
    reg [13:0] pix_cnt;  // 总像素计数器

    // === shift 寄存器:每列3个像素 ===
    reg [7:0] col_0[0:2];
    reg [7:0] col_1[0:2];
    reg [7:0] col_2[0:2];

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            col_cnt <= 0;
            pix_cnt <= 0;
            valid <= 0;
        end else if (en) begin
            // 更新像素计数器
            pix_cnt <= pix_cnt + 1;
            // 行循环更新
            col_cnt <= (col_cnt == IMG_WIDTH-1) ? 0 : col_cnt + 1;
            // === 行缓冲写入 ===
            line_buf_0[col_cnt] <= line_buf_1[col_cnt];     // 上上行 <= 上一行
            line_buf_1[col_cnt] <= pixel_in;                // 上一行 <= 当前输入
            // === 滑动窗口列移位 ===
            col_0[0] <= col_0[1];
            col_0[1] <= col_0[2];
            col_0[2] <= line_buf_0[col_cnt];

            col_1[0] <= col_1[1];
            col_1[1] <= col_1[2];
            col_1[2] <= line_buf_1[col_cnt];

            col_2[0] <= col_2[1];
            col_2[1] <= col_2[2];
            col_2[2] <= pixel_in;

            // === 输出窗口拼接 ===
            window[0] <= col_0[0]; window[1] <= col_1[0]; window[2] <= col_2[0];
            window[3] <= col_0[1]; window[4] <= col_1[1]; window[5] <= col_2[1];
            window[6] <= col_0[2]; window[7] <= col_1[2]; window[8] <= col_2[2];

            // === 有效标志:第2行后,第2列后才开始输出 ===
            valid <= (pix_cnt >= (IMG_WIDTH * 2 + 2));
        end else begin
            valid <= 0;
        end
    end

endmodule
