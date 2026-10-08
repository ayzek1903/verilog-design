// Testbench for pwm_deadtime
//   - small carrier (5 bits = 32 clocks per period) so the waveform stays readable
//   - duty steps: 25 % -> 75 % -> a pulse shorter than the dead-time
//   - self-check: reports an error if pwm_h and pwm_l are ever high together
module tb;
    reg        clk, rst;
    reg  [4:0] duty;
    wire       pwm_h, pwm_l;

    pwm_deadtime #(.WIDTH(5), .DEADTIME(2)) uut (
        .clk(clk), .rst(rst), .duty(duty), .pwm_h(pwm_h), .pwm_l(pwm_l)
    );

    initial clk = 0;
    always #5 clk = ~clk;          // 10 ns clock period

    integer errors = 0;
    always @(posedge clk)
        if (pwm_h && pwm_l) begin
            errors = errors + 1;
            $display("ERROR at %0t ns: both switches on (shoot-through)", $time);
        end

    initial begin
        $dumpfile("pwm_deadtime.vcd");
        $dumpvars(0, tb);
        rst = 1; duty = 8;          // 8/32 = 25 %
        #12 rst = 0;
        #640 duty = 24;             // 24/32 = 75 %, takes effect at the next period
        #640 duty = 1;              // 1-clock pulse, shorter than the 2-clock dead-time
        #640;
        if (errors == 0) $display("PASS: no shoot-through");
        $finish;
    end
endmodule
