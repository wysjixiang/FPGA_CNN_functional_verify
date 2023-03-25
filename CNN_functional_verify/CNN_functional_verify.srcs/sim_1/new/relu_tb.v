`timescale 1ns / 1ps


module relu_tb(data_out);



output reg [15:0] data_out;

localparam node = 49;
localparam width = 16;


reg [width-1:0] data_rom [node-1:0];
reg [width*node-1:0] data_buf;
reg [5:0] addr;

 // localparam file_path = "D:/Vivado_Project/CNN_functional_verify/CNN_functional_verify.srcs/sim_1/new/relu_test_data.txt";

wire [width*node-1:0] data_relu;
reg clk;
reg reset_n;

initial	begin
	$readmemh("relu_test_data.txt",data_rom);
	clk <= 1'b0;
	reset_n <= 1'b0;
	#100 reset_n <= 1'b1;
end


always#10 clk = ~clk;



Relu #(
	.node(node)	
) relu_inst (
	.data_in	(data_buf),
	.data_out	(data_relu)
);


always@(posedge clk or negedge reset_n) begin
	if(~reset_n) addr <= 6'd0;
	else if(addr == 6'd48) addr <= addr ;
	else addr <= addr + 1'b1;

end


always@(posedge clk) begin
	
	data_buf[addr*width+:width] <= data_rom[addr];

end


reg [5:0] cnt;
always@(posedge clk or negedge reset_n) begin

	data_out <= data_relu[cnt*width+:width];
	if(~reset_n) begin
		cnt <= 6'd0;
		
	end else if(cnt == 6'd48) cnt <= 6'd0;
	else cnt <= cnt + 1'b1;
	


end

endmodule
