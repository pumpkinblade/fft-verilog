module register#(
    N = 1,
    INIT = {N{1'b0}}
)(
    input clk,
    input rst_n,
    input[N-1:0] d,
    output reg[N-1:0] q
);
    always @(posedge clk, negedge rst_n) begin
        if(~rst_n)begin
            q <= INIT;
        end
        else begin
            q <= d;
        end
    end
endmodule