// 32-bit Brent Kung

module Brent (A,B,Cin,Sum);

parameter N = 32;

input [N-1:0] A, B;
input Cin;

output [N:0] Sum;

//output [N-1] Sum;
//output Cout;

wire  P[6:1][N-1:0];  // [no of stages]  [no of bits]
wire	G[6:1][N-1:0];

wire	[N:0] C;
wire	[N-1:0] S;



// Stage 1

genvar i;

generate
	for(i=0; i<N; i=i+1) begin : stage1
		PG I1 (A[i], B[i], P[1][i],G[1][i]);
	end
endgenerate


//PG I0 (A[0], B[0], P[1][0],G[1][0]);
//PG I1 (A[1], B[1], P[1][1],G[1][1]);
//PG I2 (A[2], B[2], P[1][2],G[1][2]);
//PG I3 (A[3], B[3], P[1][3],G[1][3]);



// Stage 2

genvar j;

generate
	for(j=0; j<(N/2); j=j+1) begin : stage2
		PG_Nx I2 (G[1][2*j+1], P[1][2*j+1], G[1][2*j], P[1][2*j], G[2][j], P[2][j]);
	end
endgenerate


//PG_Nx I4 (G[1][1], P[1][1], G[1][0], P[1][0], G[2][0], P[2][0]);
//PG_Nx I5 (G[1][3], P[1][3], G[1][2], P[1][2], G[2][1], P[2][1]);


// Stage 3

genvar k;

generate
	for(k=0; k<(N/4); k=k+1) begin : stage3
		PG_Nx I3 (G[2][2*k+1], P[2][2*k+1], G[2][2*k], P[2][2*k], G[3][k], P[3][k]);
	end
endgenerate


//PG_Nx I6 (G[2][1], P[2][1], G[2][0], P[2][0], G[3][0], P[3][0]);



// Stage 4

genvar l;

generate
	for(l=0; l<(N/8); l=l+1) begin : stage4
		PG_Nx I4 (G[3][2*l+1], P[3][2*l+1], G[3][2*l], P[3][2*l], G[4][l], P[4][l]);
	end
endgenerate



// Stage 5

genvar m;

generate
	for(m=0; m<(N/16); m=m+1) begin : stage5
		PG_Nx I5 (G[4][2*m+1], P[4][2*m+1], G[4][2*m], P[4][2*m], G[5][m], P[5][m]);
	end
endgenerate



// Stage 6

PG_Nx I6 (G[5][1], P[5][1], G[5][0], P[5][0], G[6][0], P[6][0]);


// Carry Calculation

assign C[0]  = Cin;

// From the last block of every stage
assign C[1]  = G[1][0] | (P[1][0] & C[0]);
assign C[2]  = G[2][0] | (P[2][0] & C[0]);
assign C[4]  = G[3][0] | (P[3][0] & C[0]);
assign C[8]  = G[4][0] | (P[4][0] & C[0]);
assign C[16] = G[5][0] | (P[5][0] & C[0]);
assign C[32] = G[6][0] | (P[6][0] & C[0]);

// From the above values and 1st Stage
assign C[ 3] = G[1][2]  | (P[1][2]  & C[2]);
assign C[ 5] = G[1][4]  | (P[1][4]  & C[4]);

// From Stage 2

assign C[ 6] = G[2][2] | (P[2][2] & C[4]);	// [Stage] [Block No. according to the diagram]



// Stage 3

assign C[ 7] = G[1][6] | (P[1][6] & C[6]);	// Doubt cleared (See diagram)

assign C[ 9] = G[1][8] | (P[1][8] & C[8]);
assign C[10] = G[2][4] | (P[2][4] & C[8]);
assign C[11] = G[1][10] | (P[1][10] & C[10]);
assign C[12] = G[3][2] | (P[3][2] & C[8]);
assign C[13] = G[1][12] | (P[1][12] & C[12]);
assign C[14] = G[2][6] | (P[2][6] & C[12]);	// Doubt in last C[?]  is it from the which last block value ???
assign C[15] = G[1][14] | (P[1][14] & C[14]);

