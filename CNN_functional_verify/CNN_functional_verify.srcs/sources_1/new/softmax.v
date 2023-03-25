`timescale 1ns / 1ps


module softmax(clk,reset_n,en_input,data_in,ready_for_data,done,data_out);

localparam node = 10;
localparam width = 16;

input clk;
input reset_n;
input en_input;
input [width*node-1:0] data_in;
output ready_for_data;
output done;
output [width*node-1:0] data_out;


// done/ready signal of exponent module
wire exponent_done;
wire exponent_ready;
wire exponent_en;

// reg of exponent and sum of exponent
wire [width*node-1:0] exponent_data_wire;
wire [width-1:0] exponent_sum_wire;
reg [width*node-1:0] exponent_data_reg;
reg [width-1:0] exponent_sum_reg;

// done/ready signal of exponent module
wire softmax_func_done;
wire softmax_func_ready;

// en signal of softmax_func module  
wire softmax_func_en;


// input buffer state_buffer
localparam s_buffer_full = 1'b0;
localparam s_buffer_empty = 1'b1;
reg state_buffer;

assign ready_for_data = (state_buffer == s_buffer_empty);


// reg of data_in 
reg [width*node-1:0] data_input;






// input buffer state_buffer
localparam s_exponent_full = 1'b0;
localparam s_exponent_empty = 1'b1;
reg state_exponent;





// buffer state machine
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) state_buffer <= s_buffer_empty;
	else if(en_input & (state_buffer == s_buffer_empty))
		state_buffer <= s_buffer_full;
	else if( (state_buffer == s_buffer_full) & (exponent_done == 1'b1) & (state_exponent == s_exponent_empty))
		state_buffer <= s_buffer_empty;
	else state_buffer <= state_buffer;
end


always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		data_input <= 16'h0000;
	end else if(en_input & (state_buffer == s_buffer_empty))
		data_input <= data_in;
	else data_input <= data_input;

end



// en signal of exponent module 
assign exponent_en = (state_buffer == s_buffer_full);



///////////////////////////////////
// exponent module part




// state machine of expoent module
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) state_exponent <= s_exponent_empty;
	else if(exponent_done & (state_exponent == s_exponent_empty))
		state_exponent <= s_exponent_full;
	else if((state_exponent == s_exponent_full) & (softmax_func_done == 1'b1))
		state_exponent <= s_exponent_empty;
	else state_exponent <= state_exponent;

end





// control of the result of exponent module 
always@(posedge clk or negedge reset_n) begin
	if(~reset_n)  begin
		exponent_data_reg <= 'h0;
		exponent_sum_reg <= 'h0;
	end else if(exponent_done & (state_exponent == s_exponent_empty)) begin
		exponent_data_reg <= exponent_data_wire;
		exponent_sum_reg <= exponent_sum_wire;
	end else begin
		exponent_data_reg <= exponent_data_reg;
		exponent_sum_reg <= exponent_sum_reg;	
	end
end



assign softmax_func_en = (state_exponent == s_exponent_full);

assign done = softmax_func_done;


// 需要144个时钟周期才能算完10个数的指数和他们的和
exponent_and_sum_exp exponent_and_sum_exp_inst(
	.clk				(clk),
	.reset_n			(reset_n),
	.en					(exponent_en),
	.data_in			(data_input),
	.done				(exponent_done),
	.ready				(exponent_ready),
	.reg_exponent		(exponent_data_wire),	
	.data_sum_exponent	(exponent_sum_wire)
);


// 大概只需要13-16个时钟周期即可，主要取决于算reciprocal收敛的速度
softmax_func softmax_func_inst(
	.clk			(clk)		,
	.reset_n		(reset_n)			,
	.en				(softmax_func_en)			,
	.exp_data_in	(exponent_data_reg)			,
	.sum_exp		(exponent_sum_reg)			,
	.done			(softmax_func_done)	 ,
	.ready			(softmax_func_ready) ,
	.data_out		(data_out)	
);


endmodule
