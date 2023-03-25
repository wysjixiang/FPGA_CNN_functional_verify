`timescale 1ns / 1ps


module top_tb(done,data_out);


localparam width =16;

output done;
output [width*10-1:0] data_out;

reg [63:0] filter;
// reg [width*28*28-1:0] data ; 
reg [width-1:0] data [28*28-1:0] ; 
reg [width*28*28-1:0] data_in;

reg clk;
reg reset_n;
reg en;

integer i;

initial begin
	$readmemh("D:/Vivado_Project/CNN_functional_verify/FPGA_CNN_data.txt",data);
	clk <= 1'b0;
	reset_n <= 1'b0;
	filter <= 64'h3c00_3c00_3c00_3c00;
	en <= 1'b0;
	
	for(i=0;i<28*28;i=i+1) begin	
		data_in[i*width+:width] = data[i];
	end	
	
	
	#100 reset_n = 1'b1;
	#100 en = 1'b1;
	
end

always#10 clk = ~clk;

wire valid;

top_layer top_layer_inst(
	.clk			(clk)	,
	.reset_n		(reset_n)	,
	.en_input		(en)	,
	.filter_input	(filter)	,
	.data_in		(data_in)	,
	.valid			(valid)	,
	.done			(done)	,
	.data_out		(data_out)	
);

endmodule
