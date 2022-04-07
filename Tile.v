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


module Tile #(parameter TILE_DIM = 2)(
    clk, 
    reset,
    start,
    instruction,
	external,
    BRAM_i,
    BRAM_j,
 	WEA,
    WEB,
    ADDRA,
    ADDRB,
    DIA,
    DIB,
    DOA,
    DOB,
    EIN,
	WIN,
	NIN,
    SIN,  
    EOUT,
	WOUT,
    NOUT,
    SOUT
    );


input clk;
input reset;
input start;
input external;
wire[3:0] alu_op;
input[31:0] instruction;
input[7:0] BRAM_i;
input[7:0] BRAM_j;
input WEA;
input WEB;
input[9:0] ADDRA;
input[9:0] ADDRB;
input[15:0] DIA;
input[15:0] DIB;
output[15:0] DOA;
output[15:0] DOB;
input[0:TILE_DIM*8-1] WIN;
input[0:TILE_DIM*8-1] EIN;
input[0:TILE_DIM*8-1] SIN;
input[0:TILE_DIM*8-1] NIN;
output[0:TILE_DIM*8-1] WOUT;
output[0:TILE_DIM*8-1] EOUT;
output[0:TILE_DIM*8-1] SOUT;
output[0:TILE_DIM*8-1] NOUT;


wire[9:0] addra;
wire[9:0] addrb;
wire[1:0] east_mode;
wire[1:0] west_mode;
wire[1:0] south_mode;
wire[1:0] north_mode;

//other helper signals
wire[7:0] count; //debug: was [6:0]
wire[2:0] state; //debug:


wire[7:0] EtoW[TILE_DIM-1:0][TILE_DIM-1:0];
wire[7:0] WtoE[TILE_DIM-1:0][TILE_DIM-1:0];
wire[7:0] StoN[TILE_DIM-1:0][TILE_DIM-1:0];
wire[7:0] NtoS[TILE_DIM-1:0][TILE_DIM-1:0];

wire[15:0] wDOA[TILE_DIM-1:0][TILE_DIM-1:0];
wire[15:0] wDOB[TILE_DIM-1:0][TILE_DIM-1:0];

assign DOA = wDOA[BRAM_i][BRAM_j];
assign DOB = wDOB[BRAM_i][BRAM_j];

Controller #(32) FSM
		(
			clk, 
			reset,
			start,
			instruction,
			//alu control
			alu_op,
			//bram control
			wea,
			web,
			addra, 
			addrb,
			//move control
			east,	
			west,	
			south,	
			north,
			east_mode,
			west_mode,
			south_mode,
			north_mode,
			
			//other helper signals
			count,
			state
		);


generate

genvar gi;
genvar gj;

for (gi=0; gi<TILE_DIM; gi=gi+1) begin : ROW
	for (gj=0; gj<TILE_DIM; gj=gj+1) begin : COL
		PE16_Block #(TILE_DIM, 32) block 
		(
			clk,
			reset,
            // LENGTH,
			//alu control
			alu_op,
			//bram control
			(gi==BRAM_i && gj==BRAM_j? (external? WEA : wea) : wea),
			(gi==BRAM_i && gj==BRAM_j? (external? WEB : web) : web),
			(gi==BRAM_i && gj==BRAM_j? (external? ADDRA : addra) : addra),
			(gi==BRAM_i && gj==BRAM_j? (external? ADDRB : addrb) : addrb),
            gi==BRAM_i && gj==BRAM_j? DIA : 16'hzzzz,
            gi==BRAM_i && gj==BRAM_j? DIB : 16'hzzzz,
		    wDOA[gi][gj],
            wDOB[gi][gj],
            external,
			//other helper signals
			count,
			// bram_init_flag,
			// bram_init_flag? bram_init_d : 16'hzzzz,
			state,
			//move control
			east,	
			west,	
			south,		
			north,		
			//move data
			// gi%SIZE == SIZE-1  		? WtoE[gi-(SIZE-1)] : WtoE[gi+1],
			// gi%SIZE == 0  			? EtoW[gi+(SIZE-1)] : EtoW[gi-1],
			// gi	<   SIZE  			? StoN[gi+(SIZE*(SIZE-1))] : StoN[gi-SIZE],
			// gi	>= (SIZE*(SIZE-1))  ? NtoS[gi-(SIZE*(SIZE-1))] : NtoS[gi+SIZE],
			gj==TILE_DIM-1              ? EIN[8*gi+:8] : WtoE[gi][gj+1],//Ein
			gj==0                   ? WIN[8*gi+:8] : EtoW[gi][gj-1],//Win
			gi==0   			    ? NIN[8*gj+:8] : StoN[gi-1][gj],//Nin was gi+1
			gi==TILE_DIM-1              ? SIN[8*gj+:8] : NtoS[gi+1][gj],//Sin was gi-1
		    EtoW[gi][gj], //Eout
			WtoE[gi][gj], //Wout
			NtoS[gi][gj], //Nout
			StoN[gi][gj]  //Sout
			
		
		);
		assign EOUT[8*gi+:8] = EtoW[gi][TILE_DIM-1];
		assign WOUT[8*gi+:8] = WtoE[gi][0]; //debug: was [0][gi]
		assign SOUT[8*gj+:8] = StoN[TILE_DIM-1][gj];
		assign NOUT[8*gj+:8] = NtoS[0][gj];
	end
  end
  
endgenerate
endmodule