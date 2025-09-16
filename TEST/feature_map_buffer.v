module feature_map_buffer #(
    parameter DATA_WIDTH = 8,
    parameter WRITE_H = 64,
    parameter WRITE_W = 64,
    parameter WRITE_C = 16,
    parameter READ_H  = 64,
    parameter READ_W  = 64,
    parameter READ_C  = 16,
    parameter mode_sel = 1  // 0: A写B读, 1: B写A读
)(
    input  wire                  clk,
    input  wire                  rst,

    // 写入端口
    input  wire                  write_en,
    input  wire [DATA_WIDTH-1:0] data_in,
    input  wire [3:0]            write_ch,
    input  wire [5:0]            write_h,
    input  wire [5:0]            write_w,

    // 读取端口
    input  wire                  read_en,
    input  wire [3:0]            read_ch,
    input  wire [5:0]            read_h,
    input  wire [5:0]            read_w,
    output reg  [DATA_WIDTH-1:0] data_out
);

    localparam TOTAL_ADDR_WIDTH = 16;
    reg [DATA_WIDTH-1:0] bram_a [0:(1<<TOTAL_ADDR_WIDTH)-1];
    reg [DATA_WIDTH-1:0] bram_b [0:(1<<TOTAL_ADDR_WIDTH)-1];

    localparam WRITE_CH_OFFSET = WRITE_H * WRITE_W;
    localparam READ_CH_OFFSET  = READ_H  * READ_W;
    wire [15:0] write_addr = ch_idx   *  WRITE_CH_OFFSET +  h_idx   *  WRITE_W + w_idx;
    wire [15:0] read_addr  = read_ch  *  READ_CH_OFFSET  +  read_h  *  READ_W + read_w;

    // 写入双缓冲
    always @(posedge clk) begin
        if (write_en) begin
            if (mode_sel == 1'b0)
                bram_a[write_addr] <= data_in;
            else
                bram_b[write_addr] <= data_in;
        end
    end

    // 读取双缓冲
    always @(posedge clk) begin
        if (read_en) begin
            if (mode_sel == 1'b0)
                data_out <= bram_b[read_addr];
            else
                data_out <= bram_a[read_addr];
        end
    end

endmodule
