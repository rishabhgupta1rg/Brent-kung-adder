`timescale 1ns/1ps
module testbench();

parameter N = 32;

reg [N-1:0] A, B;
reg Cin;

wire [N:0] Sum;
//wire Cout;

Brent dut_instance (.A(A), .B(B), .Cin(Cin), .Sum(Sum));

integer i;

initial begin

	for (i=0; i<101; i=i+1)
		begin
		A <= $random;
		B <= $random;
		Cin <= $random %2;
				
					#10;
					if (Sum !== A + B + Cin)
						begin
							$display("Error: Sum is wrong");
							$stop;
							
						end
		end
end

endmodule
