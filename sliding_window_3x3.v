module sliding_window_3x3 #(
    parameter IMG_WIDTH = 128
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        en,             // 输入使能，每拍1像素
    input  wire [7:0]  pixel_in,       // 输入像素
    output reg         valid,          // 输出有效
    output reg  [7:0]  o_temp [0:8]    // 3x3 窗口输出
);
    localparam PAD_WIDTH = IMG_WIDTH + 2;

    // 行列计数器
    reg [7:0] row;
    reg [7:0] col;

    // 输入数据有效判断：row 1~128，col 1~128 是真实像素，其它为 padding 0
    wire data_valid = (row >= 1 && row <= IMG_WIDTH) && (col >= 1 && col <= IMG_WIDTH);

    // 自动补白
    wire [7:0] pixel_eff = data_valid ? pixel_in : 8'd0;

    // 行缓冲
    reg [7:0] line_buf_0 [0:PAD_WIDTH-1];  // row-2
    reg [7:0] line_buf_1 [0:PAD_WIDTH-1];  // row-1

    // 列 shift 寄存器
    reg [7:0] shift_col_0 [0:2];
    reg [7:0] shift_col_1 [0:2];
    reg [7:0] shift_col_2 [0:2];

    // 行列计数逻辑
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            row <= 0;
            col <= 0;
        end else if (en) begin
            if (col == PAD_WIDTH-1) begin
                col <= 0;
                row <= row + 1;
            end else begin
                col <= col + 1;
            end
        end
    end

    // 行缓冲更新
    always @(posedge clk) begin
        if (en) begin
            line_buf_0[col] <= line_buf_1[col];
            line_buf_1[col] <= pixel_eff;
        end
    end

    // 列 shift
    always @(posedge clk) begin
        if (en) begin
            shift_col_0[0] <= shift_col_0[1];
            shift_col_0[1] <= shift_col_0[2];
            shift_col_0[2] <= line_buf_0 [col];

            shift_col_1[0] <= shift_col_1[1];
            shift_col_1[1] <= shift_col_1[2];
            shift_col_1[2] <= line_buf_1 [col];

            shift_col_2[0] <= shift_col_2[1];
            shift_col_2[1] <= shift_col_2[2];
            shift_col_2[2] <= pixel_eff;
        end
    end

    // 输出窗口
    always @(posedge clk) begin
        if (en) begin
            o_temp[0] <= shift_col_0[0]; o_temp[1] <= shift_col_1[0]; o_temp[2] <= shift_col_2[0];
            o_temp[3] <= shift_col_0[1]; o_temp[4] <= shift_col_1[1]; o_temp[5] <= shift_col_2[1];
            o_temp[6] <= shift_col_0[2]; o_temp[7] <= shift_col_1[2]; o_temp[8] <= shift_col_2[2];
        end
    end

    // 输出 valid：从第 2 行第 2 列开始输出
    always @(posedge clk or posedge rst) begin
        if (rst)
            valid <= 0;
        else
            valid <= (row >= 2 && row <= PAD_WIDTH-1) && (col >= 2 && col <= PAD_WIDTH-1) && en;
    end

endmodule
