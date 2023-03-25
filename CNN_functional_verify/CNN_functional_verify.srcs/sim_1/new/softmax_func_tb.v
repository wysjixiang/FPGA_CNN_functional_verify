`timescale 1ns / 1ps

module softmax_func_tb(ack,data_out);



localparam width = 16;
localparam node = 10;

output ack;
output [width*node-1:0] data_out;


reg clk;
reg en;
reg reset_n;
reg [width*node-1:0] data_in;
reg [width-1:0] sum_exp;


initial begin
	clk <= 1'b0;
    en <= 1'b0;
    reset_n <= 1'b0;
	data_in <= 160'h0000371c3b1c3d553f1c407141554238431c43ff;
	sum_exp <= 16'h58B2;
	#100 reset_n = 1'b1;
	#100 en = 1'b1;
	
	#3000 en = 1'b0;
	#100 en = 1'b1;
	
end

always#10 clk = ~clk;


softmax_func softmax_func_inst(
	.clk			(clk),
	.reset_n		(reset_n),
	.en				(en),
	.exp_data_in	(data_in),	
	.sum_exp		(sum_exp),
	.ack			(ack),	
	.data_out		(data_out)
);




endmodule
