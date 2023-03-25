`timescale 1ns / 1ps


module reciprocal_tb(data_out,locked);

output [15:0] data_out;
output locked;

reg [15:0] data;
reg clk;
reg reset_n;
reg en;



initial	begin
	clk <= 1'b0;
	reset_n <= 1'b0;
	data <= 16'h4000;
	en <= 1'b0;
	#100 reset_n = 1'b1;
	#200	en = 1'b1;
	

end


always#20 clk = ~clk;



FP16_reciprocal FP16_reciprocal_inst(
	.clk		(clk)	,
	.reset_n	(reset_n)	,
	.en			(en)	,
	.data_in	(data)	,
	.data_out	(data_out)	,
	.locked		(locked)	
);




endmodule
