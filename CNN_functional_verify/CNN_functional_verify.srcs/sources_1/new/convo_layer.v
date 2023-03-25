`timescale 1ns / 1ps

// 有两个思路：
// 1、直接用组合电路实现
// 2、用时序电路实现，做一个3级pipeline的卷积模块


// 尝试用时序电路pipeline实现
module convo_layer(
	clk,
	reset_n,
	load,
	din,
	filter,
	
	reg_convo_out
    );
	
parameter num = 4;	
parameter width = 16;	

input clk;
input reset_n;
input load;
input [num*width-1:0] din;
input [num*width-1:0] filter;	
output reg [width-1:0] reg_convo_out;	
	

wire [num*width-1:0] wire_mult_buf;
wire [2*width-1:0] wire_add_buf;
wire [width-1:0] wire_convo_out;

reg [num*width-1:0] reg_mult_buf;
reg [2*width-1:0] reg_add_buf;


// generate for FP_mult
genvar n;

generate
	for(n=0;n<4;n=n+1) begin

		FP16_mult mult_inst(
			.floatA		(din[n*width+:width])	,
			.floatB		(filter[n*width+:width])	,
			.product    (wire_mult_buf[n*width+:width])
		
		);
	end
endgenerate


// 第一级pipeline
always@(posedge clk or negedge reset_n) begin
	if(~reset_n | ~load) begin
		reg_mult_buf <= 0;
	end else begin
		
		reg_mult_buf <= wire_mult_buf;
	end
end



FP16_add add_inst0(
	.floatA		(reg_mult_buf[1*width-1:(1-1)*width])	,
	.floatB		(reg_mult_buf[2*width-1:(2-1)*width])	,
	.sum    	(wire_add_buf[1*width-1:(1-1)*width])

);

FP16_add add_inst1(
	.floatA		(reg_mult_buf[3*width-1:(3-1)*width])	,
	.floatB		(reg_mult_buf[4*width-1:(4-1)*width])	,
	.sum    	(wire_add_buf[2*width-1:(2-1)*width])

);

//第二级pipeline
always@(posedge clk or negedge reset_n) begin
	if(~reset_n ) begin
		reg_add_buf <= 0;
	end else begin
		
		reg_add_buf <= wire_add_buf;
	end
end



FP16_add add_inst2(
	.floatA		(reg_add_buf[1*width-1:(1-1)*width])	,
	.floatB		(reg_add_buf[2*width-1:(2-1)*width])	,
	.sum    	(wire_convo_out)

);

//第三级pipeline
always@(posedge clk or negedge reset_n) begin
	if(~reset_n ) begin
		reg_convo_out <= 0;
	end else begin
		
		reg_convo_out <= wire_convo_out;
	end
end



endmodule
