// 2-to-1 multiplexer
module mux2 ( 
input a ,
input b,
input sel,
output reg y 
);
always @(*) begin
if (sel)
y=a ;
else 
y=b ;
end 
endmodule 
