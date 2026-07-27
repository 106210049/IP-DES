class transaction;
  string mode_type;
  
  rand bit [63:0] des_data;
  rand bit [63:0] des_key_in;
  rand bit des_encipher_en;
  rand bit des_decipher_en;
  
  bit desc_ready;
  bit [63:0] desc_result;
  
  constraint mode_c {
    !(des_encipher_en && des_decipher_en); 
  }

  constraint data_in {
    des_data inside {[64'h0 : 64'hFFFFFFFFFFFFFFFF]};
  }

  constraint des_key {
    des_key_in inside {[64'h0 : 64'hFFFFFFFFFFFFFFFF]};
  }
  
  covergroup cov_des_in;
    cp_data_in: coverpoint des_data{
      bins fixed_data = {62'h00123456789abcde};
      bins random_data = {[64'h0 : 64'hFFFFFFFFFFFFFFFF]};
    }
    cp_key_in: coverpoint des_key_in{
      bins fixed_key = {62'h0133457799bbcdff};
      bins random_key = {[64'h0 : 64'hFFFFFFFFFFFFFFFF]};
    }
  endgroup

  covergroup cov_des_mode;
    cp_enc: coverpoint des_encipher_en{
      bins enc = {1'b1};
    }
    cp_dec: coverpoint des_decipher_en{
      bins dec = {1'b1};
    }
  endgroup

  function new();
    this.des_data = '0;
    this.des_key_in = '0;
    this.des_encipher_en = 0;
    this.des_decipher_en = 0;
    cov_des_in = new();
    cov_des_mode = new();
  endfunction

  function void coverage_sample();
    if(cov_des_in != null && cov_des_mode != null)  begin
      cov_des_in.sample();
      cov_des_mode.sample();
    end
  endfunction

endclass