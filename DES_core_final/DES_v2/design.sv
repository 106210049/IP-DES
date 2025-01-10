// Code your design here
`define DELAY #0.01
`include "Sbox.sv"
`include "PC1.sv"
`include "PC2.sv"
`include "Encrypt_Counter.sv"
`include "IP.sv"
module DES_core(
  input logic clk,
  input logic rst_n,
  input logic des_encipher_en,
  input logic des_decipher_en,
  input logic [63:0] des_data,
  input logic [63:0] des_key_in,
  
  output logic desc_ready,
  output logic [63:0] desc_result 

);
  wire [63:0] ip_input;
  wire [31:0] l0,r0;
  reg [31:0] ln,rn;
  reg encipher_process;
  wire lr_sel;
  wire [31:0] r_input,l_input;
  wire [47:0] re;
  wire [47:0] round_key;
  wire [47:0] re_xor_key;
  wire [5:0] s1_in,s2_in,s3_in,s4_in,s5_in,s6_in,s7_in,s8_in;
  reg [3:0] s1_out,s2_out,s3_out,s4_out,s5_out,s6_out,s7_out,s8_out;
  wire [31:0] p_in;
  wire [31:0] f_value;
  wire [27:0] c0,d0;
  wire rkey_sel;
  wire [27:0] cin,din;
  reg [27:0] cn,dn;
  wire shift_left_1;
  wire shift_right_1;
  reg key_process;
  reg [55:0] cn_dn;
  reg decipher_process;
  wire [63:0]inv_p_input;
  reg [3:0] r_counter;
  wire k16_complete;
  reg k16_calculation;
  reg encipher_en_sync;
  //---------------- Initial Permutation - IP -------------
  
  InitialPermutation IP(
    .des_data(des_data),
    .r_counter(r_counter),
    .encipher_process(encipher_process),
    .rkey_sel(rkey_sel),
    .ln(ln),
    .rn(rn),
    .l_input(l_input),
    .r_input(r_input)
  );
  
  
  //-------------------------------------------------------
//Cipher function - f (R,K)
//-------------------------------------------------------
  
  //----------------- E table - Converting 32-bit R to 48-bit value ---------------------------
  
  
  assign	re	= {
    	r_input[0], r_input[31], r_input[30], r_input[29], r_input[28], r_input[27],
		r_input[28], r_input[27], r_input[26], r_input[25], r_input[24], r_input[23],
		r_input[24], r_input[23], r_input[22], r_input[21], r_input[20], r_input[19],
		r_input[20], r_input[19], r_input[18], r_input[17], r_input[16], r_input[15],
		r_input[16], r_input[15], r_input[14], r_input[13], r_input[12], r_input[11],
		r_input[12], r_input[11], r_input[10], r_input[9], r_input[8], r_input[7],
		r_input[8], r_input[7], r_input[6], r_input[5], r_input[4], r_input[3],
		r_input[4], r_input[3], r_input[2], r_input[1], r_input[0], r_input[31]
  };
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

  Sbox sbox(s1_in,
            s2_in,
            s3_in,
            s4_in,
            s5_in,
            s6_in,
            s7_in,
            s8_in,
            s1_out,
            s2_out,
            s3_out,
            s4_out,
            s5_out,
            s6_out,
            s7_out,
            s8_out);
  //-------- Permutation - P / the final value of f(R, K) function -----------------
  
  assign p_in={s1_out,s2_out,s3_out,s4_out,s5_out,s6_out,s7_out,s8_out};
  assign f_value={
    	p_in[16], p_in[25], p_in[12], p_in[11],
		p_in[3], p_in[20], p_in[4], p_in[15],
		p_in[31], p_in[17], p_in[9], p_in[6],
		p_in[27], p_in[14], p_in[1], p_in[22],
		p_in[30], p_in[24], p_in[8], p_in[18],
		p_in[0], p_in[5], p_in[29], p_in[23],
		p_in[13], p_in[19], p_in[2], p_in[26],
		p_in[10], p_in[21], p_in[28], p_in[7]
  };
  //------------------------------------------------------------------------
//Key Schedule Calculation
//------------------------------------------------------------------------
  
//   reg encipher_process;
//------------ Permuted Choice 1 - PC1 ------------------
  
  PC1 pc1(des_key_in,rkey_sel, decipher_process,cn,dn,cin,din);
  
  //------------ Shift Left --------------------------------
  
  
  always_ff@(posedge clk)	begin
    if(decipher_process)	begin
      if(shift_right_1)	begin
        cn	<= `DELAY {cin[0], cin[27:1]};
		dn	<= `DELAY {din[0], din[27:1]};
      end
      else	begin
        cn	<= `DELAY {cin[1:0], cin[27:2]};
		dn	<= `DELAY {din[1:0], din[27:2]};
      end
    end
      else	begin
        if(key_process)	begin
          if(shift_left_1)	begin
            cn	<= `DELAY {cin[26:0], cin[27]};
			dn	<= `DELAY {din[26:0], din[27]};
          end
          else	begin
            cn	<= `DELAY {cin[25:0], cin[27:26]};
			dn	<= `DELAY {din[25:0], din[27:26]};
          end
        end
        else begin
          cn<=cn;
          dn<=dn;
        end
      end
  end
  assign	cn_dn	= {cn, dn};
