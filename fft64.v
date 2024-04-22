module fft64 (
    input clk,
    input rst_n,
    input inv,
    input valid_in,
    input sop_in,
    input[15:0] x_re,
    input[15:0] x_im,
    output valid_out,
    output sop_out,
    output[15:0] y_re,
    output[15:0] y_im
);
    // 收集输入
    genvar gv_i;
    wire[5:0] d_counter_in, q_counter_in;
    wire d_sop_in, q_sop_in;
    wire d_inv_in, q_inv_in;
    wire[2047:0] d_raw_in, q_raw_in;
    assign d_counter_in = sop_in ? 6'd0 : (valid_in ? q_counter_in + 1 : q_counter_in);
    assign d_sop_in = sop_in ? 1'b1 : (q_counter_in == 6'd63 ? 1'b0 : q_sop_in);
    assign d_inv_in = sop_in ? inv : q_inv_in;
    assign d_raw_in = valid_in ? {x_re, x_im, q_raw_in[2047:32]} : q_raw_in;
    register#(.N(6)) reg_counter_in(clk, rst_n, d_counter_in, q_counter_in);
    register#(.N(1)) reg_inv(clk, rst_n, d_inv_in, q_inv_in);
    register#(.N(1)) reg_sop_in(clk, rst_n, d_sop_in, q_sop_in);
    register#(.N(2048)) reg_raw_in(clk, rst_n, d_raw_in, q_raw_in);

    // 整理输入
    wire[31:0] fft_in[63:0];
    generate
        for(gv_i = 0; gv_i < 64; gv_i = gv_i + 1) begin
            assign fft_in[gv_i] = q_raw_in[gv_i*32+31:gv_i*32];
        end
    endgenerate

    // 初始化w常数
    wire[31:0] w[5:0][31:0];
    generate
        // w0
        for(gv_i = 0; gv_i < 32; gv_i = gv_i+1) begin
            assign w[0][gv_i+0] = {16'h0100, 16'h0000};
        end
        // w1
        for(gv_i = 0; gv_i < 32; gv_i = gv_i+2) begin
            assign w[1][gv_i+0] = {16'h0100, 16'h0000};
            assign w[1][gv_i+1] = {16'h0000, 16'hff00};
        end
        // w2
        for(gv_i = 0; gv_i < 32; gv_i = gv_i+4) begin
            assign w[2][gv_i+0] = {16'h0100, 16'h0000};
            assign w[2][gv_i+1] = {16'h00b5, 16'hff4b};
            assign w[2][gv_i+2] = {16'h0000, 16'hff01};
            assign w[2][gv_i+3] = {16'hff4b, 16'hff4b};
        end
        // w3
        for(gv_i = 0; gv_i < 32; gv_i = gv_i+8) begin
            assign w[3][gv_i+0] = {16'h0100, 16'h0000};
            assign w[3][gv_i+1] = {16'h00ec, 16'hff9f};
            assign w[3][gv_i+2] = {16'h00b5, 16'hff4b};
            assign w[3][gv_i+3] = {16'h0061, 16'hff14};
            assign w[3][gv_i+4] = {16'h0000, 16'hff00};
            assign w[3][gv_i+5] = {16'hff9f, 16'hff14};
            assign w[3][gv_i+6] = {16'hff4b, 16'hff4b};
            assign w[3][gv_i+7] = {16'hff14, 16'hff9f};
        end
        // w4
        for(gv_i = 0; gv_i < 32; gv_i = gv_i+16) begin
            assign w[4][gv_i+0] = {16'h0100, 16'h0000};
            assign w[4][gv_i+1] = {16'h00fb, 16'hffcf};
            assign w[4][gv_i+2] = {16'h00ec, 16'hff9f};
            assign w[4][gv_i+3] = {16'h00d4, 16'hff72};
            assign w[4][gv_i+4] = {16'h00b5, 16'hff4b};
            assign w[4][gv_i+5] = {16'h008e, 16'hff2c};
            assign w[4][gv_i+6] = {16'h0061, 16'hff14};
            assign w[4][gv_i+7] = {16'h0031, 16'hff05};
            assign w[4][gv_i+8] = {16'h0000, 16'hff01};
            assign w[4][gv_i+9] = {16'hffcf, 16'hff05};
            assign w[4][gv_i+10] = {16'hff9f, 16'hff14};
            assign w[4][gv_i+11] = {16'hff72, 16'hff2c};
            assign w[4][gv_i+12] = {16'hff4b, 16'hff4b};
            assign w[4][gv_i+13] = {16'hff2c, 16'hff72};
            assign w[4][gv_i+14] = {16'hff14, 16'hff9f};
            assign w[4][gv_i+15] = {16'hff05, 16'hffcf};
        end
        // w5
        for(gv_i = 0; gv_i < 32; gv_i = gv_i+32) begin
            assign w[5][gv_i+0] = {16'h0100, 16'h0000};
            assign w[5][gv_i+1] = {16'h00fe, 16'hffe7};
            assign w[5][gv_i+2] = {16'h00fb, 16'hffcf};
            assign w[5][gv_i+3] = {16'h00f4, 16'hffb6};
            assign w[5][gv_i+4] = {16'h00ec, 16'hff9f};
            assign w[5][gv_i+5] = {16'h00e1, 16'hff88};
            assign w[5][gv_i+6] = {16'h00d4, 16'hff72};
            assign w[5][gv_i+7] = {16'h00c5, 16'hff5e};
            assign w[5][gv_i+8] = {16'h00b5, 16'hff4b};
            assign w[5][gv_i+9] = {16'h00a2, 16'hff3b};
            assign w[5][gv_i+10] = {16'h008e, 16'hff2c};
            assign w[5][gv_i+11] = {16'h0078, 16'hff1f};
            assign w[5][gv_i+12] = {16'h0061, 16'hff14};
            assign w[5][gv_i+13] = {16'h004a, 16'hff0c};
            assign w[5][gv_i+14] = {16'h0031, 16'hff05};
            assign w[5][gv_i+15] = {16'h0019, 16'hff02};
            assign w[5][gv_i+16] = {16'h0000, 16'hff01};
            assign w[5][gv_i+17] = {16'hffe7, 16'hff02};
            assign w[5][gv_i+18] = {16'hffcf, 16'hff05};
            assign w[5][gv_i+19] = {16'hffb6, 16'hff0c};
            assign w[5][gv_i+20] = {16'hff9f, 16'hff14};
            assign w[5][gv_i+21] = {16'hff88, 16'hff1f};
            assign w[5][gv_i+22] = {16'hff72, 16'hff2c};
            assign w[5][gv_i+23] = {16'hff5e, 16'hff3b};
            assign w[5][gv_i+24] = {16'hff4b, 16'hff4b};
            assign w[5][gv_i+25] = {16'hff3b, 16'hff5e};
            assign w[5][gv_i+26] = {16'hff2c, 16'hff72};
            assign w[5][gv_i+27] = {16'hff1f, 16'hff88};
            assign w[5][gv_i+28] = {16'hff14, 16'hff9f};
            assign w[5][gv_i+29] = {16'hff0c, 16'hffb6};
            assign w[5][gv_i+30] = {16'hff05, 16'hffcf};
            assign w[5][gv_i+31] = {16'hff02, 16'hffe7};
        end
    endgenerate

    // 位逆序重排
    wire[31:0] d_fft[6:1][63:0], q_fft[6:0][63:0];
    assign q_fft[0][ 0] = fft_in[ 0];
    assign q_fft[0][ 1] = fft_in[32];
    assign q_fft[0][ 2] = fft_in[16];
    assign q_fft[0][ 3] = fft_in[48];
    assign q_fft[0][ 4] = fft_in[ 8];
    assign q_fft[0][ 5] = fft_in[40];
    assign q_fft[0][ 6] = fft_in[24];
    assign q_fft[0][ 7] = fft_in[56];
    assign q_fft[0][ 8] = fft_in[ 4];
    assign q_fft[0][ 9] = fft_in[36];
    assign q_fft[0][10] = fft_in[20];
    assign q_fft[0][11] = fft_in[52];
    assign q_fft[0][12] = fft_in[12];
    assign q_fft[0][13] = fft_in[44];
    assign q_fft[0][14] = fft_in[28];
    assign q_fft[0][15] = fft_in[60];
    assign q_fft[0][16] = fft_in[ 2];
    assign q_fft[0][17] = fft_in[34];
    assign q_fft[0][18] = fft_in[18];
    assign q_fft[0][19] = fft_in[50];
    assign q_fft[0][20] = fft_in[10];
    assign q_fft[0][21] = fft_in[42];
    assign q_fft[0][22] = fft_in[26];
    assign q_fft[0][23] = fft_in[58];
    assign q_fft[0][24] = fft_in[ 6];
    assign q_fft[0][25] = fft_in[38];
    assign q_fft[0][26] = fft_in[22];
    assign q_fft[0][27] = fft_in[54];
    assign q_fft[0][28] = fft_in[14];
    assign q_fft[0][29] = fft_in[46];
    assign q_fft[0][30] = fft_in[30];
    assign q_fft[0][31] = fft_in[62];
    assign q_fft[0][32] = fft_in[ 1];
    assign q_fft[0][33] = fft_in[33];
    assign q_fft[0][34] = fft_in[17];
    assign q_fft[0][35] = fft_in[49];
    assign q_fft[0][36] = fft_in[ 9];
    assign q_fft[0][37] = fft_in[41];
    assign q_fft[0][38] = fft_in[25];
    assign q_fft[0][39] = fft_in[57];
    assign q_fft[0][40] = fft_in[ 5];
    assign q_fft[0][41] = fft_in[37];
    assign q_fft[0][42] = fft_in[21];
    assign q_fft[0][43] = fft_in[53];
    assign q_fft[0][44] = fft_in[13];
    assign q_fft[0][45] = fft_in[45];
    assign q_fft[0][46] = fft_in[29];
    assign q_fft[0][47] = fft_in[61];
    assign q_fft[0][48] = fft_in[ 3];
    assign q_fft[0][49] = fft_in[35];
    assign q_fft[0][50] = fft_in[19];
    assign q_fft[0][51] = fft_in[51];
    assign q_fft[0][52] = fft_in[11];
    assign q_fft[0][53] = fft_in[43];
    assign q_fft[0][54] = fft_in[27];
    assign q_fft[0][55] = fft_in[59];
    assign q_fft[0][56] = fft_in[ 7];
    assign q_fft[0][57] = fft_in[39];
    assign q_fft[0][58] = fft_in[23];
    assign q_fft[0][59] = fft_in[55];
    assign q_fft[0][60] = fft_in[15];
    assign q_fft[0][61] = fft_in[47];
    assign q_fft[0][62] = fft_in[31];
    assign q_fft[0][63] = fft_in[63];

    // 开始计算一组fft的计数器
    wire[2:0] d_counter_fft, q_counter_fft;
    assign d_counter_fft = ((q_counter_in == 6'd63) & q_sop_in) ? 3'd0 : (q_counter_fft == 3'd7 ? 3'd7 : q_counter_fft + 1);
    register#(.N(3), .INIT(3'd7)) reg_counter_fft(clk, rst_n, d_counter_fft, q_counter_fft);

    // 记录fft运算过程中是否是逆变换
    wire d_inv_fft, q_inv_fft;
    assign d_inv_fft = ((q_counter_in == 6'd63) & q_sop_in) ? q_inv_in : q_inv_fft;
    register#(.N(1)) reg_inv_fft(clk, rst_n, d_inv_fft, q_inv_fft);

    // fft
    genvar gv_j, gv_k;
    generate
        for(gv_i = 0; gv_i < 6; gv_i = gv_i+1) begin
            for(gv_k = 0; gv_k < (1 << gv_i); gv_k = gv_k+1) begin
                for(gv_j = 0; gv_j < 64; gv_j = gv_j+(1<<(gv_i+1))) begin
                    butterfly_op b_inst(q_fft[gv_i][gv_j+gv_k], q_fft[gv_i][gv_j+gv_k+(1<<gv_i)],
                                        w[gv_i][gv_k], q_inv_fft,
                                        d_fft[gv_i+1][gv_j+gv_k], d_fft[gv_i+1][gv_j+gv_k+(1<<gv_i)]);
                end
            end
        end
    endgenerate
    // 寄存中间结果
    generate
        for(gv_i = 1; gv_i <= 6; gv_i = gv_i+1) begin
            for(gv_j = 0; gv_j < 64; gv_j = gv_j+1) begin
                register#(.N(32)) reg_fft(clk, rst_n, d_fft[gv_i][gv_j], q_fft[gv_i][gv_j]);
            end
        end
    endgenerate

    // 整理输出
    wire[2047:0] fft_out;
    generate
        for(gv_i = 0; gv_i < 64; gv_i = gv_i + 1) begin
            assign fft_out[gv_i*32+31:gv_i*32] = q_fft[6][gv_i];
        end
    endgenerate

    // 输出
    wire d_sop_out, q_sop_out;
    wire d_inv_out, q_inv_out;
    wire[5:0] d_counter_out, q_counter_out;
    wire[2047:0] d_raw_out, q_raw_out;
    assign d_sop_out = q_counter_fft == 3'd5;
    assign d_inv_out = q_counter_fft == 3'd5 ? q_inv_fft : q_inv_out;
    assign d_counter_out = q_sop_out ? 6'd63 : (q_counter_out == 6'd0 ? 6'd0 : q_counter_out - 1);
    assign d_raw_out = q_counter_fft == 3'd5 ? fft_out : {32'b0, q_raw_out[2047:32]};
    register#(.N(1)) reg_sop_out(clk, rst_n, d_sop_out, q_sop_out);
    register#(.N(1)) reg_inv_out(clk, rst_n, d_inv_out, q_inv_out);
    register#(.N(6)) reg_counter_out(clk, rst_n, d_counter_out, q_counter_out);
    register#(.N(2048)) reg_raw_out(clk, rst_n, d_raw_out, q_raw_out);

    assign y_re = q_inv_out ? {{6{q_raw_out[31]}}, q_raw_out[31:22]} : q_raw_out[31:16];
    assign y_im = q_inv_out ? {{6{q_raw_out[15]}}, q_raw_out[15:6]} : q_raw_out[15:0];
    assign sop_out = q_sop_out;
    assign valid_out = q_sop_out | ~(q_counter_out == 6'd0);
endmodule