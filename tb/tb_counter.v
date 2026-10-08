// Testbench for the 4-bit counter
module tb;
  reg clk, rst;
  wire [3:0] count;

  counter uut(.clk(clk), .rst(rst), .count(count));

  initial clk = 0;
  always #5 clk = ~clk;      // clock toggles every 5 ns (period 10 ns)

  initial begin
    $dumpfile("counter.vcd"); // waveform output
    $dumpvars(0, tb);
    rst = 1;
    #12 rst = 0;              // release reset at t = 12 ns
    #100 $finish;            // stop after 100 ns
  end
endmodule
