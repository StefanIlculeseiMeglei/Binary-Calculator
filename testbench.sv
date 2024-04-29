module test;
  reg[7:0] A;
  reg [7:0] B;
  reg [3:0] Sel;
  reg Clk;
  reg InputKey;
  reg RW;
  reg ValidCmd;
  reg [7:0] Addr;
  reg [3:0] Din;
  reg ConfigDiv;
  reg Reset;
  wire DoutValid;
  wire DataOut;
  wire ClkTx;
  wire CalcBusy;
  wire CalcActive;
  wire CalcMode;
  reg sf=0;
  calc_binar inst(.A(A),
                  .B(B),
                  .Sel(Sel),
                  .Clk(Clk),
                  .InputKey(InputKey),
                  .RW(RW),
                  .ValidCmd(ValidCmd),
                  .Addr(Addr),
                  .Din(Din),
                  .ConfigDiv(ConfigDiv),
                  .Reset(Reset),
                  .DoutValid(DoutValid),
                  .DataOut(DataOut),
                  .ClkTx(ClkTx),
                  .CalcBusy(CalcBusy),
                  .CalcActive(CalcActive),
                  .CalcMode(CalcMode));
  
  initial Clk=0;
  always #5 Clk=~Clk;
  
  initial begin
$dumpfile("dump.vcd"); 
$dumpvars();
  A=0;
  B=0;
  Sel=0;
  Clk=0;
  RW=0;
  ValidCmd=0;
  Addr=0;
  Din=0;
  ConfigDiv=0;
  InputKey=0;
  Reset=1;
  #10;
  Reset=0;
    
    
    
    
  ValidCmd=1;
  
  // start mode 0
  IntroducePass(5'b00101);
 
  
  Din=1;   ///block schimba tx
  ConfigDiv=1;
  #200;
  ConfigDiv=0;
  #10; // sf block
    
    
  A=5;
  B=1;
  Sel=5;
  #10;
  waitBusy();  
  #10;  
  waitBusy();  
    
    
  // sf mode 0  
    
  Reset=1;
  #10;
  Reset=0;
  
    
  // start mode 1
  IntroducePass(5'b10101);  
   

       
  A=5;
  B=2;
  Sel=1;
  Addr=0;
  #10;
  RW=1; // citire
  waitBusy();
  A=1;
  B=1;
  Sel=0;
  Addr=0;
  #50;
  waitBusy();
  A=3;
  B=8;
  Sel=3;
  Addr=1;
  #50;
  waitBusy();  
  
    
    
  A=0;
  B=0;
  Sel=0;  
  Addr=2;
  #50;
  waitBusy();    
    
  A=2;
  B=2;
  Sel=1;
  Addr=3;
  #50;
  waitBusy();   
    
    
    
  // afisare  
  RW=0;
  Addr=0;
  #40;
  waitBusy();
  
  Addr=1;
  #40;
  waitBusy();
    
   
  Addr=2;
  #40;
  waitBusy();   
    
  Addr=3;
  #40;
  waitBusy();
    
  // sf mode 1
  #40;
  sf=1;
$finish;
end
  
  
  task waitBusy();
    begin
    if(CalcActive) begin
      while(CalcBusy)
        #5;
    end
      else begin
        $display("Calculatorul nu este activ");
      end
    end
  endtask
  
  
  task IntroducePass(input [4:0] Key);
    integer i=0;
    begin
      i=0;
      repeat(5) begin
        InputKey=(Key>>i)%2;
        #10;
        i=i+1;
      end
      i=0;
      while(!CalcActive && i<10) begin
        #5;
        i=i+1;
      end
      if(i>=10) begin
        $display("Parola %0b%0b%0b%0b%0b este incorecta!", (Key>>4)%2,(Key>>3)%2,(Key>>2)%2,(Key>>1)%2,Key%2);
      end
    end
  endtask
endmodule
