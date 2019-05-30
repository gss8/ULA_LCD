// 50MHz
module ULA_LCD(clk, rs, rw, en, dados, led, SOMA, SUBT, MULT, IGUAL, A, B, sinalA, sinalB);
    
	input [7:0] A;
	input [7:0] B;
	input sinalA;
	input sinalB;
	input SOMA;
	input SUBT;
	input MULT;
	input IGUAL;
	output led;
	output en;
	output rw;
	output rs;
	output [7:0] dados;
	input clk;
	reg led = 0;
	reg rs = 0;
	reg rw =0;
	reg en = 0;
	reg [7:0] dados;
	integer c45=0, c5=0, c1=0, charPos=0, c25=0;
	integer iniciar=0, flag5=0, flag45=0, flagbt1=0, flagbt2=0, flagbt3=0, flagbt4=0, operacao=0, flag2meio=0, est2;
	reg flag_rst=1'b0;
	reg [31:0] estado=0;
	reg subest = 0;
    
	parameter clear = 1, opSOMA=1, opSUBT=2, opMULT=3, opIGUAL=4, skipLn=192, WAIT=10, WRITE=11, DEFAULT=6;
    
    
	always @(posedge clk) begin
    	if(flag_rst) begin
        	c45 = 0;
        	flag5 = 0;
        	flag45 = 0;
        	flag2meio = 0;
    	end
    	if(c45 == 2250000) begin
            	c45 = 0;
            	flag45 = 1;
    	end
    	else begin
        	c45 = c45+1;
    	end
    	if(c5 == 250000) begin
        	c5 = 0;
        	flag5 = 1;
    	end
    	else begin
        	c5 = c5 + 1;
    	end
    	if(c25 == 125000) begin
			flag2meio = 1;
		end
		else begin
			c25 = c25 + 1;
		end
	end
    
    
	always @(posedge clk & !iniciar) begin
    	case(estado)
   		 
			0: begin
				if(flag45) estado <= 1;
			end
   		 
        	1: begin
   			 if(subest == 0) begin
   				 en <= 0;
   				 subest <= 1;
   				 flag_rst <= 1;
   			 end
   			 else if(subest == 1) begin
   				 if(flag5) begin
   					 c1 = c1+1;
   					 rs <= 1'b0;
   					 rw <= 1'b0;
   					 en <= 1'b1;
   					 dados <= 8'b00111000;
   					 flag_rst <= 1;
   				 end
   				 else begin
   					 en <= 0;
   					 flag_rst <= 0;
   				 end
   				 if(c1 == 4) begin
   					 flag_rst <= 1;
   					 estado <= 20;
   					 subest <= 0;
   					 est2 <= 2;
   				 end
   			 end
           	 
           	 
        	end
       	 
        	20: begin
				if(subest == 0) begin
					en <= 0;
					subest <= 1;
					flag_rst <= 1;
				end
				else if(subest == 1) begin
					if(flag2meio) begin
						estado <= est2;
						subest <= 0;
					end
					else begin
						flag_rst <= 0;
					end
				end
    	
			end
        	
        	2: begin
   			 if(subest == 0) begin
   				 en <= 0;
   				 subest <= 1;
   				 flag_rst <= 1;
   			 end
   			 
   			 else if(subest == 1) begin  	
				if(flag5) begin
					 rs <= 1'b0;
					 rw <= 1'b0;
					 en <= 1'b1;
					 dados <= 8'b00001111;
					 flag_rst <= 1;
					 subest <= 0;
					 estado <= 20;
					 est2 <= 3;	
				end
				else flag_rst <= 0; 
   			 end
           	 
        	end
       	 
        	3: begin
   			 if(subest == 0) begin
   				 en <= 0;
   				 subest <= 1;
   				 flag_rst <= 1;
   			 end
   			 
   			 if(subest == 1) begin
   				 if(flag5) begin
   					 rs <= 1'b0;
   					 rw <= 1'b0;
   					 en <= 1'b1;
   					 dados <= 8'b00000001;
   					 flag_rst <= 1;
   					 subest <= 0;
   					 estado <= 20;
   					 est2 <= 4;
   				 end
   				 else begin
   					 en <= 0;
   					 flag_rst <= 0;
   				 end
   			 end
   			 
           	 
        	end
       	 
        	4: begin
				 if(subest == 0) begin
					 en <= 0;
					 subest <= 1;
					 flag_rst <= 1;
				 end
				 
				 if(subest == 1) begin
					 if(flag5) begin
						 rs <= 1'b0;
						 rw <= 1'b0;
						 en <= 1'b1;
						 dados <= 8'b0000110;
						 flag_rst <= 1;
						 subest <= 0;
						 estado <= 20;
						 est2 <= 5;
					 end
					 else begin
						 en <= 0;
						 flag_rst <= 0;
					 end
				 end
           	 
        	end
        	
        	5: begin
				if(subest == 0) begin
					dados <= 0;
					 en <= 0;
					 subest <= 1;
					 flag_rst <= 1;
				 end
				 
				 if(subest == 1) begin
					 if(flag5) begin
						 rs <= 1;
						 rw <= 0;
						 en <= 1;
						 dados <= 32;
						 subest <= 0;
						 est2 <= 6;
						 estado <= 20; 
					 end
					 else begin
						 en <= 0;
						 flag_rst <= 0;
					 end
				 end
			end
			
			6: begin
				en <= 0;
				dados <= 32;
				if(!SOMA & !flagbt1) begin
					flagbt1 = 1;
				end
				else if(SOMA & flagbt1) begin
					subest <= 0;
					operacao = opSOMA;
					estado <= 9;
					charPos <= 21;
					flagbt1 <= 0;
					flag_rst <= 1;
				end
				 
				if(!SUBT & !flagbt2) begin
					flagbt2 = 1;
				end
				else if(SUBT & flagbt2) begin
					subest <= 0;
					operacao = opSUBT;
					estado <= 7;
					flagbt2 = 0;
				end
				 
				if(!MULT & !flagbt3) begin
					flagbt3 = 1;
				end
				else if(MULT & flagbt3) begin
					subest <= 0;
					operacao = opMULT;
					estado <= 7;
					flagbt3 = 0;
				end
				 
				if(!IGUAL & !flagbt4) begin
					flagbt4 = 1;
				end
				else if(IGUAL & flagbt4) begin
					charPos <= 0;
					subest <= 0;
					operacao = opIGUAL;
					estado <= 15;
					flagbt4 = 0;
				end
   			 
			end
        	
			9: begin
				if(subest == 0) begin
					rs <= 0;
					rw <= 0;
					en <= 0;
					dados <= 0;
					subest <= 1;
					flag_rst <= 1;
				end
				else if(subest == 1) begin
					if(flag5) begin
						rs <= 0;
						rw <= 0;
						en <= 1;
						dados <= 8'b00000001;
						subest <= 0;
						flag_rst <= 1;
						estado <= 20;
						est2 <= 10;

					end
				end
			
			end
			
			
        	10: begin
				if(subest == 0) begin
					en <= 0;
					subest <= 1;
					flag_rst <= 1;
				end
				else if(subest == 1) begin
					if(flag5) begin
						subest <= 0;
						flag_rst <= 1;
						estado <= 11;

					end
					else begin
						en <= 0;
					end
				end
   			end
   			 
   			
   			11: begin
				if (charPos == 21) begin
					estado <= 10;
					charPos <= 20;
				end
				else if (charPos == 20) begin
					rs <= 1;
					rw <= 0;
					en <= 1;
					dados <= 32;
					charPos <= 0;
					estado <= 20;
					est2 <= 10;
				end	
				else if(charPos == 0) begin
					rs <= 1;
					rw <= 0;
					en <= 1;
					dados <= ((A/100) + 48);
					charPos <= 1;
					estado <= 20;
					est2 <= 10;
				end
				else if(charPos == 1) begin
					rs <= 1;
					rw <= 0;
					en <= 1;
					dados <= (((A/10)%10) + 48);
					charPos <= 2;
					estado <= 20;
					est2 <= 10;
				end
				else if(charPos == 2) begin
					rs <= 1;
					rw <= 0;
					en <= 1;
					dados <= ((A%10) + 48);
					charPos <= 3;
					estado <= 20;
					est2 <= 10;
				end
				else if(charPos == 3) begin
					rs <= 1;
					rw <= 0;
					en <= 1;
					dados <= 32;
					charPos <= 4;
					estado <= 20;
					est2 <= 10;
				end
				else if(charPos == 4) begin
					rs <= 1;
					rw <= 0;
					en <= 1;
					dados <= 43;
					charPos <= 5;
					estado <= 20;
					est2 <= 10;
				end
				else if(charPos == 5) begin
					rs <= 1;
					rw <= 0;
					en <= 1;
					dados <= 32;
					charPos <= 6;
					estado <= 20;
					est2 <= 10;
				end
				else if(charPos == 6) begin
					rs <= 1;
					rw <= 0;
					en <= 1;
					dados <= ((B/100) + 48);
					charPos <= 7;
					estado <= 20;
					est2 <= 10;
				end
				else if(charPos == 7) begin
					rs <= 1;
					rw <= 0;
					en <= 1;
					dados <= ((B/10)%10 + 48);
					charPos <= 8;
					estado <= 20;
					est2 <= 10;
				end
				else if(charPos == 8) begin
					rs <= 1;
					rw <= 0;
					en <= 1;
					dados <= ((B%10) + 48);
					charPos <= 9;
					estado <= 20;
					est2 <= 10;
				end
				else if(charPos == 9) begin
					rs <= 1;
					rw <= 0;
					en <= 1;
					dados <= 32;
					charPos <= 10;
					estado <= 20;
					est2 <= 10;
				end
				else if(charPos == 10) begin
					estado <= 20;
					est2 <= 6;
				end
   		 
			end
   			  
   			15: begin
				if(subest == 0) begin
					en <= 0;
					led  = 1;
					subest <= 1;
					flag_rst <= 1;
				end
				else if(subest == 1) begin
					if(flag5) begin
						rs <= 0;
						rw <= 0;
						en <= 1;
						subest <= 0;
						estado <= 20;
						est2 <= 13;
						dados <= 8'b11000000;
					end
					else begin
						flag_rst <= 0;
						en <= 0;
					end
				end
				
			end
			
			13: begin
				if(subest == 0) begin
					en <= 0;
					subest <= 1;
					flag_rst <= 1;
				end
				else if(subest == 1) begin
					if(flag5) begin
						subest <= 0;
						estado <= 14;
					end
					else begin
						flag_rst <= 0;
						en <= 0;
					end
				end
			end
			
			14: begin
				if(subest == 0) begin
					en <= 0;
					subest <= 1;
					flag_rst <= 1;
				end
				else if(subest == 1) begin
					if(flag5) begin
						if(charPos == 0) begin
							subest <= 0;
							estado <= 20;
							est2 <= 13;
							charPos <= 1;
						end
						else if(charPos == 1) begin
						
							rs <= 1;
							rw <= 0;
							en <= 1;
							dados <= ((A+B)/100 + 48);
							subest <= 0;
							charPos <= 2;
							estado <= 20;
							est2 <= 13;
						end
						else if(charPos == 2) begin
							rs <= 1;
							rw <= 0;
							en <= 1;
							dados <= ((((A+B)/10)%10) + 48);
							subest <= 0;
							charPos <= 3;
							estado <= 20;
							est2 <= 13;
						end
						else if(charPos == 3) begin
							rs <= 1;
							rw <= 0;
							en <= 1;
							dados <= (((A+B)%10) + 48);
							subest <= 0;
							charPos <= 4;
							estado <= 20;
							est2 <= 13;
						end
						else if(charPos == 4) begin
							rs <= 1;
							rw <= 0;
							en <= 1;
							dados <= 32;
							subest <= 0;
							charPos <= 5;
							estado <= 20;
							est2 <= 13;
						end
						else if(charPos == 5) begin
							subest <= 0;
							estado <= 20;
							est2 <= 6;
						end
					end
					else begin
						flag_rst <= 0;
						en <= 0;
					end
				end
			end
   		 
    	endcase
	end
    
    
	always @(iniciar)begin
   	 
	end
    
endmodule
