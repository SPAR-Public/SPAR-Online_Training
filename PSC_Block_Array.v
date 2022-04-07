/*
 * Copyright (c) 2022, SPAR-Internal
 * All rights reserved.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */


`timescale 1ns / 1ps

module PSC_Block_Array
    #(parameter MAX_WORD_LENGTH = 16, parameter[7:0] TILE_DIM = 8'h02)(
        input clk, 
        input reset, 
        input [1:0] mode,
        input start,
        output finish,
        input [8*TILE_DIM-1:0] serial_data_in,
        input [4*MAX_WORD_LENGTH*TILE_DIM-1:0] parallel_data_in,
        output[8*TILE_DIM-1:0] serial_data_out,
        output[4*MAX_WORD_LENGTH*TILE_DIM-1:0] parallel_data_out
    );
    

genvar gi;
// generate and endgenerate is optional
generate
    for (gi=0; gi<TILE_DIM; gi=gi+1) begin : psc_block
        Parallel_Serial_Converter # (TILE_DIM, MAX_WORD_LENGTH, MAX_WORD_LENGTH) ps_convert_block
        (
            clk,  
            reset, 
            mode,
            start,
            finish,
            serial_data_in[8*gi+:8],
            parallel_data_in[4*MAX_WORD_LENGTH*gi+:4*MAX_WORD_LENGTH],
            serial_data_out[8*gi+:8],
            parallel_data_out[4*MAX_WORD_LENGTH*gi+:4*MAX_WORD_LENGTH]
        );
    end
endgenerate
endmodule