//------------- Permuted Choice 2 - PC2 -------------------
  PC2 pc2(cn_dn,round_key);
  
    //-------- The ciphertext of DES --------------------------------------

  always_ff@(posedge clk)	begin
    if(decipher_process|encipher_process)	begin
      ln	<= `DELAY r_input;
	  rn	<= `DELAY l_input ^ f_value;
    end
  end
  assign inv_p_input={rn,ln};
  assign desc_result = {
   inv_p_input[24], inv_p_input[56], inv_p_input[16], inv_p_input[48], inv_p_input[8], inv_p_input[40], inv_p_input[0], inv_p_input[32],
   inv_p_input[25], inv_p_input[57], inv_p_input[17], inv_p_input[49], inv_p_input[9], inv_p_input[41], inv_p_input[1], inv_p_input[33],
   inv_p_input[26], inv_p_input[58], inv_p_input[18], inv_p_input[50], inv_p_input[10], inv_p_input[42], inv_p_input[2], inv_p_input[34],
   inv_p_input[27], inv_p_input[59], inv_p_input[19], inv_p_input[51], inv_p_input[11], inv_p_input[43], inv_p_input[3], inv_p_input[35],
   inv_p_input[28], inv_p_input[60], inv_p_input[20], inv_p_input[52], inv_p_input[12], inv_p_input[44], inv_p_input[4], inv_p_input[36],
   inv_p_input[29], inv_p_input[61], inv_p_input[21], inv_p_input[53], inv_p_input[13], inv_p_input[45], inv_p_input[5], inv_p_input[37],
   inv_p_input[30], inv_p_input[62], inv_p_input[22], inv_p_input[54], inv_p_input[14], inv_p_input[46], inv_p_input[6], inv_p_input[38],
   inv_p_input[31], inv_p_input[63], inv_p_input[23], inv_p_input[55], inv_p_input[15], inv_p_input[47], inv_p_input[7], inv_p_input[39]};
  
  
  //-------------- Encryption round counter -----------------------
//
  EncryptionRoundCounter counter(clk,rst_n,key_process,r_counter);
  //  -------------- Encryption follow -----------------------

  wire shift_left;
  assign k16_complete=(&r_counter);
  assign rkey_sel=(|r_counter);
  assign shift_left=k16_complete|(~rkey_sel);
  assign shift_left_1=shift_left|(r_counter==4'd1)|(r_counter==4'd8);
  assign shift_right_1=shift_left|(r_counter==4'd7)|(r_counter==4'd14);
  
  always @ (posedge clk, negedge rst_n) begin
	if (~rst_n)	decipher_process	<= `DELAY 1'b0;
	else if (k16_complete & (~encipher_process)) begin
		if (k16_calculation)
			decipher_process	<= `DELAY 1'b1;
		else	decipher_process	<= `DELAY 1'b0;
	end
end
  
  always @ (posedge clk, negedge rst_n) begin
    if (~rst_n) begin	key_process	<= `DELAY 1'b0; end
    else if  (des_decipher_en | des_encipher_en) begin
      key_process	<= `DELAY 1'b1; end
    else if ((decipher_process | encipher_process) & k16_complete) begin
      key_process	<= `DELAY 1'b0; end
end
  always @ (posedge clk, negedge rst_n) begin
    if (~rst_n) begin	k16_calculation	<= `DELAY 1'b0; end
    else begin	k16_calculation	<= `DELAY key_process & (~decipher_process) & (~encipher_process);	end
end
assign	desc_ready	= (~key_process) & (~encipher_process);
  
//
  //Determining the encipher or decipher process
//
always @ (posedge clk, negedge rst_n) begin
  if (~rst_n) begin encipher_en_sync	<= `DELAY 1'b0; end
  else begin	encipher_en_sync	<= `DELAY des_encipher_en; end
end
  

always @ (posedge clk, negedge rst_n) begin
  if (~rst_n)	begin encipher_process	<= `DELAY 1'b0; end
  else if (encipher_en_sync) begin
    encipher_process	<= `DELAY 1'b1; end
  else if (~rkey_sel) begin
    encipher_process	<= `DELAY 1'b0; end
end
endmodule: DES_core