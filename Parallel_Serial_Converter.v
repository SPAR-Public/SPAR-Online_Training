module Parallel_Serial_Converter
 # (parameter SIZE = 4,  parameter MAX_WORD_LENGTH = 32, parameter LENGTH = 32)
(
	clk,  
	reset, 
    mode,
    start,
    finish,
    serial_data_in,
    parallel_data_in,
    serial_data_out,
    parallel_data_out
//    debug_in_mode_1,
//    debug_in_mode_2
);

input clk, reset, start;
input[1:0] mode;
input [8*SIZE-1:0] serial_data_in;
input [4*MAX_WORD_LENGTH*SIZE-1:0] parallel_data_in;
output reg finish;
output[8*SIZE-1:0] serial_data_out;
output[4*MAX_WORD_LENGTH*SIZE-1:0] parallel_data_out;
//output debug_in_mode_1;
//output debug_in_mode_2;
// input[5:0] LENGTH;

integer i;
// 11011110101011011011111011101111
//   01111010101101101111101110111100
reg [4*SIZE*MAX_WORD_LENGTH-1:0] parallel_regs;
// reg [2*4*SIZE-1:0] serial_regs;
reg [7:0] counter;
reg state;
reg counting;
//reg in_mode_1 = 1'b0;
//reg in_mode_2 = 1'b0;
// always@(posedge clk)
// begin
//     if(reset==0) clk2 <= 0;
//     else clk2 <= !clk2;

//     if(start) clk2 <= 1;
// end

always@(posedge clk) begin
    if(reset==0) begin
        counter <= LENGTH;
        finish <= 0;
        counting    <= 0;
    end
    else begin
        if(start) begin
            counter     <= 0;
            finish      <= 0;
            counting    <= 0;
        end
        else if(counter<LENGTH+1) begin
            counter <= counter + 1;
            counting <= 1;
            if(counter == LENGTH) begin
                finish <= 1;
                counting <= 0;
            end
        end
        else finish <= 0;
    end
end


//filling up the parallel regs (writing to parallel regs)
always@(posedge clk)
begin
    if(reset==0) begin
        parallel_regs <= 0;
        i <= 0;
        state <= 0;
    end
    else
    begin
        if(mode==0)
        begin
            parallel_regs <= parallel_regs;
        end
        if(mode==1) begin
//            in_mode_1 = 1'b1;
            if(counting) begin
                case(state)
				0: begin
				state <= 1;
				end
				1: begin
				for(i=0; i<SIZE*4; i=i+1) begin
                    parallel_regs[i*LENGTH-1 + counter -:2] <= serial_data_in[i*2+1 -:2];
                end
                state <= 0;
				end
                endcase
            end
        end
        else if(mode==2)
        begin
//            in_mode_2 = 1'b1;
            parallel_regs <= parallel_data_in;
        end
        
    end
end

assign parallel_data_out = parallel_regs;
//assign debug_in_mode_1 = in_mode_1;
//assign debug_in_mode_2 = in_mode_2;

genvar gi;
generate
for (gi=0; gi<SIZE*4; gi=gi+1) begin : s
    assign serial_data_out[gi*2+1 -:2] = counting && mode==0? parallel_regs[gi*LENGTH+1 + counter-2 -:2] : 2'hz;
end
endgenerate


endmodule