assign C[17] = G[1][16] | (P[1][16] & C[16]);
assign C[18] = G[2][8] | (P[2][8] & C[16]);
assign C[19] = G[1][18] | (P[1][18] & C[18]);
assign C[20] = G[3][4] | (P[3][4] & C[16]);
assign C[21] = G[1][20] | (P[1][20] & C[20]);
assign C[22] = G[2][10] | (P[2][10] & C[20]);
assign C[23] = G[1][22] | (P[1][22] & C[22]);
assign C[24] = G[4][2] | (P[4][2] & C[16]);
assign C[25] = G[1][24] | (P[1][24] & C[24]);
assign C[26] = G[2][12] | (P[2][12] & C[24]);
assign C[27] = G[1][26] | (P[1][26] & C[26]);
assign C[28] = G[3][6] | (P[3][6] & C[24]);
//assign C[28] = G[2][13] | (P[2][13] & C[24]);
assign C[29] = G[1][28] | (P[1][28] & C[28]);
assign C[30] = G[2][14] | (P[2][14] & C[28]);
assign C[31] = G[1][30] | (P[1][30] & C[30]);





// Sum Calculation

//assign S[] = P[1][] ^ C[];



genvar n;

generate
	for(n=0; n<N; n=n+1) begin : sum
		assign S[n] = P[1][n] ^ C[n];
	end
endgenerate


assign Sum = {C[N],S};
//assign Cout = C[4];

endmodule




module PG_Nx (G, P, G_1, P_1, G_Nx, P_Nx);	// G_i, P_i, G_{i-1}, P_{i-1}, G_{i}{i-1}, P_{i}{i-1}
input G, P, G_1, P_1;
output reg G_Nx, P_Nx;

always @(*)
begin

	G_Nx = G | (P & G_1);
	P_Nx = P & P_1;
end

endmodule



module PG (A, B, P, G);
input A, B;
output reg P, G;

always @(*)
begin

	P = A ^ B;
	G = A & B;
end

endmodule




















