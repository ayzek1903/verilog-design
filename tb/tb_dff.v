module tb;
    reg clk, d;
    wire q;

    dff uut(.clk(clk), .d(d), .q(q));

    initial clk = 0;
    always #5 clk = ~clk;      // clock toggles every 5 time units (period 10)

    initial begin
        $dumpfile("dff.vcd");
        $dumpvars(0, tb);
        d = 0;
        #7  d = 1;    // change d BETWEEN clock edges
        #10 d = 0;
        #6  d = 1;
        #12 d = 0;
        #8  d = 1;
        #20 $finish;
    end
endmodule