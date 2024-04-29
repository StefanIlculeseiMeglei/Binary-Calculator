// ALU
module ALU( A,B, Sel,Out,Flag /// 0-zero, 1-carry, 2-overflow,3-underflow
);
  input [7:0] A;
  input [7:0] B;
  input [3:0] Sel;
  output [7:0] Out;
  output [3:0] Flag ;
  reg [3:0] tmp_flag=0;
  reg [7:0] rez=0;
  localparam clear =0;
  localparam zero_flag=1;
  localparam carry_flag=2;
  localparam Overflow_flag=4;
  localparam Underflow_flag=8;
  assign Out=rez;
  assign Flag=tmp_flag;
  always @(A, B,Sel) begin
    tmp_flag=clear;
    case(Sel)
    0:begin
      rez=A+B;
      if(({1'b0,A}+{1'b0,B})>9'b01111_1111) begin
       	 tmp_flag=carry_flag;
      end 
      
      if(rez==0) begin
          tmp_flag=tmp_flag+1;
        end
    end
    1:begin
      rez=A-B;
      if(A<B) begin
        tmp_flag=Underflow_flag;
      end
      if(rez==0) begin
          tmp_flag=tmp_flag+1;
        end
      
    end
    2:begin
      rez=A*B;
      if(A>8'h0f && B>8'h0f) begin
        tmp_flag=Overflow_flag;
      end
      if(rez==0) begin
          tmp_flag=tmp_flag+1;
        end
    end
      
       3:begin
      rez=A/B;
         if(A<B) begin
        tmp_flag=Underflow_flag;
         end
         if(rez==0) begin
          tmp_flag=tmp_flag+1;
        end
    end
      4:begin
        rez=A;
        repeat(B) begin
          tmp_flag=2*((rez>>7)%2);
          rez=rez<<1;
        end
        if(rez==0) begin
          tmp_flag=tmp_flag+1;
        end
        
    end
      5: begin
        if(B!=0) begin
        rez=A>>(B-1);
        tmp_flag=2*(rez%2);
        rez=rez>>1;
        end
        else begin 
          rez=A;
        end
        
        if(rez==0) begin
          tmp_flag=tmp_flag+1;
        end
      end
      6: begin
        rez=A&B; // and
        
        if(rez==0) begin
          tmp_flag=tmp_flag+1;
        end
      end
      7: begin
        rez=A|B; // or
        
        if(rez==0) begin
          tmp_flag=tmp_flag+1;
        end
      end
      8: begin
        rez=(A&(~B))|((~A)&B); //xor
        
        if(rez==0) begin
          tmp_flag=tmp_flag+1;
        end
      end
      9: begin
        rez=(A|(~B))&((~A)|B); //xnor
        
        if(rez==0) begin
          tmp_flag=tmp_flag+1;
        end
      end
      10: begin
        rez=~(A&B); //nand
        
        if(rez==0) begin
          tmp_flag=tmp_flag+1;
        end
      end
      11: begin
        if(A>B) begin //A>B
          rez=1;
        end else begin
          rez=0;
          tmp_flag=tmp_flag+1;
        end; 
        
      end
      12: begin
        if(A==B) begin //A==B
          rez=1;
        end else begin
          rez=0;
          tmp_flag=tmp_flag+1;
        end; 
        
      end
      default: begin
        rez=0;
        tmp_flag=0;
      end
    endcase
  end
endmodule



module concatenator(input [7:0] InA,
                    input [7:0] InB,
                    input [7:0] InC,
                    input [3:0] InD,
                    input [3:0] InE,
                    output [31:0] Out
                   );
  assign Out={InE,InD,InC,InB,InA};
endmodule



module serial_tranceiver#(parameter p=31)(
  input [32] DataIn,
  input Sample,
  input StartTxm,
  input Reset,
  input Clk,
  input ClkTx,
  output TxDone,
  output TxBusy,
  output Dout
);
  reg [32] mem;
  reg data_out=0;
  reg start=0;
  reg Busy=0;
  reg done=0;
  reg TxDoneTmp=0;
  integer counter=0;
  /// p=31 pentru transfer 32
  /// p=15 pt transder de 16 biti
  always @(posedge Clk or posedge Reset) begin
    if(Reset) begin
      mem<=0;
      start<=0;
      counter<=0;
      Busy<=0;
      done<=0;
      TxDoneTmp<=0;
    end else if(Sample) begin
      mem<=DataIn;
      done<=0;
      TxDoneTmp<=0;
      data_out<=0;
      Busy<=0;
    end else if(StartTxm) begin
      start<=1;
    end else if(!StartTxm) begin
      start<=0;
      data_out<=0;
      counter<=0;
      done<=0;
      TxDoneTmp<=0;
    end
    
    
    
  end
  
  always @(posedge ClkTx or posedge Reset) begin
    if(counter<p+1) begin
    if(start ) begin
      done<=0;
      data_out<=(mem>>(p-counter))%2;
      Busy<=(counter<(p+1)?1:0);
      counter<=counter+1;
      
      if(counter==p) begin
      if(!done) begin
       done<=1;
       TxDoneTmp<=1;
       end else if(done) begin
         TxDoneTmp<=0;
       end
      end
      
    end
    end
     else begin
       Busy<=0;
       data_out<=0;
       TxDoneTmp<=0;
     end
  end

    
 
  
    
  assign Dout=data_out;
  assign TxBusy=Busy;
  assign TxDone=TxDoneTmp;
