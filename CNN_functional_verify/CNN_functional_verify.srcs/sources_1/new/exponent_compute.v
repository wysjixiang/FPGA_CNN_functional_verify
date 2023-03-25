`timescale 1ns / 1ps


// 目前的实现方案需要多个（包括寄存周期在内,12个时钟周期）个时钟周期运算才能得出9阶泰勒展开近似的e^x运算结果。
// 所以该模块需要考虑到握手！
module exponent_compute(clk,reset_n,en,data_in,locked,data_out);
// 10阶泰勒展开计算指数。 在精度误差为10%要求之内时，输入值的范围为：-2.481445 ~ 3.999;
// 因为4^8 = 65536，超过FP16能表达的最大的数.
// 数值为负时，绝对值越大误差越大。3.999时，误差仅为2.1797%

// 但是，我们还要考虑到之前的节点是Relu层，因此所有的输入数都是正数！！所以精度大大提高。
// 最差精度即为误差精度2.1797%

localparam width = 16;

input clk;
input reset_n;
input en;
input [width-1:0] data_in;
output reg locked;
output reg [width-1:0] data_out;


// 计数模块
reg [4:0] cnt;
always@(posedge clk or negedge reset_n) begin
	if(~reset_n | ~en) begin
		cnt <= 5'd0;
	end else if(cnt == 5'd10) cnt <= cnt;
	else cnt <= cnt + 1'b1;

end


reg [width-1:0] factorial;
always@(posedge clk or negedge reset_n) begin
	if(~reset_n | ~en) factorial <= 16'h0;
	else begin
		case(cnt)
			5'd0: factorial <= 16'h3c00;
			5'd1: factorial <= 16'h3c00;
			5'd2: factorial <= 16'h3800;	// 1/2!
			5'd3: factorial <= 16'h3155;	// 1/3!
			5'd4: factorial <= 16'h2955;	// 1/4!
			5'd5: factorial <= 16'h2044;	// 1/5!
			5'd6: factorial <= 16'h15b0;	// 1/6!

			5'd7: factorial <= 16'h0a80;	// 1/7!
			5'd8: factorial <= 16'h01a0;	// 1/8!
			
			default: factorial <= 16'h0;	
		
		
		endcase
	end

end



// 寄存输入信号
reg [width-1:0] reg_data_in;
always@(posedge clk or negedge reset_n) begin
	if(~reset_n ) begin
		reg_data_in <= 16'd0;
	end else reg_data_in <= data_in;

end


reg [width-1:0] data_pipe1_reg;
wire [width-1:0] data_pipe1_wire;

reg [width-1:0] data_pipe2_reg;
wire [width-1:0] data_pipe2_wire;

reg [width-1:0] data_pipe3_reg;
wire [width-1:0] data_pipe3_wire;

wire [width-1:0] data_sum;


// pipe_1 reg
always@(posedge clk or negedge reset_n) begin
	if(~reset_n | ~en) data_pipe1_reg <= 16'd0;
	else if( cnt == 5'd0) data_pipe1_reg <= 16'h3c00;
	else data_pipe1_reg <= data_pipe1_wire;

end


// pipe_2 reg
always@(posedge clk) begin
	if(~reset_n | ~en) data_pipe2_reg <= 16'h0;
	else data_pipe2_reg <= data_pipe2_wire;

end

// pipe_3 reg
always@(posedge clk) begin
	if(~reset_n | ~en) data_pipe3_reg <= 16'h0;
	else data_pipe3_reg <= data_sum;

end

// 最后寄存
always@(posedge clk) begin
	if(~reset_n | ~en) begin
		locked <= 1'b0;
		data_out <= 16'h0;	
	end else if(cnt == 5'd10) begin
		locked <= 1'b1;
		data_out <= data_sum;
	end else begin
		locked <= 1'b0;
		data_out <= data_out;		
	end
end


// 3级流水运算
// Pipiline_1 : x的幂计算
FP16_mult FP16_mult_L0(
	.floatA		(reg_data_in),
	.floatB		(data_pipe1_reg),
	.product	(data_pipe1_wire)

);

// Pipiline_2 : x的幂与阶数相乘
FP16_mult FP16_mult_L1(
	.floatA		(data_pipe1_reg),
	.floatB		(factorial),
	.product	(data_pipe2_wire)

);

// Pipiline_3 : 累加
FP16_add FP16_add_L0(
	.floatA	(data_pipe2_reg),
	.floatB	(data_pipe3_reg),
	.sum	(data_sum)

);


endmodule




/* 7阶泰勒展开备份

`timescale 1ns / 1ps


