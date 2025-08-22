module weight_mem #(
    parameter WEIGHT_WIDTH = 8,
    parameter LAYER_NUM    = 8,
    parameter IN_CH_NUM    = 64,
    parameter OUT_CH_NUM   = 64,
    parameter KERNEL_SIZE  = 9
)(
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     start,

    input  wire [7:0]               in_ch,
    input  wire [7:0]               out_ch,

    output reg  [WEIGHT_WIDTH-1:0]  weight_out,
    output reg                      valid_out,
    input  wire                     ready_in
);
    localparam ADDR_WIDTH = 14;     //$clog2(TOTAL_NUM);

    reg [WEIGHT_WIDTH-1:0] weight_rom [0:36864-1];
    initial $readmemh("weight.mem", weight_rom);

    reg [$clog2(KERNEL_SIZE)-1:0] k_idx;
    reg [ADDR_WIDTH-1:0] base_addr;
    reg busy;

    wire [ADDR_WIDTH-1:0] start_addr = (in_ch * OUT_CH_NUM + out_ch) * KERNEL_SIZE;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            weight_out <= 0;
            valid_out  <= 0;
            busy       <= 0;
            k_idx      <= 0;
            base_addr  <= 0;
        end else begin
            if (start && !busy) begin
                base_addr  <= start_addr;
                k_idx      <= 0;
                busy       <= 1;
                weight_out <= weight_rom[start_addr];
                valid_out      <= 1;
            end else if (busy && valid_out && ready_in) begin
                if (k_idx + 1 == KERNEL_SIZE) begin
                    busy       <= 0;
                    valid_out  <= 0;
                end else begin
                    k_idx      <= k_idx + 1;
                    weight_out <= weight_rom[base_addr + k_idx + 1];
                    valid_out      <= 1;
                end
            end
        end
    end

endmodule
