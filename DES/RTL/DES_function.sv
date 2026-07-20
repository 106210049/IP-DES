`include "E_table.sv"
`include "Sbox.sv"
`include "Permutation.sv"
module DES_function(
  input logic [31:0] r_input,
  input logic [47:0] round_key,
  
  output logic [31:0] f_value
);
 
  logic [47:0] re_xor_key;
  logic [47:0] re;
   logic [5:0] s1_in,s2_in,s3_in,s4_in,s5_in,s6_in,s7_in,s8_in;
  logic [3:0] s1_out,s2_out,s3_out,s4_out,s5_out,s6_out,s7_out,s8_out;
  
  logic [31:0] p_in;
  
  E_table etable_inst (
    .r_input(r_input),
    .re(re)
  );
  
  //----------------- After converting from 32-bit to 48-bit, Right data XOR with Round KEY -----------------------
assign re_xor_key=re^round_key;
  //----------------- S1/2/3/4/5/6/7/8 Converting 48-bit (with KEY) to 32-bit -----------------
  assign s1_in=re_xor_key[47:42];
  assign s2_in=re_xor_key[41:36];
  assign s3_in=re_xor_key[35:30];
  assign s4_in=re_xor_key[29:24];
  assign s5_in=re_xor_key[23:18];
  assign s6_in=re_xor_key[17:12];
  assign s7_in=re_xor_key[11:6];
  assign s8_in=re_xor_key[5:0];
  
  Sbox sbox(
    .s1_in(s1_in),
    .s2_in(s2_in),
    .s3_in(s3_in),
    .s4_in(s4_in),
    .s5_in(s5_in),
    .s6_in(s6_in),
    .s7_in(s7_in),
    .s8_in(s8_in),
    .s1_out(s1_out),
    .s2_out(s2_out),
    .s3_out(s3_out),
    .s4_out(s4_out),
    .s5_out(s5_out),
    .s6_out(s6_out),
    .s7_out(s7_out),
    .s8_out(s8_out)
  );
  assign p_in={s1_out,s2_out,s3_out,s4_out,s5_out,s6_out,s7_out,s8_out};
  
  Permutation P_inst(
    .p_in(p_in),
    .f_value(f_value)
  );
  
endmodule