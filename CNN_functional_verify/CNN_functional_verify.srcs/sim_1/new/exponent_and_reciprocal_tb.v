`timescale 1ns / 1ps


module exponent_and_reciprocal_tb(ready,data_out,data_sum_exponent);


localparam width = 16;
localparam node = 10;

output ready;
output [width*node-1:0] data_out;
output [width-1:0] data_sum_exponent;


reg clk;
reg en;
reg reset_n;
reg [width*node-1:0] data_in;



initial begin
	clk <= 1'b0;
    en <= 1'b0;
    reset_n <= 1'b0;
	data_in <= 160'h0000371c3b1c3d553f1c407141554238431c43ff;

	#100 reset_n = 1'b1;
	#100 en = 1'b1;
	
	// # 500 en = 1'b0;
	// # 100 en = 1'b1;

end

always#10 clk = ~clk;


exponent_and_sum_exp exponent_and_sum_exp_inst(
	.clk				(clk),
	.reset_n			(reset_n),
	.en					(en),
	.data_in			(data_in),
	.ready				(ready),
	.reg_exponent		(data_out),
	.data_sum_exponent  (data_sum_exponent)
);



endmodule
