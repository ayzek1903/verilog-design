// 4-bit up counter — increments by 1 on every rising clock edge
module counter(
  input clk,
  input rst,
  output reg [3:0] count
);
  always @(posedge clk or posedge rst) begin
    if (rst)
      count <= 4'b0000;
    else
      count <= count + 1;
  end
endmodule
