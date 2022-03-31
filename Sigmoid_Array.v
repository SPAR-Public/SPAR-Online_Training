`timescale 1ns / 1ps

module Sigmoid_Array
    #(parameter N = 16, parameter SIZE = 100)(
		input clk,
        input [N*SIZE-1:0] X,
        output[N*SIZE-1:0] Y,
		output [SIZE-1:0] Ready
        );

genvar gi;
// generate and endgenerate is optional
generate
    for (gi=N*SIZE-1; gi>=0; gi=gi-N) begin : genbit
        Sigmoid_PLAN #(N) g1 (clk, X[gi-:N],Y[gi-:N], Ready[gi/N]); //debug: added Ready
    end
endgenerate

endmodule
