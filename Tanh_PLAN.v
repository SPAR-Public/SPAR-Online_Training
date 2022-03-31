`timescale 1ns / 1ps

module Tanh_PLAN
    #(parameter N = 32)
    (input clk,
    input [N-1:0] x_in,
    output reg [N-1:0] out,
	output reg ready
    );
    
parameter [N/2-1:0] z16 = 0; //16 zeros
parameter [N/2-2:0] z15 = 0; //15 zeros
parameter [N/2-3:0] z14 = 0; //14 zeros
parameter [N/2-4:0] z13 = 0; //13 zeros
parameter [N/2-6:0] z11 = 0; //11 zeros


    reg [N-1:0] x, shif_x, out_tmp, sig_out, two_sig_out, neg_two_sig_out;
    reg [N-1:0] abs_x;
    reg [3:0] state = 4'b0;
    
    always @(clk, x)
    begin
        case(state)
        4'b0000:
        begin
            x = x_in << 1;
            x = -x;
            if ($signed(x) < 0) abs_x = -x;
            else abs_x = x;
            if(abs_x > {z13, 3'b101, z16}) // |x| > 5
            begin
                state = 4'b0001;
            end
            else if(abs_x < {z13, 3'b101, z16} &&  abs_x >= {z14,5'b10011,z13}) // 2.375 =< |x| < 5
            begin
                state = 4'b0010;
            end
            else if(abs_x >= {z15, 1'b1, z16} &&  abs_x < {z14,5'b10011,z13}) // 1 =< |x| < 2.375
            begin
                state = 4'b0011;
            end
            else if(abs_x < {z15, 1'b1, z16}) // 0=< |x| < 1
            begin
                state = 4'b0100;
            end
        end //case 0000
        4'b0001:
        begin
            // 1
            out_tmp[N-1:0] = {z15, 1'b1, z16};
            state = 4'b0101;
        end //case 0001
        4'b0010:
        begin
            //0.03125 * |x| + 0.84375
            shif_x = abs_x >> 5;
            out_tmp = shif_x + {z16,5'b11011,z11};
            //add(shif_x, {z16,'b11011,z11}, out_tmp); 
            state = 4'b0101;
        end //case 0010
        4'b0011:
        begin
            //0.125 * |x| + 0.625
            shif_x = abs_x >> 3;
            out_tmp = shif_x + {z16,3'b101,z13};
            //add(shif_x, {z16,'b101,z13}, out_tmp);
            state = 4'b0101; 
        end //case 0011
        4'b0100:
        begin
             // 0.25 * |x| + 0.5
            shif_x = abs_x >> 2;
            out_tmp = shif_x + {z16,1'b1,z15};
            //add(shif_x, {z16,'b1,z15}, out_tmp); 
            state = 4'b0101; 
        end //case 0100
        4'b0101:
        begin
            if ($signed(x) > 0) sig_out = out_tmp;
            else sig_out = {z15, 1'b1, z16} - out_tmp; //1 - sig(x)
            state = 4'b0110;
        end //case 0101
        4'b0110:
        begin
             two_sig_out = sig_out << 1; //2 * sig(-2x)
            //neg_two_sig_out = -two_sig_out;
            out = {z15, 1'b1, z16} - two_sig_out;
            //sub({z15, 'b1, z16}, two_sig_out, out);  //1 - 2 * sig(-2x)
			ready = 1'b1;
			state = 4'b0000;
        end //case 0110
        endcase //case

        //5 in 8 bits b1010000
        //1 in 8 bits b00010000
        //2.37 in 8 bits b0100110
        //0.84375 in 8 bits b00001101
        //0.625 in 8 bits b00001010
        //0.25 in 8 bits b00000100
    end //always
endmodule