//// 32-bit Brent Kung
//
//module Brent (A,B,Cin,Sum);
//
//parameter N = 32;
//
//input [N-1:0] A, B;
//input Cin;
//
//output [N:0] Sum;
//
////output [N-1] Sum;
////output Cout;
//
//wire  P[6:1][N-1:0];  // [no of stages]  [no of bits]
//wire	G[6:1][N-1:0];
//
//wire	[N:0] C;
//wire	[N-1:0] S;
//
//
//
//// Stage 1
//
//genvar i;
//
//generate
//	for(i=0; i<N; i=i+1) begin : stage1
//		PG I1 (A[i], B[i], P[1][i],G[1][i]);
//	end
//endgenerate
//
//
////PG I0 (A[0], B[0], P[1][0],G[1][0]);
////PG I1 (A[1], B[1], P[1][1],G[1][1]);
////PG I2 (A[2], B[2], P[1][2],G[1][2]);
////PG I3 (A[3], B[3], P[1][3],G[1][3]);
//
//
//
//// Stage 2
//
//genvar j;
//
//generate
//	for(j=0; j<(N/2); j=j+1) begin : stage2
//		PG_Nx I2 (G[1][2*j+1], P[1][2*j+1], G[1][2*j], P[1][2*j], G[2][j], P[2][j]);
//	end
//endgenerate
//
//
////PG_Nx I4 (G[1][1], P[1][1], G[1][0], P[1][0], G[2][0], P[2][0]);
////PG_Nx I5 (G[1][3], P[1][3], G[1][2], P[1][2], G[2][1], P[2][1]);
//
//
//// Stage 3
//
//genvar k;
//
//generate
//	for(k=0; k<(N/4); k=k+1) begin : stage3
//		PG_Nx I3 (G[2][2*k+1], P[2][2*k+1], G[2][2*k], P[2][2*k], G[3][k], P[3][k]);
//	end
//endgenerate
//
//
////PG_Nx I6 (G[2][1], P[2][1], G[2][0], P[2][0], G[3][0], P[3][0]);
//
//
//
//// Stage 4
//
//genvar l;
//
//generate
//	for(l=0; l<(N/8); l=l+1) begin : stage4
//		PG_Nx I4 (G[3][2*l+1], P[3][2*l+1], G[3][2*l], P[3][2*l], G[4][l], P[4][l]);
//	end
//endgenerate
//
//
//
//// Stage 5
//
//genvar m;
//
//generate
//	for(m=0; m<(N/16); m=m+1) begin : stage5
//		PG_Nx I5 (G[4][2*m+1], P[4][2*m+1], G[4][2*m], P[4][2*m], G[5][m], P[5][m]);
//	end
//endgenerate
//
//
//
//// Stage 6
//
//PG_Nx I6 (G[5][1], P[5][1], G[5][0], P[5][0], G[6][0], P[6][0]);
//
//
//// Carry Calculation
//
//assign C[0]  = Cin;
//
//// From the last block of every stage
//assign C[1]  = G[1][0] | (P[1][0] & C[0]);
//assign C[2]  = G[2][0] | (P[2][0] & C[0]);
//assign C[4]  = G[3][0] | (P[3][0] & C[0]);
//assign C[8]  = G[4][0] | (P[4][0] & C[0]);
//assign C[16] = G[5][0] | (P[5][0] & C[0]);
//assign C[32] = G[6][0] | (P[6][0] & C[0]);
//
//// From the above values and 1st Stage
//assign C[ 3] = G[1][2]  | (P[1][2]  & C[2]);
//assign C[ 5] = G[1][4]  | (P[1][4]  & C[4]);
//
//// From Stage 2
//
//assign C[ 6] = G[2][2] | (P[2][2] & C[4]);	// [Stage] [Block No. according to the diagram]
//
//
//
//// Stage 3
//
//assign C[ 7] = G[1][6] | (P[1][6] & C[6]);	// Doubt cleared (See diagram)
//
//assign C[ 9] = G[1][8] | (P[1][8] & C[8]);
//assign C[10] = G[2][4] | (P[2][4] & C[8]);
//assign C[11] = G[1][10] | (P[1][10] & C[10]);
//assign C[12] = G[3][2] | (P[3][2] & C[8]);
//assign C[13] = G[1][12] | (P[1][12] & C[12]);
//assign C[14] = G[2][6] | (P[2][6] & C[12]);	// Doubt in last C[?]  is it from the which last block value ???
//assign C[15] = G[1][14] | (P[1][14] & C[14]);
//
//assign C[17] = G[1][16] | (P[1][16] & C[16]);
//assign C[18] = G[2][8] | (P[2][8] & C[16]);
//assign C[19] = G[1][18] | (P[1][18] & C[18]);
//assign C[20] = G[3][4] | (P[1][4] & C[16]);
//assign C[21] = G[1][20] | (P[1][20] & C[20]);
//assign C[22] = G[2][10] | (P[2][10] & C[20]);
//assign C[23] = G[1][22] | (P[1][22] & C[22]);
//assign C[24] = G[4][2] | (P[4][2] & C[16]);
//assign C[25] = G[1][24] | (P[1][24] & C[24]);
//assign C[26] = G[2][12] | (P[2][12] & C[24]);
//assign C[27] = G[1][26] | (P[1][26] & C[26]);
//assign C[28] = G[2][13] | (P[2][13] & C[24]);
//assign C[29] = G[1][28] | (P[1][28] & C[28]);
//assign C[30] = G[2][14] | (P[2][14] & C[28]);
//assign C[31] = G[1][31] | (P[1][31] & C[30]);
//
//
//
//
//
//// Sum Calculation
//
////assign S[] = P[1][] ^ C[];
//
//
//
//genvar n;
//
//generate
//	for(n=0; n<N; n=n+1) begin : sum
//		assign S[n] = P[1][n] ^ C[n];
//	end
//endgenerate
//
//
//assign Sum = {C[N],S};
////assign Cout = C[4];
//
//endmodule
//
//
//
//
//module PG_Nx (G, P, G_1, P_1, G_Nx, P_Nx);	// G_i, P_i, G_{i-1}, P_{i-1}, G_{i}{i-1}, P_{i}{i-1}
//input G, P, G_1, P_1;
//output reg G_Nx, P_Nx;
//
//always @(*)
//begin
//
//	G_Nx = G | (P & G_1);
//	P_Nx = P & P_1;
//end
//
//endmodule
//
//
//
//module PG (A, B, P, G);
//input A, B;
//output reg P, G;
//
//always @(*)
//begin
//
//	P = A ^ B;
//	G = A & B;
//end
//
//endmodule
