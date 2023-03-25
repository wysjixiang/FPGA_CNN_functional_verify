`timescale 1ns / 1ps


module FC(clk,reset_n,data_in,bias,product_fac,data_out);


parameter input_node = 49;
parameter output_node = 49;
localparam width = 16;



input clk;
input reset_n;
input [input_node*width-1:0] data_in ;
input [input_node*output_node*width-1:0] bias ;
input [input_node*output_node*width-1:0] product_fac ;
output [output_node*width-1:0] data_out;



genvar i;
generate 
	for(i=0;i<output_node;i=i+1) begin: inst_0
		
		node_compute node_compute_inst
		(
			.clk			(clk)		,
			.reset_n		(reset_n)		,
			.product_fac	(product_fac[(i+1)*input_node*width-1-:width*input_node])		,
			.bias			(bias[(i+1)*input_node*width-1-:width*input_node])		,
			.data_in		(data_in)		,
			.data_out		(data_out[(i+1)*width-1-:width])		
		);

	end

endgenerate






endmodule
