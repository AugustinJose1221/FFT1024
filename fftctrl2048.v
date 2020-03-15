module fftctrl2048(input wire clock, input wire reset,
input wire enable,
output reg addr_enable,
output reg addr_writemode,
output reg butterfly_enable,
output reg done);
reg [3:0] state;
reg [15:0] iterations;
reg [3:0] waitcounter;
/*
States
0: Stopped
1: Started, addresser is outputing correct address
2: Butterfly enable asserted
3: Butterfly enable deasserted, waiting for butterfly
4: Butterfly done, write is asserted
5: Write deasserted, addresser enabled to advance to next address
6: Waiting for addresser to finish
7: Done, Check for correct # of iterations
*/
always @(posedge clock) begin
if (reset) begin
state <= 0;
iterations <= 0;
waitcounter <= 0;
done <= 0;
addr_enable <= 0;
addr_writemode <= 0;
butterfly_enable <= 0;
end
if (state == 0 && enable) begin
state <= 1;
done <= 0;
end
if(state == 1) begin
state <= 2;
butterfly_enable <= 1;
end
/*
if(state == 1 && waitcounter < 1) begin
waitcounter <= waitcounter + 1;
end
if(state == 1 && waitcounter == 1) begin
waitcounter <= 0;
state <= 2;
butterfly_enable <= 1;
end
*/
if (state == 2) begin
state <= 3;
butterfly_enable <= 0;
end
if (state == 3 && waitcounter < 1) begin
waitcounter <= waitcounter + 1;
end
if (state == 3 && waitcounter == 1) begin
waitcounter <= 0;
state <= 4;
addr_writemode <= 1;
end
if (state == 4) begin
state <= 5;
addr_writemode <= 0;
end
if (state == 5) begin
state <= 6;
addr_enable <= 1;
end
if (state == 6) begin
addr_enable <= 0;
if (iterations == 11263) begin
iterations <= 0;
state <= 7;
done <= 1;
end
else begin
iterations <= iterations + 1;
state <= 1;
end
end
if (state == 7) begin
done <= 0;
state <= 0;
end
end
endmodule
