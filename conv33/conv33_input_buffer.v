module conv33_input_buffer #(
    parameter DATA_WIDTH = 8
)(
    input  wire clk,
    input  wire rst,
    input  wire start,

    input  wire valid_in,
    input  wire ready_out,
    input  wire [DATA_WIDTH-1:0] in_0_0,
    input  wire [DATA_WIDTH-1:0] in_0_1,
    input  wire [DATA_WIDTH-1:0] in_0_2,
    input  wire [DATA_WIDTH-1:0] in_1_0,
    input  wire [DATA_WIDTH-1:0] in_1_1,
    input  wire [DATA_WIDTH-1:0] in_1_2,
    input  wire [DATA_WIDTH-1:0] in_2_0,
    input  wire [DATA_WIDTH-1:0] in_2_1,
    input  wire [DATA_WIDTH-1:0] in_2_2,

    output reg  [DATA_WIDTH-1:0] out_0_0,
    output reg  [DATA_WIDTH-1:0] out_0_1,
    output reg  [DATA_WIDTH-1:0] out_0_2,
    output reg  [DATA_WIDTH-1:0] out_1_0,
    output reg  [DATA_WIDTH-1:0] out_1_1,
    output reg  [DATA_WIDTH-1:0] out_1_2,
    output reg  [DATA_WIDTH-1:0] out_2_0,
    output reg  [DATA_WIDTH-1:0] out_2_1,
    output reg  [DATA_WIDTH-1:0] out_2_2
);

    reg [DATA_WIDTH-1:0] buf_0_0, buf_0_1, buf_0_2;
    reg [DATA_WIDTH-1:0] buf_1_0, buf_1_1, buf_1_2;
    reg [DATA_WIDTH-1:0] buf_2_0, buf_2_1, buf_2_2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            buf_0_0 <= 0; buf_0_1 <= 0; buf_0_2 <= 0;
            buf_1_0 <= 0; buf_1_1 <= 0; buf_1_2 <= 0;
            buf_2_0 <= 0; buf_2_1 <= 0; buf_2_2 <= 0;
            
        end else if (valid_in && ready_out) begin
            buf_0_0 <= in_0_0; buf_0_1 <= in_0_1; buf_0_2 <= in_0_2;
            buf_1_0 <= in_1_0; buf_1_1 <= in_1_1; buf_1_2 <= in_1_2;
            buf_2_0 <= in_2_0; buf_2_1 <= in_2_1; buf_2_2 <= in_2_2;
        end
    end

    always @(posedge clk) begin
    if (rst) begin
        out_0_0 <= 0; out_0_1 <= 0; out_0_2 <= 0;
        out_1_0 <= 0; out_1_1 <= 0; out_1_2 <= 0;
        out_2_0 <= 0; out_2_1 <= 0; out_2_2 <= 0;
    end else if (start) begin
        out_0_0 <= buf_0_0; out_0_1 <= buf_0_1; out_0_2 <= buf_0_2;
        out_1_0 <= buf_1_0; out_1_1 <= buf_1_1; out_1_2 <= buf_1_2;
        out_2_0 <= buf_2_0; out_2_1 <= buf_2_1; out_2_2 <= buf_2_2;
    end
end

endmodule
