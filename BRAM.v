module BRAM
	(	
		clk,
		reset,
		wea,
		web,
		addra,
		addrb,
		dia,
		dib,
		doa,
		dob
	);
input clk, reset, wea, web;
input [9:0] addra,addrb;
input [15:0] dia, dib;
output reg [15:0] doa,dob;

(* ram_style = "block" *) reg[15:0] ram[1023:0] ;

always @(posedge clk) 
begin
	if (wea) begin
	    ram[addra] = dia;
	end
	doa = ram[addra];
	
end
always @(posedge clk) 
begin  
    if (web) begin
	    ram[addrb] = dib;
	end
	dob = ram[addrb];
end

endmodule
