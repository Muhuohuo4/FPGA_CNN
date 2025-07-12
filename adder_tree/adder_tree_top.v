module adder_tree_top #(
    parameter CHANNELS = 128,  // 可为 16/32/64/128/256
    parameter WIDTH    = 32
)(
    input  wire signed [WIDTH-1:0] data_in [0:CHANNELS-1],
    output wire signed [WIDTH-1:0] sum_out
);

    generate
        if (CHANNELS == 16) begin
            adder_tree_16 #(.WIDTH(WIDTH)) u_adder (
                .data_in(data_in),
                .sum_out(sum_out)
            );
        end else if (CHANNELS == 32) begin
            adder_tree_32 #(.WIDTH(WIDTH)) u_adder (
                .data_in(data_in),
                .sum_out(sum_out)
            );
        end else if (CHANNELS == 64) begin
            adder_tree_64 #(.WIDTH(WIDTH)) u_adder (
                .data_in(data_in),
                .sum_out(sum_out)
            );
        end else if (CHANNELS == 128) begin
            adder_tree_128 #(.WIDTH(WIDTH)) u_adder (
                .data_in(data_in),
                .sum_out(sum_out)
            );
        end else if (CHANNELS == 256) begin
            adder_tree_256 #(.WIDTH(WIDTH)) u_adder (
                .data_in(data_in),
                .sum_out(sum_out)
            );
        end else begin
            invalid_config _error();  // 非法通道数
        end
    endgenerate

endmodule
