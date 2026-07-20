class transaction;
  string mode_type;
  
  rand bit [63:0] des_data;
  rand bit [63:0] des_key_in;
  rand bit des_encipher_en;
  rand bit des_decipher_en;
  
  bit desc_ready;
  bit [63:0] desc_result;
  
  constraint mode_c {
    des_encipher_en != des_decipher_en; 
}
  

endclass