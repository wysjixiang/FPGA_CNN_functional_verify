`timescale 1ns / 1ps


module top_layer(clk,reset_n,en_input,filter_input,data_in,valid,done,data_out);
	


localparam width = 16;
localparam num_data = 4;
localparam node = 14*14; //	14*14	
localparam output_node = 10;

input clk;
input reset_n;
input en_input;
input [num_data*width-1:0] filter_input;
input [num_data*width*node-1:0] data_in;	// 784 bits
output valid;
output done;
output [output_node*width-1:0] data_out;




// reg of input data 
reg [num_data*width-1:0] filter_reg;
reg [num_data*width*node-1:0] data_con_relu_reg;

// done signal of con_max_fc_relu_layer
wire done_con_max_fc_relu_layer;

// state_softmax
reg state_softmax;
wire [width*10-1:0] data_out_con_max_fc_relu_layer;
wire [width*10-1:0] data_into_softmax;

wire ready_softmax;
wire en_softmax;


// state_buffer machine
localparam s_buffer_empty = 1'b0;
localparam s_buffer_full  = 1'b1;
reg state_buffer;
reg [3:0] cnt;
localparam counter = 11;


assign valid = (state_buffer == s_buffer_empty);



assign done_con_max_fc_relu_layer = (cnt == counter);


// state machine transaction
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) state_buffer <= s_buffer_empty;
	else if(en_input & (state_buffer == s_buffer_empty))
		state_buffer <= s_buffer_full;
	else if((state_buffer == s_buffer_full) & done_con_max_fc_relu_layer & ready_softmax)
		state_buffer <= s_buffer_empty;
	else state_buffer <= state_buffer;
end


// cnt is for counting period 
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) cnt <= 'd0;
	else if((state_buffer == s_buffer_full) & cnt == counter) cnt <= cnt;
	else if(state_buffer == s_buffer_full) cnt <= cnt + 1'b1;
	else cnt <= 'd0;

end


// input data is valid when condition is satisfied
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		data_con_relu_reg <= 'h0;
		filter_reg <= 'h0;
	end else if(en_input & (state_buffer == s_buffer_empty)) begin
		data_con_relu_reg <= data_in;
		filter_reg <= filter_input;
	end else begin
		data_con_relu_reg <= data_con_relu_reg;
		filter_reg <= filter_reg;
	end
end





assign data_into_softmax = data_out_con_max_fc_relu_layer;

// state machine of softmax
// state machine transaction

always@(posedge clk or negedge reset_n) begin
	if(~reset_n) state_softmax <= s_buffer_empty;
	else if(done_con_max_fc_relu_layer & (state_softmax == s_buffer_empty))
		state_softmax <= s_buffer_full;
	else if((state_softmax == s_buffer_full) & ready_softmax)
		state_softmax <= s_buffer_empty;
	else state_softmax <= state_softmax;
end


con_max_fc_relu_layer con_max_fc_relu_layer_inst(
	.clk		(clk)		,
	.reset_n	(reset_n)		,
	.filter		(filter_reg)		,
	.data_in	(data_con_relu_reg)		,
	.data_out	(data_out_con_max_fc_relu_layer)		
);

assign en_softmax = ( state_softmax == s_buffer_full);


softmax softmax_inst(
	.clk				(clk)				,
	.reset_n			(reset_n)			,
	.en_input			(en_softmax)					,
	.data_in			(data_into_softmax)					,
	.ready_for_data		(ready_softmax)		,
	.done				(done)				,
	.data_out			(data_out)		
);
	

endmodule
