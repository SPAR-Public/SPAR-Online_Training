`timescale 1ns / 1ps

module PSC_Tile_Array
    #(parameter MAX_WORD_LENGTH = 16, parameter[7:0] ARRAY_DIM = 8'h02, parameter[7:0] TILE_DIM = 8'h02)(
        input clk, 
        input reset, 
        input [1:0] mode,
        input start,
        output finish,
        input [8*ARRAY_DIM*TILE_DIM-1:0] serial_data_in,
        input [4*MAX_WORD_LENGTH*ARRAY_DIM*TILE_DIM-1:0] parallel_data_in,
  
        output[8*ARRAY_DIM*TILE_DIM-1:0] serial_data_out,
        output[4*MAX_WORD_LENGTH*ARRAY_DIM*TILE_DIM-1:0] parallel_data_out
    );
    

genvar gi;
// generate and endgenerate is optional
generate
    for (gi=0; gi<ARRAY_DIM; gi=gi+1) begin : psc_tile
        PSC_Block_Array # (MAX_WORD_LENGTH, TILE_DIM) ps_convert_tile
        (
            clk,  
            reset, 
            mode,
            start,
            finish,
            serial_data_in[8*TILE_DIM*gi+:8*TILE_DIM],
            parallel_data_in[4*MAX_WORD_LENGTH*TILE_DIM*gi+:4*MAX_WORD_LENGTH*TILE_DIM],
            serial_data_out[8*TILE_DIM*gi+:8*TILE_DIM],
            parallel_data_out[4*MAX_WORD_LENGTH*TILE_DIM*gi+:4*MAX_WORD_LENGTH*TILE_DIM]
        );
    end
endgenerate
endmodule
