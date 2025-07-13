module conv33_weight_input #(
    parameter DATA_WIDTH = 8
)(
    input  wire                   clk,
    input  wire                   rst,

    // 串行加载权重数据
    input  wire                   start,
    input  wire [DATA_WIDTH-1:0]  data_in,

    // 输出控制
    input  wire                   read_en,

    // 输出权重（并行 9 个）
    output reg  [DATA_WIDTH-1:0]  weight_0,
    output reg  [DATA_WIDTH-1:0]  weight_1,
    output reg  [DATA_WIDTH-1:0]  weight_2,
    output reg  [DATA_WIDTH-1:0]  weight_3,
    output reg  [DATA_WIDTH-1:0]  weight_4,
    output reg  [DATA_WIDTH-1:0]  weight_5,
    output reg  [DATA_WIDTH-1:0]  weight_6,
    output reg  [DATA_WIDTH-1:0]  weight_7,
    output reg  [DATA_WIDTH-1:0]  weight_8,

    output reg                    weight_load,      // 加载完成标志
    output reg                    valid_out         // 输出权重有效标志
);

    reg [DATA_WIDTH-1:0] buffer [0:8];
    reg [3:0] load_cnt;

    // 权重加载（串行）
    always @(posedge clk) begin
        if (rst) begin
            load_cnt    <= 0;
            weight_load <= 0;
        end else if (start && load_cnt < 9) begin
            buffer[load_cnt] <= load_data;
            load_cnt <= load_cnt + 1;

            if (load_cnt == 8)
                weight_load <= 1; 
            else
                weight_load <= 0;
        end else begin
            weight_load <= 0;  // 默认拉低（1拍脉冲）
        end
    end

    // 并行输出
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            weight_0 <= 0; weight_1 <= 0; weight_2 <= 0;
            weight_3 <= 0; weight_4 <= 0; weight_5 <= 0;
            weight_6 <= 0; weight_7 <= 0; weight_8 <= 0;
            valid    <= 0;
        end else if (read_en) begin
            weight_0 <= buffer[0]; weight_1 <= buffer[1]; weight_2 <= buffer[2];
            weight_3 <= buffer[3]; weight_4 <= buffer[4]; weight_5 <= buffer[5];
            weight_6 <= buffer[6]; weight_7 <= buffer[7]; weight_8 <= buffer[8];
            valid    <= 1;
        end else begin
            valid    <= 0;
        end
    end

endmodule
