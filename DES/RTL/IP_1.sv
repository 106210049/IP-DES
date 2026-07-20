module IP_1(
  input logic clk, rst_n, encipher_process, decipher_process,
  input logic [31:0] l_input, r_input, f_value,
  output logic [31:0] ln,rn,
  output logic [63:0] desc_result
);
  
  logic [63:0] inv_p_input;
always_ff@(posedge clk)	begin
    if(decipher_process|encipher_process)	begin
      ln	<=  r_input;
	  rn	<=  l_input ^ f_value;
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

endmodule
  