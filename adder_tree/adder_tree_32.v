module adder_tree_32 #(
    parameter WIDTH = 32
)(
    input  wire signed [WIDTH-1:0] data_in [0:31],
    output wire signed [WIDTH-1:0] sum_out
);
    wire signed [WIDTH-1:0] sum_l0 [0:15];
    wire signed [WIDTH-1:0] sum_l1 [0:7];
    wire signed [WIDTH-1:0] sum_l2 [0:3];
    wire signed [WIDTH-1:0] sum_l3 [0:1];
    wire signed [WIDTH-1:0] sum_l4 [0:0];

    genvar i0;
    generate
        for (i0 = 0; i0 < 16; i0 = i0 + 1) begin: L0
            assign sum_l0[i0] = data_in[2*i0] + data_in[2*i0+1];
        end
    endgenerate

    genvar i1;
    generate
        for (i1 = 0; i1 < 8; i1 = i1 + 1) begin: L1
            assign sum_l1[i1] = sum_l0[2*i1] + sum_l0[2*i1+1];
        end
    endgenerate

    genvar i2;
    generate
        for (i2 = 0; i2 < 4; i2 = i2 + 1) begin: L2
            assign sum_l2[i2] = sum_l1[2*i2] + sum_l1[2*i2+1];
        end
    endgenerate

    genvar i3;
    generate
        for (i3 = 0; i3 < 2; i3 = i3 + 1) begin: L3
            assign sum_l3[i3] = sum_l2[2*i3] + sum_l2[2*i3+1];
        end
    endgenerate

    genvar i4;
    generate
        for (i4 = 0; i4 < 1; i4 = i4 + 1) begin: L4
            assign sum_l4[i4] = sum_l3[2*i4] + sum_l3[2*i4+1];
        end
    endgenerate

    assign sum_out = sum_l4[0];
endmodule
