`include "PC1.sv"
`include "PC2.sv"
`include "Shifter_Block.sv"
module Key_Schedule(
  input logic clk,rst_n, shift_left_1,shift_right_1, decipher_process, rkey_en, key_process,
  input logic [63:0] des_key_in,
  
  output logic [47:0] round_key
);
  logic [27:0] cn,dn;
  logic [55:0] cn_dn;
  logic [27:0] cin,din;
  PC1 pc1_inst (
    .des_key_in(des_key_in),
    .rkey_en(rkey_en), 
    .decipher_process(decipher_process),
    .cn(cn),
    .dn(dn),
    .cin(cin),
    .din(din)
  );
  
  Shifter_Block shifter_inst(
    .clk(clk), 
    .rst_n(rst_n), 
    .key_process(key_process), 
    .shift_left_1(shift_left_1), 
    .shift_right_1(shift_right_1), 
    .decipher_process(decipher_process),
    .cin(cin),
    .din(din),
    .cn(cn),
    .dn(dn)
  );
  assign cn_dn = {cn,dn};
  PC2 pc2_inst(
    .cn_dn(cn_dn),
    .round_key(round_key)
  );
  
endmodule