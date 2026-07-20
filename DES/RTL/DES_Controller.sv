module DES_Controller(
  input  logic clk,
  input  logic rst_n,
  input  logic des_encipher_en,
  input  logic des_decipher_en,        

  output logic  key_process,            
  output logic  rkey_en,
  output logic  shift_right_1,
  output logic  shift_left_1,
  output logic  decipher_process,
  output logic  encipher_process,
  output logic [3:0] r_counter,
  output logic desc_ready              
);

  // ---------------- Local signals ----------------
  logic        k16_calculation;
  logic        encipher_en_sync;
  logic       k16_complete;
  logic       shift_left;

  // ---------------- Counter logic ----------------
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
      r_counter <= 4'd0;
    else if (key_process)
      r_counter <= r_counter + 4'd1;
  end

  // ---------------- Control signal generation ----------------
  assign k16_complete = (&r_counter);
  assign rkey_en      = (|r_counter);
  assign shift_left   = k16_complete | (~rkey_en);
  assign shift_left_1  = shift_left | (r_counter==4'd1) | (r_counter==4'd8);
  assign shift_right_1 = shift_left | (r_counter==4'd7) | (r_counter==4'd14);

  // ---------------- Decipher process ----------------
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
      decipher_process <=  1'b0;
    else if (k16_complete & (~encipher_process)) begin
      if (k16_calculation)
        decipher_process <=  1'b1;
      else
        decipher_process <=  1'b0;
    end
  end

  // ---------------- Key process ----------------
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
      key_process <=  1'b0;
    else if (des_decipher_en | des_encipher_en)
      key_process <=  1'b1;
    else if ((decipher_process | encipher_process) & k16_complete)
      key_process <=  1'b0;
  end

  // ---------------- K16 calculation ----------------
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
      k16_calculation <=  1'b0;
    else
      k16_calculation <=  key_process & (~decipher_process) & (~encipher_process);
  end

  assign desc_ready = (~key_process) & (~encipher_process);

  // ---------------- Encipher enable sync ----------------
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
      encipher_en_sync <=  1'b0;
    else
      encipher_en_sync <=  des_encipher_en;
  end

  // ---------------- Encipher process ----------------
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
      encipher_process <=  1'b0;
    else if (encipher_en_sync)
      encipher_process <=  1'b1;
    else if (~rkey_en)
      encipher_process <=  1'b0;
  end

endmodule
