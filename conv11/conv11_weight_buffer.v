module conv11_weight_buffer #(
    parameter DATA_WIDTH = 8
)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   start,
    output wire                   done,
    
    input  wire                   valid_in,
    output wire                   ready_out,

    input  wire [DATA_WIDTH-1:0]  data_in,
    // 输出权重（并行 9 个）
    output reg  [DATA_WIDTH-1:0]  weight_0,
    output reg  [DATA_WIDTH-1:0]  weight_1,
    output reg  [DATA_WIDTH-1:0]  weight_2,
    output reg  [DATA_WIDTH-1:0]  weight_3,
    output reg  [DATA_WIDTH-1:0]  weight_4,
    output reg  [DATA_WIDTH-1:0]  weight_5,
    output reg  [DATA_WIDTH-1:0]  weight_6,
    output reg  [DATA_WIDTH-1:0]  weight_7,
    output reg  [DATA_WIDTH-1:0]  weight_8
);

    reg [DATA_WIDTH-1:0] buffer [0:8];
    reg [3:0] cnt;

    assign ready_out = (cnt < 9);

    // 权重加载（串行）
    always @(posedge clk or posedge rst) begin
        if (rst)
            cnt <= 0;
        else if (valid_in && ready_out) begin
            buffer[cnt] <= data_in;
            cnt <= cnt + 1;
        end
    end

    // 并行输出
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            weight_0 <= 0; weight_1 <= 0; weight_2 <= 0;
            weight_3 <= 0; weight_4 <= 0; weight_5 <= 0;
            weight_6 <= 0; weight_7 <= 0; weight_8 <= 0;
            done <= 0;
        end else if (start) begin
            weight_0 <= buffer[0]; weight_1 <= buffer[1]; weight_2 <= buffer[2];
            weight_3 <= buffer[3]; weight_4 <= buffer[4]; weight_5 <= buffer[5];
            weight_6 <= buffer[6]; weight_7 <= buffer[7]; weight_8 <= buffer[8];
            done <= 1;
        end else begin
            done <= 0;
        end
    end

endmodule
