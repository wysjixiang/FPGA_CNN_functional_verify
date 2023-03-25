`timescale 1ns / 1ps


// 4级流水线
module node_compute(clk,reset_n,product_fac,bias,data_in,data_out);


parameter node = 49;
localparam width = 16;



input clk;
input reset_n;
input [width*node-1:0] product_fac;
input [width*node-1:0] bias;
input [width*node-1:0] data_in;
output reg [width-1:0] data_out;


wire [width*node-1:0] wire_mult_buf;
wire [width*node-1:0] wire_add_buf_0;

genvar i;
generate
	for(i=0;i<node;i=i+1) begin: inst1
		FP16_mult fc_mult_inst(
			.floatA		(data_in[(i+1)*width-1:i*width]),
			.floatB		(product_fac[(i+1)*width-1:i*width])	,
			.product    (wire_mult_buf[(i+1)*width-1:i*width])
		
		);		

		FP16_add fc_add_inst_0(
			.floatA		(wire_mult_buf[(i+1)*width-1:i*width])	,
			.floatB		(bias[(i+1)*width-1:i*width])	,
			.sum    	(wire_add_buf_0[(i+1)*width-1:i*width])

		);		


	end

endgenerate


// 寄存第一级pipeline
reg [width*node-1:0] data_buf_1 ;

always@(posedge clk or negedge reset_n) begin
	if(~reset_n) data_buf_1 <= 'd0;
	else data_buf_1 <= wire_add_buf_0;

end


// 继续累加
wire [width*25-1:0] wire_add_buf_1;
assign wire_add_buf_1[width*25-1-:width] = data_buf_1[width*node-1-:width];

generate
	for(i=0;i< 24;i=i+1) begin: inst2
	
		FP16_add fc_add_inst_1(
			.floatA		(data_buf_1[(i*2+1)*width-1-:width])	,
			.floatB		(data_buf_1[(i*2+2)*width-1-:width])	,
			.sum    	(wire_add_buf_1[(i+1)*width-1:i*width])
		);		

	end

endgenerate


wire [width*13-1:0] wire_add_buf_2;
assign wire_add_buf_2[width*13-1-:width] = wire_add_buf_1[width*25-1-:width];

generate
	for(i=0;i< 12;i=i+1) begin: inst3
	
		FP16_add fc_add_inst_2(
			.floatA		(wire_add_buf_1[(i*2+1)*width-1-:width])	,
			.floatB		(wire_add_buf_1[(i*2+2)*width-1-:width])	,
			.sum    	(wire_add_buf_2[(i+1)*width-1:i*width])
		);		

	end

endgenerate


// 寄存第二级pipeline
reg [width*13-1:0] data_buf_2;

always@(posedge clk or negedge reset_n) begin
	if(~reset_n) data_buf_2 <= 'd0;
	else data_buf_2 <= wire_add_buf_2;

end



// 继续累加
wire [width*7-1:0] wire_add_buf_3;
assign wire_add_buf_3[width*7-1-:width] = data_buf_2[width*13-1-:width];

generate
	for(i=0;i< 6;i=i+1) begin: inst4
	
		FP16_add fc_add_inst_3(
			.floatA		(data_buf_2[(i*2+1)*width-1-:width])	,
			.floatB		(data_buf_2[(i*2+2)*width-1-:width])	,
			.sum    	(wire_add_buf_3[(i+1)*width-1:i*width])
		);		

	end

endgenerate


wire [width*4-1:0] wire_add_buf_4;
assign wire_add_buf_4[width*4-1-:width] = wire_add_buf_3[width*7-1-:width];

generate
	for(i=0;i< 3;i=i+1) begin: inst5
	
		FP16_add fc_add_inst_4(
			.floatA		(wire_add_buf_3[(i*2+1)*width-1-:width])	,
			.floatB		(wire_add_buf_3[(i*2+2)*width-1-:width])	,
			.sum    	(wire_add_buf_4[(i+1)*width-1:i*width])
		);		

	end

endgenerate


// 寄存第三级pipeline
reg [width*4-1:0] data_buf_3;

always@(posedge clk or negedge reset_n) begin
	if(~reset_n) data_buf_3 <= 'd0;
	else data_buf_3 <= wire_add_buf_4;

end



// 继续累加
wire [width*2-1:0] wire_add_buf_5;

generate
	for(i=0;i<2;i=i+1) begin: inst6
	
		FP16_add fc_add_inst_5(
			.floatA		(data_buf_3[(i*2+1)*width-1-:width])	,
			.floatB		(data_buf_3[(i*2+2)*width-1-:width])	,
			.sum    	(wire_add_buf_5[(i+1)*width-1:i*width])
		);		

	end

endgenerate


wire [width-1:0] wire_add_buf_6 ;

FP16_add fc_add_inst_6(
	.floatA		(wire_add_buf_5[1*width-1-:width])	,
	.floatB		(wire_add_buf_5[2*width-1-:width])	,
	.sum    	(wire_add_buf_6)
);

// 寄存第四级pipeline，最后的输出


always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		data_out <= 'd0;
	
	end else data_out <= wire_add_buf_6;

end



endmodule
