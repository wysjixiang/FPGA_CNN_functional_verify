`timescale 1ns / 1ps
// 注： 由于FP16精度问题，当计算结果越大，每两个值之间的精度差距会越大。
// 即，精度是会根据值的大小变化的！
// 精度变化范围是：  2^(-14) ~ 2^(15).每两个之间都会有一个区间，这个区间有2^10 1024个表示数。
// 所以FP16拿来算比较小的数是比较好的，当数较大时，就别用了，误差太大！





module con_max_fc_relu_layer(clk,reset_n,filter,data_in,data_out);

	
localparam width = 16;
localparam num_data = 4;
localparam node = 14*14; //	14*14	
localparam output_node = 10;
	
input clk;
input reset_n;
input [num_data*width-1:0] filter;
input [num_data*width*node-1:0] data_in;
output [width*node-1:0] data_out;



reg [49*49*width-1:0] bias_fc1 ;
reg [49*49*width-1:0] product_fac_fc1 ;
reg [49*10*width-1:0] bias_fc2 ;
reg [49*10*width-1:0] product_fac_fc2 ;


integer i;

initial begin
	// bias_fc1 = 'h0;
	// bias_fc2 = 'h0;
	
	for(i=0;i<49*49;i=i+1) begin
		bias_fc1[width*i+:width] = 16'h1418;
	end


	for(i=0;i<49*10;i=i+1) begin
		bias_fc2[width*i+:width] = 16'h1818;
	end	
	
	
	

	for(i=0;i<49*49;i=i+1) begin
		product_fac_fc1[width*i+:width] = 16'h2539;
	end


	for(i=0;i<49*10;i=i+1) begin
		product_fac_fc2[width*i+:width] = 16'h2139;
	end

	
end


wire [width*node-1:0] data_convo ;	// 14*14*16
// 获得第一层卷积后的数据，data_out就是卷积完的。将该数据输入到maxpooling层
convo_control 
#(.node(node) )
	convo_control_inst0(
		.clk				(clk),
		.reset_n			(reset_n),
		.filter				(filter),
		.data_in			(data_in),
		.data_out			(data_convo)
    );
	

wire [width*node/4-1:0] data_maxpooling;	//	7*7*16
// maxpooling
maxpooling maxpooling_inst(
	.clk			(clk)			,
	.reset_n		(reset_n)		,
	.data_in		(data_convo)	,
	.data_out		(data_maxpooling)	
);



wire [width*node/4-1:0] data_fc1 ;	//	7*7*16
// FC-1
FC #(
	.input_node(7*7),
	.output_node(7*7)
) FC1_inst(
	.clk			(clk)				,
	.reset_n		(reset_n)			,
	.data_in		(data_maxpooling)	,
	.bias			(bias_fc1)			,
	.product_fac	(product_fac_fc1)	,
	.data_out		(data_fc1)			
);


wire [width*node/4-1:0] data_relu1 ;	//	7*7*16
// Relu-1
Relu #(
	.node(node/4)
) Relu_layer1_inst(
	.data_in	(data_fc1),
	.data_out   (data_relu1)
);

wire [width*output_node-1:0] data_fc2 ;	//	10*16
// FC-2
FC #(
	.input_node(7*7),
	.output_node(10)
) FC2_inst(
	.clk			(clk)				,
	.reset_n		(reset_n)			,
	.data_in		(data_relu1)	,
	.bias			(bias_fc2)			,
	.product_fac	(product_fac_fc2)	,
	.data_out		(data_fc2)
);




wire [width*output_node-1:0] data_relu2 ;	//	10*16
assign data_out = data_relu2;
// Relu-2
Relu #(
	.node(output_node)
) Relu_layer2_inst(
	.data_in	(data_fc2),
	.data_out   (data_relu2)
);




endmodule
