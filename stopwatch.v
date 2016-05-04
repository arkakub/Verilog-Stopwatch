module timer (out, clk, start, stop, reset);
  
  input clk, start, stop, reset;
  wire clk, q, cls, start, stop, reset;
  wire [6:0] hs, sec, min, hr, dy;

  output  wire [6:0] out;
 
  presc pre (q, clk, start, stop, reset);
  counter cnt (hs, sec, min, hr, dy, q, start, stop, reset);
  presc2 pr2 (cls, clk, q);
  transm trs (out, hs, sec, min, hr, dy, clk, q, cls);
  
endmodule

module presc (q, clk, start, stop, reset);

  output q;
  input clk, start, stop, reset;
  wire clk;
  
  reg [16:0] ticker;
 
  always @ (negedge clk or negedge reset or negedge start)
	begin
 		  
      if(~reset || ~start) ticker<=0;	
      
      else if(~stop) ticker <= ticker;
 
      else if(ticker == 73728) ticker <= 0;
 	  
      else ticker <= ticker + 1;
      
	end
  
  assign q = ((ticker == 73728)?1'b1:1'b0);

endmodule

module counter (hs, sec, min, hr, dy, q, start, stop, reset);

  output reg [6:0] hs, sec, min, hr, dy;
 
  input q, start, stop, reset;
  wire q, start, stop, reset;
  
  reg [2:0] i,j;
  
  always @ (negedge q or negedge reset or negedge start or negedge stop) begin
	
    if(~reset) begin 
      hs<=0;
      sec<=0;
      min<=0;
      hr<=0;
      dy<=0;
      i<=0;
      j<=0;
    end
    
    else if(j==2) begin
      j<=0;
      i<=1;	
    end
    
    else if(~stop) begin
      if(i) j<=j+1;
    end
    else if(j==1);
      
    else if(hs==99) begin
      hs<=0;
      sec<=sec+1;
      if(sec==59) begin
        sec<=0;
        min<=min+1;
        if(min==59) begin
          min<=0;
          hr<=hr+1;
          if(hr==23) begin
            hr<=0;
            dy<=dy+1;
            if(dy==99) 
              dy<=0;
          end
        end
      end
    end
    
    else if(~start) begin
      i<=1;
      j<=0;
    end
     
    else if(i) hs<=hs+1;
      
    else begin
      hs<=0;
      sec<=0;
      min<=0;
      hr<=0;
      dy<=0;
    end
      
  end
  
endmodule

module presc2 (cls, clk, q);
  input clk, q;
  output reg cls;
  
  reg [15:0] i;
  
  always @ (negedge q) begin
    cls<=1'd0; i<=0;
  end
  
  always @ (posedge clk) begin
    if(i==7373)begin
      cls<=!cls;
      i<=0;

    end else i<=i+1;
    
  end
  
endmodule

module transm (out, hs, sec, min, hr, dy, clk, q, cls);
  
  input clk, cls, q;
  input wire [6:0] hs, sec, min, hr, dy;

  output reg [6:0] out;
   
  reg[3:0] i;
  
  always @ (negedge q) begin
    out<=hs;
    i<=0;
  end
   
  always @ (posedge cls) begin
    
    if(i==0) out<=hs;
    else if(i==1)out<=sec; 
    else if(i==2)out<=min; 
    else if(i==3)out<=hr; 
    else if(i==4) begin
      out<=dy; 
     i<=i;
    end
    i<=i+1;
  end
  
endmodule
