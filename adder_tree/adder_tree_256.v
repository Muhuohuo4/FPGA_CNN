module adder_tree_256 #(
    parameter WIDTH = 32
)(
    input  wire signed [WIDTH-1:0] data_in [0:255],
    output wire signed [WIDTH-1:0] sum_out
);
    wire signed [WIDTH-1:0] sum_l0 [0:127];
    wire signed [WIDTH-1:0] sum_l1 [0:63];
    wire signed [WIDTH-1:0] sum_l2 [0:31];
    wire signed [WIDTH-1:0] sum_l3 [0:15];
    wire signed [WIDTH-1:0] sum_l4 [0:7];
    wire signed [WIDTH-1:0] sum_l5 [0:3];
    wire signed [WIDTH-1:0] sum_l6 [0:1];
    wire signed [WIDTH-1:0] sum_l7 [0:0];

    genvar i0;
    generate
        for (i0 = 0; i0 < 128; i0 = i0 + 1) begin: L0
            assign sum_l0[i0] = data_in[2*i0] + data_in[2*i0+1];
        end
    endgenerate

    genvar i1;
    generate
        for (i1 = 0; i1 < 64; i1 = i1 + 1) begin: L1
            assign sum_l1[i1] = sum_l0[2*i1] + sum_l0[2*i1+1];
        end
    endgenerate

    genvar i2;
    generate
        for (i2 = 0; i2 < 32; i2 = i2 + 1) begin: L2
            assign sum_l2[i2] = sum_l1[2*i2] + sum_l1[2*i2+1];
        end
    endgenerate

    genvar i3;
    generate
        for (i3 = 0; i3 < 16; i3 = i3 + 1) begin: L3
            assign sum_l3[i3] = sum_l2[2*i3] + sum_l2[2*i3+1];
        end
    endgenerate

    genvar i4;
    generate
        for (i4 = 0; i4 < 8; i4 = i4 + 1) begin: L4
            assign sum_l4[i4] = sum_l3[2*i4] + sum_l3[2*i4+1];
        end
    endgenerate

    genvar i5;
    generate
        for (i5 = 0; i5 < 4; i5 = i5 + 1) begin: L5
            assign sum_l5[i5] = sum_l4[2*i5] + sum_l4[2*i5+1];
        end
    endgenerate

    genvar i6;
    generate
        for (i6 = 0; i6 < 2; i6 = i6 + 1) begin: L6
            assign sum_l6[i6] = sum_l5[2*i6] + sum_l5[2*i6+1];
        end
    endgenerate

    genvar i7;
    generate
        for (i7 = 0; i7 < 1; i7 = i7 + 1) begin: L7
            assign sum_l7[i7] = sum_l6[2*i7] + sum_l6[2*i7+1];
        end
    endgenerate

    assign sum_out = sum_l7[0];
endmodule
