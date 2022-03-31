//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/13/2021 10:19:00 AM
// Design Name: 
// Module Name: TopTop
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module TopTop #(parameter[15:0] DIM = 16'h0505, parameter MAX_WORD_LENGTH = 32)
(
    input clk,
    input reset,
    input start,
    // input[5:0] LENGTH,
    input[31:0] instruction,
    input external,
    input[7:0] Tile_i,
    input[7:0] Tile_j,
    input[7:0] Block_i,
    input[7:0] Block_j,
    input WEA,
    input WEB,
    input[9:0] ADDRA,
    input[9:0] ADDRB,
    input[15:0] DIA,
    input[15:0] DIB,
    output[15:0] DOA,
    output[15:0] DOB,
    input[1:0] Activation_Function,
    input Tanh_In
    
    );

parameter[7:0] ARRAY_DIM = DIM[15:8];
parameter[7:0] TILE_DIM = DIM[7:0];

wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] EAST_O;
wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] WEST_O;
wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] SOUTH_O;
wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] NORTH_O;
wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] EAST_I;
wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] WEST_I;
wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] SOUTH_I;
wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] NORTH_I;

reg[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] WEST_I_Buffer;

wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] SIG_O;
wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] TANH_O;

wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] SIG_I;
wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] TANH_I;  

wire [0:4*ARRAY_DIM*TILE_DIM-1] Ready_Sig;
wire [0:4*ARRAY_DIM*TILE_DIM-1] Ready_Tanh;

Top #({ARRAY_DIM,TILE_DIM}, MAX_WORD_LENGTH) top
    (
        clk,
        reset,
        start,
        instruction,
        external,
        Tile_i,
        Tile_j,
        Block_i,
        Block_j,
        WEA,
        WEB,
        ADDRA,
        ADDRB,
        DIA,
        DIB,
        DOA,
        DOB,
        EAST_I,
        WEST_I,
        SOUTH_I,
        NORTH_I,
        EAST_O,
        WEST_O,
        SOUTH_O,
        NORTH_O
       
    );


assign SIG_I = EAST_O;
Sigmoid_Array #(MAX_WORD_LENGTH, 4*ARRAY_DIM*TILE_DIM) sig
    (
        clk,
        SIG_I,
        SIG_O,
        Ready_Sig //debug:
    );
assign TANH_I = Tanh_In == 0? EAST_O : NORTH_O;
Tanh_Array #(MAX_WORD_LENGTH, 4*ARRAY_DIM*TILE_DIM) tanh
    (
        clk,
        TANH_I,
        TANH_O,
        Ready_Tanh //debug:
    );

//assign WEST_I = 0;
//assign EAST_I = 0;
//assign SOUTH_I = 0;
//assign NORTH_I = Activation_Function == 0? EAST_O : (Activation_Function == 1 && Ready_Sig[0] == 1'b1)? SIG_O : (Activation_Function == 2 && Ready_Tanh[0] == 1'b1)? TANH_O : 'hz;

assign WEST_I = WEST_I_Buffer;
assign EAST_I = Activation_Function == 0? NORTH_O : (Activation_Function == 1 && Ready_Sig[0] == 1'b1)? SIG_O : (Activation_Function == 2 && Ready_Tanh[0] == 1'b1)? TANH_O : 'hz;
assign SOUTH_I = 0;
assign NORTH_I = Activation_Function == 0? EAST_O : (Activation_Function == 1 && Ready_Sig[0] == 1'b1)? SIG_O : (Activation_Function == 2 && Ready_Tanh[0] == 1'b1)? TANH_O : 'hz;

always @(EAST_O)
begin
	if(instruction[31:26] == 5 && instruction[15:11] == 0 && EAST_O != 0)
	begin
		WEST_I_Buffer = EAST_O;
	end
end

//debug: tryting to remove AF from the middle
//assign NORTH_I = EAST_O; //debug: tryting to remove AF from the middle

endmodule
