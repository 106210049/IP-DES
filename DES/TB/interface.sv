interface des_if(input bit clk, input bit rst_n);

  	logic des_encipher_en;
    logic des_decipher_en;
    logic [63:0] des_data;
    logic [63:0] des_key_in;
    logic desc_ready;
    logic [63:0] desc_result;

    modport DES (
      input clk,
      input rst_n,
      input des_encipher_en,
      input des_decipher_en,
      input des_data,
      input des_key_in,
      output desc_ready,
      output desc_result
    );
endinterface

