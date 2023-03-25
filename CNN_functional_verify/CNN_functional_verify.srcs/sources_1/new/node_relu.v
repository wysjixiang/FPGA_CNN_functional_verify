`timescale 1ns / 1ps

module node_relu(data_in,data_out);

localparam width = 16;

input [width-1:0] data_in;
output reg [width-1:0] data_out;


always@(*) begin
	if(data_in[width-1] == 1'b1) data_out = 16'd0;
	else data_out = data_in;

end

endmodule
