module conv11_output #(
    parameter OUT_WIDTH = 32
)(
    input  wire clk,
    input  wire rst,
    // 输入握手
    input  wire                 valid_in,
    output wire                 ready_out,
    // 输出握手
    output reg                  valid_out,
    input  wire                 ready_in,
    input  wire start, 
    output wire done,

    input  wire [OUT_WIDTH-1:0] data_in,
    output reg  [OUT_WIDTH-1:0] data_out
);
    
    reg [OUT_WIDTH-1:0] buffer;
    reg buffer_full;
    assign ready_out = start && ~buffer_full;

    // 接收数据
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            buffer      <= 0;
            buffer_full <= 0;
        end else if (start && valid_in && ~buffer_full) begin
            buffer      <= data_in;
            buffer_full <= 1;
        end else if (start && valid_out && ready_in) begin
            buffer_full <= 0;
        end
    end

    // 输出逻辑
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            valid_out <= 0;
            data_out  <= 0;
        end else if (start && buffer_full && ready_in) begin
            valid_out <= 1;
            data_out  <= buffer;
        end else begin
            valid_out <= 0;
        end
    end

    // 输出完成脉冲
    assign done = valid_out && ready_in;

endmodule
