module fftx82048(input wire clock, reset,
input wire [7:0] input_data_in,
input wire [10:0] input_addr,
input wire input_we,
input wire input_enable,
output reg done,
output wire [31:0] data_out);
//To start off the FFT, assert input_enable for 1 cycle
wire mem_we;
wire [10:0] mem_addr0;
wire [10:0] mem_addr1;
wire [31:0] mem_data_in0;
wire [31:0] mem_data_in1;
wire [31:0] mem_data_out0;
wire [31:0] mem_data_out1;
wire addr_enable;
wire addr_writemode;
wire butterfly_enable;
wire ctrl_done;
wire [10:0] tf_addr;
wire [31:0] tf_data;
//Working memory
bram_2048_32 mem(.clka(clock),
.clkb(clock),
.addra(~done ? mem_addr0 : input_addr),
.addrb(mem_addr1),
.wea(~done ? mem_we : input_we),
.web(mem_we),
.douta(mem_data_out0),
.doutb(mem_data_out1),
.dina(~done ? mem_data_in0 : {{8{input_data_in[7]}}, input_data_in , 16'b0}),
.dinb(mem_data_in1)
);
assign data_out = mem_data_out0;
//FFT controller
fftctrl2048 cpu(.clock(clock), .reset(reset),
.enable(input_enable),
.addr_enable(addr_enable),
.addr_writemode(addr_writemode),
.butterfly_enable(butterfly_enable),
.done(ctrl_done));
//Addresser
fftaddr2048 addresser(.clock(clock), .reset(reset),
.enable(addr_enable),
.writemode(addr_writemode),
.mem_we(mem_we), //write enable for memory
.mem_addr0(mem_addr0), //memory address
.mem_addr1(mem_addr1),
.tf_addr(tf_addr));
//Twiddle factor generator
//exp2048 tfgen(.clock(clock), .reset(reset), .addr(tf_addr), .data_out(tf_data));
exp2048cg tfgen(.CLK(clock), .THETA(tf_addr), .COSINE(tf_data[31:16]), .SINE(tf_data[15:0]));
//Butterfly
butterflyx8 b(.clock(clock), .reset(reset),
.enable(butterfly_enable),
.a(mem_data_out0),
.b(mem_data_out1),
.tf(tf_data), //twiddle factor
.y(mem_data_in0),
.z(mem_data_in1));
always @(posedge clock) begin
if (reset) begin
done <= 1;
end
if (input_enable) begin
done <= 0;
end
if (ctrl_done) begin
done <= 1;
end
end
endmodule
