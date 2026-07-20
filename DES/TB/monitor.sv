class monitor;

  virtual des_if vif;

  mailbox mon_to_sb;

  transaction tr;

  function new(
    mailbox mon_to_sb,
    virtual des_if vif
  );
    this.mon_to_sb = mon_to_sb;
    this.vif       = vif;
  endfunction


  task run();

    wait(vif.rst_n === 1'b1);

    $display("[MON] Reset released, starting monitor...");

    forever begin

      @(posedge vif.clk);

      // Monitor tự bắt input từ interface, không nhận từ driver
      if (vif.des_encipher_en === 1'b1 ||
          vif.des_decipher_en === 1'b1) begin

        tr = new();

        tr.des_data        = vif.des_data;
        tr.des_key_in      = vif.des_key_in;
        tr.des_encipher_en = vif.des_encipher_en;
        tr.des_decipher_en = vif.des_decipher_en;

        if (vif.des_encipher_en === 1'b1)
          tr.mode_type = "ENC";
        else if (vif.des_decipher_en === 1'b1)
          tr.mode_type = "DEC";
        else
          tr.mode_type = "UNKNOWN";

        $display("[MON] Captured input | MODE=%s | DATA=%016h | KEY=%016h | ENC=%0b | DEC=%0b",
                 tr.mode_type,
                 tr.des_data,
                 tr.des_key_in,
                 tr.des_encipher_en,
                 tr.des_decipher_en);

        // Đợi DUT bắt đầu xử lý
        wait(vif.desc_ready === 1'b0);

        // Đợi DUT hoàn thành
        wait(vif.desc_ready === 1'b1);

        // Capture output tại lúc done
        @(posedge vif.clk);

        tr.desc_result = vif.desc_result;
        tr.desc_ready  = vif.desc_ready;

        $display("[MON] Captured output | MODE=%s | RESULT=%016h | READY=%0b",
                 tr.mode_type,
                 tr.desc_result,
                 tr.desc_ready);

        mon_to_sb.put(tr);

      end

    end

  endtask

endclass