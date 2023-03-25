`timescale 1ns / 1ps



module Relu(data_in,data_out);


parameter node = 49;
localparam width = 16;

input [width*node-1:0] data_in;
output [width*node-1:0] data_out;


genvar i;

generate
	for(i=0;i<node;i=i+1) begin: loop1
		node_relu node_relu_inst(
		.data_in	(data_in[i*width+:width]),
		.data_out   (data_out[i*width+:width])
		);
		
	end

endgenerate

endmodule
