`timescale 1ns / 1ps



module FP16_reciprocal(clk,reset_n,en,data_in,data_out,locked);


parameter DATA_WIDTH=16;
input [DATA_WIDTH-1:0] data_in; //the number that we need to get the 1/number of
input clk;
input en;
input reset_n;
output reg[DATA_WIDTH-1:0] data_out; // = 1/data_in
output reg locked;


// Xn+1 = 2*Xn - data_in[mantissa]*Xn^2;	
// FP16的数据, s,E,M  变为 s,-E,1/M;
wire [DATA_WIDTH-1:0] Xi_pre ;
wire [DATA_WIDTH-1:0] Xi ; // X[i]= 43/17 - (32/17)D'	//这个是初值
wire [DATA_WIDTH-1:0] Xip1; //X[i+1]
wire [DATA_WIDTH-1:0] out0; // Xi*D
wire [DATA_WIDTH-1:0] out1; // 1-Xi*D
wire [DATA_WIDTH-1:0] out2; // X*(1-Xi*D)
reg  [DATA_WIDTH-1:0] mux;

wire [15:0] data_buf;

wire [4:0] exponent;
//assign exponent = 5'd14 - data_in[14:10] + Xip1[14:10];


wire [15:0] fac_1;
assign data_buf = {{1'b0,5'd14},data_in[9:0]};
assign exponent = 5'd14 - data_in[14:10] + mux[14:10];
assign fac_1 = 16'h3C00;


localparam P1=	16'h410F; // 43/17
localparam P2=	16'hBF87; // -32/17


// 得到初值Xi；X[i]= 43/17 - (32/17)data_buf
// 初值的选取和收敛的速度有很大关系
FP16_mult F_mult0 (P2,data_buf,Xi_pre); // -(32/17)* D'
FP16_add F_add0 (Xi_pre,P1,Xi); // 43/17 * (-32/17)D'

// 迭代过程
FP16_mult F_mult1 (mux,data_buf,out0); // Xi*D'
FP16_add F_sub (fac_1,{1'b1,out0[DATA_WIDTH-2:0]},out1); // 1-Xi*D
FP16_mult F_mult2 (mux,out1,out2); // Xi*(1-Xi*D)
FP16_add F_add1 (mux,out2,Xip1); //Xi+Xi*(1-D*Xi)



always@(posedge clk or negedge reset_n) begin
	if(~reset_n ) begin
		mux <= 16'd0;
		data_out <= 16'd0;
		locked <= 1'b0;
	end	else if(en == 1'b0) begin
		mux <= Xi;

	end else begin

		if(mux == Xip1) begin
			mux <= Xip1;
			locked <= 1'b1;
			data_out <={data_in[15],exponent,Xip1[9:0]}; //sign of number, new exponent, mantissa of Xip1
		end else begin
			locked <= 1'b0;
			mux <= Xip1; //continue until ack is 1
		
		end
	end
end


endmodule
