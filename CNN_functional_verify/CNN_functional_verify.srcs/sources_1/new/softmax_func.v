`timescale 1ns / 1ps
module softmax_func(clk,reset_n,en,exp_data_in,sum_exp,done,ready,data_out);



localparam width = 16;
localparam node = 10;

input clk;
input reset_n;
input en;
input [width*node-1:0] exp_data_in;
input [width-1:0] sum_exp;

output done;
output ready;
output reg [width*node-1:0] data_out;



// wire of reciprocal signal
wire reciprocal_locked;
wire [width-1:0] exp_reciprocal;


// wire of FP16 mult
wire [width-1:0] exp_mult;
reg [width-1:0] mult_input;


// state machine
localparam s_idle = 4'd0;
localparam s_reciprocal = 4'd1;
localparam s_e0 = 4'd2;
localparam s_e1 = 4'd3;
localparam s_e2 = 4'd4;
localparam s_e3 = 4'd5;
localparam s_e4 = 4'd6;
localparam s_e5 = 4'd7;
localparam s_e6 = 4'd8;
localparam s_e7 = 4'd9;
localparam s_e8 = 4'd10;
localparam s_e9 = 4'd11;
localparam s_buf = 4'd12;
localparam s_end = 4'd13;

reg [3:0] state;
reg reciprocal_en;

assign ready = (state == s_idle);

always@(posedge clk or negedge reset_n) begin
	reciprocal_en <= 1'b1;
	
	if(~reset_n | ~en)  begin
		state <= s_idle;
		reciprocal_en <= 1'b0;
	end else if(state == s_reciprocal) begin
		if(reciprocal_locked == 1'b1) begin
			state <= state + 1'b1;
		end else state <= state;
	end else if(state == s_end) state <= s_end;
	else state <= state + 1'b1;

end

// done signal
assign done = (state == s_end);


always@(posedge clk) begin
	data_out <= data_out;
	
	case(state)
		s_idle			: data_out <= 'h0;

		s_e0 			: data_out[width*0+:width] <= exp_mult;
		s_e1 			: data_out[width*1+:width] <= exp_mult;
		s_e2 			: data_out[width*2+:width] <= exp_mult;
		s_e3 			: data_out[width*3+:width] <= exp_mult;
		s_e4 			: data_out[width*4+:width] <= exp_mult;
        s_e5 			: data_out[width*5+:width] <= exp_mult;
        s_e6 			: data_out[width*6+:width] <= exp_mult;
        s_e7 			: data_out[width*7+:width] <= exp_mult;
        s_e8 			: data_out[width*8+:width] <= exp_mult;
		s_e9			: data_out[width*9+:width] <= exp_mult;

		default			:	data_out <= data_out;

	endcase
end


always@(posedge clk ) begin
	case(state) 
		
		s_reciprocal 	: begin
			if(reciprocal_locked == 1'b1) mult_input <= exp_data_in[width*0+:width];
			else mult_input <= 16'h0;
		end
		s_e0 			:   mult_input <= exp_data_in[width*1+:width];
		s_e1 			:   mult_input <= exp_data_in[width*2+:width];
		s_e2 			:   mult_input <= exp_data_in[width*3+:width];
		s_e3 			:   mult_input <= exp_data_in[width*4+:width];
		s_e4 			:   mult_input <= exp_data_in[width*5+:width];
		s_e5 			:   mult_input <= exp_data_in[width*6+:width];
		s_e6 			:   mult_input <= exp_data_in[width*7+:width];
		s_e7 			:   mult_input <= exp_data_in[width*8+:width];
		s_e8 			:   mult_input <= exp_data_in[width*9+:width];

		default			: mult_input <= 16'h3c00;
		

	endcase
end


FP16_mult FP16_mult_inst(
	.floatA		(exp_reciprocal),
	.floatB		(mult_input)	,
	.product	(exp_mult)	
);


FP16_reciprocal FP16_reciprocal_inst(
	.clk		(clk)				,
	.reset_n	(reset_n)			,
	.en			(reciprocal_en)		,
	.data_in	(sum_exp)			,
	.data_out	(exp_reciprocal)	,
	.locked		(reciprocal_locked)			
);


endmodule
