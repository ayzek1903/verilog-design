module tb;
    reg [3:0] a, b, c, d;
    reg [1:0] sel;
    wire [3:0] y;

    mux4b uut(.a(a), .b(b), .c(c), .d(d), .sel(sel), .y(y));

    initial begin
        $dumpfile("mux4b.vcd");
        $dumpvars(0, tb);

        a = 5; b = 12; c = 9; d = 3;
        sel = 2'b00;
        #10 sel = 2'b01;
        #10 sel = 2'b10;
        #10 sel = 2'b11;
        #10 $finish;
    end
endmodule