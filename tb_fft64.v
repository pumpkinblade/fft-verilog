module tb_fft64;
    reg clk, rst_n, inv, valid_in, sop_in;
    reg[15:0] x_re, x_im;
    wire valid_out, sop_out;
    wire[15:0] y_re, y_im;
    integer inFile, outFile, i;
    fft64 inst(clk, rst_n, inv, valid_in, sop_in, x_re, x_im, valid_out, sop_out, y_re, y_im);

    always #10 clk = ~clk;
    initial begin
        clk = 0;
        rst_n = 0;
        #10
        rst_n = 1;

        inFile = $fopen("./tb_fft_in.txt", "r");
        outFile = $fopen("./tb_fft_out.txt", "w");
        while(!$feof(inFile)) begin
            sop_in = 1;
            valid_in = 1;
            $fscanf(inFile, "%b\n", inv);
            $fscanf(inFile, "%h %h\n", x_re, x_im);
            #20
            sop_in = 0;
            for(i = 1; i < 64; i = i + 1) begin
                $fscanf(inFile, "%h %h\n", x_re, x_im);
                #20;
            end
        end
        valid_in = 0;
        #1500
        $fclose(inFile);
        $fclose(outFile);
        $finish;
    end

    always@(posedge clk) begin
        if(valid_out) begin
            if(sop_out) begin
                $fwrite(outFile, "\n");
            end
            $fwrite(outFile, "%h %h\n", y_re, y_im);
        end
    end
endmodule