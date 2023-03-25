`timescale 1ns / 1ps


module maxpooling(clk,reset_n,data_in,data_out);


parameter row = 14;
parameter col = 14;
localparam node = row*col;
localparam width = 16;


input clk;
input reset_n;
input [width*node-1:0] data_in;
output reg [width*node/4-1:0] data_out;

wire [width*node/4-1:0] data_ff;



// 1个时钟周期寄存数据
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) data_out <= 'd0;
	else data_out <= data_ff;

end



genvar i;
generate 
	for(i=0;i<row/2;i=i+1) begin
		
		
		pooling_via_row pooling_via_row_inst(
			.data_in		(data_in[(i+1)*2*col*width-1:i*2*col*width]),
			.data_out		(data_ff[(i+1)*row/2*width-1:i*row/2*width])	// 1*7*16
		);

	end

endgenerate

endmodule
