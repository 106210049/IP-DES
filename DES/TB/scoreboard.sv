class scoreboard;

  mailbox mon_to_sb;
  transaction tr;

  int compare_cnt;
  int pass_cnt;
  int fail_cnt;

  function new(mailbox mon_to_sb);
    this.mon_to_sb   = mon_to_sb;
    this.compare_cnt = 0;
    this.pass_cnt    = 0;
    this.fail_cnt    = 0;
  endfunction


  function bit [63:0] golden_model(
    bit [63:0] data,
    bit [63:0] key,
    bit        enc
  );

    longint unsigned c_data;
    longint unsigned c_key;
    longint unsigned c_result;

    c_data = data;
    c_key  = key;

    if (enc) begin
      c_result = des_encrypt_ref(c_data, c_key);
    end
    else begin
      c_result = des_decrypt_ref(c_data, c_key);
    end

    golden_model = c_result;
    return golden_model;

  endfunction


  task run();

    bit [63:0] exp_result;
    bit        enc_mode;

    forever begin

      mon_to_sb.get(tr);

      compare_cnt++;

      enc_mode = tr.des_encipher_en;

      exp_result = golden_model(
        tr.des_data,
        tr.des_key_in,
        enc_mode
      );

      if (tr.desc_result !== exp_result) begin

        fail_cnt++;

        $display("[SCB][ERROR] %0t: Mismatch!", $time);
        $display("  Compare ID : %0d", compare_cnt);
        $display("  Mode       : %s", enc_mode ? "ENC" : "DEC");
        $display("  Data       : %016h", tr.des_data);
        $display("  Key        : %016h", tr.des_key_in);
        $display("  DUT_out    : %016h", tr.desc_result);
        $display("  REF_out    : %016h", exp_result);

      end
      else begin

        pass_cnt++;

        $display("[SCB][PASS] %0t: %s successful. Result=%016h",
                 $time,
                 enc_mode ? "ENC" : "DEC",
                 tr.desc_result);

      end

    end

  endtask


  function void report();

    $display("========================================");
    $display("[SCB] DES Scoreboard Report");
    $display("  Total compare : %0d", compare_cnt);
    $display("  PASS          : %0d", pass_cnt);
    $display("  FAIL          : %0d", fail_cnt);
    $display("========================================");

  endfunction

endclass