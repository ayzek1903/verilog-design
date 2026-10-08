module tb;
    reg a, b, sel;
    wire y;

    mux2 uut(.a(a), .b(b), .sel(sel), .y(y));

    initial begin
        $dumpfile("mux2.vcd");
        $dumpvars(0, tb);

        a = 0; b = 1; sel = 0;   // sel=0 -> y = b = 1
        #10 sel = 1;             // sel=1 -> y = a = 0
        #10 a = 1;               // a=1, sel=1 → y=1
        #10 sel = 0;             // sel=0 → y=b=1
        #10 b = 0;               // b=0, sel=0 → y=0
        #10 $finish;
    end
endmodule
