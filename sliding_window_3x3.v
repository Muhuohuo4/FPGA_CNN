module sliding_window_3x3 #(
    parameter IMG_WIDTH = 128,
    parameter STRIDE    = 1
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        en,             // 输入使能，每拍1像素
    input  wire [7:0]  data_in,        // 输入像素

    output reg         valid,          // 输出有效
    output reg [7:0]   data_out_0,
    output reg [7:0]   data_out_1,
    output reg [7:0]   data_out_2,
    output reg [7:0]   data_out_3,
    output reg [7:0]   data_out_4,
    output reg [7:0]   data_out_5,
    output reg [7:0]   data_out_6,
    output reg [7:0]   data_out_7,
    output reg [7:0]   data_out_8
);

    localparam PAD_WIDTH = IMG_WIDTH + 2;

    reg [7:0] row, col;

    // Stride 判断
    wire stride_match = ((row - 1) % STRIDE == 0) && ((col - 1) % STRIDE == 0);
    wire data_valid = (row >= 1 && row <= IMG_WIDTH) && (col >= 1 && col <= IMG_WIDTH);
    wire [7:0] pixel_eff = data_valid ? data_in : 8'd0;

    reg [7:0] line_buf_0 [0:PAD_WIDTH-1];  // row-2
    reg [7:0] line_buf_1 [0:PAD_WIDTH-1];  // row-1

    reg [7:0] shift_col_0 [0:2];
    reg [7:0] shift_col_1 [0:2];
    reg [7:0] shift_col_2 [0:2];

    // 行列计数
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            row <= 0;
            col <= 0;
        end else if (en) begin
            if (col == PAD_WIDTH - 1) begin
                col <= 0;
                row <= row + 1;
            end else begin
                col <= col + 1;
            end
        end
    end

    // 行缓冲
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
            shift_col_0[2] <= line_buf_0[col];

            shift_col_1[0] <= shift_col_1[1];
            shift_col_1[1] <= shift_col_1[2];
            shift_col_1[2] <= line_buf_1[col];

            shift_col_2[0] <= shift_col_2[1];
            shift_col_2[1] <= shift_col_2[2];
            shift_col_2[2] <= pixel_eff;
        end
    end

    // 输出窗口
    always @(posedge clk) begin
        if (en) begin
            data_out_0 <= shift_col_0[0]; data_out_1 <= shift_col_1[0]; data_out_2 <= shift_col_2[0];
            data_out_3 <= shift_col_0[1]; data_out_4 <= shift_col_1[1]; data_out_5 <= shift_col_2[1];
            data_out_6 <= shift_col_0[2]; data_out_7 <= shift_col_1[2]; data_out_8 <= shift_col_2[2];
        end
    end

    // 输出 valid
    always @(posedge clk or posedge rst) begin
        if (rst)
            valid <= 0;
        else
            valid <= (row >= 2 && row <= PAD_WIDTH-1) &&
                     (col >= 2 && col <= PAD_WIDTH-1) &&
                     en && stride_match;
    end

endmodule
