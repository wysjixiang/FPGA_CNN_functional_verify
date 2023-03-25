`timescale 1ns / 1ps

module convo_control(
	clk,reset_n,filter,data_in,data_out
    );
	
	
parameter node = 14*14;
localparam width = 16;
localparam num_data = 4;	
	
input clk;
input reset_n;
input [num_data*width-1:0] filter;
input [num_data*width*node-1:0] data_in ;

// output	[num_data*width-1:0] data_out;
output [width*node-1:0] data_out ;


reg load;
	
always@(posedge clk or negedge reset_n) begin	
	if(~reset_n) begin
		load <= 1'b0;
	end
	else load <= 1'b1;
	
end	
	

genvar i;

generate
	for(i=0;i<node;i=i+1) begin
		
		// 3级流水模块
		convo_layer convo_layer_inst(
		.clk				(clk),
		.reset_n			(reset_n),
		.load				(load),
		.din				(data_in[(i+1)*num_data*width-1:i*num_data*width]),
		.filter				(filter),
		.reg_convo_out		(data_out[(i+1)*width-1:i*width])
		);
	
	end

endgenerate
	
	
endmodule
