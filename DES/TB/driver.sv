import testcase_pkg::*;
class driver;

  virtual des_if vif;

  mailbox gen_to_drv;

  transaction tr;
  function new(
    mailbox gen_to_drv,
    virtual des_if vif
  );
    this.gen_to_drv = gen_to_drv;
    this.vif        = vif;
  endfunction


  task reset_signals();
    vif.des_encipher_en = 1'b0;
    vif.des_decipher_en = 1'b0;
    vif.des_data        = 64'd0;
    vif.des_key_in      = 64'd0;
  endtask

  task mid_reset();
    #5;
    $display("Assert Reset");
    vif.rst_n = 1'b0;
    #5;
    $display("Dessert Reset");
    vif.rst_n = 1'b0;
  endtask
  task run();

    wait(vif.rst_n === 1'b1);

    $display("[DRV] Reset released, starting driver...");

    reset_signals();

    forever begin

      // Đợi DUT sẵn sàng nhận transaction mới
      wait(vif.desc_ready === 1'b1);

      // Lấy transaction từ generator
      gen_to_drv.get(tr);

      $display("[DRV] Got transaction | MODE=%s | DATA=%016h | KEY=%016h",
               tr.mode_type,
               tr.des_data,
               tr.des_key_in);

      // Drive input vào DUT tại cạnh clock
      @(posedge vif.clk);

      vif.des_data        = tr.des_data;
      vif.des_key_in      = tr.des_key_in;
      vif.des_encipher_en = tr.des_encipher_en;
      vif.des_decipher_en = tr.des_decipher_en;

      $display("[DRV] Driven transaction | MODE=%s | DATA=%016h | KEY=%016h | ENC=%0b | DEC=%0b",
               tr.mode_type,
               tr.des_data,
               tr.des_key_in,
               tr.des_encipher_en,
               tr.des_decipher_en);

      // Enable chỉ giữ 1 chu kỳ clock
      @(posedge vif.clk);

      vif.des_encipher_en = 1'b0;
      vif.des_decipher_en = 1'b0;

      // Có thể clear data/key hoặc giữ nguyên đều được.
      // Nếu muốn clean bus thì mở comment:
      // vif.des_data   = 64'd0;
      // vif.des_key_in = 64'd0;

      // Đợi DUT bắt đầu bận
      wait(vif.desc_ready === 1'b0);
      // Đợi DUT hoàn thành
      wait(vif.desc_ready === 1'b1);

      $display("[DRV] DUT completed operation | MODE=%s", tr.mode_type);

    end

  endtask

endclass