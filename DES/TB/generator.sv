import testcase_pkg::*;
class generator;

  int num_gen;
  mailbox gen_to_drv;
  transaction tr;
  test_case test;
  function new(mailbox gen_to_drv);
    this.gen_to_drv = gen_to_drv;
  endfunction

  task decryption_test();
    repeat (num_gen) begin
      tr = new();
      assert(tr.randomize() with {

        des_encipher_en == 0;
        des_decipher_en == 1;
        des_data inside {64'h1abff69d5a93e80b};
        des_key_in inside {64'h0133457799bbcdff};
      })
      else begin
        $display("[GEN][ERROR] Randomization failed!");
      end

      tr.mode_type = "ENC";

      gen_to_drv.put(tr);

      $display("[GEN] Time=%0t | MODE=%s | Data=%016h | Key=%016h",
               $time,
               tr.mode_type,
               tr.des_data,
               tr.des_key_in);

    end

    $display("[GEN] Finished generating %0d transactions", num_gen);
  endtask


  task encryption_test();
    repeat (num_gen) begin
      tr = new();
      assert(tr.randomize() with {

        des_encipher_en == 1;
        des_decipher_en == 0;
        des_data inside {64'h00123456789abcde};
        des_key_in inside {64'h0133457799bbcdff};
      })
      else begin
        $display("[GEN][ERROR] Randomization failed!");
      end

      tr.mode_type = "DEC";

      gen_to_drv.put(tr);

      $display("[GEN] Time=%0t | MODE=%s | Data=%016h | Key=%016h",
               $time,
               tr.mode_type,
               tr.des_data,
               tr.des_key_in);

    end

    $display("[GEN] Finished generating %0d transactions", num_gen);
  endtask

  task random_test();
    repeat (num_gen) begin

      tr = new();

      assert(tr.randomize() with {

        des_encipher_en dist {1 := 50, 0 := 50};

        if (des_encipher_en == 1) {
          des_decipher_en == 0;
        }
        else {
          des_decipher_en == 1;
        }

        des_data inside {[64'h0 : 64'hFFFFFFFFFFFFFFFF]};
        des_key_in inside {[64'h0 : 64'hFFFFFFFFFFFFFFFF]};

      })
      else begin
        $display("[GEN][ERROR] Randomization failed!");
      end

      if (tr.des_encipher_en) begin
        tr.mode_type = "ENC";
      end
      else begin
        tr.mode_type = "DEC";
      end

      gen_to_drv.put(tr);

      $display("[GEN] Time=%0t | MODE=%s | Data=%016h | Key=%016h",
               $time,
               tr.mode_type,
               tr.des_data,
               tr.des_key_in);

    end

    $display("[GEN] Finished generating %0d transactions", num_gen);
    
  endtask
  
  task run();
    case(test)
      ENCRYPTION: encryption_test();
      DECRYPTION: decryption_test();
      RANDOM: random_test();
      default: $display("[GEN][ERROR] Unknown test case!");
    endcase
  endtask

endclass