endmodule


module frequency_divider(
  input [3:0] Din,
  input ConfigDiv,
  input Reset,
  input Clk,
  input Enable,
  output reg ClkOut
);
  reg [3:0] T=2;
  localparam Prestab=2;
  integer counter=0;
  reg start=0;
  always @(posedge Clk or negedge Clk or posedge Reset) begin
    
    if(Reset) begin
      counter<=0;
      ClkOut<=0;
      T<=Prestab;
    end else if(ConfigDiv) begin
      T<=Din;
      ClkOut<=0;
      counter<=0;
    end else begin
    
    counter <= counter + 1;

      if (counter >= ((T * 2) - 1)) begin
        counter <= 0;
    end
      if(Enable) begin
      if (T== 1) begin
       ClkOut <= Clk;
    end else begin
      ClkOut <= (counter < T)?1'b1:1'b0;
    end
      end else  begin
        ClkOut<=0;
      end
      
      
    end

end

endmodule





module memory #(
  parameter WIDTH=8 // addr width
)(
  input [31:0] Din,
  input [WIDTH] Addr,
  input R_W,
  input Valid,
  input Reset,
  input Clk,
  output [31:0] Dout
);
  localparam DEPTH=2**WIDTH;
  reg [31:0] tmp_data=0;
  reg [31:0] mem [DEPTH];
  assign Dout=tmp_data;
  always @(posedge Clk or posedge Reset) begin
    if(Reset) begin
      tmp_data<=0;
      for(integer i=0;i<DEPTH;i++) begin
        mem[i]<=0;
      end
    end
    else if(!Reset) begin
      if(Valid) begin
        if(!R_W) begin
          tmp_data<=mem[Addr];
        end else if(R_W) begin
          mem[Addr]<=Din;
          tmp_data<=0;
        end
        
      end else if(!Valid) begin
        tmp_data<=0;
      end
      
    end
  end
endmodule


module mux2_1 #(parameter WIDTH=32)(input [WIDTH-1:0] A,
                                    input [WIDTH-1:0] B,
            input Sel,
                                    output [WIDTH-1:0] Out);
  assign Out=Sel?B:A;
endmodule



module Elock(
  input Reset,
  input Clk,
  input InputKey,
  input ValidCmd,
  output Active,
  output Mode);
  localparam IDLE = 3'b000; // Cod Gray
  localparam S1 = 3'b001;
  localparam S2 = 3'b011;
  localparam S3 = 3'b010;
  localparam S4 = 3'b110;
  localparam S5 = 3'b111;
  reg [2:0] stare_curenta=3'b000;
  reg [2:0] stare_viitoare=3'b000;
  reg ActiveTmp=0;
  reg ModeTmp1=0;
  reg ModeTmp2=0;
  
  
  always @(InputKey or stare_curenta) begin
    if(!ActiveTmp && ValidCmd) begin 
    case(stare_curenta)
  	IDLE:begin
      if(InputKey) begin
        stare_viitoare=S1;
      end else begin
        stare_viitoare=IDLE;
      end
    end
    S1:begin
      if(!InputKey) begin
        stare_viitoare=S2;
      end else begin
        stare_viitoare=S1;
      end
    end
    S2:begin
      if(InputKey) begin
        stare_viitoare=S3;
      end else begin
        stare_viitoare=IDLE;
      end
    end
    S3:begin
      if(!InputKey) begin
        stare_viitoare=S4;
      end else begin
        stare_viitoare=S1;
      end
    end
    S4: begin
      stare_viitoare=S5;
      ModeTmp1=InputKey;
    end
       S5: begin
      stare_viitoare=S5;
    end
    endcase
    end // sf !ActiveTmp
  end
  
  
  
  always @(posedge Clk or posedge Reset) begin
    if(Reset) begin
        stare_curenta<=IDLE;
      ModeTmp1<=1'b0;
      ModeTmp2<=1'b0;
      ActiveTmp<=1'b0;
      end
      else begin
       if(ValidCmd) begin
        stare_curenta<=stare_viitoare;
        if(stare_curenta==S5) begin
          ActiveTmp<=1'b1;
          ModeTmp2<=ModeTmp1;
        end // sf stare_cureta==S5
        end // sf ValidCmd
      end
  end
  
  assign Mode=ModeTmp2;
  assign Active=ActiveTmp;
