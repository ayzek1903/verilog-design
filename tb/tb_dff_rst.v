// Testbench for dff_rst: shows reset, capture delay and a missed short pulse
module tb;
    reg clk, rst, d;
    wire q;

    dff_rst uut(.clk(clk), .rst(rst), .d(d), .q(q));

    initial clk = 0;
    always #5 clk = ~clk;      // rising edges: 5, 15, 25, 35, 45, 55, 65

    initial begin
        $dumpfile("dff_rst.vcd");
        $dumpvars(0, tb);
        rst = 1; d = 0;
        #12 rst = 0;      // t=12: reset released

        #4  d = 1;        // t=16 (just after edge 15) -> q captures it only at t=25 (delay)
        #10 d = 0;        // t=26 -> q goes 0 at t=35

        #11 d = 1;        // t=37  \  short pulse between edges
        #4  d = 0;        // t=41  /  (back to 0 before edge 45 -> q MISSES it)

        #11 d = 1;        // t=52 -> q captures it at t=55
        #18 $finish;      // t=70
    end
endmodule
