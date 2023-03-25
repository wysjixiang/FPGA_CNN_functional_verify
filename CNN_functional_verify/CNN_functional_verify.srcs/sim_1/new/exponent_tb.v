`timescale 1ns / 1ps


module exponent_tb(locked,data_out);

localparam width = 16;


output locked;
output [width-1:0] data_out;


reg [width-1:0] data_in;
reg clk;
reg reset_n;
reg en;


initial begin
	clk <= 1'b0;
	reset_n <= 1'b0;
	en <= 1'b0;
	data_in <= 16'hc0f6; //-2.481445

	#100 reset_n = 1'b1;
	#200 en = 1'b1;

	# 500 en = 1'b0;
	# 100 en <= 1'b1;
	data_in <= 16'hc000;  // -2
	
	
	# 500 en = 1'b0;
	# 100 en <= 1'b1;
	data_in <= 16'hbc00;   //-1
	
	# 500 en = 1'b0;
	# 100 en <= 1'b1;
	data_in <= 16'h0000; 	//0

	# 500 en = 1'b0;
	# 100 en <= 1'b1;
	data_in <= 16'h4200;	//3

	# 500 en = 1'b0;
	# 100 en <= 1'b1;
	data_in <= 16'h43ff;	//3.999
	
end


always#10 clk = ~clk;




exponent_compute exponent_compute_inst(
	.clk		(clk)	,
	.reset_n	(reset_n)	,
	.en			(en)	,
	.data_in	(data_in)	,
	.locked		(locked)	,
	.data_out	(data_out)	
);



endmodule
