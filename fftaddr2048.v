module fftaddr2048(input wire clock, reset,
input wire enable, //makes the addresser count up
input wire writemode, //read or write mode for addresser (asserted TRUE for writing to MEMORY)
output wire mem_we, //write enable for memory
output wire [10:0] mem_addr0, //memory addresses
output wire [10:0] mem_addr1,
output wire [10:0] tf_addr); //twiddle factor address
/*
Description:
After receiving an enable signal (with writemode = 0), the addresser module does the following:
1. Assert mem_we = 0
2. Output the 2 memory addresses
3. Keep i the same
After receiving an enable signal (with we = 1), the addressor module does the following:
1. Assert mem_we = 1
2. Output the 2 memory addresses
3. Increase i by 2
*/
reg [14:0] index;
// Bits 14-11 are the stage number, bits 10-1 are the group number, bit 0 is the item number
always @(posedge clock) begin
if (reset) begin
index <= 0;
//Initially: stage = 0, group = 0, item = 0
end
if (enable) begin
index <= index + 2;
end
end
//Perform bit reversing and bit circulation
wire [10:0] data0;
wire [10:0] data1;
bitrev11 br0(index[10:0], data0);
bitrev11 br1(index[10:0]+1, data1);
bitcirc_r11 bc0(index[14:11], data0, mem_addr0);
bitcirc_r11 bc1(index[14:11], data1, mem_addr1);
assign mem_we = writemode;
//Get twiddle factor theta
//Address input to CORGEN module: theta = 2pi * (INPUT / 2^INPUT_WIDTH) radians
assign tf_addr = (index[10:0] >> (11-index[14:11])) << (10-index[14:11]);
endmodule
module bitrev11(input wire [10:0] data_in, output wire [10:0] data_out);
assign data_out[0] = data_in[10];
assign data_out[1] = data_in[9];
assign data_out[2] = data_in[8];
assign data_out[3] = data_in[7];
assign data_out[4] = data_in[6];
assign data_out[5] = data_in[5];
assign data_out[6] = data_in[4];
assign data_out[7] = data_in[3];
assign data_out[8] = data_in[2];
assign data_out[9] = data_in[1];
assign data_out[10] = data_in[0];
endmodule
module bitcirc_r11(input wire [3:0] n, input wire [10:0] data_in, output wire [10:0] data_out);
//Bit circulates data_in to the right by n bits
wire [10:0] data_out3;
wire [10:0] data_out2;
wire [10:0] data_out1;
assign data_out3 = (n[3] == 1) ? {data_in[7:0], data_in[10:8]} : data_in;
assign data_out2 = (n[2] == 1) ? {data_out3[3:0], data_out3[10:4]} : data_out3;
assign data_out1 = (n[1] == 1) ? {data_out2[1:0], data_out2[10:2]} : data_out2;
assign data_out = (n[0] == 1) ? {data_out1[0], data_out1[10:1]} : data_out1;
endmodule // bitcirc_r11
