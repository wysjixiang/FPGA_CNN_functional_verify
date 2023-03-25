`timescale 1ns / 1ps

module softmax_tb(done,data_out);



localparam width = 16;
localparam node = 10;

output done;
output [width*node-1:0] data_out;


reg clk;
reg en;
reg reset_n;
reg [width*node-1:0] data_in;
reg [width*node-1:0] data_generator;

wire ready_for_data;

initial begin
	clk <= 1'b0;
    en <= 1'b0;
    reset_n <= 1'b0;
	data_generator <= 160'h0000371c3b1c3d553f1c407141554238431c43ff;
	
	#100 reset_n = 1'b1;
	#100 en = 1'b1;
	
	#100 reset_n = 1'b0;
	en = 1'b0;
	#100 reset_n = 1'b1;
	#100 en =1'b1;
	
end

always#10 clk = ~clk;


always@(posedge clk or negedge reset_n) begin
	if(~reset_n) data_in <= 'h0;
	else if(ready_for_data) data_in <= data_generator;
	else data_in <= data_in;
end

softmax softmax_inst(
	.clk				(clk),
	.reset_n			(reset_n),
	.en_input			(en),
	.data_in			(data_in),
	.ready_for_data		(ready_for_data),
	.done				(done),
	.data_out			(data_out)
);






endmodule