endmodule





module control(input ValidCmd,
               input Clk,
               input Reset,
               input RW,
               input TxDone,
               input Active,
               input Mode,
               output AccesMem,
               output RWMem,
               output SampleData,
               output TxData,
               output ModeOut,
               output Busy
);
  reg [1:0] Mode_tmp=2'b00;
  reg RWMem_tmp=1'b0;
  reg SampleData_tmp=1'b0;
  reg TxData_tmp=1'b0;
  reg AccesMem_tmp=1'b0;
  reg IDLE=1'b1;
  reg Sent_sample=1'b0;
  reg [1:0] counter=2'b00; /// wait 1 cycle
  always@(posedge Clk or posedge Reset) begin
    if((Mode_tmp>>1)%2==0) begin // inca nu s-a terminat o operatie
      Mode_tmp<=(2+Mode);
    end
    
    if(!(Mode_tmp%2) )begin
      if(Reset) begin
         RWMem_tmp<=0;
 		 SampleData_tmp<=0;
  	  	 TxData_tmp<=0;
  		 AccesMem_tmp<=0;
        Mode_tmp<={1'b0,Mode};
      end // Sf Reset
      else if(!Reset) begin
        if(ValidCmd && Active) begin
          if(IDLE) begin
            SampleData_tmp<=1;
            IDLE=0;
          end // sf IDLE
          else if(!IDLE) begin
           	SampleData_tmp<=0;
            if(!TxDone) begin
              TxData_tmp<=1;
            end // Sf !TxDone
            else if(TxDone) begin
              TxData_tmp<=0;
              IDLE<=1;
              Mode_tmp<={1'b0,Mode};
            end // sf TxDone
            
            
          end // sf !IDLE
        end // sf Valid && Active
      end // Sf !Reset
      
    end // sf !Mode
    else if(Mode_tmp%2) begin
      
      if(Reset) begin
         RWMem_tmp<=0;
 		 SampleData_tmp<=0;
  	  	 TxData_tmp<=0;
  		 AccesMem_tmp<=0;
         counter<=0;
        Mode_tmp<={1'b0,Mode};
      end // Sf Reset
      else if(!Reset) begin
        if(ValidCmd) begin 
        if(Active && RW) begin // citire memorie
          if(IDLE) begin
            AccesMem_tmp<=1;
            RWMem_tmp<=1;
            IDLE=0;
            counter<=0;
          end // sf IDLE
          else if(!IDLE) begin
            RWMem_tmp<=0;
            
            //AccesMem_tmp<=0;
            //IDLE<=1;
            
            if(counter==0)begin // wait 1 cycle
            	counter<=1;
            end // sf counter==0
            else if(counter==1) begin
              	AccesMem_tmp<=0;
              	IDLE<=1;
              	counter<=0;
              Mode_tmp<={1'b0,Mode};
            end // sf counter==1
            
          end // sf !IDLE
        end // sf Active && RW
          else if(Active && (!RW)) begin
            if(IDLE) begin
            AccesMem_tmp<=1;
            RWMem_tmp<=0;
            IDLE=0;
            counter<=0;
          end // sf IDLE
            else if(!IDLE) begin
            
              if(counter==0)begin // wait 1 cycle
            	counter<=1;
              	SampleData_tmp<=1;
            end // sf counter==0
              else if(counter==1) begin
              	SampleData_tmp<=0;
              	counter <= 2;
            end // sf counter==1
              else if(counter==2) begin
                counter <=3;
                TxData_tmp<=1;
              end // sf coutner == 3
            
              if(TxDone) begin
              TxData_tmp<=0;
              IDLE<=1;
              AccesMem_tmp<=0;
              RWMem_tmp<=0;
              counter <=0;
                Mode_tmp<={1'b0,Mode};
            end // sf TxDone
              
          end // sf !IDLE
            
            
            
            
          end// sf Active && !RW
        end // sf Valid
      end // Sf !Reset
    
      
    end //sf Mode
    
    
  end // sf always
  
  
  
  assign RWMem=RWMem_tmp;
  assign SampleData=SampleData_tmp;
  assign TxData=TxData_tmp;
  assign Busy=~IDLE;
  assign AccesMem=AccesMem_tmp;
  assign ModeOut=Mode_tmp%2;
endmodule




module controller(
               input Clk,
  			   input InputKey,
  			   input ValidCmd,
               input Reset,
               input RW,
               input TxDone,
               output Active,
               output Mode,
               output AccesMem,
               output RWMem,
               output SampleData,
               output TxData,
               output Busy
);
  reg ActiveTmp;
  reg ModeTmp;
  assign Active=ActiveTmp;
  assign Mode=ModeTmp;
  Elock Lock(.Reset(Reset),.InputKey(InputKey),.Clk(Clk),.ValidCmd(ValidCmd),.Active(ActiveTmp),.Mode(ModeTmp));
  control  Ctrl(.ValidCmd(ValidCmd),
           .Clk(Clk),
           .Reset(Reset),
           .RW(RW),
           .TxDone(TxDone),
           .Active(ActiveTmp),
                .Mode(ModeTmp),
           .AccesMem(AccesMem),
           .RWMem(RWMem),
           .SampleData(SampleData),
           .TxData(TxData),
           .ModeOut(),
           .Busy(Busy)
);
  
endmodule






module calc_binar#(
  parameter WIDTH=8 
)(input [7:0] A,
                  input [7:0] B,
                  input [3:0] Sel,
                  input Clk,
                  input InputKey,
                  input RW,
                  input ValidCmd,
                  input [WIDTH] Addr,
                  input [3:0] Din,
  				  input ConfigDiv,
                  input Reset,
                  output  DoutValid,
                  output  DataOut,
  				  output ClkTx,
  				  output CalcBusy,
  				  output CalcActive,
  				  output CalcMode
                 );
  wire CtrlModeTmp,CtrlRWMemTmp,CtrlAccessMemTmp,CtrlSampleDataTmp,CtrlTransferDoneTmp,CtrlTransferDataTmp;
  wire [7:0] AluOutTmp;
  wire [3:0] AluFlagTmp;
  wire [7:0] MuxInATmp;
  wire [7:0] MuxInBTmp;
  wire [3:0] MuxSelTmp;
  wire [31:0] TxDinTmp;
  wire [31:0] MemOut;
  wire [31:0] ConcatOutTmp;
  wire ResetTmp;
  reg Active;
  reg ClkTxTmp;
  //assign ResetTmp=Reset;
  or(ResetTmp,Reset,~Active);
  assign ClkTx=ClkTxTmp;
  reg data_out;
  reg dout_valid;
  localparam zero8=8'b0000_0000;
  localparam zero4=4'b0000;
  mux2_1 #(8) m1(.A(A),.B(zero8),.Sel(Reset),.Out(MuxInATmp));
  mux2_1 #(8) m2(.A(B),.B(zero8),.Sel(Reset),.Out(MuxInBTmp));
  mux2_1 #(4) m3(.A(Sel),.B(zero4),.Sel(Reset),.Out(MuxSelTmp));
  mux2_1 #(32) m4(.A(ConcatOutTmp),.B(MemOut),.Sel(CtrlModeTmp),.Out(TxDinTmp));
  ALU alu(.A(MuxInATmp),.B(MuxInBTmp),.Sel(MuxSelTmp),.Out(AluOutTmp),.Flag(AluFlagTmp));
  concatenator concat(.InA(MuxInATmp),.InB(MuxInBTmp),.InC(AluOutTmp),.InD(MuxSelTmp),.InE(AluFlagTmp),.Out(ConcatOutTmp));
  
  memory #(.WIDTH(WIDTH)) mem (.Din(ConcatOutTmp),.Addr(Addr),.R_W(CtrlRWMemTmp),.Valid(CtrlAccessMemTmp),.Reset(ResetTmp),.Clk(Clk),.Dout(MemOut));
  frequency_divider fdiv(.Din(Din),.ConfigDiv(ConfigDiv),.Reset(ResetTmp),.Clk(Clk),.Enable(Active),.ClkOut(ClkTxTmp));
  
  
  serial_tranceiver transcevier(.DataIn(TxDinTmp),.Sample(CtrlSampleDataTmp),.StartTxm(CtrlTransferDataTmp),.Reset(ResetTmp),.TxDone(CtrlTransferDoneTmp),.Clk(Clk),.ClkTx(ClkTxTmp),.Dout(data_out),.TxBusy(dout_valid));
  
  
  controller inst(.ValidCmd(ValidCmd),
               .Clk(Clk),
                  .InputKey(InputKey),
               .Reset(Reset),
               .RW(RW),
                  .TxDone(CtrlTransferDoneTmp),
               .Active(Active),
                  .Mode(CtrlModeTmp),
                  .AccesMem(CtrlAccessMemTmp),
                  .RWMem(CtrlRWMemTmp),
                  .SampleData(CtrlSampleDataTmp),
                  .TxData(CtrlTransferDataTmp),
                  .Busy(CalcBusy));
  
  
  assign CalcActive=Active;
  assign DoutValid=dout_valid;
  assign DataOut=data_out;
  assign CalcMode=CtrlModeTmp;
endmodule