// 目前的实现方案需要9个时钟周期运算才能得出7阶泰勒展开近似的e^x运算结果。
// 所以该模块需要考虑到握手！
module exponent_compute(clk,reset_n,en,data_in,locked,data_out);


localparam width = 16;

input clk;
input reset_n;
input en;
input [width-1:0] data_in;
output reg locked;
output reg [width-1:0] data_out;


// 计数模块
reg [3:0] cnt;
always@(posedge clk or negedge reset_n) begin
	if(~reset_n | ~en) begin
		cnt <= 4'd0;
	end else if(cnt == 4'd8) cnt <= cnt;
	else cnt <= cnt + 1'b1;

end


reg [width-1:0] factorial;
always@(posedge clk or negedge reset_n) begin
	if(~reset_n | ~en) factorial <= 16'h0;
	else begin
		case(cnt)
			4'd0: factorial <= 16'h3c00;
			4'd1: factorial <= 16'h3c00;
			4'd2: factorial <= 16'h3800;	// 1/2!
			4'd3: factorial <= 16'h3155;	// 1/3!
			4'd4: factorial <= 16'h2955;	// 1/4!
			4'd5: factorial <= 16'h2044;	// 1/5!
			4'd6: factorial <= 16'h15b0;	// 1/6!
			default: factorial <= 16'h0;	
		
		
		endcase
	end

end



// 寄存输入信号
reg [width-1:0] reg_data_in;
always@(posedge clk or negedge reset_n) begin
	if(~reset_n ) begin
		reg_data_in <= 16'd0;
	end else reg_data_in <= data_in;

end


reg [width-1:0] data_pipe1_reg;
wire [width-1:0] data_pipe1_wire;

reg [width-1:0] data_pipe2_reg;
wire [width-1:0] data_pipe2_wire;

reg [width-1:0] data_pipe3_reg;
wire [width-1:0] data_pipe3_wire;

wire [width-1:0] data_sum;


// pipe_1 reg
always@(posedge clk or negedge reset_n) begin
	if(~reset_n | ~en) data_pipe1_reg <= 16'd0;
	else if( cnt == 4'd0) data_pipe1_reg <= 16'h3c00;
	else data_pipe1_reg <= data_pipe1_wire;

end


// pipe_2 reg
always@(posedge clk) begin
	if(~reset_n | ~en) data_pipe2_reg <= 16'h0;
	else data_pipe2_reg <= data_pipe2_wire;

end

// pipe_3 reg
always@(posedge clk) begin
	if(~reset_n | ~en) data_pipe3_reg <= 16'h0;
	else data_pipe3_reg <= data_sum;

end

// 最后寄存
always@(posedge clk) begin
	if(~reset_n | ~en) begin
		locked <= 1'b0;
		data_out <= 16'h0;	
	end else if(cnt == 4'd8) begin
		locked <= 1'b1;
		data_out <= data_sum;
	end else begin
		locked <= 1'b0;
		data_out <= data_out;		
	end
end


// 3级流水运算
// Pipiline_1 : x的幂计算
FP16_mult FP16_mult_L0(
	.floatA		(reg_data_in),
	.floatB		(data_pipe1_reg),
	.product	(data_pipe1_wire)

);

// Pipiline_2 : x的幂与阶数相乘
FP16_mult FP16_mult_L1(
	.floatA		(data_pipe1_reg),
	.floatB		(factorial),
	.product	(data_pipe2_wire)

);

// Pipiline_3 : 累加
FP16_add FP16_add_L0(
	.floatA	(data_pipe2_reg),
	.floatB	(data_pipe3_reg),
	.sum	(data_sum)

);


endmodule
*/