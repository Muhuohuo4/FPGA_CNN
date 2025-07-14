module adder_tree_top #(
    parameter CHANNELS = 128,  // 支持 16/32/64/128/256
    parameter WIDTH    = 32
)(
    input  wire                        clk,
    input  wire                        rst,
    input  wire                        valid_in,
    output wire                        ready_out,
    output reg                         valid_out,
    input  wire [$clog2(CHANNELS)-1:0] in_index,   // 当前通道索引
    input  wire signed [WIDTH-1:0]     data_in,    // 串行输入
    output reg  signed [WIDTH-1:0]     data_out
);

    reg signed [WIDTH-1:0] buffer [0:CHANNELS-1];

    always @(posedge clk) begin
        if (in_valid && ready_out) begin
            buffer[in_index] <= data_in;
        end
    end
    
    assign ready_out = 1'b1;  // 默认始终 ready，可加节奏控制

    // ========== 输出控制：最后一个通道输出 ==========
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_out  <= 0;
            valid_out <= 0;
        end else if (in_valid && in_index == CHANNELS - 1) begin
            data_out  <= adder_out;
            valid_out <= 1;
        end else begin
            valid_out <= 0;
        end
    end


    // ========== 加法树输出 ==========
    wire signed [WIDTH-1:0] adder_out;
    generate
        if (CHANNELS == 16) begin
            adder_tree_16 #(.WIDTH(WIDTH)) u_adder (
                .data_in(buffer),
                .sum_out(adder_out)
            );
        end else if (CHANNELS == 32) begin
            adder_tree_32 #(.WIDTH(WIDTH)) u_adder (
                .data_in(buffer),
                .sum_out(adder_out)
            );
        end else if (CHANNELS == 64) begin
            adder_tree_64 #(.WIDTH(WIDTH)) u_adder (
                .data_in(buffer),
                .sum_out(adder_out)
            );
        end else if (CHANNELS == 128) begin
            adder_tree_128 #(.WIDTH(WIDTH)) u_adder (
                .data_in(buffer),
                .sum_out(adder_out)
            );
        end else if (CHANNELS == 256) begin
            adder_tree_256 #(.WIDTH(WIDTH)) u_adder (
                .data_in(buffer),
                .sum_out(adder_out)
            );
        end else begin
            invalid_config _error();  // 非法通道数
        end
    endgenerate

endmodule
