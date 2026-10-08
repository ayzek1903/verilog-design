// Complementary PWM generator with dead-time for a half-bridge
//
//   pwm_h drives the high-side switch, pwm_l the low-side switch.
//   They are never high at the same time: after one switch turns off,
//   the other waits DEADTIME clock cycles before turning on.
//
//   Building blocks:
//     1. counter      -> sawtooth carrier, one PWM period = 2^WIDTH clocks
//     2. register     -> duty is latched only at the end of a period
//     3. comparator   -> raw PWM = (carrier < duty)
//     4. FSM          -> inserts the dead-time between pwm_h and pwm_l
module pwm_deadtime #(
    parameter WIDTH    = 8,   // carrier resolution in bits
    parameter DEADTIME = 4    // dead-time in clock cycles
)(
    input              clk,
    input              rst,
    input  [WIDTH-1:0] duty,   // 0 = always low side, 2^WIDTH-1 = almost always high side
    output reg         pwm_h,
    output reg         pwm_l
);
    // ---- 1. carrier counter -------------------------------------------
    reg [WIDTH-1:0] carrier;
    always @(posedge clk or posedge rst) begin
        if (rst) carrier <= 0;
        else     carrier <= carrier + 1;   // wraps around: sawtooth
    end

    // ---- 2. duty register (updated only when the period ends) ---------
    // Changing duty in the middle of a period would create a glitch.
    reg [WIDTH-1:0] duty_reg;
    always @(posedge clk or posedge rst) begin
        if (rst)                         duty_reg <= 0;
        else if (carrier == {WIDTH{1'b1}}) duty_reg <= duty;
    end

    // ---- 3. comparator ------------------------------------------------
    wire pwm_raw = (carrier < duty_reg);

    // ---- 4. dead-time FSM ---------------------------------------------
    localparam LOW      = 2'd0,   // low side on
               DEAD_UP  = 2'd1,   // both off, waiting to turn high side on
               HIGH     = 2'd2,   // high side on
               DEAD_DN  = 2'd3;   // both off, waiting to turn low side on

    reg [1:0] state;
    reg [$clog2(DEADTIME+1)-1:0] dead_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= LOW;
            dead_cnt <= 0;
        end else begin
            case (state)
                LOW:     if (pwm_raw)  begin state <= DEAD_UP; dead_cnt <= 0; end
                DEAD_UP: if (!pwm_raw)                      state <= LOW;   // pulse shorter than dead-time: skip it
                         else if (dead_cnt == DEADTIME-1)   state <= HIGH;
                         else                               dead_cnt <= dead_cnt + 1;
                HIGH:    if (!pwm_raw) begin state <= DEAD_DN; dead_cnt <= 0; end
                DEAD_DN: if (pwm_raw)                       state <= HIGH;
                         else if (dead_cnt == DEADTIME-1)   state <= LOW;
                         else                               dead_cnt <= dead_cnt + 1;
            endcase
        end
    end

    // outputs depend only on the state (Moore machine)
    always @(*) begin
        pwm_h = (state == HIGH);
        pwm_l = (state == LOW);
    end
endmodule
