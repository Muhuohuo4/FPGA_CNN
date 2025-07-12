module result_buffer #(
    parameter DATA_WIDTH = 8,
    parameter OUT_H = 64,
    parameter OUT_W = 64,
    parameter OUT_C = 16
)(
    input  wire                  clk,
    input  wire                  rst,

    // 控制双缓冲选择：0=A写B读, 1=B写A读
    input  wire                  mode_sel,

    // 写入端口
    input  wire                  write_en,
    input  wire [DATA_WIDTH-1:0] data_in,
    input  wire [3:0]            ch_idx,
    input  wire [5:0]            h_idx,
    input  wire [5:0]            w_idx,

    // 读取端口
    input  wire                  read_en,
    input  wire [3:0]            read_ch,
    input  wire [5:0]            read_h,
    input  wire [5:0]            read_w,
    output reg  [DATA_WIDTH-1:0] data_out
);

    localparam CH_OFFSET = OUT_H * OUT_W;
    localparam TOTAL_ADDR_WIDTH = 16;

    reg [DATA_WIDTH-1:0] bram_a [0:(1<<TOTAL_ADDR_WIDTH)-1];
    reg [DATA_WIDTH-1:0] bram_b [0:(1<<TOTAL_ADDR_WIDTH)-1];

    wire [15:0] write_addr = ch_idx   * CH_OFFSET + h_idx * OUT_W + w_idx;
    wire [15:0] read_addr  = read_ch * CH_OFFSET + read_h * OUT_W + read_w;

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
                data_out <= bram_b[read_addr];  // 注意读的是“另一块”
            else
                data_out <= bram_a[read_addr];
        end
    end

endmodule
