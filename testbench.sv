`timescale 1ns / 1ns

module ula_tb();

  logic clk;
  logic [31:0] a, b, y, y_expected;		// valores do testvector
  logic [2:0]  f;						
  logic        zero, zero_expected;

  logic [31:0] vectornum, errors;		// vari�veis de controle
  logic [103:0] testvectors[10000:0];	// testvectors

  // iniciar DUT - device under test
  ula dut(.a(a), .b(b), .f(f), .y(y), .zero(zero));

  // gerar clock
  always begin	   // sem lista de sensibilidade, ent�o sempre executa
    clk = 1; #50; clk = 0; #50;	
  end

  // no in�cio do teste, carregar arquivo testbench
  initial begin					// ir� executar uma vez no in�cio da simula��o
    $readmemh("ula.tv", testvectors);	// leitura do testvector
    vectornum = 0; errors = 0;			// inicializa��o das vari�veis
  end
  
  // $readmeh l� arquivos testvector escritos em hexadecimal
  
  
    // aplicar testvector na borda de subida do clock
  always @(posedge clk)
    begin
      #1; 
      f = testvectors[vectornum][102:100];
      a = testvectors[vectornum][99:68];
      b = testvectors[vectornum][67:36];
      y_expected = testvectors[vectornum][35:4];
      zero_expected = testvectors[vectornum][0];
    end

  initial begin
    // criar arquivo para gerar as formas de onda
    $dumpfile("dump.vcd");
    $dumpvars(1);
  end
  
 // avaliar os resultados na borda de descida do clock 

 always @(negedge clk) 
   begin
     if (y !== y_expected || zero !== zero_expected) begin
       $display("-------------------------------------------------------------");
       $display("Erro no vetor : %d", vectornum);
       $display(" Inputs : a = %h, b = %h, f = %b", a, b, f);
       $display(" Outputs: y = %h (%h expected), zero = %h (%h expected)", 
         y, y_expected, zero, zero_expected);
       $display("-------------------------------------------------------------");         
       errors = errors+1;
     end
     vectornum = vectornum + 1;	// incrementa o �ndice e l� o pr�ximo testvector
     if (testvectors[vectornum][0] === 1'bx) begin
       $display("-------------------------------------------------------------");
       $display("%d testes completos com %d erro(s)", vectornum, errors);
       $display("-------------------------------------------------------------");
       $stop;		// fim da simula��o
     end
   end
  
// Para visualizar os resultados passo a passo, retire os coment�rios 
 initial begin
   $monitor("Vetor %d", vectornum);
   $monitor(" Inputs : a = %d, b = %d, f = %d", $signed(a), $signed(b), f);
   $monitor(" Outputs: y = %d (%d expected), zero = %d (%d expected)", $signed(y), $signed(y_expected), zero, zero_expected); 
  end  
 
    
  // para impri