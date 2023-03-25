`timescale 1ns / 1ps


module con_max_fc_tb(done,data_out);


localparam width =16;

output done;
output [width*10-1:0] data_out;

reg [63:0] filter;
reg [width*28*28-1:0] data ; 

reg clk;
reg reset_n;
reg en;

integer i;

initial begin
	clk <= 1'b0;
	reset_n <= 1'b0;
	filter <= 64'h3c00_3c00_3c00_3c00;
	en <= 1'b0;
	
	for(i=0;i<28*28;i=i+1) begin	
		data[i*width+:width] = 16'h3c00;
	end	
	
	
	#100 reset_n = 1'b1;
	#100 en = 1'b1;
	
end

always#10 clk = ~clk;


con_max_fc_relu_layer con_max_fc_relu_layer(
	.clk		(clk)	,
	.reset_n	(reset_n)	,
	.filter		(filter)	,
	.data_in	(data)	,
	.data_out	(data_out)	
);





endmodule
