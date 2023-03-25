`timescale 1ns / 1ps


module exponent_and_sum_exp(clk,reset_n,en,data_in,done,ready,reg_exponent,data_sum_exponent);

localparam node = 10;
localparam width = 16;

input clk;
input reset_n;
input en;
input [width*node-1:0] data_in;
output reg done;
output ready;
output reg [width*node-1:0] reg_exponent;
output [width-1:0] data_sum_exponent;



// state reg
localparam s_idle = 5'd0;
localparam s_e0 = 5'd1;
localparam s_e1 = 5'd2;
localparam s_e2 = 5'd3;
localparam s_e3 = 5'd4;
localparam s_e4 = 5'd5;
localparam s_e5 = 5'd6;
localparam s_e6 = 5'd7;
localparam s_e7 = 5'd8;
localparam s_e8 = 5'd9;
localparam s_e9 = 5'd10;
localparam s_sum_exp = 5'd11;
localparam s_end = 5'd12;


// reg of input to exponent module
reg [width-1:0] reg_exponent_input;

// reg of output to exponent module
wire [width-1:0] wire_exponent_output;


// reg of input to add module
reg [width-1:0] reg_add_input;

// reg of output to add module
wire [width-1:0] wire_add_output;
reg [width-1:0] reg_add_output;

// reg of enable signal to exponent module
reg en_exponent;

// ack of exponent module
wire exponent_locked;

// state machine
reg [3:0] state;


assign data_sum_exponent = reg_add_output;
assign ready = (state == s_idle);


always@(posedge clk or negedge reset_n) begin
	if(~reset_n | ~en) begin
		state <= s_idle;
	end else if(state == s_end) begin
		state <= s_end;
	end else if((en_exponent & exponent_locked) | state == s_idle | state == s_sum_exp) begin
		state <= state + 1'b1;
	end else state <= state;
		
end


// done signal control
always@(posedge clk or negedge reset_n) begin
	if(~reset_n | ~en)  done <= 1'b0;
	else if(state == s_end) done <= 1'b1;
	else done <= 1'b0;

end

// reg_exponent_input control
always@(posedge clk or negedge reset_n) begin
	if(~reset_n | ~en) begin
		reg_exponent_input <= 16'h0;
	end else begin
	
		case(state)

			s_e0		:   reg_exponent_input <= data_in[width*0+:width];
			s_e1		:   reg_exponent_input <= data_in[width*1+:width];
			s_e2		:   reg_exponent_input <= data_in[width*2+:width];
			s_e3		:   reg_exponent_input <= data_in[width*3+:width];
			s_e4		:   reg_exponent_input <= data_in[width*4+:width];
			s_e5		:   reg_exponent_input <= data_in[width*5+:width];
			s_e6		:   reg_exponent_input <= data_in[width*6+:width];
			s_e7		:   reg_exponent_input <= data_in[width*7+:width];
			s_e8		:   reg_exponent_input <= data_in[width*8+:width];
			s_e9		:   reg_exponent_input <= data_in[width*9+:width];

			default: 	reg_exponent_input <= 16'h0;
			
		endcase
	end
end


// reg_add_input control
always@(posedge clk or negedge reset_n) begin
	if(~reset_n | ~en) begin
		reg_add_input <= 16'h0;
	end else begin
		case(state)

			s_e0		:   reg_add_input <= 16'h0;
			s_e1		:   reg_add_input <= reg_exponent[width*0+:width];
			s_e2		:   reg_add_input <= reg_exponent[width*1+:width];
			s_e3		:   reg_add_input <= reg_exponent[width*2+:width];
			s_e4		:   reg_add_input <= reg_exponent[width*3+:width];
			s_e5		:   reg_add_input <= reg_exponent[width*4+:width];
			s_e6		:   reg_add_input <= reg_exponent[width*5+:width];
			s_e7		:   reg_add_input <= reg_exponent[width*6+:width];
			s_e8		:   reg_add_input <= reg_exponent[width*7+:width];
			s_e9		:   reg_add_input <= reg_exponent[width*8+:width];
			s_sum_exp	:	reg_add_input <= reg_exponent[width*9+:width];

			default: 	reg_add_input <= 16'h0;
		endcase
	end
	
end


// reg_add_output control
always@(posedge clk or negedge reset_n) begin
	if(~reset_n | ~en ) begin
		reg_add_output <= 16'h0;
	end else if((en_exponent & exponent_locked) | state == s_sum_exp) begin
		reg_add_output <= wire_add_output;
	end else reg_add_output <= reg_add_output;
	
end




// FP16 adder inst
FP16_add FP16_add_inst(
	.floatA		(reg_add_input)		,
	.floatB		(reg_add_output)	,
	.sum		(wire_add_output)	
);




// en_exponent control
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) en_exponent <= 1'b0;
	else if(~en | state == s_idle | state == s_end) begin
		en_exponent <= 1'b0;
	end else if(exponent_locked == 1'b1) en_exponent <= 1'b0;
	else en_exponent <= 1'b1;
end





// reg of exponent
always@(posedge clk or negedge reset_n) begin
	if(~reset_n | ~en) begin
		reg_exponent <= 'h0;
	end else begin	
		reg_exponent <= reg_exponent;
		
		if(en_exponent & exponent_locked) begin
			
			case(state)
				s_e0 : reg_exponent[width*0+:width] <= wire_exponent_output;
				s_e1 : reg_exponent[width*1+:width] <= wire_exponent_output;
				s_e2 : reg_exponent[width*2+:width] <= wire_exponent_output;
				s_e3 : reg_exponent[width*3+:width] <= wire_exponent_output;
				s_e4 : reg_exponent[width*4+:width] <= wire_exponent_output;
				s_e5 : reg_exponent[width*5+:width] <= wire_exponent_output;
			    s_e6 : reg_exponent[width*6+:width] <= wire_exponent_output;
			    s_e7 : reg_exponent[width*7+:width] <= wire_exponent_output;
			    s_e8 : reg_exponent[width*8+:width] <= wire_exponent_output;
			    s_e9 : reg_exponent[width*9+:width] <= wire_exponent_output;
			endcase
		end
		
	end
		
end



// 这里只用了一个模块循环地算指数，但是速度太慢了，14个周期才能计算出一个指数值
// 可以复用10个模块，一次全部算出10个数的指数，然后再转移到下个模块加和求出指数的sum值
// 这样大概可以把144个运算周期降低到23个周期以下	
exponent_compute	exponent_compute_inst(
	.clk		(clk)					,
	.reset_n	(reset_n)				,
	.en			(en_exponent)			,
	.data_in	(reg_exponent_input)	,
	.locked		(exponent_locked)		,
	.data_out	(wire_exponent_output)	
);



endmodule
