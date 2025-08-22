module bias_scale_mem #(
    parameter BIAS_WIDTH  = 32,
    parameter SCALE_WIDTH = 16,
    parameter LAYER_NUM   = 8,
    parameter CH_NUM      = 64
)(
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     start,       // 可选：触发一次读

    input  wire [4:0]               layer_idx,   // 层编号
    input  wire [9:0]               ch_idx,      // 通道编号
    output reg  [BIAS_WIDTH-1:0]    bias_out,
    output reg  [SCALE_WIDTH-1:0]   scale_out,
    output reg                      valid_out    // 可选：输出有效（与数据对齐）
);
    // 派生位宽
    localparam integer TOTAL_NUM  = LAYER_NUM * CH_NUM;
    localparam integer ADDR_WIDTH = (TOTAL_NUM <= 1) ? 1 : $clog2(TOTAL_NUM);

    // ROM存储（提示综合为块RAM/ROM）
    (* rom_style="block", ram_style="block" *)
    reg [BIAS_WIDTH-1:0]  bias_rom  [0:TOTAL_NUM-1];
    (* rom_style="block", ram_style="block" *)
    reg [SCALE_WIDTH-1:0] scale_rom [0:TOTAL_NUM-1];

    // 仅一次初始化（仿真/FPGA综合常用写法）
    initial begin
        $readmemh("bias.mem",  bias_rom);
        $readmemh("scale.mem", scale_rom);
    end

    // 地址计算（显式扩展，避免截断）
    wire [ADDR_WIDTH:0] addr_wide   =   (layer_idx * CH_NUM) + ch_idx; // 1位冗余避免溢出
    wire [ADDR_WIDTH-1:0] addr      =   { layer_idx[$clog2(LAYER_NUM)-1:0],
                                        ch_idx  [$clog2(CH_NUM )-1:0] };

    // 同步读取：一拍延迟；valid_out 与数据对齐
    always @(posedge clk) begin
        if (rst) begin
            bias_out  <= '0;
            scale_out <= '0;
            valid_out <= 1'b0;
        end else begin
            // 若需要按 start 触发读取，则把条件加在这里
            if (start) begin
                bias_out  <= bias_rom [addr];
                scale_out <= scale_rom[addr];
                valid_out <= 1'b1;
            end else begin
                valid_out <= 1'b0;
            end
        end
    end

endmodule
