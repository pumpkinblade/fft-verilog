module butterfly_op(
    input[31:0] x1,
    input[31:0] x2,
    input[31:0] w,
    input inv,
    output[31:0] y1,
    output[31:0] y2
);
    // 实数部分和虚数部分拆分
    wire signed[15:0] x1_re, x1_im;
    wire signed[15:0] x2_re, x2_im;
    wire signed[15:0] w_re, w_im;
    assign x1_re = x1[31:16];
    assign x1_im = x1[15:0];
    assign x2_re = x2[31:16];
    assign x2_im = x2[15:0];
    assign w_re = w[31:16];
    assign w_im = w[15:0];

    // 乘法 re(w)*re(x2) re(w)*im(x2) im(w)*re(x2) im(w)*im(x2)
    wire signed[31:0] w_re_x2_re;
    wire signed[31:0] w_re_x2_im;
    wire signed[31:0] w_im_x2_re;
    wire signed[31:0] w_im_x2_im;
    assign w_re_x2_re = w_re * x2_re;
    assign w_re_x2_im = w_re * x2_im;
    assign w_im_x2_re = w_im * x2_re;
    assign w_im_x2_im = w_im * x2_im;

    // 乘法结果有32位，取中间16位
    wire signed[15:0] w_re_x2_re_16;
    wire signed[15:0] w_re_x2_im_16;
    wire signed[15:0] w_im_x2_re_16;
    wire signed[15:0] w_im_x2_im_16;
    assign w_re_x2_re_16 = w_re_x2_re[23:8];
    assign w_re_x2_im_16 = w_re_x2_im[23:8];
    assign w_im_x2_re_16 = w_im_x2_re[23:8];
    assign w_im_x2_im_16 = w_im_x2_im[23:8];

    // 复数乘法的加减部分
    wire signed[15:0] wx2_re;
    wire signed[15:0] wx2_im;
    // inv控制是 w*x2 还是 w共轭*x2
    assign wx2_re = ~inv ? w_re_x2_re_16 - w_im_x2_im_16 : w_re_x2_re_16 + w_im_x2_im_16;
    assign wx2_im = ~inv ? w_re_x2_im_16 + w_im_x2_re_16 : w_re_x2_im_16 - w_im_x2_re_16;

    // y1 = x1 + w*x2, y2 = x1 - w*x2
    wire signed[15:0] y1_re, y1_im;
    wire signed[15:0] y2_re, y2_im;
    assign y1_re = x1_re + wx2_re;
    assign y1_im = x1_im + wx2_im;
    assign y2_re = x1_re - wx2_re;
    assign y2_im = x1_im - wx2_im;

    assign y1 = {y1_re, y1_im};
    assign y2 = {y2_re, y2_im};
endmodule
