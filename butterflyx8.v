module butterflyx8(input wire clock, reset,
input wire enable,
input wire [31:0] a,
input wire [31:0] b,
input wire [31:0] tf, //twiddle factor
output reg [31:0] y,
output reg [31:0] z);
//Inputs: Two 32-bit complex numbers (16 signed bits real - more signfct. bits,
// 16 signed bits complex - less signfct. bits)
reg state;
reg signed [31:0] r_1;
reg signed [31:0] r_2;
reg signed [31:0] j_1;
reg signed [31:0] j_2;
wire signed [15:0] b_r = b[31:16];
wire signed [15:0] b_j = b[15:0];
wire signed [15:0] tf_r = tf[31:16];
wire signed [15:0] tf_j = tf[15:0];
always @(posedge clock) begin
if(reset) begin
state <= 0;
y <= 0;
z <= 0;
r_1 <= 0;
r_2 <= 0;
j_1 <= 0;
j_2 <= 0;
end
if(enable && state == 0) begin
r_1 <= b_r * tf_r;
r_2 <= b_j * tf_j;
j_1 <= b_r * tf_j;
j_2 <= b_j * tf_r;
state <= 1;
end
//Note: For twiddle factors, 2^14 = +1, -2^14 = -1
//My own lookup table: 2^15 and -2^15
/*if(state == 1) begin
y[31:16] <= a[31:16] + r_1[29:14] - r_2[29:14];
y[15:0] <= a[15:0] + j_1[29:14] + j_2[29:14];
z[31:16] <= a[31:16] - r_1[29:14] + r_2[29:14];
z[15:0] <= a[15:0] - j_1[29:14] - j_2[29:14];
state <= 0;
end*/
if(state == 1) begin
y[31:16] <= a[31:16] + r_1[30:15] - r_2[30:15];
y[15:0] <= a[15:0] + j_1[30:15] + j_2[30:15];
z[31:16] <= a[31:16] - r_1[30:15] + r_2[30:15];
z[15:0] <= a[15:0] - j_1[30:15] - j_2[30:15];
state <= 0;
end
end
endmodule
