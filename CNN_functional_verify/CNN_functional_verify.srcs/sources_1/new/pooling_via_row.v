`timescale 1ns / 1ps


module pooling_via_row(data_in,data_out);


parameter node = 2*14;
localparam width = 16;
localparam num =4;


input [width*node-1:0] data_in;
output [width*node/4-1:0] data_out;	



genvar i;
generate
	for(i=0;i<7;i=i+1) begin
		
		
		find_FP16max find_FP16max_inst(
		.data_in		(data_in[(i+1)*num*width-1:i*num*width]),
		.data_out		(data_out[(i+1)*width-1:i*width])
		);
	end

endgenerate

	
	
	
endmodule
